# Ethernet connection went away

Apparently because the B450M-A motherboard has limited PCIe lanes installing the GPU can interfere with

1. check the network interfaces

```sh
# ip -c a

1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host noprefixroute
       valid_lft forever preferred_lft forever
2: enp8s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state DOWN group default qlen 1000
    link/ether e8:9c:25:43:c3:f5 brd ff:ff:ff:ff:ff:ff
```

2. check systemd

```sh
# systemctl status systemd-networkd

● systemd-networkd.service - Network Configuration
     Loaded: loaded (/usr/lib/systemd/system/systemd-networkd.service; enabled; preset: enabled)
     Active: active (running) since Fri 2026-01-23 20:39:26 UTC; 2h 29min ago
```

3. check if I am using netplan

```sh
# sudo ls -la /ettotal 12
drwxr-xr-x   2 root root 4096 Jan 23 20:25 .
drwxr-xr-x 119 root root 4096 Jan 23 22:01 ..
-rw-------   1 root root   65 Jan 23 20:25 50-cloud-init.yamlc/netplan/

# sudo cat /etc/netplan/*.yaml
network:
  version: 2
  ethernets:
    enp7s0: # <- yeah this is the problem
      dhcp4: true
```

using the `vi` editor changed `enp7s0` to `enp8s0` and ran `sudo netplan apply`

# GPU driver was missing

1. check if the video card is recognized by the operating system to begin with

```sh
# lspci | grep -i nvidia

# YES
01:00.0 VGA compatible controller: NVIDIA Corporation GA106 [GeForce RTX 3060 Lite Hash Rate] (rev a1)
01:00.1 Audio device: NVIDIA Corporation GA106 High Definition Audio Controller (rev a1)
```

2. check if there are drivers

```sh
# lsmod | grep nvidia
# nothing showed up so no
```

3. check recommended drivers

```sh
# ubuntu-drivers devices
udevadm hwdb is deprecated. Use systemd-hwdb instead.
udevadm hwdb is deprecated. Use systemd-hwdb instead.
udevadm hwdb is deprecated. Use systemd-hwdb instead.
udevadm hwdb is deprecated. Use systemd-hwdb instead.
udevadm hwdb is deprecated. Use systemd-hwdb instead.
udevadm hwdb is deprecated. Use systemd-hwdb instead.
udevadm hwdb is deprecated. Use systemd-hwdb instead.
udevadm hwdb is deprecated. Use systemd-hwdb instead.
udevadm hwdb is deprecated. Use systemd-hwdb instead.
udevadm hwdb is deprecated. Use systemd-hwdb instead.
udevadm hwdb is deprecated. Use systemd-hwdb instead.
udevadm hwdb is deprecated. Use systemd-hwdb instead.
udevadm hwdb is deprecated. Use systemd-hwdb instead.
udevadm hwdb is deprecated. Use systemd-hwdb instead.
ERROR:root:aplay command not found
== /sys/devices/pci0000:00/0000:00:01.1/0000:01:00.0 ==
modalias : pci:v000010DEd00002504sv00001462sd0000397Dbc03sc00i00
vendor   : NVIDIA Corporation
model    : GA106 [GeForce RTX 3060 Lite Hash Rate]
driver   : nvidia-driver-470-server - distro non-free
driver   : nvidia-driver-470 - distro non-free
driver   : nvidia-driver-535-open - distro non-free
driver   : nvidia-driver-570 - distro non-free
driver   : nvidia-driver-580-open - distro non-free recommended
driver   : nvidia-driver-535 - distro non-free
driver   : nvidia-driver-580 - distro non-free
driver   : nvidia-driver-580-server-open - distro non-free
driver   : nvidia-driver-570-server-open - distro non-free
driver   : nvidia-driver-570-open - distro non-free
driver   : nvidia-driver-580-server - distro non-free
driver   : nvidia-driver-570-server - distro non-free
driver   : nvidia-driver-535-server - distro non-free
driver   : nvidia-driver-535-server-open - distro non-free
driver   : xserver-xorg-video-nouveau - distro free builtin
```

4. install driver

```sh
# sudo apt update
# sudo apt install nvidia-driver-580-open
# sudo reboot
```

5. check if gpu driver is working proper

```sh
# nvidia-smi

Fri Jan 23 20:40:49 2026
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 580.126.09             Driver Version: 580.126.09     CUDA Version: 13.0     |
+-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA GeForce RTX 3060        Off |   00000000:01:00.0 Off |                  N/A |
|  0%   29C    P8             14W /  170W |       1MiB /  12288MiB |      0%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+

+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI              PID   Type   Process name                        GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
|  No running processes found                                                             |
+-----------------------------------------------------------------------------------------+
```

# Testing the GPU

[GPU Burn](https://github.com/wilicc/gpu-burn)
