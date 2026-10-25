# ASUS ProArt P16 H7607BA: omarchy refresh pacman rewrites /etc/pacman.conf from
# the channel template and then runs pacman -Syyuu, which would drop the hold
# install/hardware/pacman.sh puts on this laptop's fork builds and downgrade
# them. Its pre-refresh-pacman hook runs in between, so give this user one that
# puts the hold back.

if omarchy-hw-match "H7607BA"; then
  omarchy-hook-install pre-refresh-pacman \
    "$OMARCHY_PATH/default/omarchy/hooks/pre-refresh-pacman.d/hold-asus-proart-p16-fork-builds"
fi
