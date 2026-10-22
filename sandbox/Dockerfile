FROM ubuntu

RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-server bash git python3 python3-pip python3-venv nodejs npm \
    curl jq ripgrep unzip procps ca-certificates tzdata rsync \
    tmux xz-utils socat ffmpeg

RUN groupadd -g 10000 hermes \
    && useradd -u 10000 -g 10000 -d /home/hermes -m -s /bin/bash hermes \
    && ln -s /opt/data /home/hermes/.hermes

COPY --chmod=644 sshd_config /etc/ssh/sshd_config

EXPOSE 2222

USER hermes

# Shared venv + youtube-transcript-api (youtube-content skill)
RUN python3 -m venv --system-site-packages /home/hermes/.venv \
    && /home/hermes/.venv/bin/pip install --no-cache-dir \
    youtube-transcript-api

ENTRYPOINT ["/usr/sbin/sshd", "-D", "-e"]
