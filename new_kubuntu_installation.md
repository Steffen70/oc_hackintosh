## Configuring Kubuntu

-   Install Kubuntu (Kubuntu 24.04.1 LTS)
-   Enlish interface
-   German (Switzerland) keyboard layout - No dead keys
-   Create new GPT partition table
-   Map /boot/efi to new fat32 partition (100MiB - add more if you intend to dual boot) - set boot flag
-   Map / to new ext4 partition (rest of the disk)
-   Install minimal installation

### Manual configuration

```bash
sudo apt update

# Set datetime format to de_CH
# Check if de_CH is available
dpkg -l | grep hunspell

# If not available install it
sudo apt install hunspell-de-ch

# Check if the locale is available
locale -a | grep de_CH

# If not available generate it
sudo locale-gen de_CH.UTF-8

# Set the locale
sudo bash -c 'cat > /etc/default/locale << EOF
LANG=en_US.UTF-8
LC_ADDRESS=de_CH.UTF-8
LC_IDENTIFICATION=de_CH.UTF-8
LC_MEASUREMENT=de_CH.UTF-8
LC_MONETARY=de_CH.UTF-8
LC_NAME=de_CH.UTF-8
LC_NUMERIC=de_CH.UTF-8
LC_PAPER=de_CH.UTF-8
LC_TELEPHONE=de_CH.UTF-8
LC_TIME=de_CH.UTF-8
EOF'

# Restart the system to apply the changes
sudo reboot

# Set "Wallpaper - Kubuntu Aurora.jpg" in SDDM settings
# Set "Breeze" as the default theme and change the Wallpaper by loading it from "/usr/share/wallpapers/"

# Set desktop wallpaper by right clicking on the desktop
# Set the wallpaper to "Wallpaper - Blue100 - Brand.jpg"

# Install LibreWolf
sudo apt install extrepo

sudo extrepo enable librewolf

sudo apt update

sudo apt install librewolf
```

### Enable ssh

```bash
sudo apt install openssh-server

sudo systemctl enable ssh

sudo systemctl start ssh

sudo systemctl status ssh

# Check ip address
sudo apt install net-tools

ifconfig

# Test connection from another machine
ssh $user_name@$ip_address

# Create a workspace directory
sudo mkdir /workspace
sudo chmod 777 /workspace
exit # Exit the ssh session

# Copy the entire oc_hackintosh directory to the workspace directory
scp -r /workspace/oc_hackintosh spag@172.20.2.115:/workspace/
```

### Install xRDP

```bash
sudo apt install xrdp

# Configure xRDP
sudo nano /etc/xrdp/sesman.ini

# Change settings in [Sessions] section
# MaxSessions=2
# KillDisconnected=true
# DisconnectedTimeLimit=60

# Add rule to allow network manager - else it will show a password prompt on every xRDP login
sudo bash -c 'cat > /etc/polkit-1/rules.d/10-allow-network-manager.rules << EOF
polkit.addRule(function(action, subject) {
    if (action.id == "org.freedesktop.NetworkManager.network-control" &&
        subject.isInGroup("sudo")) {
        return polkit.Result.YES;
    }
});
EOF'

# Restart polkit
sudo systemctl restart polkit

# Skip the grub selection screen (/etc/default/grub should already have GRUB_TIMEOUT=0)
# Uncomment GRUB_DISABLE_OS_PROBER and set to `true` - else 30_os-prober will override GRUB_TIMEOUT=0 with GRUB_TIMEOUT=10
sudo nano /etc/default/grub
sudo update-grup

sudo systemctl enable xrdp
sudo systemctl start xrdp

# Restart the system - to apply all changes
sudo reboot
```

### Install kvm

```bash
sudo apt install qemu-kvm

# Set kvm configuration - Intel CPU
sudo bash -c 'cat > /etc/modprobe.d/kvm.conf << EOF
options kvm_intel nested=1
options kvm_intel emulate_invalid_guest_state=0
options kvm ignore_msrs=1 report_ignored_msrs=0
EOF'

# Add current user to kvm and input groups
sudo usermod -aG kvm $(whoami)
sudo usermod -aG input $(whoami)

# Check groups
groups $(whoami)

# Reboot the system to apply the changes
sudo reboot

cd /workspace/oc_hackintosh

./oc_boot.sh spag_oc.qcow2 spag_ventura.img --ventura

sudo apt install remmina remmina-plugin-spice

# Add macOS VM to Remmina
# localhost macpro
# 127.0.0.1:5900
```
