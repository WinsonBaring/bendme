import SwiftUI
import MetalKit
#if canImport(BendCore)
import BendCore
#endif

private let accent = AppTheme.accent

struct SettingsView: View {
    @ObservedObject var model: AppModel
    @State private var page = "Appearance"
    @FocusState private var focusedPage: String?

    var body: some View {
        HStack(spacing: 0) {
            sidebar
            Divider()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(page).font(.system(size: 25, weight: .semibold))
                            if page != "Setup" {
                                Text(page == "Appearance" ? "A new angle on your everyday." : page == "General" ? "Quietly at home on your Mac." : "Made to change your perspective.")
                                    .foregroundStyle(.secondary).font(.system(size: 13))
                            }
                        }
                        Spacer()
                        HStack(spacing: 6) {
                            Circle().fill(model.enabled ? Color.green : accent).frame(width: 6, height: 6)
                            Text(model.enabled ? "LIVE" : "PREVIEW").font(.system(size: 10, weight: .semibold, design: .monospaced))
                        }.padding(.horizontal, 11).padding(.vertical, 7).background(AppTheme.subtle, in: Capsule())
                    }
                    if page == "Setup" { SetupView(model: model) }
                    else if page == "Appearance" { appearance }
                    else if page == "General" { general }
                    else { about }
                    if let message = model.message {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "info.circle").foregroundStyle(accent)
                            Text(message).font(.system(size: 12)).textSelection(.enabled)
                            Spacer(minLength: 0)
                            Button { model.message = nil } label: { Image(systemName: "xmark") }.buttonStyle(.plain)
                                .accessibilityLabel("Dismiss message")
                        }.padding(14).background(accent.opacity(0.09), in: RoundedRectangle(cornerRadius: 12))
                    }
                }.padding(24)
            }.background(AppTheme.background)
        }
        .frame(minWidth: 860, idealWidth: 900, minHeight: 730, idealHeight: 780)
        .preferredColorScheme(.light)
        .tint(accent)
        .defaultFocus($focusedPage, page)
        .onAppear {
            if model.showSetup { page = "Setup" }
            focusedPage = page
        }
        .onChange(of: model.showSetup) { _, visible in
            if visible { page = "Setup" }
            else if page == "Setup" { page = "Appearance" }
        }
        .onChange(of: page) { _, value in
            model.showSetup = value == "Setup"
            focusedPage = value
        }
    }

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                if let logo = bendMeLogo {
                    Image(nsImage: logo).resizable().renderingMode(.original)
                        .scaledToFit().frame(width: 32, height: 32).accessibilityHidden(true)
                }
                Text("bendme").font(.system(size: 23, weight: .semibold, design: .rounded))
            }.padding(.top, 32).padding(.bottom, 7)
            Text("A LITTLE LESS FLAT").font(.system(size: 8, weight: .medium, design: .monospaced))
                .tracking(2.4).foregroundStyle(.secondary).padding(.bottom, 42)
            Text("YOUR MAC").font(.system(size: 9, weight: .semibold)).tracking(1.4).foregroundStyle(.tertiary)
                .padding(.leading, 10).padding(.bottom, 12)
            ForEach([("Setup", "checklist"), ("Appearance", "circle.lefthalf.filled"), ("General", "slider.horizontal.3"), ("About", "info.circle")], id: \.0) { item in
                Button {
                    if item.0 == "Setup" { model.beginSetup() }
                    page = item.0
                } label: {
                    HStack(spacing: 11) {
                        Image(systemName: item.1).font(.system(size: 14)).frame(width: 20)
                            .foregroundStyle(page == item.0 ? accent : .secondary)
                        Text(item.0).font(.system(size: 13, weight: page == item.0 ? .medium : .regular))
                        Spacer()
                    }.frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 10).padding(.vertical, 12)
                        .contentShape(RoundedRectangle(cornerRadius: 8))
                        .background(page == item.0 ? AppTheme.selection : .clear, in: RoundedRectangle(cornerRadius: 8))
                        .overlay(RoundedRectangle(cornerRadius: 8)
                            .stroke(focusedPage == item.0 ? Color.primary.opacity(0.25) : .clear, lineWidth: 1))
                }.buttonStyle(.plain)
                    .focused($focusedPage, equals: item.0)
                    .focusEffectDisabled()
                    .accessibilityAddTraits(page == item.0 ? .isSelected : [])
                    .padding(.bottom, 3)
            }
            Spacer()
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 6) {
                    Circle().fill(model.angle == nil ? .orange : .green).frame(width: 5, height: 5)
                    Text(model.angle == nil ? "Preview available" : "MacBook connected").font(.system(size: 11))
                }
                Text(model.angle.map { "Lid angle  \(Int($0))°" } ?? "No lid sensor detected")
                    .font(.system(size: 10, design: .monospaced)).foregroundStyle(.secondary)
                Divider().padding(.vertical, 3)
                Text("On your Mac. Only your Mac.").font(.system(size: 10)).foregroundStyle(.tertiary)
                makerCredit
            }.padding(.bottom, 22)
        }.padding(.horizontal, 18).frame(width: 188)
            .background(AppTheme.sidebar)
    }

    private var appearance: some View {
        VStack(spacing: 14) {
            VStack(spacing: 0) {
                HStack {
                    Text("THE DESKTOP, REIMAGINED").font(.system(size: 9, weight: .medium, design: .monospaced)).tracking(1.6).foregroundStyle(.secondary)
                    Spacer()
                    Text("\(Int(model.effectivePreviewAngle))°").font(.system(size: 12, design: .monospaced)).foregroundStyle(accent)
                }.padding(.horizontal, 20).padding(.top, 17)
                LaptopPreview(progress: model.previewProgress, settings: model.settings)
                    .frame(width: 360)
                    .padding(.top, 15).padding(.bottom, 15)
                HStack(spacing: 14) {
                    Image(systemName: "angle").foregroundStyle(.secondary)
                    Slider(value: $model.previewAngle, in: 5...135).disabled(model.followLid)
                        .accessibilityLabel("Preview lid angle")
                    Toggle("Follow lid", isOn: $model.followLid).toggleStyle(.switch).controlSize(.mini)
                        .disabled(model.angle == nil).font(.system(size: 11))
                }.padding(.horizontal, 22).padding(.bottom, 17)
            }.background(LinearGradient(colors: [AppTheme.card, AppTheme.sidebar], startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.border))

            VStack(alignment: .leading, spacing: 11) {
                sectionLabel("MAKE IT FEEL LIKE YOU", trailing: "Three ways to bend")
                HStack(spacing: 11) {
                    ForEach(FoldStyle.allCases) { style in
                        Button { model.settings.style = style } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                MiniStylePreview(style: style).frame(height: 48).clipShape(RoundedRectangle(cornerRadius: 6))
                                HStack {
                                    Text(style.title).font(.system(size: 12, weight: .medium))
                                    Spacer()
                                    if model.settings.style == style {
                                        Image(systemName: "checkmark.circle.fill").foregroundStyle(accent).font(.system(size: 11))
                                    }
                                }
                                Text(style.subtitle).font(.system(size: 9)).foregroundStyle(.secondary)
                            }.padding(10).background(model.settings.style == style ? accent.opacity(0.06) : AppTheme.card, in: RoundedRectangle(cornerRadius: 11))
                                .overlay(RoundedRectangle(cornerRadius: 11).stroke(model.settings.style == style ? accent.opacity(0.8) : AppTheme.border, lineWidth: 1))
                        }.buttonStyle(.plain).accessibilityLabel("\(style.title): \(style.subtitle)")
                    }
                }
            }
            VStack(spacing: 0) {
                settingSlider("Perspective", icon: "view.3d", value: $model.settings.perspective)
                Divider().padding(.leading, 43)
                settingSlider("Variable blur", icon: "drop.halffull", value: $model.settings.blur)
                Divider().padding(.leading, 43)
                settingSlider("Shadow", icon: "circle.bottomhalf.filled", value: $model.settings.shadow)
            }.background(AppTheme.card, in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.border))
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(model.enabled ? "Your desktop is ready to bend." : "Ready when you are.").font(.system(size: 12, weight: .medium))
                    Text(model.enabled ? "Close the lid gently to see it in action." : "Enable to apply the effect to your actual desktop.").font(.system(size: 10)).foregroundStyle(.secondary)
                }
                Spacer()
                Button(action: model.toggle) {
                    HStack(spacing: 7) {
                        if model.starting { ProgressView().controlSize(.mini) }
                        Text(model.starting ? "Cancel" : model.enabled ? "Pause BendMe" : "Enable BendMe")
                        if !model.starting { Image(systemName: model.enabled ? "pause.fill" : "arrow.up.right") }
                    }.font(.system(size: 11, weight: .semibold)).padding(.horizontal, 15).padding(.vertical, 10)
                        .foregroundStyle(.white).background(accent, in: Capsule())
                }.buttonStyle(.plain)
            }
        }
    }

    private var general: some View {
        VStack(alignment: .leading, spacing: 22) {
            GroupBox {
                VStack(alignment: .leading, spacing: 14) {
                    Label("Lid sensor", systemImage: "sensor.fill").font(.headline)
                    Text(model.sensorStatus).foregroundStyle(.secondary)
                    HStack {
                        Text(model.angle.map { "Current angle: \(Int($0))°" } ?? "Manual preview works on any Metal-capable Mac.")
                        Spacer()
                        Button("Check again", action: model.refreshSensor)
                    }.font(.system(size: 12))
                }.padding(12)
            }
            GroupBox {
                VStack(alignment: .leading, spacing: 14) {
                    Label("Screen Recording", systemImage: "rectangle.dashed.badge.record").font(.headline)
                    Text(model.permissionGranted ? "Permission granted. Frames stay in memory on this Mac." : "BendMe needs permission to render your live desktop. Nothing is recorded or uploaded.")
                        .foregroundStyle(.secondary)
                    HStack {
                        Button("Guide me through setup", action: model.beginSetup)
                        Button("Open System Settings", action: model.openPrivacySettings)
                    }
                }.padding(12)
            }
            GroupBox {
                VStack(alignment: .leading, spacing: 18) {
                    HStack { Text("Clear effect at"); Spacer(); Text("\(Int(model.settings.clearAngle))°").monospacedDigit().foregroundStyle(accent) }
                    Slider(value: $model.settings.clearAngle, in: 60...135, step: 1).accessibilityLabel("Clear effect angle")
                    Text("The desktop returns to normal above this lid angle.").font(.caption).foregroundStyle(.secondary)
                    Divider()
                    Toggle("Play a soft sound when the desktop clears", isOn: $model.settings.sound)
                    Picker("Capture frame rate", selection: $model.settings.frameRate) {
                        Text("30 fps · less energy").tag(30)
                        Text("60 fps · smoother").tag(60)
                    }
                    Text("Frame rate changes apply the next time you enable BendMe.").font(.caption).foregroundStyle(.secondary)
                }.padding(12)
            }
            Label("Pause from anywhere with ⌃⌥⌘B. Escape pauses while BendMe is focused.", systemImage: "keyboard")
                .font(.system(size: 12)).foregroundStyle(.secondary)
            Button("Reset appearance") { model.settings = FoldSettings() }
        }.font(.system(size: 13))
    }

    private var about: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(spacing: 14) {
                makerCredit
                Spacer()
                Link("GitHub", destination: URL(string: "https://github.com/WinsonBaring/bendme")!)
                Link("Website", destination: URL(string: "https://winsonbaring.github.io/bendme/")!)
                Link("Report an issue", destination: URL(string: "https://github.com/WinsonBaring/bendme/issues")!)
            }.font(.system(size: 11))
            LaptopPreview(progress: 0.25, settings: model.settings).padding(35)
            Text("A familiar desktop.\nAn unexpected dimension.").font(.system(size: 28, weight: .medium)).lineSpacing(4)
            Text("BendMe uses your MacBook’s hinge sensor to tilt, soften, and shade your desktop as you close the lid. An independent implementation inspired by the Bendy effect.")
                .foregroundStyle(.secondary).lineSpacing(5)
            Divider()
            Label("Local by design. No accounts, analytics, or uploads.", systemImage: "lock.shield")
            Label("Built for macOS 14+ and compatible MacBook lid sensors.", systemImage: "macbook")
            Text("BendMe \(model.appVersion)  ·  \(model.bends) bends this session").font(.system(size: 11, design: .monospaced)).foregroundStyle(.tertiary)
        }.font(.system(size: 13))
    }

    private var makerCredit: some View {
        Link(destination: URL(string: "https://github.com/WinsonBaring")!) {
            HStack(spacing: 5) {
                Text("Made by").font(.system(size: 10))
                if let mark = developerProfileMark {
                    Image(nsImage: mark).renderingMode(.template).resizable().frame(width: 13, height: 13)
                } else {
                    Image(systemName: "person.crop.circle").font(.system(size: 13))
                }
            }.padding(.vertical, 3).contentShape(Rectangle())
        }.foregroundStyle(.secondary)
            .accessibilityLabel("Developer profile on GitHub")
            .help("Developer profile")
    }

    private func sectionLabel(_ title: String, trailing: String) -> some View {
        HStack {
            Text(title).font(.system(size: 9, weight: .medium)).tracking(1.2)
            Spacer()
            Text(trailing).font(.system(size: 10))
        }.foregroundStyle(.secondary)
    }

    private func settingSlider(_ title: String, icon: String, value: Binding<Double>) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon).foregroundStyle(.secondary).frame(width: 17)
            Text(title).font(.system(size: 12)).frame(width: 108, alignment: .leading)
            Slider(value: value, in: 0...1).accessibilityLabel(title)
            Text("\(Int(value.wrappedValue * 100))%").font(.system(size: 11, design: .monospaced))
                .foregroundStyle(.secondary).frame(width: 38, alignment: .trailing)
        }.padding(.horizontal, 16).padding(.vertical, 11)
    }
}

