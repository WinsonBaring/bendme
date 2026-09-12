import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';

test('release links point to the actual owner and one versioned download', async () => {
  const source = await readFile(new URL('../src/release.ts', import.meta.url), 'utf8');
  assert.match(source, /github\.com\/WinsonBaring\/bendme/);
  assert.match(source, /releases\/download\/v0\.1\.4\/BendMe-macOS-arm64\.dmg/);
  assert.doesNotMatch(source, /example\.com|localhost|TODO/);
});

test('all selectable effect frames are real PNG artifacts', async () => {
  for (const style of ['silk', 'shade', 'frost']) {
    for (const angle of [135, 90, 60, 25, 5]) {
      const data = await readFile(new URL(`../public/images/${style}-${angle}.png`, import.meta.url));
      assert.equal(data.subarray(1, 4).toString(), 'PNG');
      assert.equal(data.readUInt32BE(16), 640);
      assert.equal(data.readUInt32BE(20), 416);
    }
  }
});

test('public copy states release limitations and does not claim App Store availability', async () => {
  const source = await readFile(new URL('../src/App.tsx', import.meta.url), 'utf8');
  assert.match(source, /Developer ID signed and notarized by Apple/);
  assert.match(source, /Not yet\. An App Store release is being prepared/);
  assert.doesNotMatch(source, /[—–]/);
  assert.match(source, /id="privacy"/);
  assert.match(source, /aria-valuetext/);
});
