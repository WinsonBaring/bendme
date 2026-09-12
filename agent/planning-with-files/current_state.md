# Current state — local development only

User requested complete local app removal and will build/open the development app manually. Removed /Applications/BendMe.app and all extracted BendMe.app bundles outside xcarchives, ejected BendMe installer, reset public app privacy approvals, and cleared public/development preferences. Verified no installed/running app. Source, DMG/ZIP release packages, build caches and xcarchives are preserved. Two known protected empty diagnostic metadata folders remain, with no app data.

SETUP.md now gives manual commands using BENDME_OUTPUT_DIR="$HOME/Applications" so the development app opens from a stable recognized location. No build or launch performed for the user. Script syntax checked; prior source build/test evidence remains unchanged.

Releases remain paused: no version bumps, Apple submissions/notarization, tags, public releases or website deployment until explicitly resumed. Issue #10 tracks local review; #5 retains diagnostic cleanup limitations; #2 App Store remains separate.
