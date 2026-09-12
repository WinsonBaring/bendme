export const release = {
  repository: 'https://github.com/WinsonBaring/bendme',
  maker: 'https://github.com/WinsonBaring',
  download: 'https://github.com/WinsonBaring/bendme/releases/download/v0.1.0/BendMe-macOS-arm64.dmg',
  releasePage: 'https://github.com/WinsonBaring/bendme/releases/tag/v0.1.0',
  source: 'https://github.com/WinsonBaring/bendme/archive/refs/tags/v0.1.0.zip',
  issues: 'https://github.com/WinsonBaring/bendme/issues',
  license: 'https://github.com/WinsonBaring/bendme/blob/main/LICENSE',
} as const;

export function asset(path: string): string {
  return `${import.meta.env.BASE_URL}${path}`;
}
