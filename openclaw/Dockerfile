FROM ghcr.io/openclaw/openclaw

USER root

RUN apt-get update && apt-get install -y openssh-client

# RUN npm install -g @tobilu/qmd
# ENV PATH=$PATH:/opt/openclaw-plugins/node_modules/@tobilu/qmd/bin
# RUN npm install -g github:Martian-Engineering/lossless-claw --ignore-scripts

USER node
