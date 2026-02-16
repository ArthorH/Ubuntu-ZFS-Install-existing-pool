# Robust ZFS Installation (Non-Encrypted)

High-performance Ubuntu (Noble/Jammy) installation on ZFS with a focused, destructive deployment logic.

## Technical Specifications

- **Drive Preparation (Bulldozer)**: Forced unmounts, swap deactivation, and `dd` overwrite of GPT/MBR headers (first/last 10MB) to ensure a clean state.
- **Partition Layout**:
  1. **ESP**: 512MB
  2. **ZFS Root**: Size defined by `zfs_root_size` in `config.sh`.
  3. **EXT4 Data**: Unmanaged partition occupying the remainder of the disk.
- **ZFS Configuration**:
  - **No Encryption**: Native ZFS and LUKS encryption disabled for maximum throughput.
  - **No Swap**: Swap partition removed from deployment.
  - **Single Dataset Root**: Simplified hierarchy with all system directories under a single dataset (`/`).
- **Networking**: Post-reboot Wi-Fi support and robust Netplan ethernet interface auto-detection.

## Disk will look like this: 
<img width="561" height="81" alt="Untitled Diagram drawio" src="https://github.com/user-attachments/assets/9dc6c113-f83f-42de-99b9-a2875244eef9" />

## Deployment

1. **Clone**:
   ```bash
   git clone https://github.com/ArthorH/Ubuntu-ZFS-Install-existing-pool.git ~/Ubuntu_install_ZFS
   cd ~/Ubuntu_install_ZFS
   chmod -R +x install.sh ./bin/
   ```

2. **Configure**: Edit `config.sh` (disk IDs, credentials, Wi-Fi).

3. **Execute**:
   - **Phase 1 (Wipe/Bootstrap)**: `sudo ./install.sh initial`
   - **Phase 1B (Existing Pool)**: `sudo ./install.sh osinstall`
   - **Phase 2 (Post-Reboot)**: `sudo ./install.sh postreboot`

## Technical History (Feb 15, 2026 Builds)

- **Post-boot Wi-Fi**: Integrated SSID/Password hooks.
- **Partitioning**: Sequential EFI+ZFS+EXT layout implementation.
- **Bulldozer**: "DD headshot" header destruction logic.
- **Optimization**: Stripped ZFS encryption and swap partitions.
- **Architecture**: Modularized script logic into `bin/` modules.
- **Single Root**: Deployment mounts everything into the primary root dataset.

## Ubuntu ZFS Install Guide (using ArthorH/Ubuntu-ZFS-Install-existing-pool)

**Warning**: This script IS NOT A CHILL GUY. It will erase your drive, partition tables, and double-tap them by DD'ing GPT headers. If you have anything of value on that drive, move it now.

### 1. Get the stuff

Boot from an Ubuntu Live ISO (24.04 Noble recommended). Open a terminal.

```bash
sudo apt-get install git
git clone https://github.com/ArthorH/Ubuntu-ZFS-Install-existing-pool.git
cd Ubuntu-ZFS-Install-existing-pool/Ubuntu_install_ZFS
sudo chmod -R +x ./bin/ config.sh install.sh
```

### 2. Edit config.sh (the most important part)

```bash
sudo nano config.sh
```

Here's what it should look like (with my comments – read them!):

```bash
#!/bin/bash

# Ubuntu release and variant
ubuntuver="noble"            # <--- your distro (noble, jammy, etc.)
distro_variant="desktop"     # <--- desktop is default because i like it

# User and Hostname 
user="testuser"              # <----- DO NOT FORGET      you wouldnt be able to look this up after reboot
PASSWORD="testuser"          # <----- DO NOT FORGET      and doing chroot takes longer than full reinstall :((( 
hostname="ubuntu"       

# ZFS Root Pool Configuration
RPOOL="rpool"                
zfs_rpool_ashift="12"        
zfs_root_size="50G"          # <----- This one is IMPORTANT (i usually go with 300G)
topology_root="single"       # <---  i didnt tested those and they probably dont work after refactor sowy
disks_root="1"            

# Partition Sizes
EFI_boot_size="512"         

# Unmanaged Data Partition Configuration
ext4_data_mount="/data"      

# ZFS General settings
zfs_compression="zstd"  

# Installation Paths
mountpoint="/mnt/ub_server"  
log_loc="/var/log"       
install_log="ubuntu_setup_zfs_root.log"

# Network and Remote Access
ethprefix="e"                
remoteaccess_first_boot="no" 
remoteaccess_hostname="zbm"   
remoteaccess_ip_config="dhcp"         # <---  i didnt test this ethier 
remoteaccess_ip="192.168.0.222" 
remoteaccess_netmask="255.255.255.0" 

# Wi-Fi Configuration
wifi_ssid=""                 # <---  Dont mess this up if you dont want to manually type this back in CLI nano
wifi_password=""             # Look this up now. 
wifiprefix="w"              

# Timeouts and Boot
timeout_rEFInd="3"           
timeout_zbm_no_remote_access="3"   
timeout_zbm_remote_access="45"   
quiet_boot="yes"      

# APT settings
mirror_archive=""            
ubuntu_original="http://archive.ubuntu.com/ubuntu"
ipv6_apt_fix_live_iso="no"  

# Misc
install_warning_level="PRIORITY=critical" # "PRIORITY=critical" or "FRONTEND=noninteractive"
extra_programs="no"        
sanoid_snapshots="yes"       # <-- I added feachure to disable this because its not always needed and cleaning this up is a chore
locale="en_GB.UTF-8"        
timezone="Europe/London"
```

