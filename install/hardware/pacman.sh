# Hardware-specific pacman repository extensions that must survive the final
# pacman.conf restore.
if lspci -nn | grep "106b:180[12]" >/dev/null; then
  if ! grep -q '^\[arch-mact2\]' /etc/pacman.conf; then
    cat >> /etc/pacman.conf <<'EOF'

[arch-mact2]
Server = https://github.com/NoaHimesaka1873/arch-mact2-mirror/releases/download/release
SigLevel = Never
EOF
  fi
fi

# ASUS ProArt P16 H7607BA: until upstream carries this laptop's changes, it runs
# builds of linux-omarchy and omarchy-dev (with their headers and settings
# packages) made from forks that do. Hold them, so neither an upgrade to a newer
# upstream build nor omarchy-refresh-pacman's -Syyuu, which downgrades to the
# repository's version, replaces them. Only in a channel configuration: while
# the installer's offline one is in place (all.sh runs this too), the install's
# own transactions must get whatever they ask for. omarchy-refresh-pacman
# rewrites this file, so a pre-refresh-pacman hook puts the hold back
# (install/user/hardware/asus/hold-asus-proart-p16-fork-builds.sh). Temporary:
# drop both once upstream ships these changes.
if omarchy-hw-match "H7607BA" && grep -q '^Server = https://pkgs\.omarchy\.' /etc/pacman.conf; then
  p16_hold='IgnorePkg = linux-omarchy linux-omarchy-headers omarchy-dev omarchy-settings-dev'
  if ! grep -qxF "$p16_hold" /etc/pacman.conf; then
    sed -i "/^\[options\]/a $p16_hold" /etc/pacman.conf
  fi
fi
