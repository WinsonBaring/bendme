# BendCore

`FoldSettings.swift` validates persisted parameters and defines fold geometry, HID report decoding, smoothing, and bend counting. `LidSensor.swift` owns IOKit discovery, input callbacks, bounded report reads, and handle cleanup on the main run loop. No screen permissions or UI are needed.

`SetupProgress.swift` derives the installation, permission, first-effect and ready stages from observed facts. Installed-copy discovery checks fresh bundle metadata and the current build, including renamed apps such as BendMe-2.app.
