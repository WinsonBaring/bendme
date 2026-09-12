#!/usr/bin/env python3
"""Wait for the existing Apple submission; optionally publish verified artifacts.

Run in a dedicated clean checkout with dist pointing to the submitted archive.
Uses Xcode and gh's existing account sessions; never reads their credentials.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import plistlib
import subprocess
import time
from urllib.request import urlopen

ROOT = Path(__file__).resolve().parent.parent
STATE = ROOT / 'dist/DeveloperID/notarization-status.json'
REPO = 'WinsonBaring/bendme'
SITE = 'https://winsonbaring.github.io/bendme/'
NOTICE = 'The included app is Developer ID signed and notarized by Apple. This is a free direct download; an App Store release is still being prepared.'


def run(*args, cwd=ROOT):
    return subprocess.run(args, cwd=cwd, text=True, stdout=subprocess.PIPE,
                          stderr=subprocess.STDOUT, check=True).stdout


def status(stage, detail):
    STATE.parent.mkdir(parents=True, exist_ok=True)
    data = {'stage': stage, 'detail': detail, 'updated_at': time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime())}
    temporary = STATE.with_suffix('.tmp')
    temporary.write_text(json.dumps(data, indent=2) + '\n')
    temporary.replace(STATE)
    print(json.dumps(data), flush=True)


def replace(path, old, new):
    target = ROOT / path
    text = target.read_text()
    if old not in text:
        raise RuntimeError(f'Expected release text changed in {path}; manual review required')
    target.write_text(text.replace(old, new))


def publish():
    if run('git', 'status', '--porcelain').strip():
        raise RuntimeError('Publication checkout is not clean')
    run('git', 'fetch', 'origin', 'main')
    if run('git', 'rev-parse', 'HEAD') != run('git', 'rev-parse', 'origin/main'):
        raise RuntimeError('Remote source changed while waiting; publication requires review')
    release = ROOT / 'dist/NotarizedRelease'
    names = ['BendMe-macOS-arm64.dmg', 'BendMe-macOS-arm64.dmg.sha256',
             'BendMe-macOS-arm64.zip', 'SHA256SUMS.txt']
    mounted = plistlib.loads(subprocess.check_output([
        'hdiutil', 'attach', '-readonly', '-nobrowse', '-plist',
        str(release / names[0])]))
    mount = next(Path(item['mount-point']) for item in mounted['system-entities'] if 'mount-point' in item)
    try:
        run('codesign', '--verify', '--deep', '--strict', str(mount / 'BendMe.app'))
        run('xcrun', 'stapler', 'validate', str(mount / 'BendMe.app'))
        run('spctl', '--assess', '--type', 'execute', '--verbose=2', str(mount / 'BendMe.app'))
        if (mount / 'Applications').readlink() != Path('/Applications'):
            raise RuntimeError('DMG Applications shortcut is invalid')
    finally:
        run('hdiutil', 'detach', str(mount))

    replace('website/src/App.tsx',
            'This is a development preview, not yet Apple-notarized. macOS may block it. Prefer a verified installation? Build it from source or wait for a signed release.', NOTICE)
    replace('website/scripts/site.test.mjs', '/not yet Apple-notarized/', '/Developer ID signed and notarized by Apple/')
    replace('README.md',
            '> The direct download is an ad-hoc-signed development preview, not yet Apple-notarized or on the Mac App Store. macOS may block it. Build from source if you prefer; do not disable macOS security protections.',
            '> The direct download now contains a Developer ID signed app notarized by Apple, with its approval ticket attached. It remains a development preview distributed through GitHub, not a Mac App Store release. Re-download the DMG if you previously downloaded the unsigned preview.')
    replace('SETUP.md', 'The preview is not Apple-notarized; macOS may block it.',
            'The public app is Developer ID signed and Apple-notarized. Re-download the current DMG if you have the earlier unsigned preview.')
    for path, paragraph in {
        'website/README.md': 'The current direct download includes a Developer ID signed app with a validated Apple notarization ticket.',
        'distribution/README.md': 'Direct distribution notarization completed through the configured paid Xcode team. Ticket, Gatekeeper, mounted DMG and public download checks passed. App Store submission is separate.',
        'docs/VERIFICATION.md': 'Apple accepted the direct-distribution app. Xcode exported the approved app; strict signature, stapled ticket, Gatekeeper assessment and mounted DMG checks passed. Public release downloads were checked against local SHA-256 hashes before deployment.',
    }.items():
        with (ROOT / path).open('a') as file:
            file.write('\n' + paragraph + '\n')
    replace('CHANGELOG.md', '## Unreleased',
            '## Unreleased\n\n- Published Developer ID signed, Apple-notarized app downloads with attached approval tickets; replaced the earlier unsigned preview packages.')
    run('npm', 'ci', cwd=ROOT / 'website')
    run('npm', 'run', 'check', cwd=ROOT / 'website')
    run('git', 'diff', '--check')
    status('publishing', 'Approved app and website checks passed; replacing public preview assets.')
    run('gh', 'release', 'upload', 'v0.1.0', *[str(release / name) for name in names],
        '--repo', REPO, '--clobber')
    for name in names:
        with urlopen(f'https://github.com/{REPO}/releases/download/v0.1.0/{name}', timeout=60) as response:
            remote = response.read()
        if hashlib.sha256(remote).digest() != hashlib.sha256((release / name).read_bytes()).digest():
            raise RuntimeError(f'Public checksum mismatch: {name}')
    notes = ROOT / 'dist/DeveloperID/notarized-release-notes.md'
    notes.write_text('''BendMe is a free, open-source native Mac utility by Winson Baring.

**The app is now Developer ID signed and notarized by Apple, with its approval ticket attached.** Re-download if you previously obtained the unsigned preview. This is a development preview distributed through GitHub, not a Mac App Store release.

Download `BendMe-macOS-arm64.dmg`, open it, drag BendMe to Applications and eject the disk. The ZIP remains an alternative. SHA256SUMS.txt covers both downloads; a dedicated DMG checksum is also provided.

Requires Apple silicon and macOS 14 or later. Live effects require a compatible MacBook lid sensor and Screen Recording permission. Manual preview works without these. All three styles passed 15 GPU render checks on Apple M3 Pro; broader physical lid, sleep/wake and Spaces acceptance remains ongoing.

Strict signature, attached Apple ticket, Gatekeeper assessment and mounted DMG checks passed. Frames stay on your Mac; no accounts, analytics or uploads.

[Website](https://winsonbaring.github.io/bendme/) · [Setup](https://github.com/WinsonBaring/bendme/blob/main/SETUP.md) · [App Store progress](https://github.com/WinsonBaring/bendme/issues/2)
''')
    run('gh', 'release', 'edit', 'v0.1.0', '--repo', REPO, '--notes-file', str(notes))
    run('git', 'add', 'website/src/App.tsx', 'website/scripts/site.test.mjs', 'website/README.md',
        'README.md', 'SETUP.md', 'CHANGELOG.md', 'distribution/README.md', 'docs/VERIFICATION.md')
    run('git', 'commit', '-m', 'fix: publish Apple-notarized direct downloads (#4)')
    run('git', 'push', 'origin', 'HEAD:main')
    for _ in range(90):
        try:
            with urlopen(SITE, timeout=30) as response:
                if NOTICE in response.read().decode():
                    break
        except OSError:
            pass
        time.sleep(10)
    else:
        raise RuntimeError('Website deployment has not shown the verified release copy yet')
    plan = ROOT / 'agent/planning-with-files/task_plan.md'
    first, phase = plan.read_text().split('## Phase 6:', 1)
    plan.write_text(first + '## Phase 6:' + phase.replace('- [ ]', '- [x]'))
    for name in ('current_state.md', 'progress.md'):
        with (ROOT / 'agent/planning-with-files' / name).open('a') as file:
            file.write('\nIssue #4 complete: Apple accepted the app; signature, ticket, Gatekeeper, mounted DMG and public checksum checks passed. DMG/ZIP replaced and live Pages copy verified. App Store release remains separate under #2.\n')
    run('git', 'add', 'agent/planning-with-files')
    run('git', 'commit', '-m', 'docs: record verified notarized release (closes #4)')
    run('git', 'push', 'origin', 'HEAD:main')
    run('gh', 'issue', 'comment', '4', '--repo', REPO, '--body',
        'Apple notarization completed. Exported app passed signature, stapled-ticket and Gatekeeper checks. Mounted DMG and public download checksums passed. Replaced DMG/ZIP assets and verified the live website disclosure. Re-download the current DMG to replace the earlier unsigned preview.')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--publish', action='store_true', help='Publish verified assets and website from this clean checkout.')
    args = parser.parse_args()
    deadline = time.monotonic() + 24 * 60 * 60
    while True:
        try:
            run('./scripts/notarize-direct.sh', 'export')
            break
        except subprocess.CalledProcessError as error:
            if 'is processing and not ready for distribution' not in error.stdout:
                raise
            status('processing', 'Apple has not completed the existing submission.')
            if time.monotonic() >= deadline:
                raise TimeoutError('Apple is still processing after 24 hours; inspect submission status.')
            time.sleep(60)
    status('accepted', 'Apple-approved app exported; signature, ticket and Gatekeeper passed.')
    run('./scripts/package-notarized.sh')
    status('packaged', 'Verified app packaged into DMG and ZIP with checksums.')
    if args.publish:
        publish()
        status('published', SITE)
    subprocess.run(['osascript', '-e', 'display notification "BendMe notarization completed. Check the release status in the project." with title "BendMe"'], check=False)


if __name__ == '__main__':
    os.chdir(ROOT)
    try:
        main()
    except Exception as error:
        detail = str(error)
        if isinstance(error, subprocess.CalledProcessError):
            detail += '\n' + (error.stdout or '')[-4000:]
        status('failed', detail)
        raise
