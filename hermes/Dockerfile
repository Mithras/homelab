FROM nousresearch/hermes-agent

# Install openssh-server
RUN apt-get update \ 
    && apt-get install -y --no-install-recommends openssh-server

# Install firecrawl-py and hermes-lcm + optional deps
RUN chmod -R u+w /opt/hermes && \
    FC_VERSION=$(python3 -c "from tools.lazy_deps import LAZY_DEPS; print(LAZY_DEPS['search.firecrawl'][0].split('==')[1])") && \
    uv pip install "firecrawl-py==$FC_VERSION" tiktoken regex && \
    git clone https://github.com/stephenschoettler/hermes-lcm /opt/hermes/plugins/hermes-lcm && \
    chmod -R a-w /opt/hermes
    
# Install byterover
RUN npm install -g byterover-cli

# Override sshd config
RUN cat > /etc/ssh/sshd_config <<EOF
PubkeyAuthentication yes
PasswordAuthentication no
PermitRootLogin no
AuthorizedKeysFile .ssh/authorized_keys
AllowUsers hermes
EOF

# Register sshd as s6-overlay service
RUN mkdir -p /etc/s6-overlay/s6-rc.d/sshd && \
echo "longrun" > /etc/s6-overlay/s6-rc.d/sshd/type && \
printf '#!/command/with-contenv sh\nexec /usr/sbin/sshd -D\n' > /etc/s6-overlay/s6-rc.d/sshd/run && \
chmod +x /etc/s6-overlay/s6-rc.d/sshd/run && \
ln -s /etc/s6-overlay/s6-rc.d/sshd /etc/s6-overlay/s6-rc.d/user/contents.d/sshd

# Allow hermes pubkey authentication
RUN usermod -p '*' hermes

# Setup hermes-ssh
COPY hermes-ssh.sh /usr/local/bin/hermes-ssh
RUN chmod +x /usr/local/bin/hermes-ssh
