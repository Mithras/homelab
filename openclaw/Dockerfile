FROM ghcr.io/openclaw/openclaw

USER root

RUN apt-get update && apt-get install -y openssh-client iputils-ping

# Dummy binaries so gateway skill checks pass (real ones live in sandbox)
RUN for bin in gog summarize ffmpeg; do \
    echo '#!/usr/bin/env sh' > /usr/local/bin/$bin && chmod +x /usr/local/bin/$bin; \
    done

USER node
