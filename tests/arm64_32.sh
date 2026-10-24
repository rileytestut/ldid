#!/bin/sh
# macOS + Xcode; no app source or Apple account required.
# Usage: tests/arm64_32.sh /absolute/path/to/ldid [disposable-test.p12]
set -eu
signer=$1
certificate=${2:-}
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT HUP INT TERM
printf 'int main(void) { return 0; }\n' > "$test_dir/main.c"
xcrun --sdk watchos clang -target arm64_32-apple-watchos10.0 "$test_dir/main.c" -o "$test_dir/watch"
# Previously crashes in the progress callback while naming the architecture.
"$signer" -S "$test_dir/watch"
if [ -n "$certificate" ]; then
    "$signer" "-K$certificate" -S "$test_dir/watch"
    codesign --verify --strict "$test_dir/watch"
fi
