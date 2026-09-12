# Setup

## Requirements

- macOS 14 Sonoma or later, Metal-capable Mac, Xcode with Swift 5.10 or later.
- Live lid tracking needs a compatible MacBook sensor (HID sensor page `0x20`, usage `0x8A`). The settings preview works without one.
- Screen Recording permission for the **live desktop** only. No Accessibility permission is needed.

## Install the public preview

Download the DMG from [GitHub Releases](https://github.com/WinsonBaring/bendme/releases/tag/v0.1.3), open it, and open BendMe to begin its interactive **Setup** guide. Follow its buttons to install in Applications, open the right permission settings, and try the first live effect. A floating companion points out the switch to use in System Settings. If BendMe is absent, choose **BendMe isn’t listed — help me add it** for the upper-list + button and app-path assistance. Eject the disk after the installed copy opens. The public app is Developer ID signed and Apple-notarized. Re-download the current DMG if you have the earlier unsigned preview. Source builds remain available. The ZIP is retained as an alternative download.

## Build and run

From this directory:

```sh
./scripts/build-app.sh
open dist/BendMe.app
```

The script builds a release executable, bundles its Metal resource, and signs it locally. Launch the app bundle rather than `swift run` for a stable macOS permission identity. Keep the app in the same location when granting permissions.

Open **Setup** in the sidebar (or **Setup Guide…** in the menu bar) for installation, Screen Recording permission, restart recovery, and first-effect checks. macOS consent remains your choice; BendMe opens the relevant settings and checks access automatically. You can choose **Explore the preview instead** without screen access.

The app starts paused each time. Closing settings leaves the menu-bar app running. The overlay does not transform mouse coordinates; pause it before precision interaction. The menu bar stays accessible above the overlay.

## Controls

- **Appearance:** Silk / Shade / Frost, manual angle, Follow lid, perspective, blur, shadow, Enable/Pause.
- **General:** permission controls, sensor retry, clear angle (60–135°), optional opening sound, 30/60 fps, reset appearance.
- **Global pause:** Control–Option–Command–B, without Accessibility permission.
- **Escape:** pauses when BendMe itself is focused. The menu-bar Pause command works while other apps are focused.

BendMe never prevents ordinary closed-lid sleep. It pauses on display changes and session deactivation; re-enable after displays settle. Sleep stops capture and sensor reads; wake retries the sensor and restores a previously enabled session.

## Verify

```sh
swift test
./scripts/build-app.sh
dist/BendMe.app/Contents/MacOS/BendMe --diagnose
dist/BendMe.app/Contents/MacOS/BendMe --self-test dist/verification
codesign --verify --deep --strict dist/BendMe.app
# After Screen Recording permission is granted, test in the GUI app context:
open -n -g -W --stdout /tmp/bendme-capture.out --stderr /tmp/bendme-capture.err dist/BendMe.app --args --capture-test
cat /tmp/bendme-capture.out /tmp/bendme-capture.err
```

Expected: passing unit tests; a valid signed bundle; diagnostics reporting GPU, sensor/angle, built-in display, and permission status; GPU `PASS` and 15 rendered PNGs in `dist/verification`. Diagnostics never requests permissions. See [docs/VERIFICATION.md](docs/VERIFICATION.md) for current evidence.

## Troubleshooting

- **Sensor unavailable:** open the built-in display, click Check again. Unsupported machines retain manual preview. The hardware protocol is undocumented by Apple and can vary by model/OS.
- **Permission denied:** use General → Open System Settings. After a rebuild macOS can require permission again because this is an ad-hoc signed development app.
- **Permission is on but the app still says denied:** quit BendMe, reset only its stale authorization with `tccutil reset ScreenCapture local.bendme.mac`, then use the **+** button in Screen Recording settings to add the exact current `dist/BendMe.app`. Choose Quit & Reopen, then Enable BendMe. This removes only BendMe's screen permission; other apps are unaffected. Do this only when re-authorizing BendMe is intended.
- **CLI says denied but the GUI is LIVE:** run the smoke test using `open` as shown above. macOS can attribute a directly executed CLI to its parent shell instead of the GUI app.
- **Black or stopped capture:** pause with the menu or Control–Option–Command–B; retry after checking permissions. Protected video and secure system surfaces may not be capturable.
- **Display configuration changed:** reopen the MacBook and enable again. Only the built-in display is supported.
- **Energy use:** choose 30 fps and pause when unused. Capture stays ready while enabled; GPU effect rendering stops when the lid is above the clear angle.

## Distribution

The default signature is ad-hoc, suitable for this local build, **not notarized distribution**. To sign with your own installed Developer ID:

```sh
BENDME_SIGNING_IDENTITY='Developer ID Application: Your Name (TEAMID)' ./scripts/build-app.sh
```

Notarization, hardened-runtime release configuration, and a distribution account are separate release work. No credentials are included. Do not ship the local ad-hoc build as a notarized release.

## Public distribution and website

- Free preview packaging without replacing the running local app: `./scripts/package-preview.sh`.
- `BENDME_OUTPUT_DIR` and `BENDME_BUNDLE_ID` select a separate output directory and bundle identity for `build-app.sh`. Defaults preserve the original local development identity.
- Website commands, public URLs and Pages setup: [website/SETUP.md](website/SETUP.md).
- App Store archive and account requirements: [distribution/SETUP.md](distribution/SETUP.md).

- Direct Developer ID signing and Apple notarization through an existing paid Xcode account: [distribution/SETUP.md](distribution/SETUP.md#direct-github-distribution-with-apple-notarization). Local identity listings do not include all Xcode-managed signing capabilities.

## Fresh-install testing after uninstall

Quit BendMe, remove its installed app and eject any mounted installer disks before testing a freshly downloaded DMG. The public app identifier is `com.winsonbaring.bendme`; the original source-build identifier is `local.bendme.mac`. Resetting BendMe-only privacy grants and preferences causes the next installation to request permission and use default settings again. Release archives and source files can be retained independently of the installed app. The local uninstall verification and any remaining OS-protected test metadata are recorded in [docs/VERIFICATION.md](docs/VERIFICATION.md).

BendMe 0.1.1 appears in the Dock and opens its settings window. Clicking its Dock icon restores the settings window if hidden or minimized. Closing settings leaves BendMe running; use Quit to exit.
