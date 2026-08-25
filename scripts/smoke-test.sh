#!/usr/bin/env bash

set -euo pipefail

readonly system="${1:?usage: smoke-test.sh SYSTEM [VERSION]}"
readonly expected_version="${2:-$(nix eval --raw --file version.nix version)}"

nix flake check --no-build
result_path="$(nix build --no-link --print-out-paths ".#packages.$system.playwright-cli")"
actual_version="$("$result_path/bin/playwright-cli" --version)"
[[ "$actual_version" == "$expected_version" ]] || {
  printf 'Unexpected version: %s\n' "$actual_version" >&2
  exit 1
}

temp_root="${RUNNER_TEMP:-${TMPDIR:-/tmp}}"
work_dir="$(mktemp -d "$temp_root/playwright-cli-smoke.XXXXXX")"
cd "$work_dir"
session="smoke-${system}"
trap '"$result_path/bin/playwright-cli" -s="$session" close >/dev/null 2>&1 || true' EXIT
timeout 60 "$result_path/bin/playwright-cli" -s="$session" open --browser=chromium https://example.com
result="$(timeout 30 "$result_path/bin/playwright-cli" -s="$session" eval '() => document.title')"
[[ "$result" == *'Example Domain'* ]] || {
  printf 'Browser smoke test failed.\n' >&2
  exit 1
}
"$result_path/bin/playwright-cli" -s="$session" close
trap - EXIT
