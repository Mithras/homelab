FROM nousresearch/hermes-agent

# RUN apt-get update \
#     && apt-get install -y --no-install-recommends XXX

# Install firecrawl-py and hermes-lcm + optional deps
RUN chmod -R u+w /opt/hermes && \
    FC_VERSION=$(python3 -c "from tools.lazy_deps import LAZY_DEPS; print(LAZY_DEPS['search.firecrawl'][0].split('==')[1])") && \
    uv pip install "firecrawl-py==$FC_VERSION" tiktoken regex && \
    git clone https://github.com/stephenschoettler/hermes-lcm /opt/hermes/plugins/hermes-lcm && \
    chmod -R a-w /opt/hermes

# Install byterover
RUN npm install -g byterover-cli
