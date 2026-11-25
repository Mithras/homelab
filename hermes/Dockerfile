FROM docker.io/nousresearch/hermes-agent

# Install openssh-server, socat
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    openssh-server socat \
    libportaudio2 libasound2-plugins alsa-utils pulseaudio-utils

# Install hermes-lcm
RUN chmod -R u+w /opt/hermes \
    && git clone https://github.com/stephenschoettler/hermes-lcm /opt/hermes/plugins/hermes-lcm \ 
    && chmod -R a-w /opt/hermes

# Install firecrawl and voice
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv
RUN chmod -R u+w /opt/hermes \
    && uv sync --directory /opt/hermes --frozen --inexact --extra acp --extra firecrawl --extra audio-io --extra wake-openwakeword \
    && chmod -R a-w /opt/hermes \
    && rm /usr/local/bin/uv
# /opt/hermes/.venv/bin/python -c 'import firecrawl; print(firecrawl.__version__)'

# Install mcp-excalidraw-server
RUN npm install -g --prefix /usr/local mcp-excalidraw-server \
    && test -x /usr/local/bin/mcp-excalidraw-server

# Install Home Assistant plugin
RUN chmod -R u+w /opt/hermes \
    && git clone https://github.com/NousResearch/hermes-official-plugins /tmp/hermes-official-plugins \
    && mkdir -p /opt/hermes/plugins/platforms \
    && cp -a /tmp/hermes-official-plugins/homeassistant /opt/hermes/plugins/platforms/homeassistant \
    && rm -rf /tmp/hermes-official-plugins \
    && chmod -R a-w /opt/hermes

# Override sshd config
RUN { echo 'PubkeyAuthentication yes'; \
      echo 'PasswordAuthentication no'; \
      echo 'PermitRootLogin no'; \
      echo 'HostKey /etc/ssh/host_keys/ssh_host_ed25519_key'; \
      echo 'HostKey /etc/ssh/host_keys/ssh_host_ecdsa_key'; \
      echo 'HostKey /etc/ssh/host_keys/ssh_host_rsa_key'; \
      echo 'AuthorizedKeysFile /etc/ssh/authorized_keys'; \
      echo 'AllowUsers hermes'; \
    } > /etc/ssh/sshd_config \
    && mkdir -p /run/sshd

# Register s6-overlay services
COPY s6/sshd /etc/s6-overlay/s6-rc.d/sshd
COPY s6/socat-cdp /etc/s6-overlay/s6-rc.d/socat-cdp
COPY s6/acp-sock /etc/s6-overlay/s6-rc.d/acp-sock
RUN touch /etc/s6-overlay/s6-rc.d/user/contents.d/sshd \
    /etc/s6-overlay/s6-rc.d/user/contents.d/socat-cdp \
    /etc/s6-overlay/s6-rc.d/user/contents.d/acp-sock

# Allow hermes pubkey authentication
RUN usermod -p '*' hermes

# Setup hermes-ssh
COPY hermes-ssh.sh /usr/local/bin/hermes-ssh
RUN chmod +x /usr/local/bin/hermes-ssh
