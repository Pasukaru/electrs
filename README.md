# pasukaru/electrs

Docker image for [romanz/electrs](https://github.com/romanz/electrs), an efficient Electrum server implementation in Rust.

Images are built and pushed to [ghcr.io/pasukaru/electrs](https://ghcr.io/pasukaru/electrs) via the [release workflow](.github/workflows/release.yml) on every version tag. Multi-arch images are available for `linux/amd64` and `linux/arm64`.

## Quick start

```sh
docker pull ghcr.io/pasukaru/electrs:latest
```

Tags follow upstream electrs versioning (e.g. `v0.11.1`). 

## Configuration

Refer to the [upstream configuration docs](https://github.com/romanz/electrs/blob/master/doc/config.md). 
Mount a volume at `/data` to persist the index that electrs maintains internally.
The container runs as user `electrs` (uid `1000`). If you pre-create the host directory, make sure it is owned by uid `1000`.

## Ports

| Port | Protocol |
|---|---|
| `50001` | Electrum RPC |
| `4224` | Prometheus metrics |

## Example

See [example/docker-compose.yml](example/docker-compose.yml) for a full setup with Bitcoin Core and electrs.

Bitcoin Core will start IBD and store chain data in `example/data/bitcoin-core/`. 
This will take significant time and disk space - you don't have to wait for it to complete to see if electrs works.
Check the electrs logs with `docker logs -f electrs`.

> **arm64:** The Bitcoin Core image referenced in the example does not include an arm64 build. On arm64, either build your own Bitcoin Core image, find one that supports arm64, or add `platform: linux/amd64` to the `bitcoin-core` service to run it under emulation (not recommended long-term).
