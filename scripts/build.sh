#!/usr/bin/env bash
set -euo pipefail

root_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
source_dir=${1:?usage: build.sh SOURCE_DIR}
output_dir=${2:-"$root_dir/artifacts"}

mkdir -p "$output_dir/packages"
output_dir=$(cd "$output_dir" && pwd)
cd "$source_dir/linux-cachyos"

sed -i '/^makedepends=(/,/^)/ { /^[[:space:]]*pahole[[:space:]]*$/d; }' PKGBUILD
env -u CI -u GITHUB_RUN_ID makepkg --skipchecksums --syncdeps --noconfirm --needed
cp -a "$source_dir/linux-cachyos/linux-cachyos/config" "$output_dir/kernel.config"
cp -a ./*.pkg.tar.* "$output_dir/packages/"
sha256sum "$output_dir/packages"/* > "$output_dir/packages/SHA256SUMS"

printf 'packages written to %s\n' "$output_dir/packages"
