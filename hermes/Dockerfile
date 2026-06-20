FROM nousresearch/hermes-agent

# Install firecrawl-py
RUN chmod -R u+w /opt/hermes && \
    FC_VERSION=$(python3 -c "from tools.lazy_deps import LAZY_DEPS; print(LAZY_DEPS['search.firecrawl'][0].split('==')[1])") && \
    uv pip install "firecrawl-py==$FC_VERSION" && \
    chmod -R a-w /opt/hermes

# RUN apt-get update \
#     && apt-get install -y --no-install-recommends XXX
