echo "Add haptic clicks, the charge limit and fan modes, a SoundWire-safe audio quantum and the BIOS .300 GPU power fix on the ASUS ProArt P16"

# See install/hardware/asus/fix-asus-proart-p16-platform.sh, which sets up new
# installs the same way.
quantum_conf="${OMARCHY_P16_QUANTUM_CONF:-/etc/pipewire/pipewire.conf.d/60-omarchy-asus-proart-p16-min-quantum.conf}"
nvidia_conf="${OMARCHY_P16_NVIDIA_CONF:-/etc/modprobe.d/omarchy-asus-proart-p16-nvidia.conf}"
rebuild_marker="${OMARCHY_LIMINE_REBUILD_MARKER:-/var/lib/omarchy/migrations/1792920271}"

if ! omarchy-hw-match "H7607BA"; then
  exit 0
fi

omarchy-pkg-add asus-proart-touchpad-haptics
# udev starts the haptics service when the pad appears; replay that for this boot.
sudo udevadm trigger --action=add --subsystem-match=hidraw 2>/dev/null || true

# DKMS builds it for the installed kernels; it loads at the next boot.
omarchy-pkg-add asus-proart-p16-ec-dkms

if [[ ! -f $quantum_conf ]]; then
  sudo install -Dm644 /dev/stdin "$quantum_conf" <<'EOF'
# ASUS ProArt P16: the SoundWire speaker paths underrun below 1024 samples; see
# install/hardware/asus/fix-asus-proart-p16-platform.sh.
context.properties = {
    default.clock.min-quantum = 1024
}
EOF
  systemctl --user restart wireplumber pipewire pipewire-pulse 2>/dev/null || true
fi

# Only BIOS H7607BA.300 reports the AC adapter as offline.
if [[ $(cat /sys/class/dmi/id/bios_version 2>/dev/null) != "H7607BA.300" ]]; then
  exit 0
fi

if [[ ! -f $nvidia_conf ]]; then
  sudo install -Dm644 /dev/stdin "$nvidia_conf" <<'EOF'
# ASUS ProArt P16 on BIOS H7607BA.300: _PSR always reads "on battery", so skip
# the ACPI battery power cap; see install/hardware/asus/fix-asus-proart-p16-platform.sh.
options nvidia NVreg_RegistryDwords="RMSkipACPIBattCap=1"
EOF
fi

# nvidia loads from the initramfs. A marker records the machine-wide rebuild:
# another user's run must not repeat it, while a missing marker still retries an
# interrupted rebuild.
[[ ! -e $rebuild_marker ]] || exit 0

sudo limine-mkinitcpio
sudo install -Dm644 /dev/null "$rebuild_marker"
