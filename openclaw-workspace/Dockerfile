# Stage 1: Build gog binaries
FROM golang:alpine AS build

RUN apk add --no-cache ca-certificates git curl jq bash

RUN GOG_VERSION=$(curl -fsSL https://api.github.com/repos/openclaw/gogcli/releases/latest \
      | jq -r '.tag_name') && \
    git clone --depth 1 --branch "$GOG_VERSION" https://github.com/openclaw/gogcli.git /src

WORKDIR /src

RUN go build -o /out/gog-full ./cmd/gog && \
    ./build-safe.sh safety-profiles/agent-safe.yaml -o /out/gog-agent

# Stage 2: Final image with agent-safe gog binary
FROM lscr.io/linuxserver/openssh-server AS agent

RUN apk add --no-cache \
    ca-certificates tzdata curl git jq python3 ripgrep ffmpeg nodejs npm

RUN npm i -g @steipete/summarize firecrawl-cli

COPY --from=build /out/gog-agent /usr/local/bin/gog

# Stage 3: Final image with full gog binary
FROM lscr.io/linuxserver/openssh-server AS full

RUN apk add --no-cache \
    ca-certificates tzdata curl git jq python3 ripgrep ffmpeg nodejs npm

RUN npm i -g @steipete/summarize firecrawl-cli

COPY --from=build /out/gog-full /usr/local/bin/gog
