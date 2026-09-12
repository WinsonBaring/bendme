# Contributing

BendMe is free and open source. Small, focused fixes and documented hardware reports are welcome.

1. Read [PROJECT.md](PROJECT.md) and [SETUP.md](SETUP.md).
2. Open an issue before large behavior changes. Include your Mac model and macOS version for sensor reports; omit personal screen contents and credentials.
3. Keep app frames local, preserve an immediate pause path, and fail by removing the overlay.
4. Run `swift test` for native changes and `npm --prefix website run check` for website changes.
5. Include the change, its reason, and the validation result in your pull request. Never claim physical hardware validation based solely on unit tests.

Original contributions are provided under the repository's MIT license. Third-party code or assets must retain their own attribution and license. Do not add screen recordings, telemetry, accounts, cloud keys, or private APIs as a shortcut.
