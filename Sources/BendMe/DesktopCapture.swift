import AppKit
import ScreenCaptureKit

@MainActor
final class DesktopCapture: NSObject, SCStreamOutput, SCStreamDelegate {
    private var stream: SCStream?
    var onFrame: ((CVPixelBuffer) -> Void)?
    var onFailure: ((String) -> Void)?
    private(set) var frameCount = 0

    func start(displayID: CGDirectDisplayID, excluding windows: [CGWindowID], frameRate: Int) async throws {
        let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: false)
        guard let display = content.displays.first(where: { $0.displayID == displayID }) else {
            throw BendError.unavailable("The built-in display is unavailable. Open the MacBook lid and try again.")
        }
        // Explicit exclusion is essential: otherwise each frame captures its own effect.
        let excluded = content.windows.filter { windows.contains($0.windowID) }
        guard excluded.count == windows.count else {
            throw BendError.unavailable("The effect window is not ready for capture. Please enable BendMe again.")
        }
        let filter = SCContentFilter(display: display, excludingWindows: excluded)
        let config = SCStreamConfiguration()
        let ratio = min(1.0, 2304.0 / Double(display.width))
        config.width = max(2, Int(Double(display.width) * ratio) / 2 * 2)
        config.height = max(2, Int(Double(display.height) * ratio) / 2 * 2)
        config.minimumFrameInterval = CMTime(value: 1, timescale: Int32(frameRate))
        config.queueDepth = 3
        config.pixelFormat = kCVPixelFormatType_32BGRA
        config.showsCursor = false
        config.capturesAudio = false
        config.colorSpaceName = CGColorSpace.sRGB
        let stream = SCStream(filter: filter, configuration: config, delegate: self)
        // Serial main queue keeps capture, render and window lifetime changes ordered.
        try stream.addStreamOutput(self, type: .screen, sampleHandlerQueue: .main)
        self.stream = stream
        frameCount = 0
        do { try await stream.startCapture() }
        catch { self.stream = nil; throw error }
    }

    func stop() async {
        let previous = stream
        stream = nil
        try? await previous?.stopCapture()
    }

    nonisolated func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {
        MainActor.assumeIsolated {
        guard stream === self.stream, type == .screen, sampleBuffer.isValid,
              let attachments = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, createIfNecessary: false) as? [[SCStreamFrameInfo: Any]],
              let raw = attachments.first?[.status] as? Int,
              SCFrameStatus(rawValue: raw) == .complete,
              let frame = sampleBuffer.imageBuffer else { return }
        frameCount += 1
        onFrame?(frame)
        }
    }

    nonisolated func stream(_ stream: SCStream, didStopWithError error: Error) {
        let streamID = ObjectIdentifier(stream)
        DispatchQueue.main.async { [weak self] in
            guard let self, self.stream.map(ObjectIdentifier.init) == streamID else { return }
            self.stream = nil
            self.onFailure?(error.localizedDescription)
        }
    }
}
