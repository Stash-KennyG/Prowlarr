# GHCR Container Publishing

This repository publishes source-built images to:

- `ghcr.io/stash-kennyg/prowlarr`

## Tag behavior

- Push to `develop` publishes:
  - `ghcr.io/stash-kennyg/prowlarr:latest`
  - `ghcr.io/stash-kennyg/prowlarr:develop`
  - `ghcr.io/stash-kennyg/prowlarr:sha-<short>`
- Push a version tag like `v1.0.1` publishes:
  - `ghcr.io/stash-kennyg/prowlarr:1.0.1`
  - `ghcr.io/stash-kennyg/prowlarr:1.0`
  - `ghcr.io/stash-kennyg/prowlarr:1`

## Pull examples

```bash
docker pull ghcr.io/stash-kennyg/prowlarr
docker pull ghcr.io/stash-kennyg/prowlarr:latest
docker pull ghcr.io/stash-kennyg/prowlarr:1.0.1
```

## Run example

```bash
docker run -d \
  --name=prowlarr \
  -p 9696:9696 \
  -v /path/to/prowlarr/data:/config \
  --restart unless-stopped \
  ghcr.io/stash-kennyg/prowlarr:latest
```

The container stores configuration and data in `/config`.
