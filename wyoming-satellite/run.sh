#!/bin/bash

# git clone https://github.com/piitaya/wyoming-porcupine3
# cd wyoming-porcupine3
# script/setup

# sudo cp wyoming-porcupine3.service /etc/systemd/system/wyoming-porcupine3.service
# sudo systemctl daemon-reload
# sudo systemctl enable --now wyoming-porcupine3.service
# sudo systemctl restart wyoming-porcupine3.service
# systemctl status wyoming-porcupine3.service

source .env

pushd wyoming-porcupine3
script/run \
    --uri 'tcp://0.0.0.0:10400' \
    --system 'raspberry-pi' \
    --access-key="$ACCESS_KEY" \
    --custom-wake-words-dir='custom_wake_words' \
    --sensitivity 0.55
    --debug
popd
