import { createRoot, hydrateRoot } from 'react-dom/client';
import { StrictMode } from 'react';
import App from './App';

const root = document.getElementById('root');
if (root) {
  const app = <StrictMode><App /></StrictMode>;
  if (root.querySelector('main')) hydrateRoot(root, app);
  else createRoot(root).render(app);
}

