# Platform settings for the ASUS ProArt P16 H7607BA (NVIDIA N1x) that the
# generic N1x setup (n1x.sh) does not cover. None of this has been validated on
# Omarchy yet; see each block.

if omarchy-hw-match "H7607BA"; then
  # Haptic click feedback. The touchpad has a haptic actuator with only a
  # manual trigger, so nothing vibrates on a click unless the host plays a
  # waveform. udev starts the package's service when the pad appears.
  omarchy-pkg-add asus-proart-touchpad-haptics

  # Battery charge limit, ASUS fan modes and EC sensors. On BIOS H7607BA.303
  # the ACPI battery and AC adapter work through linux-omarchy's FF-A EC
  # driver, and proart_battery only adds what ACPI lacks; on BIOS .300, whose
  # EC accessors are broken, it provides the battery itself. It decides when it
  # loads. The base install supplies the kernel headers DKMS builds against.
  omarchy-pkg-add asus-proart-p16-ec-dkms

  # SoundWire speaker underruns. Both speaker paths (the woofers on DL0 and the
  # tweeters on DL1) share link 1, and each xrun recovery restarts both with
  # bank switches and a fixed 1 ms sleep, longer than a 256-sample quantum. An
  # application asking for ~6 ms took the graph to 256 samples and the speakers
  # into an xrun loop (crackling, then silence) on Ubuntu. Never go below 1024.
  mkdir -p /etc/pipewire/pipewire.conf.d
  cat >/etc/pipewire/pipewire.conf.d/60-omarchy-asus-proart-p16-min-quantum.conf <<'CONF'
# ASUS ProArt P16: the SoundWire speaker paths underrun below 1024 samples; see
# install/hardware/asus/fix-asus-proart-p16-platform.sh.
context.properties = {
    default.clock.min-quantum = 1024
}
CONF

  # GPU power cap on AC. BIOS H7607BA.300's EC accessors returned the request
  # instead of the answer, so the AC adapter's _PSR always read 0 and the NVIDIA
  # driver held the GPU to its battery power limit on AC too. Tell it to skip
  # the ACPI battery cap there. BIOS .303 fixed those accessors, so _PSR should
  # work and the option is left off until a P16 on .303 shows otherwise
  # (nvidia-smi -q -d POWER on AC). nvidia loads from the initramfs, so the
  # option takes effect once the initramfs is rebuilt.
  bios_version=$(cat /sys/class/dmi/id/bios_version 2>/dev/null || true)
  if [[ $bios_version == "H7607BA.300" ]]; then
    mkdir -p /etc/modprobe.d
    cat >/etc/modprobe.d/omarchy-asus-proart-p16-nvidia.conf <<'CONF'
# ASUS ProArt P16 on BIOS H7607BA.300: _PSR always reads "on battery", so skip
# the ACPI battery power cap; see install/hardware/asus/fix-asus-proart-p16-platform.sh.
options nvidia NVreg_RegistryDwords="RMSkipACPIBattCap=1"
CONF
  fi

  # Not set here, pending a test on the P16: Ubuntu's linux-nvidia needed
  # acpi_osi="!Windows 2022" on this laptop, because the firmware hides the
  # SSPM (NVDA8400) and some NVIDIA platform devices from Windows 2022, and
  # Linux claims to be Windows 2022. linux-omarchy degrades without the SSPM
  # (1097, 1098) and the ProArt P14 does not need it. If USB, I2C or audio are
  # missing on the P16, check `ls /sys/bus/acpi/devices | grep NVDA8400` and
  # add the option with a Limine drop-in:
  #   KERNEL_CMDLINE[default]+=" acpi_osi=!\"Windows 2022\""
  # USB4 likewise stays on n1x.sh's conservative settings until a dock is
  # tested on each of the P16's ports.
fi
