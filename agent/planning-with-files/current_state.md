# Current state

Native app remains available and authorized at `dist/BendMe.app`; release packaging preserves that installation. Public repository: https://github.com/WinsonBaring/bendme. Issue #1 tracks free desktop preview and maker website; issue #2 tracks App Store submission. User declined plugins and browser tools; CLI is used.

Prepared: MIT source, separate ad-hoc arm64 development preview at dist/Release, responsive prerendered website, GitHub Pages deployment, Xcode archive target, sandbox entitlements, privacy manifest and draft store metadata.

Verified: eight Swift tests, 15 GPU renders, strict preview signature, website lint/three tests/typecheck/build, static assets/anchors, zero npm advisories, unsigned Xcode archive, and sandboxed physical lid sensor diagnostic. Prior working local app captured three complete frames through LaunchServices.

Next: push source, publish GitHub prerelease and verify Pages deployment/download checksums. App Store remains unsubmitted: no distribution identity, verified membership or App Store Connect record/access; final signed sandbox capture, physical lid/Spaces/sleep acceptance and real store screenshots remain open. No browser visual QA performed under user constraint.
