FROM ghcr.io/sparfenyuk/mcp-proxy:latest

# Install the 'uv' package
RUN python3 -m ensurepip && pip install --no-cache-dir uv

# Install nodejs and npm
RUN apk add --update nodejs npm

ENV PATH="/usr/local/bin:$PATH" \
    UV_PYTHON_PREFERENCE=only-system

ENTRYPOINT [ "mcp-proxy" ]
