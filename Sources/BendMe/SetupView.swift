import SwiftUI
#if canImport(BendCore)
import BendCore
#endif

private let setupAccent = Color(red: 0.92, green: 0.61, blue: 0.36)

struct SetupView: View {
    @ObservedObject var model: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
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
            .background(.white.opacity(0.035), in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.07)))

            if model.setupProgress.step != .ready {
                Button("Explore the preview instead") { model.finishSetup(previewOnly: true) }
                    .buttonStyle(.plain).font(.system(size: 12)).foregroundStyle(.secondary)
                Text("You can return to Setup any time. The preview does not need screen access.")
                    .font(.system(size: 11)).foregroundStyle(.tertiary)
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
            heading("Let BendMe see your desktop.", detail: "Screen Recording access lets BendMe draw the live effect. Frames stay in memory on your Mac; they are never saved or uploaded.")
            Button(action: model.startPermissionSetup) {
                Label("Allow screen access", systemImage: "rectangle.dashed.badge.record")
            }.buttonStyle(.borderedProminent).controlSize(.large)
            Text("This opens Apple's permission prompt or the correct System Settings page. A small guide stays beside it.")
                .font(.system(size: 12)).foregroundStyle(.secondary)
            PermissionPointer()
            HStack {
                Button("Open Screen Recording settings", action: model.openPrivacySettings)
                Button("Check access", action: model.refreshSetupStatus)
            }
            Divider()
            Label("Only Screen Recording is needed. Accessibility access is not required.", systemImage: "checkmark.shield")
                .font(.system(size: 12)).foregroundStyle(.secondary)
            Text("Already switched it on? Choose Quit & Reopen if macOS offers it, or use the button below. Setup will resume when BendMe opens.")
                .font(.system(size: 12)).foregroundStyle(.secondary)
            Button(model.reopening ? "Reopening…" : "Reopen BendMe") { model.reopenApplication() }
                .disabled(model.reopening)
        }
    }

    private var tryEffect: some View {
        Group {
            heading("Let's try your first bend.", detail: "Screen access is confirmed. Now we'll check the real desktop effect together.")
            Label("Screen Recording allowed", systemImage: "checkmark.circle.fill").foregroundStyle(.green)
            if model.angle == nil {
                Label("No compatible lid sensor detected", systemImage: "macbook.trianglebadge.exclamationmark")
                Text(model.sensorStatus).font(.system(size: 12)).foregroundStyle(.secondary)
                Text("Open the built-in MacBook display and check again. If this Mac has no compatible sensor, you can still explore the manual preview.")
                    .font(.system(size: 12)).foregroundStyle(.secondary)
                Button("Check lid sensor", action: model.refreshSensor)
            } else {
                instruction(1, "Start the live effect", "Click Start BendMe. We'll confirm that desktop frames are arriving before marking this step ready.")
                Button(model.starting ? "Cancel starting" : model.enabled ? "Pause BendMe" : "Start BendMe", action: model.toggle)
                    .buttonStyle(.borderedProminent).controlSize(.large)
                if let message = model.message {
                    Label(message, systemImage: "exclamationmark.triangle").font(.system(size: 12)).foregroundStyle(.orange)
                    Button("Review screen access", action: model.openPrivacySettings)
                }
                Label(model.setupHasFrames ? "Live desktop frames received" : model.starting || model.enabled ? "Waiting for the first desktop frame…" : "The effect is paused", systemImage: model.setupHasFrames ? "checkmark.circle.fill" : "circle.dashed")
                    .font(.system(size: 12)).foregroundStyle(model.setupHasFrames ? .green : .secondary)
                instruction(2, "Gently lower your lid", "The effect appears below \(Int(model.settings.clearAngle))°. Keep the lid partly open; closing it normally can put your Mac to sleep.")
                HStack {
                    Image(systemName: "angle").foregroundStyle(setupAccent)
                    Text("Your lid: \(Int(model.angle ?? 0))°").font(.system(size: 24, weight: .medium, design: .rounded)).monospacedDigit()
                    Spacer()
                    Text("Effect below \(Int(model.settings.clearAngle))°").font(.caption).foregroundStyle(.secondary)
                }.padding(16).background(.white.opacity(0.035), in: RoundedRectangle(cornerRadius: 12))
                Text(model.enabled && (model.angle ?? 0) >= model.settings.clearAngle ? "Your lid is above the clear angle, so a normal-looking desktop is expected right now." : "We'll mark this step complete when BendMe presents the live effect.")
                    .font(.system(size: 12)).foregroundStyle(.secondary)
                instruction(3, "Open your lid to clear it", "You can pause any time with Control + Option + Command + B, or Pause in the menu bar.")
            }
            if !model.setupHasFrames && model.enabled {
                Button("Review screen access", action: model.openPrivacySettings)
            }
        }
    }

    private var ready: some View {
        Group {
            Image(systemName: "checkmark.circle.fill").font(.system(size: 44)).foregroundStyle(.green)
            heading("You made your first bend.", detail: "BendMe received your desktop frames and presented the effect. You're ready to make it your own.")
            Label("Installed in Applications", systemImage: "checkmark")
            Label("Screen access confirmed", systemImage: "checkmark")
            Label("Live effect displayed", systemImage: "checkmark")
            Text(model.enabled ? "The effect is enabled. Opening your lid above \(Int(model.settings.clearAngle))° clears it." : "The effect is paused. Enable it from Appearance when you're ready.")
                .font(.system(size: 12)).foregroundStyle(.secondary)
            Button("Choose my style") { model.finishSetup() }.buttonStyle(.borderedProminent).controlSize(.large)
            Text("BendMe starts paused each time you launch it. Click its Dock icon for settings; use the menu bar for quick controls.")
                .font(.system(size: 12)).foregroundStyle(.secondary)
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

private struct PermissionPointer: View {
    var compact = false
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("LOOK FOR THIS ROW IN SYSTEM SETTINGS")
                .font(.system(size: 9, weight: .semibold)).tracking(1).foregroundStyle(.secondary)
            HStack {
                Image(systemName: "macbook").foregroundStyle(setupAccent)
                Text("BendMe").font(.system(size: 13, weight: .medium))
                Spacer()
                Image(systemName: "arrow.right").foregroundStyle(setupAccent)
                Capsule().fill(.green).frame(width: 32, height: 19)
                    .overlay(alignment: .trailing) { Circle().fill(.white).frame(width: 15, height: 15).padding(2) }
            }.padding(12).background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 9))
                .accessibilityElement(children: .ignore).accessibilityLabel("Example: find the BendMe row in System Settings and turn its switch on")
            Text(compact ? "In System Settings, turn on BendMe's switch. The row above is an example." : "Turn on the switch next to BendMe in System Settings. The row above is an example, not a permission control.")
                .font(.system(size: 12)).foregroundStyle(.secondary)
            Text(compact ? "Missing from the list? Click +, select BendMe in Applications, and click Open." : "The page may be called Screen Recording or Screen & System Audio Recording. If BendMe is missing, click +, select BendMe in Applications, and click Open.")
                .font(.system(size: 12)).foregroundStyle(.secondary)
        }
    }
}

