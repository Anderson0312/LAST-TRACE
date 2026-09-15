#!/usr/bin/env bash
# Idempotent Cloud Agent bootstrap for Último Acesso (Flutter).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

FLUTTER_HOME="${FLUTTER_HOME:-$HOME/flutter}"
export PATH="$FLUTTER_HOME/bin:$PATH"

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter not on PATH; installing SDK into $FLUTTER_HOME"
  if [[ ! -x "$FLUTTER_HOME/bin/flutter" ]]; then
    rm -rf "$FLUTTER_HOME"
    git clone --depth 1 --branch 3.35.4 https://github.com/flutter/flutter.git "$FLUTTER_HOME"
  fi
  export PATH="$FLUTTER_HOME/bin:$PATH"
fi

# Persist PATH for subsequent agent shells when possible.
for profile in "$HOME/.bashrc" "$HOME/.profile"; do
  if [[ -f "$profile" ]] && ! grep -Fq 'flutter/bin' "$profile"; then
    printf '\n# Flutter SDK (Cloud Agent)\nexport PATH="$HOME/flutter/bin:$PATH"\n' >>"$profile"
  fi
done

flutter --version
flutter pub get
flutter pub get
