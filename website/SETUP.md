# Website setup

Requires Node 22.13+ and npm. From this directory:

```sh
npm ci
npm run check
npm run dev
```

Open the printed localhost URL with `/bendme/`. `npm run check` runs lint, three asset/content tests, TypeScript, and the prerendered production build. Expected result: all checks pass and `dist/index.html` contains readable page content before JavaScript loads.

GitHub Actions publishes `dist` to GitHub Pages on main. Configure Pages with GitHub Actions. Deployment workflow: [pages.yml](../.github/workflows/pages.yml). Update `src/release.ts`, `index.html`, `vite.config.ts`, and public sitemap/robots URLs together if repository or host changes. No environment variables or API keys required.
