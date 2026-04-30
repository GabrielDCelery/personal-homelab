# Storage Migration

## What is this document for?

Steps for migrating data between drives on the homelab desktop server.

## Planned storage layout

- **NVMe 500GB** — OS, Docker internals (`/var/lib/docker`)
- **SATA SSD 1 (1TB)** — `/srv` (all service data)
- **SATA SSD 2 (1TB)** — backups of `/srv`

## Discovering storage devices

Before starting, identify what devices are available and how they are currently used.

**List all block devices with filesystem and mount info:**

```sh
lsblk -o NAME,SIZE,TYPE,FSTYPE,UUID,MOUNTPOINT
```

**Check disk usage on mounted filesystems:**

```sh
df -h
```

**Get hardware detail (model, serial, interface type):**

```sh
sudo lshw -class disk -short
```

**Check current fstab (what mounts automatically on boot):**

```sh
cat /etc/fstab
```

**Identify a device's UUID (needed for fstab entries):**

```sh
sudo blkid /dev/sda
```

In the output of `lsblk`, devices with no `FSTYPE` and no `MOUNTPOINT` are unformatted and unmounted — ready to be set up.

## Migrating /srv to a SATA SSD

### 1. Format the drive

```sh
sudo mkfs.ext4 /dev/sda
```

### 2. Mount temporarily

```sh
sudo mkdir /mnt/sata
sudo mount /dev/sda /mnt/sata
```

### 3. Copy everything across

```sh
sudo rsync -av /srv/ /mnt/sata/
```

### 4. Verify the copy

```sh
du -sh /srv
du -sh /mnt/sata
```

### 5. Stop all Docker services

```sh
docker compose down  # run in each service directory
```

### 6. Swap the mount

```sh
sudo umount /mnt/sata
sudo mount /dev/sda /srv
```

### 7. Make it permanent

```sh
UUID=$(blkid -s UUID -o value /dev/sda)
echo "UUID=$UUID /srv ext4 defaults 0 2" | sudo tee -a /etc/fstab
```

### 8. Restart Docker services and verify

```sh
docker compose up -d  # run in each service directory
```