struct PermissionCompanionView: View {
    @ObservedObject var model: AppModel
    var returnToSetup: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Label("BendMe setup", systemImage: "macbook").font(.headline).foregroundStyle(setupAccent)
                if model.permissionGranted {
                    Label("Access confirmed", systemImage: "checkmark.circle.fill").foregroundStyle(.green)
                    Text("Return to BendMe to try the live effect.").font(.system(size: 13))
                    Button("Return to BendMe", action: returnToSetup).buttonStyle(.borderedProminent)
                } else {
                    Text("Switch on BendMe.").font(.system(size: 21, weight: .semibold))
                    PermissionPointer(compact: true)
                    Button("Open the right settings page", action: model.openPrivacySettings)
                    Text("If macOS asks, choose Quit & Reopen. Otherwise reopen BendMe below after switching access on.")
                        .font(.system(size: 12)).foregroundStyle(.secondary)
                    Button(model.reopening ? "Reopening…" : "Reopen BendMe") { model.reopenApplication() }
                        .buttonStyle(.borderedProminent).disabled(model.reopening)
                    Button("Check access again", action: model.refreshSetupStatus)
                    Text("Waiting for macOS to confirm access…").font(.caption).foregroundStyle(.secondary)
                    Button("Back to setup", action: returnToSetup)
                }
            }.padding(20).frame(maxWidth: .infinity, alignment: .leading)
        }.frame(width: 330, height: 520)
            .background(Color(red: 0.105, green: 0.112, blue: 0.13))
            .preferredColorScheme(.dark).tint(setupAccent)
    }
}
