# FDC suite deployment

## Overview

This repository contains docker-compose files and configuration files for verifiers and blockchain nodes that are required to run a FDC client.

Bitcoin, Dogecoin and Ripple use an indexer that creates a local database with data from the blockchain. This is then exposed via api by verifier api server.

EVM based chains (Ethereum, Flare, Songbird) use a verifier api server that directly queries the rpc node.

- Blockchain nodes:
    - Bitcoin - [flarefoundation/bitcoin](https://hub.docker.com/r/flarefoundation/bitcoin)
    - Dogecoin - [flarefoundation/dogecoin](https://hub.docker.com/r/flarefoundation/dogecoin)
    - Ripple - [flare-foundation/connected-chains-docker/rippled](https://github.com/flare-foundation/connected-chains-docker/pkgs/container/connected-chains-docker%2Frippled)
    - Ethereum - [ethereum/client-go](https://hub.docker.com/r/ethereum/client-go) and [prysm](https://docs.prylabs.network/docs/install/install-with-docker)

- Indexers and verification servers for:
    - BTC - [flare-foundation/verifier-utxo-indexer](https://github.com/flare-foundation/verifier-utxo-indexer) and [flare-foundation/verifier-indexer-api](https://github.com/flare-foundation/verifier-indexer-api)
    - DOGE - [flare-foundation/verifier-utxo-indexer](https://github.com/flare-foundation/verifier-utxo-indexer) and [flare-foundation/verifier-indexer-api](https://github.com/flare-foundation/verifier-indexer-api)
    - XRP - [flare-foundation/verifier-xrp-indexer](https://github.com/flare-foundation/verifier-xrp-indexer) and [flare-foundation/verifier-indexer-api](https://github.com/flare-foundation/verifier-indexer-api)

- EVM verifier - [flare-foundation/evm-verifier](https://github.com/flare-foundation/evm-verifier)

- Web2 verifier [flare-foundation/verifier-indexer-api](https://github.com/flare-foundation/verifier-indexer-api)

EVM verifier also requires FLR and SGB nodes, which are not part of this repository.

The components listed here are all required to run a full FDC suite, but they are not required to be deployed from this repository. For example, if you already have a compatible Bitcoin rpc node, you can configure this repo to run everything else except for BTC node.

This repository can also be used multiple times to split this deployment across multiple servers.

## Hardware Requirements

The minimal hardware requirements for a complete `testnet` configuration are:

- CPU: 8 cores @ 2.2GHz
- DISK: 100 GB SSD disk
- MEMORY: 8 GB

The minimal hardware requirements for a complete `mainnet` configuration are:

- CPU: 16/32 cores/threads @ 2.2GHz
- DISK: 4 TB NVMe disk
- MEMORY: 64 GB

If you don't want to deploy everything on a single server, separate components can be deployed on different servers. In that case the requirements for a single server can be lower.

### Web2 Verifier

It is strongly recommended to deploy the Web2 verifier to a standalone server as under heavy load it might impact the performance of other components. Hardware recommendations:

- CPU: 4 cores @ 2.2GHz
- DISK: n/a
- MEMORY: 8 GB

Alternatively, it could be run on the same machine with resource restrictions added to the Docker container:
```yaml
services:
  verifier_web2:
    ...
    cpus: 4 # Should be less than 50% of available cpus
    mem_limit: 2048m
    ...
```

## Software Requirements

FDC suite deploy was tested on Debian 12 and Ubuntu 22.04.

Additional required software:

- *Docker* version 24.0.0 or higher
- *Docker Compose* version 2.18.0 or higher

## Prerequisites

- A machine(s) with `docker` and `docker compose` installed.
- A deployment user in the `docker` group.
- The Docker folder set to a mount point that has sufficient disk space for Docker volumes. The installation creates several Docker volumes.

## Step 1 Clone deployment Repository

``` bash
git clone https://github.com/flare-foundation/fdc-suite-deployment.git
cd fdc-suite-deployment

```

### 1.1 (Optional) Build docker images

Docker images are automatically built and published to github container registry. By default the deployment will download the images automatically. If you need to build them manually clone the required git repository (linked in the overview of this readme), and run:

``` bash
docker build -t <image-tag> .
```

replace image tag with the tag that is used in `docker-compose.yaml` files that use this image or modify docker-compose files to use your image tag.

## Step 2: Configuration

### 2.1 Configuring blockchain nodes

#### BTC

The only required configuration is setting the authentication for the node. To generate a password for admin user run:
``` bash
cd nodes-mainnet/btc
./generate-password.sh
```
example output:
```
password: c021cae645db6d3371b26ced94c8d17a5d9f3accbf3591d8b4c0be19623e5662
String to be appended to bitcoin.conf:
rpcauth=admin:a0956d81a2344f1602d9ed7b82ef3118$2caf19c9cf27937f728f600fc14e8db97f80218d727e331a57c3cfc55b3e17fe
Your password:
c021cae645db6d3371b26ced94c8d17a5d9f3accbf3591d8b4c0be19623e5662
```

or configure the username and password manually:

``` bash
./rpcauth.py <USERNAME> <PASSWORD>
```

#### DOGE

Configuration works like BTC.

For example, to generate a password for admin user run:
``` bash
cd nodes-mainnet/doge
./generate-password.sh
```

#### XRP

Default configuration doesn't need any additional configuration.

#### ETH

Configure file `nodes-mainnet/eth/jwt.hex` for authentication. To generate the password randomly run:
``` bash
openssl rand -hex 32 > nodes-mainnet/eth/jwt.hex
```

Blockchain nodes expose all ports by default.

### 2.2 Simple configuration for indexers and verifiers

Files `.env.example` and `generate-config.sh` files in the root of this repository are used to configure indexers and verifiers. They don't configure anything related to blockchain nodes.

For a simple configuration of verifiers the only file that needs to be edited is `.env` file in the root of this repository. Copy `.env.example` file to `.env` and edit it.

Inside this file:

For RPC nodes, fill in the authentication data you created in the previous step. If you run blockchain nodes and verifiers on the same server, you can use the ip `172.17.0.1` to reach the nodes.

Indexers will start indexing the blockchain with the block number configured in `*_START_BLOCK_NUMBER` variables. This needs to be set the first time when you start the indexers to avoid indexing too much data. FDC requires at least 14 days of history, so pick a block number that was finalized 14 days ago. On later restarts indexers will start indexing from the latest block in the database.

Set `TESTNET` to `true` if you are running verifiers for testnets.

Set `VERIFIER_API_KEYS` to api keys that will have access to verifier api servers. One or more comma separated keys can be configured. You will likely need at least one key for FDC client that will call verifier api servers.

`*_DB_PASSWORD` variables are used internally for the indexer database. If you don't know why you probably don't need to access the database, so set those passwords to a random string.

### 2.3 Generating configs for indexers and verifiers

from the root of this repo, run `./generate-config.sh`

This script uses the values from `.env` and generates config files from `*.example` files in directories:

- verifiers/btc/
- verifiers/doge/
- verifiers/xrp/
- evm-verifier/
- web2-verifier/

## Step 3: Running

### 3.1 Starting blockchain nodes

cd into correct directory (example `nodes-mainnet/btc`) and run `docker compose up -d`.

Do this for all blockchain nodes you plan to run on the current server.

### 3.2 Starting indexers and verifiers

cd into correct directory (example `verifiers/btc`) and run `docker compose up -d`.

Do this for all verifiers you plan to run on the current server.

## Step 4: Updates

Before updating to a new version of this repository always read the [release notes](./RELEASES.md).

If the release version you are updating to has no specific instructions, you can update the deployment by doing:

- checkout the new version of this repository
- generate new configs by running `./generate-config.sh` in the root of this repo
- pull and start updated containers by running `docker compose up -d` for every component
