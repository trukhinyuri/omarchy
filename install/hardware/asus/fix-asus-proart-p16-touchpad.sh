# Touchpad quirk for the ASUS ProArt P16 H7607BA (NVIDIA N1x, PixArt 093A:4F01
# haptic touchpad on i2c-hid).
#
# Like the ProArt P14's 093A:4F02, the pad reports ABS_MT_PRESSURE as force on a
# 0-65535 logical range that libinput's default pressure thresholds never reach.
# Mark it a pressure pad so libinput ignores the pressure axis. Matched on the
# model number: "ProArt P16" alone would also match the x86 H7606 models.
#
# libinput reads only local-overrides.quirks from /etc/libinput, so append a
# section there instead of writing a file of our own.

if omarchy-hw-match "H7607BA"; then
  quirks=/etc/libinput/local-overrides.quirks

  if ! grep -qxF '[ASUS ProArt P16 Touchpad]' "$quirks" 2>/dev/null; then
    mkdir -p /etc/libinput
    cat >>"$quirks" <<'EOF'

[ASUS ProArt P16 Touchpad]
MatchBus=i2c
MatchUdevType=touchpad
MatchVendor=0x093A
MatchProduct=0x4F01
MatchDMIModalias=dmi:*svnASUS*:pn*H7607BA*
AttrInputProp=+INPUT_PROP_PRESSUREPAD
EOF
  fi
fi
