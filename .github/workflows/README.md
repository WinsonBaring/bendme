# Automation

`ci.yml` checks the static site, dependencies, Swift tests, and an unsigned Xcode archive. `pages.yml` builds and publishes only the website's public static output. Both use read-only source permissions; Pages alone gets deployment and OIDC permissions. No desktop capture or signing secrets run in CI.
