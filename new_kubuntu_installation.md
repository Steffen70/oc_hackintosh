## Configuring Kubuntu

-   Install Kubuntu (Kubuntu 24.04.1 LTS)
-   Enlish interface
-   German (Switzerland) keyboard layout - No dead keys
-   Create new GPT partition table
-   Map /boot/efi to new fat32 partition (100MiB - add more if you intend to dual boot) - set boot flag
-   Map / to new ext4 partition (rest of the disk)

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
