# Speakers of the ASUS ProArt P16 H7607BA (NVIDIA N1x): a 2-way system.
#
# The Cirrus CS35L56 woofer amplifiers name their DSP firmware and tuning after
# the laptop (subsystem ID 1043:1484), and linux-firmware has none for it, so
# they run their ROM defaults. The firmware package carries ASUS's tuning.
#
# The tweeters are the CS42L43's speaker amplifier, which Omarchy's UCM profile
# for this laptop feeds from the headphone output's SoundWire port. The tweeter
# package mutes them while headphones are plugged in.
#
# Runs before speaker-tuning.sh: the asus-proart-p16-n1x tuning matches only
# once the amplifier tuning is installed.

if omarchy-hw-match "H7607BA"; then
  omarchy-pkg-add asus-proart-p16-speaker-firmware asus-proart-p16-tweeters
fi
