FROM docker.io/nousresearch/hermes-agent

# Install openssh-server, socat
RUN apt-get update \ 
    && apt-get install -y --no-install-recommends openssh-server socat

# Install hermes-lcm
RUN chmod -R u+w /opt/hermes \
    && git clone https://github.com/stephenschoettler/hermes-lcm /opt/hermes/plugins/hermes-lcm \ 
    && chmod -R a-w /opt/hermes

# Install firecrawl-py + optional deps
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv
RUN chmod -R u+w /opt/hermes \
    && uv sync --directory /opt/hermes --frozen --inexact --extra firecrawl \
    && chmod -R a-w /opt/hermes \
    && rm /usr/local/bin/uv
# /opt/hermes/.venv/bin/python -c 'import firecrawl; print(firecrawl.__version__)'

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
RUN touch /etc/s6-overlay/s6-rc.d/sshd /etc/s6-overlay/s6-rc.d/user/contents.d/sshd \
    /etc/s6-overlay/s6-rc.d/user/contents.d/socat-cdp

# Allow hermes pubkey authentication
RUN usermod -p '*' hermes

# Setup hermes-ssh
COPY hermes-ssh.sh /usr/local/bin/hermes-ssh
RUN chmod +x /usr/local/bin/hermes-ssh
