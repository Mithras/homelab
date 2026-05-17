FROM ghcr.io/openclaw/openclaw

USER root

RUN apt-get update && apt-get install -y openssh-client ffmpeg yt-dlp tesseract-ocr iputils-ping jq

RUN npm i -g @steipete/summarize

USER node
