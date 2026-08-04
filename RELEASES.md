# Release Notes

Important changes and upgrade notes will be listed in this file. Always read this file before updating to a new version of this deployment repo.

## Unreleased

### Added

- added four SGB FDC2 verifier services using `go-verifier-api`
- added a default-enabled SGB C-chain indexer only for FDC2 verifiers

### Update notes

Add the new `FDC2_SGB_*` variables from `.env.example` to your `.env`, ensure every `VERIFIER_API_KEYS` entry is at least 16 characters, and run `./generate-config.sh`.

The embedded C-chain indexer is enabled by default and creates a persistent MySQL volume containing 15 days of `TeeInstructionsSent` logs. It could take up to 1 hour to catch up. To use an external C-chain indexer database, leave `FDC2_SGB_COMPOSE_PROFILES` empty, set `FDC2_SGB_CCHAIN_DATABASE_URL` to the external MySQL DSN, and regenerate the configuration.

The XRP indexer database defaults to local mode. This means that FDC2 verifiers will connect directly to XRP verifier's docker compose network. Start `verifiers/xrp/` before `fdc2-verifiers/sgb/` so its `verifier-xrp_default` network exists. For a remote XRP indexer, set `FDC2_SGB_XRP_DATABASE_MODE=external`, set `FDC2_SGB_XRP_EXTERNAL_DATABASE_URL` to the external PostgreSQL DSN, and regenerate the configuration.

FDC2 verifiers run on separate ports for each type. Example FDC client configuration for FDC2 verifier URLs:

```
TEE_TEEAVAILABILITYCHECK_URL=http://<fdc2-verifier-host>:9901/verifier/tee/TeeAvailabilityCheck/verify
XRP_PMWMULTISIGACCOUNTCONFIGURED_URL=http://<fdc2-verifier-host>:9902/verifier/xrp/PMWMultisigAccountConfigured/verify
XRP_PMWPAYMENTSTATUS_URL=http://<fdc2-verifier-host>:9903/verifier/xrp/PMWPaymentStatus/verify
XRP_PMWFEEPROOF_URL=http://<fdc2-verifier-host>:9904/verifier/xrp/PMWFeeProof/verify
```

## \[[v1.3.3](https://github.com/flare-foundation/fdc-suite-deployment/tree/v1.3.3)\] - 2026-07-13

### Changed

- updated xrpl node to `3.2.0`

### Update notes

In the mainnet xrpl node config, the peering port has changed from `51235` to `2459`. If you have any firewall rules set up for incoming peering connections, update them.

## \[[v1.3.2](https://github.com/flare-foundation/fdc-suite-deployment/tree/v1.3.2)\] - 2026-06-11

### Changed

- updated BTC and DOGE indexers to `verifier-utxo-indexer:v1.1.1`

## \[[v1.3.1](https://github.com/flare-foundation/fdc-suite-deployment/tree/v1.3.1)\] - 2026-06-05

### Changed

- updated BTC, DOGE, XRP, EVM and web2 verifiers to `verifier-indexer-api:v1.6.1`

## \[[v1.3.0](https://github.com/flare-foundation/fdc-suite-deployment/tree/v1.3.0)\] - 2026-06-04

### Changed

- changed EVM verifier deployment to run `verifier-indexer-api:v1.6.0` as separate ETH, FLR, and SGB verifier instances
- updated BTC and DOGE indexers to `verifier-utxo-indexer:v1.1.0`
- updated BTC, DOGE, and XRP verifiers to `verifier-indexer-api:v1.6.0`
- updated XRP indexer to `verifier-xrp-indexer:v2.1.0`
- updated web2 verifier to `verifier-indexer-api:v1.6.0`

### Update notes

The EVM verifier changed from one shared `evm-verifier` service on port `9800` to three `verifier-indexer-api` services: ETH on port `9701`, FLR on port `9702` and SGB on port `9703`.

Because EVM verifiers are now on separate ports, you will most likely need to update your FDC client verifier URLs. For example:

```env
ETH_EVMTRANSACTION_URL=https://<host>:9701/verifier/eth/EVMTransaction/verifyFDC
FLR_EVMTRANSACTION_URL=https://<host>:9702/verifier/flr/EVMTransaction/verifyFDC
SGB_EVMTRANSACTION_URL=https://<host>:9703/verifier/sgb/EVMTransaction/verifyFDC
```

