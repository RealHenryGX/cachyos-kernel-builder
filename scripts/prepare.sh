#!/usr/bin/env bash
set -euo pipefail

root_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
output_dir=${1:-"$root_dir/artifacts"}
source "$root_dir/config/build.env"

mkdir -p "$output_dir"
output_dir=$(cd "$output_dir" && pwd)
work_dir=$(mktemp -d)
trap 'rm -rf "$work_dir"' EXIT

git clone --depth=1 --branch "$UPSTREAM_REF" "$UPSTREAM_REPOSITORY" "$work_dir/$PACKAGE_DIR"
cd "$work_dir/$PACKAGE_DIR"

upstream_sha=$(git rev-parse HEAD)
config_file="$work_dir/$PACKAGE_DIR/$PACKAGE_DIR/config"
patch_file="$root_dir/patches/0001-enable-ima-secure-boot.patch"

if grep -Fxq 'CONFIG_IMA=y' "$config_file" && grep -Fxq 'CONFIG_IMA_SECURE_AND_OR_TRUSTED_BOOT=y' "$config_file"; then
  printf 'upstream already contains the IMA settings; downstream patch is no longer needed\n' >&2
  exit 2
fi

git apply --check "$patch_file"
git apply "$patch_file"
"$root_dir/scripts/verify-config.sh" "$config_file"

cp -a "$work_dir/$PACKAGE_DIR" "$output_dir/source"
cat > "$output_dir/build-manifest.txt" <<EOF
upstream_repository=$UPSTREAM_REPOSITORY
upstream_ref=$UPSTREAM_REF
upstream_commit=$upstream_sha
package_dir=$PACKAGE_DIR
ima_reference_pull=$IMA_REFERENCE_PULL
ima_reference_commit=$IMA_REFERENCE_COMMIT
patch=patches/0001-enable-ima-secure-boot.patch
EOF

printf 'prepared source at %s\n' "$output_dir/source"
