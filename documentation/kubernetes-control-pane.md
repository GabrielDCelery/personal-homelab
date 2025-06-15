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

## Open windows port using Windows Firewall with Advanced Security GUI

```sh
Get-Service WinRM
Start-Service WinRM

Set-Service WinRM -StartupType Automatic

winrm quickconfig


PS C:\WINDOWS\system32> winrm quickconfig
WinRM service is already running on this machine.
WinRM is not set up to allow remote access to this machine for management.
The following changes must be made:

Enable the WinRM firewall exception.
Configure LocalAccountTokenFilterPolicy to grant administrative rights remotely to local users.

Make these changes [y/n]? y

WinRM has been updated for remote management.

WinRM firewall exception enabled.
Configured LocalAccountTokenFilterPolicy to grant administrative rights remotely to local users.
```

```sh
1. Press **Win + R**, type **wf.msc** and press Enter
2. Select **Inbound Rules** from the left panel
3. Click **New Rule** from the right panel
4. Select **Port** and click **Next**
5. Choose **TCP** and enter **5985** in the "Specific local ports" field
6. Click **Next**
7. Select **Allow the connection** and click **Next**
8. Select which network profiles this rule applies to (Domain/Private/Public)
9. Name the rule (e.g., "WinRM HTTP 5985") and click **Finish**

```
