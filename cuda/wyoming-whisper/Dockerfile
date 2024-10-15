# Source: https://github.com/rhasspy/wyoming-addons/pull/4
ARG BASE=debian:bullseye-slim
FROM $BASE

WORKDIR /usr/src
ARG WYOMING_WHISPER_VERSION

# pip3 install --break-system-packages
# --extra-index-url https://www.piwheels.org/simple \
RUN \
    apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        python3 \
        python3-dev \
        python3-pip \
    && pip3 install --no-cache-dir \
        "wyoming-faster-whisper @ https://github.com/rhasspy/wyoming-faster-whisper/archive/refs/tags/v${WYOMING_WHISPER_VERSION}.tar.gz" \
    && apt-get purge -y --auto-remove \
        build-essential \
        python3-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /
COPY run.sh ./

EXPOSE 10300

ENTRYPOINT ["bash", "/run.sh"]
