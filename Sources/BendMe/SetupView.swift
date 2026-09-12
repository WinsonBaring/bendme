import SwiftUI
#if canImport(BendCore)
import BendCore
#endif

private let setupAccent = AppTheme.accent

struct SetupView: View {
    @ObservedObject var model: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            if model.setupProgress.step == .install || model.setupProgress.step == .permission {
                HStack(spacing: 12) {
                    ForEach(SetupStep.allCases, id: \.rawValue) { step in
                        HStack(spacing: 6) {
                            Image(systemName: step.rawValue < model.setupProgress.step.rawValue ? "checkmark.circle.fill" : "\(step.rawValue + 1).circle.fill")
                            Text(step.title)
                        }
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(step.rawValue <= model.setupProgress.step.rawValue ? setupAccent : .secondary)
                        .accessibilityLabel("Step \(step.rawValue + 1), \(step.title)\(step == model.setupProgress.step ? ", current step" : "")")
                        if step != .ready { Spacer(minLength: 0) }
                    }
                }
            }
            VStack(alignment: .leading, spacing: 20) {
                switch model.setupProgress.step {
                case .install: installation
                case .permission: permission
                case .tryEffect: tryEffect
                case .ready: ready
                }
            }
            .padding(22)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.card, in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.border))

            if model.setupProgress.step != .ready {
                Button("Use preview") { model.finishSetup(previewOnly: true) }
                    .buttonStyle(.plain).font(.system(size: 12)).foregroundStyle(.secondary)
            }
        }
    }

    private var installation: some View {
        Group {
            heading("Give BendMe a home.", detail: "Install it in Applications so the Dock and permission settings point to the same copy.")
            HStack(spacing: 24) {
                VStack(spacing: 8) { Image(systemName: "macbook").font(.system(size: 42)); Text("BendMe").font(.caption) }
                Image(systemName: "arrow.right").foregroundStyle(setupAccent)
                VStack(spacing: 8) { Image(systemName: "folder.fill").font(.system(size: 42)).foregroundStyle(.blue); Text("Applications").font(.caption) }
                Spacer()
            }.padding(18).accessibilityElement(children: .ignore)
                .accessibilityLabel("Drag BendMe into the Applications folder in Finder")
            instruction(1, "Find this copy", "Click Show BendMe to reveal the app in Finder.")
            Button("Show BendMe in Finder", action: model.revealApplication)
            instruction(2, "Drag it into Applications", "Open Applications, then drag BendMe into that folder. Replace the older copy if Finder asks.")
            Button("Open Applications", action: model.openApplications)
            instruction(3, "Open your installed app", "Once this version is there, the button below becomes available. This temporary copy will close after the installed app opens.")
            Button(model.reopening ? "Opening…" : "Open installed BendMe") {
                if let url = model.installedCopyURL { model.reopenApplication(at: url) }
            }.buttonStyle(.borderedProminent)
                .disabled(model.installedCopyURL == nil || model.reopening)
            if model.installedCopyURL == nil {
                Label("Looking for this version in Applications…", systemImage: "magnifyingglass")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
    }

    private var permission: some View {
        Group {
            heading("Allow Screen Recording", detail: "BendMe needs screen access for the live effect. Nothing is saved or uploaded.")
            Button(action: model.needsScreenSettings ? model.openPrivacySettings : model.startPermissionSetup) {
                Label(model.requestingScreenAccess ? "Waiting for macOS…" : model.needsScreenSettings ? "Open System Settings" : "Allow Screen Recording",
                      systemImage: "rectangle.dashed.badge.record")
            }.buttonStyle(.borderedProminent).controlSize(.large).disabled(model.requestingScreenAccess)
            if model.requestingScreenAccess {
                Text("Approve access in the macOS window.").font(.system(size: 12)).foregroundStyle(.secondary)
            } else if model.needsScreenSettings {
                Text("Enable BendMe in Settings, then reopen it.").font(.system(size: 12)).foregroundStyle(.secondary)
                Button(model.reopening ? "Reopening…" : "Reopen BendMe") { model.reopenApplication() }
                    .disabled(model.reopening)
            }
        }
    }

    private var tryEffect: some View {
        Group {
            if model.angle == nil {
                heading("Lid sensor unavailable", detail: "Open your MacBook display, then try again.")
                Button("Try again", action: model.refreshSensor)
            } else {
                heading("Try BendMe", detail: model.enabled ? "Gently lower your lid below \(Int(model.settings.clearAngle))°." : "Start, then gently lower your lid.")
                Button(model.starting ? "Cancel" : model.enabled ? "Pause BendMe" : "Start BendMe") {
                    let isStarting = !model.enabled && !model.starting
                    model.toggle()
                    if isStarting && (model.starting || model.enabled) {
                        model.showSetup = false
                    }
                }
                    .buttonStyle(.borderedProminent).controlSize(.large)
                    .help("Pause anytime with Control + Option + Command + B")
                if model.starting {
                    ProgressView("Starting…").controlSize(.small)
                } else if model.enabled {
                    Text("Open your lid to clear the effect.")
                        .font(.system(size: 12)).foregroundStyle(.secondary)
                }
                if model.message != nil {
                    Button("Review screen access", action: model.openPrivacySettings)
                }
            }
        }
    }

    private var ready: some View {
        Group {
            Label("All set", systemImage: "checkmark.circle.fill")
                .font(.system(size: 23, weight: .semibold)).foregroundStyle(.green)
            Button("Choose my style") { model.finishSetup() }
                .buttonStyle(.borderedProminent).controlSize(.large)
        }
    }

    private func heading(_ title: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.system(size: 23, weight: .semibold))
            Text(detail).font(.system(size: 13)).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
        }
    }

    private func instruction(_ number: Int, _ title: String, _ detail: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text("\(number)").font(.system(size: 11, weight: .semibold)).frame(width: 22, height: 22)
                .background(setupAccent.opacity(0.15), in: Circle()).foregroundStyle(setupAccent)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.system(size: 13, weight: .medium))
                Text(detail).font(.system(size: 12)).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
