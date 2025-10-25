FROM node:slim

# RUN apt-get update && apt-get install -y --no-install-recommends \

ARG UID=1000
ARG GID=${UID}
RUN groupmod -g ${GID} node
RUN usermod -u ${UID} -g ${GID} node

USER node

WORKDIR /home/node

ENTRYPOINT ["npx", "-y"]
