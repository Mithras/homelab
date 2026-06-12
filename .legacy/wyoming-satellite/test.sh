script/run \
  --uri tcp://0.0.0.0:10700 \
  --mic-command "arecord -D plughw:CARD=USB,DEV=0 -q -r 16000 -c 1 -f S16_LE -t raw" \
  --snd-command "aplay -D default:CARD=USB -q -r 22050 -c 1 -f S16_LE -t raw" \
  --wake-uri tcp://localhost:10400 \
  --wake-word-name ok_nabu \
  --name 'Wyoming Satellite' \
  --debug \
  --debug-recording-dir debug-recording-dir \
  --mic-noise-suppression 1 \
  --mic-auto-gain 5
# --mic-volume-multiplier 2
# --awake-wav sounds/awake.wav \
# --done-wav sounds/done.wav \
# --timer-finished-wav sounds/timer_finished.wav \
# --timer-finished-wav-repeat 3 1 \
