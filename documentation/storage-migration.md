# Storage Migration

## What is this document for?

Steps for migrating data between drives on the homelab desktop server.

## Planned storage layout

- **NVMe 500GB** — OS, Docker internals (`/var/lib/docker`)
- **SATA SSD 1 (1TB)** — `/srv` (all service data)
- **SATA SSD 2 (1TB)** — backups of `/srv`

## Discovering storage devices

Before touching anything, build a complete picture of the current state. Linux device names like `/dev/sda` are assigned at boot and can change if you add or remove drives — so you need to confirm which physical disk is which before formatting anything.

**List all block devices with filesystem and mount info:**

```sh
lsblk -o NAME,SIZE,TYPE,FSTYPE,UUID,MOUNTPOINT
```

This is your starting point. It shows every disk and partition, whether it has a filesystem, and where it's mounted. Devices with no `FSTYPE` and no `MOUNTPOINT` are unformatted and unmounted — safe to format. Devices with a `MOUNTPOINT` are in active use — do not format these.

**Check disk usage on mounted filesystems:**

```sh
df -h
```

Shows only mounted filesystems and how full they are. Useful for confirming which partition is your OS disk and how much space is left. Unmounted drives won't appear here, which is why you need `lsblk` as well.

**Get hardware detail (model, serial, interface type):**

```sh
sudo lshw -class disk -short
```

Cross-reference this with `lsblk` to confirm which device name maps to which physical drive. If you have two SSDs of the same size, this is how you tell them apart — model name and serial number.

**Check current fstab (what mounts automatically on boot):**

```sh
cat /etc/fstab
```

Shows what is currently configured to auto-mount on boot. Check this before and after making changes to confirm your new entries were written correctly and nothing existing was accidentally broken.

**Identify a device's UUID (needed for fstab entries):**

```sh
sudo blkid /dev/sda
```

Device names like `/dev/sda` can change between reboots if drive order changes. UUIDs are tied to the filesystem on the drive itself and never change, so fstab entries should always use UUID rather than device name.

## Migrating /srv to a SATA SSD

### 1. Format the drive

```sh
sudo mkfs.ext4 /dev/sda
```

This writes an ext4 filesystem to the drive, wiping anything previously on it. If the drive had a partition table (like a GPT label), Linux will warn you and ask you to confirm — that's expected, type `y` to proceed. Only do this if you confirmed in the discovery step that this drive has no `MOUNTPOINT` and is not in active use.

### 2. Mount temporarily

```sh
sudo mkdir /mnt/sata
sudo mount /dev/sda /mnt/sata
```

Mount the newly formatted drive to a temporary location so you can copy data onto it. You're not switching anything over yet — this is just to get the drive accessible.

### 3. Stop all Docker services

```sh
docker compose down  # run in each service directory
```

Stop all services before copying data. Copying while containers are running risks capturing files mid-write, which can result in corrupted or inconsistent data on the new drive — databases are especially vulnerable to this.

### 4. Copy everything across

```sh
sudo rsync -aAXv /srv/ /mnt/sata/
```

Copy all data from `/srv` to the new drive. The flags preserve permissions, ownership, symlinks, ACLs, and extended attributes — important for Docker service data. Note the trailing slash on `/srv/` — without it rsync would create a nested `srv/` directory inside the destination instead of copying the contents directly.

### 5. Verify the copy

```sh
du -sh /srv
du -sh /mnt/sata
```

Both should report the same size. If they differ, something was missed and you should not proceed.

### 6. Swap the mount

```sh
sudo umount /mnt/sata
sudo mount /dev/sda /srv
```

Unmount from the temporary location and remount the drive at `/srv`. From this point on, all service data reads and writes go to the SATA SSD. The original data on the NVMe is still there untouched — `/srv` on the NVMe is just no longer the active mount.

### 7. Make it permanent

```sh
UUID=$(sudo blkid -s UUID -o value /dev/sda)
echo "UUID=$UUID /srv ext4 defaults 0 2" | sudo tee -a /etc/fstab
```

Without this, the mount won't survive a reboot. This writes the fstab entry using the drive's UUID rather than the device name, so it still works correctly even if the drive is assigned a different name on the next boot.

### 8. Restart Docker services and verify

```sh
docker compose up -d  # run in each service directory
```

Bring services back up and confirm everything works as expected. Check service logs if anything fails — the most common issue is file permission problems from the rsync.

## Setting up sdb as a backup drive

### 1. Format the drive

```sh
sudo mkfs.ext4 /dev/sdb
```

Same as formatting the primary drive. If `sdb` is completely blank it won't prompt for confirmation — if it does, check the discovery step output again to make sure you have the right device.

### 2. Create the mount point and mount

```sh
sudo mkdir /mnt/backup
sudo mount /dev/sdb /mnt/backup
```

Creates the directory that will serve as the backup mount point and mounts the drive there. `/mnt/backup` is a conventional location for this kind of secondary mount.

### 3. Make it permanent

```sh
UUID=$(sudo blkid -s UUID -o value /dev/sdb)
echo "UUID=$UUID /mnt/backup ext4 defaults 0 2" | sudo tee -a /etc/fstab
```

Same reasoning as for `/srv` — use UUID so the mount survives reboots and drive renaming.

### 4. Verify fstab before reboot

```sh
sudo mount -a
```

This replays all fstab entries without rebooting. If you made a typo in the fstab entry it will error here rather than leaving the machine in a broken state on next boot.

## Setting up the backup cron job

A nightly rsync from `/srv` to `/mnt/backup` keeps the backup drive as a current mirror. If the primary drive fails, you can remount `/mnt/backup` at `/srv` and be back up with at most one day of data loss.

### 1. Create the sync script

```sh
sudo tee /usr/local/bin/backup-srv.sh > /dev/null << 'EOF'
#!/bin/bash
flock -n /tmp/backup-srv.lock ionice -c 3 rsync -aAXv --delete /srv/ /mnt/backup/
EOF
sudo chmod +x /usr/local/bin/backup-srv.sh
```

The `--delete` flag removes files from the backup that no longer exist on the primary — this keeps it a true mirror rather than an ever-growing archive. The script is placed in `/usr/local/bin` so it's available system-wide and clearly identifiable as a local admin script.

### 2. Add the cron job (runs hourly)

```sh
sudo crontab -e
```

Add this line:

```
0 * * * * /usr/local/bin/backup-srv.sh >> /var/log/backup-srv.log 2>&1
```

Runs as root at 2am daily so it has permission to read all files in `/srv`. Output is appended to a log file so you can check whether recent syncs succeeded.

### 3. Verify the cron job was saved

```sh
sudo crontab -l
```

Confirm the entry is there. A common mistake is saving the wrong crontab (user vs root) — since you edited with `sudo crontab -e`, this lists root's crontab to confirm.
