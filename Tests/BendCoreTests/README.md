# Core tests

`FoldTests.swift` covers sensor report boundaries, nonfinite values, monotonic fold behavior, open-lid identity, settings validation and persistence, frame-rate-independent smoothing, and counter hysteresis. Run `swift test` from the repository root. No physical lid motion or permission is required.

`SetupProgressTests.swift` adds nine tests for stage gating, permission revocation, sensor availability, installation path boundaries, fresh metadata, renamed copies and wrong-version rejection. Together with the eight fold tests, the suite has 17 tests.
