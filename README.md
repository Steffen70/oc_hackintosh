## Setup Instructions - SSH iOS Development Environment

### Step 1: Clone the Repository

Clone this repository to your local machine and navigate to the repository root.

### Step 2: Follow Initial Setup Instructions

Follow the steps in the [README.md](README.md) file to set up the environment and install macOS (Sonoma).

### Step 3: Initial VM Boot

Start the VM for the first time with the GUI to complete the initial macOS setup:

```bash
./OpenCore-Boot.sh
```

Complete the macOS setup and install XCode and other GUI-dependent tools.

**Note:** Active SSH on macOS `System Preferences > Sharing > Remote Login`.

### Step 4: Install XCode and Generate Unique Serial

If you need to install XCode, you'll need a unique serial number. Complete steps 1-5 below and start `./OpenCore-Boot.sh` again to connect to your Apple account, install XCode, and other tools.

```bash
# Run the following commands on the macOS VM

# Download XCode from [Apple Developer](https://developer.apple.com/download/all/?q=xcode)
xip -x ~/Downloads/$xcode_version.xip

# Install XCode command line tools
xcode-select --install

# Continue on the host machine to generate a unique serial number

# Clone the GenSMBIOS repository and navigate to the directory
git clone https://github.com/corpnewt/GenSMBIOS.git
cd GenSMBIOS

# Make the script executable
chmod +x GenSMBIOS.command
./GenSMBIOS.command
```

1. Install/Update MacSerial.
2. Select `$osx_kvm_path/OpenCore/headless/config.plist` as the configuration file.
3. Generate SMBIOS for `iMacPro1,1`.
4. Generate UUID.

### Step 5: Generate OpenCore Image with NoUI Configuration

```bash
# Update submodule
git submodule update --init --recursive ./resources/OcBinaryData

cd ./OpenCore

# Generate OpenCore image with NoUI configuration
rm -f OpenCore.qcow2; sudo ./opencore-image-ng.sh --cfg ./headless/config.plist --img OpenCore.qcow2
```

### Step 6: Start OpenCore VM with NoUI Configuration

```bash
# Navigate to repository root
cd $osx_kvm_path
# cd ..

# Make the shell script executable
chmod +x ./headless_boot.sh

./headless_boot.sh
```

### Step 7: Connect to macOS VM with SSH

```bash
ssh -p 2222 $user_name@localhost

# Copy xcode from host to VM via scp
scp -P 2222 Xcode_13.3.1.xip $user_name@localhost:~/Downloads/
```

### Step 8: Map Port 22 to 2222 and Open Firewall

```bash
# Map port 22 to 2222
sudo iptables -t nat -A PREROUTING -p tcp --dport 22 -j REDIRECT --to-port 2222

# Open firewall
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
```

#### Make Port Forwarding Persistent

```bash
# Ensure the iptables-persistent package is installed
sudo apt-get install -y iptables-persistent

# iptables-persistent will ask you if you want to save the current rules during installation - select yes

# Or save the current iptables rules manually
sudo iptables-save | sudo tee /etc/iptables/rules.v4
```

### Step 9: Connect from Any Device on the Network to the VM

```bash
ssh $user_name@$vm_host_ip
```

### Step 10: Shutdown the VM

```bash
# (run on mac via SSH)
sudo shutdown -h now
```

## Additional Notes

When you use the VSCode Remote SSH extension, you will disconnect from the VM as soon as the VM enters sleep mode. To prevent this, you can enable automatic login and disable lock screen in the macOS settings. This way, the user will be logged in automatically when the VM starts and won't enter sleep mode.

I personally use Nix flakes to manage the environment, so I can install all the required tools with `nix develop` and run the scripts from there. (The Nix package manager does not support XCode, so you need to install it manually first.)

Additionally, I use GitHub to store my credentials, which allows me to just copy the `.gitconfig` and `.git-credentials` to the user home directory on the VM.

To debug iOS apps, it's easiest to use XCode Wi-Fi debugging, so you don't need to connect the phone to the VM.
