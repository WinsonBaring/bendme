import AppKit
import MetalKit
import MetalPerformanceShaders
#if canImport(BendCore)
import BendCore
#endif

struct ShaderParameters {
    var progress: Float
    var perspective: Float
    var blur: Float
    var shadow: Float
    var style: Float

    init(progress: Double, settings: FoldSettings) {
        let settings = settings.validated()
        self.progress = Float(clamp(progress, 0...1, fallback: 0))
        perspective = Float(settings.perspective)
        blur = Float(settings.blur)
        shadow = Float(settings.shadow)
        style = settings.style == .silk ? 0 : settings.style == .shade ? 1 : 2
    }
}

enum BendError: LocalizedError {
    case unavailable(String)
    var errorDescription: String? {
        switch self { case .unavailable(let message): return message }
    }
}

final class MetalRenderer: NSObject, MTKViewDelegate {
    let device: MTLDevice
    let queue: MTLCommandQueue
    let pipeline: MTLRenderPipelineState
    private var cache: CVMetalTextureCache?
    private var frame: CVPixelBuffer?
    private var imageTexture: MTLTexture?
    private let inFlight = DispatchSemaphore(value: 3)
    private var blurTextures: [MTLTexture] = []
    private var blurKernels: [MPSImageGaussianBlur] = []
    var parameters = ShaderParameters(progress: 0, settings: FoldSettings())
    var onFailure: ((String) -> Void)?
    var onPresented: (() -> Void)?

