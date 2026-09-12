#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
python3 - <<'PY'
from pathlib import Path
import platform
import subprocess
root = Path.cwd()
output = root / 'dist/SetupVerification'
output.mkdir(parents=True, exist_ok=True)
files = [str(p) for p in (root / 'Sources').rglob('*.swift') if p.name != 'BendMeMain.swift']
binary = output / 'render-setup'
subprocess.run(['swiftc', '-parse-as-library', '-swift-version', '5', '-target',
                platform.machine() + '-apple-macos14.0', *files,
                str(root / 'scripts/render-setup-checks.swift'), '-o', str(binary)], check=True)
subprocess.run([str(binary), str(output)], check=True)
PY
