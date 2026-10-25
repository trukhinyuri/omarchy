echo "Give the ASUS ProArt P16 (NVIDIA N1x) speakers ASUS's amplifier tuning, its tweeters and the 2-way tuning"

# See install/hardware/asus/fix-asus-proart-p16-speakers.sh and the
# asus-proart-p16-n1x speaker tuning. The amplifiers load the new tuning at the
# next boot. PipeWire reads the UCM profile, which now routes the tweeters, when
# it opens the card, so restart it before switching the tuning on.
if ! omarchy-hw-match "H7607BA"; then
  exit 0
fi

omarchy-pkg-add asus-proart-p16-speaker-firmware asus-proart-p16-tweeters

# The tweeter service starts with the sound card; start it for this boot too.
sudo systemctl start asus-proart-p16-tweeters.service 2>/dev/null || true

systemctl --user restart wireplumber pipewire pipewire-pulse 2>/dev/null || true

if omarchy-audio-tuning match >/dev/null 2>&1; then
  omarchy-pkg-add lsp-plugins-lv2
  omarchy-audio-tuning on
fi
