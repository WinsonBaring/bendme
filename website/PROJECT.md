# Website architecture

Vite 8, React 19, strict TypeScript, Lucide icons and locally served Geist font. Dependencies are pinned in package.json and package-lock.json. Node prerenders React into the built HTML; React hydrates the interactive controls.

`src/App.tsx` owns the landing page and discrete 15-frame preview. `src/release.ts` centralizes public links; `src/styles.css` supplies responsive light/dark themes and reduced-motion support. The demo never reads a visitor's screen or sensor. Actual GPU frames come from the desktop self-test.

Design: consumer utility, variance 7, motion 4, density 3. Charcoal and warm amber, editorial typography, a single product illustration and a restrained profile section. Controls use semantic elements, labels, focus styles and generous hit areas. Browser-based visual and assistive-technology QA remains unperformed under the user's no-browser constraint.

Build and verification: [SETUP.md](SETUP.md). Asset rights: [ASSETS.md](ASSETS.md), [third-party notices](../THIRD_PARTY_NOTICES.md).
