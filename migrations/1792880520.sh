echo "Give the ASUS ProArt P16 (NVIDIA N1x) speakers ASUS's amplifier tuning"

# See install/hardware/asus/fix-asus-proart-p16-speakers.sh. The amplifiers load
# the tuning at the next boot.
if ! omarchy-hw-match "H7607BA"; then
  exit 0
fi

omarchy-pkg-add asus-proart-p16-speaker-firmware
