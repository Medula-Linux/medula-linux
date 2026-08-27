#!/bin/bash
set -e

echo "=== Medula Linux Build Script ==="

# --- Fix 1: isolinux symlinks (Debian usa rutas distintas a Ubuntu) ---
sudo ln -sf /usr/lib/ISOLINUX/isolinux.bin /usr/share/live/build/bootloaders/isolinux/isolinux.bin
sudo ln -sf /usr/lib/syslinux/modules/bios/vesamenu.c32 /usr/share/live/build/bootloaders/isolinux/vesamenu.c32
sudo ln -sf /usr/lib/syslinux/modules/bios/ldlinux.c32 /usr/share/live/build/bootloaders/isolinux/ldlinux.c32
sudo ln -sf /usr/lib/syslinux/modules/bios/libcom32.c32 /usr/share/live/build/bootloaders/isolinux/libcom32.c32
sudo ln -sf /usr/lib/syslinux/modules/bios/libutil.c32 /usr/share/live/build/bootloaders/isolinux/libutil.c32
sudo ln -sf /usr/lib/syslinux/modules/bios/menu.c32 /usr/share/live/build/bootloaders/isolinux/menu.c32

# --- Fix 2: rsvg wrapper (rsvg-convert moderno necesita -o, rsvg viejo no) ---
if [ ! -x /usr/bin/rsvg ] || file /usr/bin/rsvg | grep -q ELF; then
  sudo tee /usr/bin/rsvg > /dev/null << 'EOF'
#!/bin/bash
args=("$@")
last=$((${#args[@]}-1))
output="${args[$last]}"
unset "args[$last]"
rsvg-convert "${args[@]}" -o "$output"
EOF
  sudo chmod +x /usr/bin/rsvg
fi

# --- Fix 3: patch live-build Contents-*.gz URL (falta /main/) ---
sudo sed -i 's|dists/\${LB_PARENT_DISTRIBUTION}/Contents|dists/\${LB_PARENT_DISTRIBUTION}/main/Contents|' /usr/lib/live/build/lb_chroot_linux-image 2>/dev/null || true
sudo sed -i 's|dists/\${LB_DISTRIBUTION}/Contents|dists/\${LB_DISTRIBUTION}/main/Contents|' /usr/lib/live/build/lb_chroot_linux-image 2>/dev/null || true
sudo sed -i 's|dists/\${LB_PARENT_DISTRIBUTION}/Contents|dists/\${LB_PARENT_DISTRIBUTION}/main/Contents|' /usr/lib/live/build/lb_binary_debian-installer 2>/dev/null || true
sudo sed -i 's|dists/\${LB_DISTRIBUTION}/Contents|dists/\${LB_DISTRIBUTION}/main/Contents|' /usr/lib/live/build/lb_binary_debian-installer 2>/dev/null || true

# --- Fix 4: disable broken gfxboot bootlogo hack (lines 364-376 of lb_binary_syslinux) ---
sudo sed -i '364,376s/^\([^#]\)/#\1/' /usr/lib/live/build/lb_binary_syslinux 2>/dev/null || true

echo "=== Fixes applied. Configuring build... ==="

cd ~/medula-linux

lb config \
  --mode debian \
  --distribution bookworm \
  --archive-areas "main contrib non-free non-free-firmware" \
  --binary-images iso \
  --debian-installer false \
  --mirror-bootstrap http://deb.debian.org/debian/ \
  --mirror-binary http://deb.debian.org/debian/ \
  --mirror-chroot http://deb.debian.org/debian/ \
  --security false \
  --memtest none \
  --bootloader syslinux

echo "=== Building ISO (this takes a while)... ==="
sudo lb build

echo "=== Done. Checking for ISO... ==="
ls -lh binary.iso 2>/dev/null && echo "SUCCESS: binary.iso created" || echo "FAILED: no ISO produced"
