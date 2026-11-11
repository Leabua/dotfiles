# NixOS → Arch (no USB)

Boot the Arch ISO straight from the HDD, wipe the SSD, install Arch.

- ISO: `/mnt/hdd/archlinux-2026.11.01-x86_64.iso`
- HDD UUID: `4fc12482-bbb3-4ced-a896-2b5f560c9f6b`
- Bootloader: systemd-boot (UEFI)

| Drive | Looks like | Action |
|---|---|---|
| SSD | ~100 GB, partitions `boot`, `swap`, `nixos` | **WIPE** |
| HDD | ~900 GB, one ext4 partition, holds the ISO and backups | **NEVER TOUCH** |

## Phase 1: Prep in NixOS

About 2 minutes. Nothing gets deleted.

- [ ] Push dotfiles and copy anything you need from the SSD to the HDD.
  ```sh
  cd ~/dotfiles && git push
  rsync -a ~/ /mnt/hdd/home-backup/
  ```
- [ ] Copy the ISO's kernel and initramfs to the boot partition.
  ```sh
  sudo mkdir -p /mnt/iso /boot/archiso
  sudo mount -o loop,ro /mnt/hdd/archlinux-2026.11.01-x86_64.iso /mnt/iso
  sudo cp /mnt/iso/arch/boot/x86_64/{vmlinuz-linux,initramfs-linux.img} /boot/archiso/
  sudo umount /mnt/iso
  ```
- [ ] Add the boot menu entry.
  ```sh
  sudo tee /boot/loader/entries/archiso.conf <<'EOF'
  title   Arch Linux ISO
  linux   /archiso/vmlinuz-linux
  initrd  /archiso/initramfs-linux.img
  options img_dev=/dev/disk/by-uuid/4fc12482-bbb3-4ced-a896-2b5f560c9f6b img_loop=/archlinux-2026.11.01-x86_64.iso
  EOF
  ```
- [ ] Check the entry is listed, then reboot.
  ```sh
  bootctl list | grep -A3 "Arch Linux ISO"
  reboot
  ```

## Phase 2: Boot the live ISO

- [ ] In the boot menu, pick **Arch Linux ISO**. You land in the same root shell a USB would give you.
  > If it fails to boot, reboot and pick NixOS. Nothing has changed yet.
- [ ] Connect to Wi-Fi. The device is usually `wlan0`; `device list` shows the real name.
  ```sh
  iwctl device list
  iwctl station wlan0 scan
  iwctl station wlan0 connect "YourNetwork"
  ping -c 3 archlinux.org
  ```
- [ ] Identify the drives **by size**. `sda` and `sdb` can swap names between boots.
  ```sh
  lsblk -o NAME,SIZE,FSTYPE,LABEL,MOUNTPOINTS
  ```
  - SSD: ~100 GB, partitions labelled `boot`, `swap`, `nixos`. **This is the one to wipe.**
  - HDD: ~900 GB, one ext4 partition, no label. **Leave it alone.**

  With 8 GB RAM the live system copies itself into RAM and unmounts the HDD, so the HDD
  will *not* show as mounted. Go by size and labels only.

## Phase 3: Install with archinstall

> [!CAUTION]
> **Pick the SSD only.** The ~900 GB HDD will show up in the disk list. Do not select it. This is the one step where a wrong choice loses your backups.

- [ ] Start the installer: `archinstall`
- [ ] **Disk configuration** → best-effort default partition layout → select the ~100 GB SSD → ext4 (or btrfs). This wipes the whole SSD, NixOS boot entries included.
- [ ] **Bootloader**: systemd-boot. **Swap**: zram is fine.
- [ ] **Profile** → Desktop → Hyprland. Niri isn't in the menu; `arch.md` installs it after.
- [ ] **Audio**: pipewire. **Network**: NetworkManager. Set user, password, timezone, then Install.
- [ ] When it finishes, `reboot`. The boot menu now shows only Arch.

## After: first boot into Arch

- [ ] Mount the HDD at `/mnt/hdd` on every boot.
  ```sh
  sudo mkdir -p /mnt/hdd
  echo 'UUID=4fc12482-bbb3-4ced-a896-2b5f560c9f6b /mnt/hdd ext4 defaults,nofail 0 2' | sudo tee -a /etc/fstab
  sudo systemctl daemon-reload && sudo mount -a
  ls /mnt/hdd
  ```
- [ ] Get your dotfiles. Use HTTPS; SSH keys aren't set up yet.
  ```sh
  sudo pacman -S --needed git
  git clone https://github.com/Leabua/dotfiles.git ~/dotfiles
  ```
- [ ] Follow [`arch.md`](arch.md): pacman tweaks, yay, packages, services, then `stow`. The `nixos/` folder does nothing on Arch.
- [ ] Once everything works, delete the ISO: `rm /mnt/hdd/archlinux-2026.11.01-x86_64.iso`
