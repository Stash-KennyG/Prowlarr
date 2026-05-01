FROM mcr.microsoft.com/dotnet/sdk:8.0-bookworm-slim AS builder

ARG TARGETARCH

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl gnupg \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" > /etc/apt/sources.list.d/nodesource.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends nodejs \
    && npm install -g yarn \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src

COPY . .

RUN case "${TARGETARCH}" in \
      "amd64") export RID="linux-x64" ;; \
      "arm64") export RID="linux-arm64" ;; \
      *) echo "Unsupported TARGETARCH: ${TARGETARCH}" && exit 1 ;; \
    esac \
    && yarn install --frozen-lockfile --network-timeout 120000 \
    && yarn run build --env production \
    && dotnet msbuild -restore src/Prowlarr.sln -p:SelfContained=True -p:Configuration=Release -p:Platform=Posix -p:RuntimeIdentifiers="${RID}" -p:NuGetAudit=false -p:RunAnalyzers=false -t:PublishAllRids \
    && mkdir -p /out \
    && cp -a "_output/net8.0/${RID}/publish/." /out/ \
    && mkdir -p /out/Prowlarr.Update \
    && cp -a "_output/Prowlarr.Update/net8.0/${RID}/publish/." /out/Prowlarr.Update/ \
    && cp -a "_output/UI" /out/UI \
    && cp -a "LICENSE" /out/LICENSE

FROM debian:bookworm-slim AS runtime

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates tzdata libsqlite3-0 libicu72 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /out/ /app/

RUN chmod +x /app/Prowlarr

EXPOSE 9696
VOLUME ["/config"]

ENTRYPOINT ["/app/Prowlarr", "-nobrowser", "-data=/config"]
