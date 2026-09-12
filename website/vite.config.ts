import react from '@vitejs/plugin-react';
import { defineConfig } from 'vite';

export default defineConfig({
  base: '/bendme/',
  plugins: [react()],
  build: { sourcemap: false, target: 'es2022' },
});
