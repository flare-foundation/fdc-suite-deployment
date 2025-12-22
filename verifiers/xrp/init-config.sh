#!/bin/bash

command -v jq >/dev/null 2>&1 || apt update && apt install -y jq curl

CONFIG_FILE="/app/config.toml"
THRESHOLD="${DIFFERENCE_BLOCK_FORCE_CHANGE_START_BLOCK:-300000}"

cluster_start_block=$(curl -s -X POST https://xrplcluster.com/ \
  -d '{ "method": "server_info", "params": [{}] }' \
  -H "Content-Type: application/json" | jq '.result.info.validated_ledger.seq - 4')

if ! [[ "$cluster_start_block" =~ ^[0-9]+$ ]]; then
    echo "Invalid start_block from cluster: $cluster_start_block"
    exec ./xrp-indexer
fi

echo "Cluster start block: $cluster_start_block"

rpc_url=$(grep -oP 'url\s*=\s*"\K[^"]+' "$CONFIG_FILE")

if [[ -z "$rpc_url" ]]; then
    echo "Failed to find blockchain URL in config.toml"
    exec ./xrp-indexer
fi

ledger_range=$(curl -s -X POST "$rpc_url" \
  -d '{ "method": "server_info", "params": [{}] }' \
  -H "Content-Type: application/json" | jq -r '.result.info.complete_ledgers')

update_start_block_number() {
  tmp_file=$(mktemp)
  sed "s/^start_block_number = .*/start_block_number = $cluster_start_block/" "$CONFIG_FILE" > "$tmp_file" \
    && cat "$tmp_file" > "$CONFIG_FILE" \
    && rm "$tmp_file"
}

if [[ "$ledger_range" =~ ^([0-9]+)-([0-9]+)$ ]]; then
    lower=${BASH_REMATCH[1]}
    upper=${BASH_REMATCH[2]}
    range=$((upper - lower))

    echo "Local ledger range: $lower - $upper (range: $range)"
    echo "Threshold from DIFFERENCE_BLOCK_FORCE_CHANGE_START_BLOCK: $THRESHOLD"

    if [[ "$FORCE_UPDATE_START_BLOCK" == "true" ]]; then
        echo "FORCE_UPDATE_START_BLOCK is enabled: updating to $cluster_start_block"
        update_start_block_number
    elif (( range > THRESHOLD )); then
        echo "Range exceeds threshold ($THRESHOLD); updating to $cluster_start_block"
        update_start_block_number
    else
        echo "Ledger range is within threshold; no update needed"
    fi
else
    echo "Could not parse complete_ledgers: $ledger_range"
    echo "Using start_block_number value."
fi

exec ./xrp-indexer
