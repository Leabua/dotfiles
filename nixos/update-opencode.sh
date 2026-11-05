#!/usr/bin/env bash
# Bump opencode-v2.nix to the latest @opencode/cli-linux-x64 release on npm.
set -euo pipefail
file="$(dirname "$(readlink -f "$0")")/opencode-v2.nix"
meta="$(curl -fsSL https://registry.npmjs.org/@opencode/cli-linux-x64/latest)"
version="$(jq -r .version <<<"$meta")"
hash="$(jq -r .dist.integrity <<<"$meta")"
current="$(sed -n 's/^ *version = "\(.*\)";/\1/p' "$file")"
if [[ "$version" == "$current" ]]; then
  echo "opencode: already at $version"
  exit 0
fi
sed -i -e "s|^\( *version = \)\".*\";|\1\"$version\";|" \
       -e "s|^\( *hash = \)\"sha512-.*\";|\1\"$hash\";|" "$file"
echo "opencode: $current -> $version"