Save and exit. If you miss something, you'll be sorry later.

### 3. Run the initial install

First, see what options the script has:

```bash
sudo ./install.sh bad option
```

It'll show you:

```text
Usage: ./install.sh initial | osinstall | postreboot | reinstall-zbm | reinstall-pyznap
```

Now do the real thing:

```bash
sudo ./install.sh initial
```

What happens:

- It unmounts all drives.
- Kills all partition tables.
- DD's GPT headers (double tap).
- Creates partitions: EFI + ZFS + optional ext4 data.
- Installs a minimal system.

If you missed configs and the script already partitioned your drive, you'll have to reboot the live ISO because another bulldoze from the same OS will throw partition request send but unable to inform kernel and crash.

If you see this, you're golden:

```text
Initial minimal system setup complete.
Reboot required to complete installation.
First login is user:passwd                  <----- remember it!!!
Following reboot, run script with postreboot option to complete installation.
```

If you don't see that message, the script crashed. Reboot and try again.

### 4. Reboot and fix network (if needed)

Log in with the username/password you set.

Check if internet works:

```bash
ping 8.8.8.8
```

If not, netplan probably isn't installed correctly. Luckily the script auto‑installs wpa‑supplicant and all the needed stuff for wifi or wire.

Edit the netplan config:

```bash
sudo nano /etc/netplan/01-netcfg.yaml
```

It should look something like this (adjust for your hardware):

```yaml
network:
    version: 2
    ethernets:
        # if you have ethernet, something like:
        enp0s3:
            dhcp4: yes
    wifis:
        wl0:
            dhcp4: yes
            access-points:
                "your-wifi-ssid":
                    password: "your-wifi-password"
```

Then apply:

```bash
sudo netplan generate   # if this throws errors, you have a typo
sudo netplan apply      # this WILL throw errors ... just mash it until it gets depressed and does what it must
```

Check internet again. If it still doesn't work... i usually rage quit and reinstall the system.

### 5. Complete the installation (postreboot)

Go back to the Ubuntu_install_ZFS directory (it should still be there) and run:

```bash
sudo ./install.sh postreboot
```

Sit back and watch. If the script throws errors (doesn't say "now you can reboot"), it's not super bad – the script does all ZFS configs in chroot on the live USB, so just reboot, select the image, and try the installer again. Sometimes it hangs on installing stupid stuff like firefox when the mirror gets sad. It's much easier to debug in a desktop environment with forums open and music blasting.

After that, you're basically set.

### 6. Installing additional systems on the same root pool

Disclaimer: I haven't tested if you can just go ahead and ballz run the installer right after doing initial install. But you could try if you have spare time.

Boot into live USB again (i know it sucks but i don't have the mental capacity to do it right. The right way is to have a 30GB backup domain Ubuntu sitting between EFI → backup Ubuntu ← ZFS system … ext4 data with all the fun shiny tools like this repo and ZFS midnight commander and cool wallpaper).

Download the repo and all tooling once again, then run:

```bash
sudo ./install.sh osinstall
```

If the original system installed with no issues, this will go the same. The script overwrites ZFSboot every time you install a new system. It does not affect the ZFS system in any way. I know it's jank – I'm not going to fix it right now.

Enjoy your ZFS‑based Ubuntu!


# Credits

Be shure to check out https://github.com/Sithuk/ubuntu-server-zfsbootmenu Sithuk's script!
Without this script this project would have been impossible :)  ❤️

# License
MIT
