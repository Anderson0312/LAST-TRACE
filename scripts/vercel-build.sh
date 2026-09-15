#!/usr/bin/env bash
set -euo pipefail
export PATH="${HOME}/flutter/bin:${PATH}"
flutter build web --release