struct LaptopPreview: View {
    var progress: Double
    var settings: FoldSettings
    var body: some View {
        VStack(spacing: 0) {
            MetalPreview(progress: progress, settings: settings)
                .aspectRatio(1.6, contentMode: .fit)
                .clipShape(UnevenRoundedRectangle(topLeadingRadius: 9, topTrailingRadius: 9))
                .padding(8).padding(.bottom, 2)
                .background(Color.black, in: UnevenRoundedRectangle(topLeadingRadius: 16, topTrailingRadius: 16))
                .overlay(alignment: .top) {
                    UnevenRoundedRectangle(bottomLeadingRadius: 4, bottomTrailingRadius: 4)
                        .fill(.black).frame(width: 68, height: 15)
                }.padding(.horizontal, 15)
            UnevenRoundedRectangle(bottomLeadingRadius: 6, bottomTrailingRadius: 6)
                .fill(LinearGradient(colors: [Color(white: 0.43), Color(white: 0.23)], startPoint: .top, endPoint: .bottom))
                .frame(height: 10)
                .overlay(alignment: .top) { Capsule().fill(.black.opacity(0.5)).frame(width: 80, height: 3) }
        }.shadow(color: .black.opacity(0.12), radius: 16, y: 12)
    }
}

struct MetalPreview: NSViewRepresentable {
    var progress: Double
    var settings: FoldSettings
    func makeCoordinator() -> Coordinator { Coordinator() }
    func makeNSView(context: Context) -> NSView {
        guard let device = MTLCreateSystemDefaultDevice() else { return fallback("Metal is unavailable") }
        do {
            let renderer = try MetalRenderer(device: device)
            guard let artwork = PreviewArtwork.image() else { return fallback("Preview artwork could not load") }
            try renderer.setImage(artwork)
            context.coordinator.renderer = renderer
            let view = MTKView(frame: .zero, device: device)
            view.colorPixelFormat = .bgra8Unorm
            view.delegate = renderer
            view.isPaused = true
            view.enableSetNeedsDisplay = true
            renderer.parameters = ShaderParameters(progress: progress, settings: settings)
            return view
        } catch { return fallback(error.localizedDescription) }
    }
    func updateNSView(_ nsView: NSView, context: Context) {
        context.coordinator.renderer?.parameters = ShaderParameters(progress: progress, settings: settings)
        nsView.needsDisplay = true
    }
    static func dismantleNSView(_ nsView: NSView, coordinator: Coordinator) {
        (nsView as? MTKView)?.delegate = nil
        coordinator.renderer = nil
    }
    private func fallback(_ text: String) -> NSView {
        let label = NSTextField(wrappingLabelWithString: text)
        label.textColor = .secondaryLabelColor
        return label
    }
    final class Coordinator { var renderer: MetalRenderer? }
}

struct MiniStylePreview: View {
    let style: FoldStyle
    var body: some View {
        var settings = FoldSettings()
        settings.style = style
        settings.shadow = style == .shade ? 0.9 : 0.3
        settings.blur = style == .frost ? 1 : 0.4
        return MetalPreview(progress: 0.45, settings: settings)
    }
}

private let developerProfileMark = bundledBrandImage("GitHub-Mark")
private let bendMeLogo = bundledBrandImage("BendMeLogo")

private func bundledBrandImage(_ name: String) -> NSImage? {
    var bundles = [Bundle.main]
    if let url = Bundle.main.resourceURL?.appendingPathComponent("BendMe_BendMe.bundle"),
       let bundle = Bundle(url: url) { bundles.insert(bundle, at: 0) }
    #if SWIFT_PACKAGE
    bundles.append(Bundle.module)
    #endif
    for bundle in bundles {
        if let url = bundle.url(forResource: name, withExtension: "png", subdirectory: "Resources"),
           let image = NSImage(contentsOf: url) { return image }
    }
    return nil
}
