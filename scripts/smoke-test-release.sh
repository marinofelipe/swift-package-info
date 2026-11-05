#!/usr/bin/env bash
# Smoke tests the release binary of swift-package-info by running it
# against a real package and validating the JSON report.
#
# Usage: scripts/smoke-test-release.sh [path-to-binary]
# Defaults to .build/release/swift-package-info (run `swift build -c release` first).

set -euo pipefail

BINARY="${1:-.build/release/swift-package-info}"
URL="https://github.com/onevcat/Kingfisher"
VERSION="8.1.0"
PRODUCT="Kingfisher"

if [[ ! -x "$BINARY" ]]; then
  echo "error: binary not found or not executable at $BINARY" >&2
  exit 1
fi

WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT
BINARY="$(cd "$(dirname "$BINARY")" && pwd)/$(basename "$BINARY")"

echo "==> $BINARY --version"
"$BINARY" --version

echo "==> full-analyzes $PRODUCT $VERSION (jsonDump)"
# Runs from a temp dir, as the tool clones the measurement app into the current directory.
(cd "$WORK_DIR" && "$BINARY" full-analyzes \
  --url "$URL" \
  --package-version "$VERSION" \
  --product "$PRODUCT" \
  --report jsonDump) | tee "$WORK_DIR/output.txt"

# Progress messages are also printed to stdout, so extract the JSON report:
# everything from the first line that is exactly "{" to the end.
sed -n '/^{$/,$p' "$WORK_DIR/output.txt" > "$WORK_DIR/report.json"

echo "==> Validating report"
jq -e '
  (.binarySize.amount | type == "number" and . > 0)
  and (.platforms | type == "object" and has("iOS"))
  and (.dependencies | type == "array")
' "$WORK_DIR/report.json" > /dev/null || {
  echo "error: unexpected report:" >&2
  cat "$WORK_DIR/report.json" >&2
  exit 1
}

echo "==> Smoke test passed"