    init(device: MTLDevice) throws {
        self.device = device
        guard let queue = device.makeCommandQueue() else {
            throw BendError.unavailable("The graphics command queue could not be created.")
        }
        self.queue = queue
        let packaged = Bundle.main.resourceURL?.appendingPathComponent("BendMe_BendMe.bundle")
        let resources: Bundle
        if Bundle.main.bundleURL.pathExtension == "app" {
            guard let packaged, let bundle = Bundle(url: packaged) else {
                throw BendError.unavailable("The app resource bundle is missing. Rebuild BendMe.")
            }
            resources = bundle
        } else {
            #if SWIFT_PACKAGE
            resources = Bundle.module
            #else
            resources = Bundle.main
            #endif
        }
        guard let url = resources.url(forResource: "Fold", withExtension: "metal", subdirectory: "Resources") else {
            throw BendError.unavailable("The Fold shader is missing. Rebuild the app bundle.")
        }
        let source = try String(contentsOf: url)
        let library = try device.makeLibrary(source: source, options: nil)
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = library.makeFunction(name: "foldVertex")
        descriptor.fragmentFunction = library.makeFunction(name: "foldFragment")
        descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipeline = try device.makeRenderPipelineState(descriptor: descriptor)
        super.init()
        guard CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, device, nil, &cache) == kCVReturnSuccess else {
            throw BendError.unavailable("The screen texture cache could not be created.")
        }
    }

    func setFrame(_ frame: CVPixelBuffer) { self.frame = frame }
    func clearFrame() { frame = nil; if let cache { CVMetalTextureCacheFlush(cache, 0) } }

    func setImage(_ image: CGImage) throws {
        imageTexture = try MTKTextureLoader(device: device).newTexture(cgImage: image, options: [.SRGB: false])
    }

    private func texture() -> (MTLTexture, CVMetalTexture?)? {
        if let frame, let cache {
            var wrapper: CVMetalTexture?
            let result = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, cache, frame, nil,
                .bgra8Unorm, CVPixelBufferGetWidth(frame), CVPixelBufferGetHeight(frame), 0, &wrapper)
            if result == kCVReturnSuccess, let wrapper, let texture = CVMetalTextureGetTexture(wrapper) {
                return (texture, wrapper)
            }
        }
        return imageTexture.map { ($0, nil) }
    }

    func encode(into target: MTLTexture, source: MTLTexture, command: MTLCommandBuffer) throws {
        let blurActive = parameters.progress * parameters.blur > 0.0001
        if blurActive {
            if blurTextures.count != 3 || blurTextures.first?.width != source.width || blurTextures.first?.height != source.height {
                blurTextures.removeAll()
                blurKernels.removeAll()
                for sigma: Float in [3, 10, 24] {
                    let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm,
                        width: source.width, height: source.height, mipmapped: false)
                    descriptor.usage = [.shaderRead, .shaderWrite]
                    descriptor.storageMode = .private
                    guard let texture = device.makeTexture(descriptor: descriptor) else {
                        throw BendError.unavailable("Could not allocate the blur textures.")
                    }
                    blurTextures.append(texture)
                    let kernel = MPSImageGaussianBlur(device: device, sigma: sigma * Float(source.width) / 1200)
                    kernel.edgeMode = .clamp
                    blurKernels.append(kernel)
                }
            }
            for (kernel, texture) in zip(blurKernels, blurTextures) {
                kernel.encode(commandBuffer: command, sourceTexture: source, destinationTexture: texture)
            }
        }
        let pass = MTLRenderPassDescriptor()
        pass.colorAttachments[0].texture = target
        pass.colorAttachments[0].loadAction = .clear
        pass.colorAttachments[0].storeAction = .store
        pass.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 1)
        guard let encoder = command.makeRenderCommandEncoder(descriptor: pass) else {
            throw BendError.unavailable("The graphics encoder could not start.")
        }
        encoder.setRenderPipelineState(pipeline)
        encoder.setFragmentTexture(source, index: 0)
        for index in 0..<3 {
            encoder.setFragmentTexture(blurActive ? blurTextures[index] : source, index: index + 1)
        }
        var values = parameters
        encoder.setFragmentBytes(&values, length: MemoryLayout<ShaderParameters>.stride, index: 0)
        encoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        encoder.endEncoding()
    }

    func draw(in view: MTKView) {
        guard inFlight.wait(timeout: .now()) == .success else { return }
        guard let (source, wrapper) = texture(), let drawable = view.currentDrawable,
              let command = queue.makeCommandBuffer() else { inFlight.signal(); return }
        do {
            try encode(into: drawable.texture, source: source, command: command)
            command.present(drawable)
            let pixelBuffer = frame
            command.addCompletedHandler { [weak self, wrapper, pixelBuffer, inFlight] buffer in
                // IOSurface and its texture must survive until the GPU finishes.
                withExtendedLifetime((wrapper, pixelBuffer)) {}
                inFlight.signal()
                DispatchQueue.main.async {
                    if let error = buffer.error { self?.onFailure?(error.localizedDescription) }
                    else { self?.onPresented?() }
                }
            }
            command.commit()
        } catch { inFlight.signal(); onFailure?(error.localizedDescription) }
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

    func renderImage(_ image: CGImage, progress: Double, settings: FoldSettings) throws -> CGImage {
        parameters = ShaderParameters(progress: progress, settings: settings)
        let source = try MTKTextureLoader(device: device).newTexture(cgImage: image, options: [.SRGB: false])
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm,
            width: image.width, height: image.height, mipmapped: false)
        descriptor.usage = [.renderTarget, .shaderRead]
        descriptor.storageMode = .shared
        guard let target = device.makeTexture(descriptor: descriptor), let command = queue.makeCommandBuffer() else {
            throw BendError.unavailable("Could not allocate an offscreen render target.")
        }
        try encode(into: target, source: source, command: command)
        command.commit()
        command.waitUntilCompleted()
        if let error = command.error { throw error }
        var bytes = [UInt8](repeating: 0, count: image.width * image.height * 4)
        target.getBytes(&bytes, bytesPerRow: image.width * 4,
                        from: MTLRegionMake2D(0, 0, image.width, image.height), mipmapLevel: 0)
        let data = Data(bytes) as CFData
        guard let provider = CGDataProvider(data: data), let result = CGImage(width: image.width, height: image.height,
            bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: image.width * 4,
            space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGBitmapInfo(rawValue:
                CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue),
            provider: provider, decode: nil, shouldInterpolate: true, intent: .defaultIntent) else {
            throw BendError.unavailable("Could not create the rendered image.")
        }
        return result
    }
}
