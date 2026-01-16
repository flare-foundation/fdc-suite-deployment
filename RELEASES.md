# Release Notes

Important changes and upgrade notes will be listed in this file. Always read this file before updating to a new version of this deployment repo.

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

