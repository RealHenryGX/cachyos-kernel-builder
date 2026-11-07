#!/usr/bin/env bash
set -euo pipefail

config_file=${1:?usage: verify-config.sh CONFIG_FILE}

required=(
  'CONFIG_IMA=y'
  'CONFIG_IMA_LSM_RULES=y'
  'CONFIG_IMA_NG_TEMPLATE=y'
  'CONFIG_IMA_ARCH_POLICY=y'
  'CONFIG_IMA_SECURE_AND_OR_TRUSTED_BOOT=y'
)

for setting in "${required[@]}"; do
  if ! grep -Fxq "$setting" "$config_file"; then
    printf 'missing required setting: %s\n' "$setting" >&2
    exit 1
  fi
done

if grep -Fxq '# CONFIG_IMA is not set' "$config_file"; then
  printf 'IMA is still disabled\n' >&2
  exit 1
fi

if grep -Fxq '# CONFIG_IMA_SECURE_AND_OR_TRUSTED_BOOT is not set' "$config_file"; then
  printf 'Secure Boot IMA support is still disabled\n' >&2
  exit 1
fi

printf 'kernel configuration passed IMA checks: %s\n' "$config_file"
