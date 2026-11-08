FROM python

RUN python3 -m ensurepip && pip install --no-cache-dir uv

RUN uv pip install -U llama-benchy --system

ARG USER=llama-benchy
ARG UID=1000
ARG GID=${UID}
RUN groupadd -g ${GID} ${USER} \
    && useradd  -u ${UID} -g $GID -m ${USER}

USER $USER

WORKDIR /home/llama-benchy

RUN mkdir .cache

ENTRYPOINT ["llama-benchy"]
