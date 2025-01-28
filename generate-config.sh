#!/usr/bin/env bash
set -eu

source <(
    grep -v '^#' "./.env" |
    sed -E 's|^([^=]+)=(.*)$|export \1="\2"|g'
)

config_files=(
    "verifiers/btc/database.env"
    "verifiers/btc/indexer.env"
    "verifiers/btc/verifier.env"
    "verifiers/doge/database.env"
    "verifiers/doge/indexer.env"
    "verifiers/doge/verifier.env"
    "verifiers/xrp/database.env"
    "verifiers/xrp/config.toml"
    "verifiers/xrp/verifier.env"
    "evm-verifier/verifier.env"
)

for config_file in "${config_files[@]}"; do
    echo "writing config file ${config_file}"
    envsubst < "${config_file}.example" > "${config_file}"
done

echo "done"
