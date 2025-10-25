FROM python:slim

# RUN apt-get update && apt-get install -y --no-install-recommends \

RUN python3 -m ensurepip && pip install --no-cache-dir uv

ARG USER=mcp
ARG UID=1000
ARG GID=${UID}
RUN groupadd -g ${GID} ${USER} \
    && useradd  -u ${UID} -g $GID -m ${USER}

ENV PATH="/usr/local/bin:$PATH" \
    UV_PYTHON_PREFERENCE=only-system \
    UV_CACHE_DIR=/home/mcp/.cache

USER $USER

WORKDIR /home/mcp

ENTRYPOINT ["uvx"]
