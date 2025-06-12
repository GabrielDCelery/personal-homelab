```sh
sudo apt update
sudo apt install openssh-server -y
sudo systemctl enable ssh
sudo sustemctl start ssh
sudo systemctl status ssh
```

```sh
ssh-copy-id <user>@<machine>
```

```sh
sudo visudo -f /etc/sudoers.d/username
username ALL=(ALL) NOPASSWD: ALL
```
