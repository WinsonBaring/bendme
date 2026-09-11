# BendCore

`FoldSettings.swift` validates persisted parameters and defines fold geometry, HID report decoding, smoothing, and bend counting. `LidSensor.swift` owns IOKit discovery, input callbacks, bounded report reads, and handle cleanup on the main run loop. No screen permissions or UI are needed.