Recommended EVM verifier upgrade procedure:

1. In `evm-verifier/`, stop the old deployment with `docker compose down` before updating the deployment repo.
2. Pull or update this repository.
3. Run `./generate-config.sh` from the repository root.
4. In `evm-verifier/`, run `docker compose up -d` to start the new EVM verifier services.

Other updated verifiers can be updated by running `docker compose up -d` like always.

## \[[v1.2.5](https://github.com/flare-foundation/fdc-suite-deployment/tree/v1.2.5)\] - 2026-05-15

### Changed

- updated ripple node to `3.1.3`

## \[[v1.2.4](https://github.com/flare-foundation/fdc-suite-deployment/tree/v1.2.4)\] - 2026-04-17

### Changed

- updated xrp indexer to `v2.0.0`
- updated xrp verifier to `v1.5.0`
- updated PostgreSQL version to 18

### Update notes

This release requires reindexing of XRP verifier database data. DOGE and BTC also require a migration or reindex.

- `XRP` must be fully reindexed because `verifier-xrp-indexer v2.0.0` changes the database schema.
- `BTC`, `DOGE`, and `XRP` are now using PostgreSQL 18, so you must either migrate the existing database or remove the database volume and reindex.

To reduce downtime, it is recommended to prepare a parallel deployment first and switch the FDC client to it during the reindex.

For each affected verifier:
1. Stop the old deployment with `docker compose down`.
2. Migrate the database or remove the old database volume. (for example `docker volume rm verifier-btc_btc-indexer-database`)
3. Run `./generate-config.sh`.
4. Start the new version with `docker compose up -d`.

## \[[v1.2.3](https://github.com/flare-foundation/fdc-suite-deployment/tree/v1.2.3)\] - 2026-03-25

### Changed

- updated ripple node to `3.1.2`
- changed registry for all node images to ghcr (https://github.com/flare-foundation/connected-chains-docker)
- Updated Web2 verifier version to `v1.4.0`
- tagged all container images with digest hashes

## \[[v1.2.2](https://github.com/flare-foundation/fdc-suite-deployment/tree/v1.2.2)\] - 2026-01-16

### Changed

- updated ripple node image to `3.0.0-dless`

## \[[v1.2.1](https://github.com/flare-foundation/fdc-suite-deployment/tree/v1.2.1)\] - 2026-01-08

### Changed

- updated web2 verifier image to `v1.3.1`

## \[[v1.2.0](https://github.com/flare-foundation/fdc-suite-deployment/tree/v1.2.0)\] - 2025-12-17

### Changed

- added web2 verifier

### Update notes

This release adds new `WEB2_` variables to `.env.example`. Copy them to your `.env` file and populate them. Then run `generate-config.sh` and start web2-verifier with `docker-compose up -d`.

## \[[v1.1.1](https://github.com/flare-foundation/fdc-suite-deployment/tree/v1.1.1)\] - 2025-12-08

### Changed

- updated ripple node image to `2.6.2-nonroot`

## \[[v1.1.0](https://github.com/flare-foundation/fdc-suite-deployment/tree/v1.1.0)\] - 2025-11-12

### Update notes

This version changes docker images for bitcoin, dogecoin and ripple nodes to use distroless images. These images also run the node process with a different non-privileged user. This means that the owner of the node data in the docker volume needs to be changed.

First update the deployment repository to the new version, then stop the node running old version with `docker compose down`, then chown the data in the volume with one of the commands:

for btc:
```
docker run --rm -t -i -v btc_bitcoin-mainnet-data:/nodevol alpine chown -R 65532:65532 /nodevol
```

for doge:
```
docker run --rm -t -i -v doge_dogecoin-mainnet-data:/nodevol alpine chown -R 65532:65532 /nodevol
```

for xrp:
```
docker run --rm -t -i -v xrp_ripple-mainnet-data:/nodevol alpine chown -R 65532:65532 /nodevol
```

Finally, start the new version of the node with `docker compose up -d`.

### Changed

- updated bitcoin node to `30.0-dless`
- changed dogecoin node to distroless image `1.14.9-dless`
- updated ripple node to `2.6.1-dless`
- updated xrp indexer to `v1.0.4` to fix history drop issue
- added `history_drop_frequency` to xrp indexer config
