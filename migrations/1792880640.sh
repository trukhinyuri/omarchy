echo "Give the ASUS ProArt P16 the ProArt P14's USB4 settings so a dock's Ethernet appears"

# See install/hardware/n1x.sh: the P16 has the P14's three USB4 host routers and
# three 10de:22cf tunnel root ports. Until now it got the other N1x laptops'
# bus numbers (from n1x.sh or 1790984600) and no root-port rule.
limine_conf_dir="${OMARCHY_LIMINE_ENTRY_TOOL_DIR:-/etc/limine-entry-tool.d}"
dropin="$limine_conf_dir/00-omarchy-n1x-usb4.conf"
rules="${OMARCHY_N1X_USB4_ROOT_PORT_RULES:-/etc/udev/rules.d/71-omarchy-n1x-usb4-root-ports.rules}"
pci_devices="${OMARCHY_PCI_DEVICES_PATH:-/sys/bus/pci/devices}"
rebuild_marker="${OMARCHY_LIMINE_REBUILD_MARKER:-/var/lib/omarchy/migrations/1792880640}"
generic='KERNEL_CMDLINE[default]+=" power_wrap_drv.usb4_release=0 pci=hpbussize=0x20"'
proart='KERNEL_CMDLINE[default]+=" power_wrap_drv.usb4_release=0 pci=hpbussize=0x80,hpmmiosize=32M,hpmmioprefsize=32G"'

if ! omarchy-hw-aarch64-n1x || ! omarchy-hw-match "H7607BA"; then
  exit 0
fi

if [[ ! -f $rules ]]; then
  sudo install -Dm644 /dev/stdin "$rules" <<'EOF'
# N1x: the USB4 tunnel root ports cannot wake for a hotplug, so keep them out of
# runtime suspend; see install/hardware/n1x.sh.
ACTION=="add|bind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{device}=="0x22cf", ATTR{power/control}="on"
EOF
fi

# udev only applies the rule to new events, so replay one for any port that is
# still allowed to suspend. Once they are all on, another user's run is a no-op.
for port in "$pci_devices"/*; do
  [[ $(cat "$port/vendor" 2>/dev/null) == "0x10de" && $(cat "$port/device" 2>/dev/null) == "0x22cf" ]] || continue
  [[ $(cat "$port/power/control" 2>/dev/null) != "on" ]] || continue
  sudo udevadm control --reload
  sudo udevadm trigger --action=add --subsystem-match=pci --attr-match=vendor=0x10de --attr-match=device=0x22cf
  break
done

# Rewrite the drop-in only while it holds the generic line Omarchy wrote, or
# when there is none; any other USB4 drop-in is the administrator's choice, so
# leave it and the boot image alone.
if [[ ! -f $dropin ]] || grep -qxF "$generic" "$dropin"; then
  sudo install -Dm644 /dev/stdin "$dropin" <<'EOF'
# N1x: keep the USB4 host routers powered and leave room for docks behind them;
# see install/hardware/n1x.sh.
KERNEL_CMDLINE[default]+=" power_wrap_drv.usb4_release=0 pci=hpbussize=0x80,hpmmiosize=32M,hpmmioprefsize=32G"
EOF
elif ! grep -qxF "$proart" "$dropin"; then
  exit 0
fi

# The bus numbers and windows are kernel parameters, so rebuild once. A marker
# records it: another user's run must not repeat it, while a missing marker
# still retries an interrupted rebuild.
[[ ! -e $rebuild_marker ]] || exit 0

sudo limine-mkinitcpio
sudo install -Dm644 /dev/null "$rebuild_marker"
