#!/usr/bin/env bash
set -eu

source <(
    grep -v '^#' "./.env" |
    sed -E 's|^([^=]+)=(.*)$|export \1="\2"|g'
)

case "${FDC2_SGB_XRP_DATABASE_MODE:-}" in
    local)
        export FDC2_SGB_COMPOSE_FILE="docker-compose.yaml:docker-compose.xrp-local.yaml"
        export FDC2_SGB_SOURCE_DATABASE_URL="postgres://db:${XRP_DB_PASSWORD}@database:5432/db?sslmode=disable"
        ;;
    external)
        export FDC2_SGB_COMPOSE_FILE="docker-compose.yaml"
        if [[ -z "${FDC2_SGB_XRP_EXTERNAL_DATABASE_URL:-}" ]]; then
            echo "FDC2_SGB_XRP_EXTERNAL_DATABASE_URL must be set in external mode" >&2
            exit 1
        fi
        export FDC2_SGB_SOURCE_DATABASE_URL="${FDC2_SGB_XRP_EXTERNAL_DATABASE_URL}"
        ;;
    *)
        echo "FDC2_SGB_XRP_DATABASE_MODE must be local or external" >&2
        exit 1
        ;;
esac

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
    "evm-verifier/verifier-eth.env"
    "evm-verifier/verifier-flr.env"
    "evm-verifier/verifier-sgb.env"
    "web2-verifier/verifier.env"
    "fdc2-verifiers/sgb/.env"
    "fdc2-verifiers/sgb/c-chain-indexer/database.env"
    "fdc2-verifiers/sgb/c-chain-indexer/indexer.env"
    "fdc2-verifiers/sgb/c-chain-indexer/config.toml"
    "fdc2-verifiers/sgb/verifier.env"
    "fdc2-verifiers/sgb/tee.env"
    "fdc2-verifiers/sgb/pmw-multisig.env"
    "fdc2-verifiers/sgb/pmw-indexed.env"
)

for config_file in "${config_files[@]}"; do
    echo "writing config file ${config_file}"
    envsubst < "${config_file}.example" > "${config_file}"
done

echo "done"
