#!/bin/bash

# Ubuntu release and variant
ubuntuver="noble"            # Ubuntu release. "jammy" (22.04), "noble" (24.04), "questing" (25.10)
distro_variant="desktop"      # Ubuntu variant. "server" (CLI only), "desktop", "kubuntu", etc.

# User and Hostname
user="testuser"              # Username for new install
PASSWORD="testuser"          # Password for user in new install
hostname="ubuntu"            # Hostname for the system

# ZFS Root Pool Configuration
RPOOL="rpool"                # Root pool name
zfs_rpool_ashift="12"        # ashift=9 (512B), 12 (4KiB), 13 (8KiB)
zfs_root_size="50G"          # ZFS root size. Used ONLY when ext4_data_mode="remainder"; in "none"/"disk" mode ZFS fills the whole disk.
topology_root="single"       # "single", "mirror", "raid0", "raidz1", "raidz2", "raidz3"
disks_root="1"               # Number of disks for root pool (ignored for single)

# Partition Sizes
EFI_boot_size="512"          # EFI partition size in MiB

# Unmanaged Data Partition Configuration
# ext4_data_mode:
#   "remainder" - create an ext4 partition in the leftover space on the OS disk (default)
#   "none"      - do not create or mount a data partition
#   "disk"      - create the ext4 data partition on a separate disk (selected at install time)
ext4_data_mode="remainder"
ext4_data_disk=""            # Optional: pin the data disk by its /dev/disk/by-id name, e.g. "ata-WDC_WD40EFRX-68N32N0_WD-WCC7K1234567". If empty, you pick it interactively.
ext4_data_mount="/data"      # Mount point for the unmanaged ext4 partition

# ZFS General settings
zfs_compression="zstd"       # "lz4" or "zstd"

# Installation Paths
mountpoint="/mnt/ub_server"  # Mountpoint in live ISO
log_loc="/var/log"           # Installation log location
install_log="ubuntu_setup_zfs_root.log" # Log filename

# Network and Remote Access
ethprefix="e"                # First letter of ethernet interface
remoteaccess_first_boot="no" # "yes" to enable remote access during first boot
remoteaccess_hostname="zbm"  # Hostname for ZFSBootMenu
remoteaccess_ip_config="dhcp" # "dhcp", "dhcp,dhcp6", "dhcp6", or "static"
remoteaccess_ip="192.168.0.222" # Static IP for ZFSBootMenu
remoteaccess_netmask="255.255.255.0" # Subnet mask for static IP

# Wi-Fi Configuration
wifi_ssid=""                 # Your Wi-Fi SSID
wifi_password=""             # Your Wi-Fi Password
wifiprefix="w"               # First letter of wifi interface (e.g., "w" for wlan0)

# Timeouts and Boot
timeout_rEFInd="3"           # rEFInd timeout
timeout_zbm_no_remote_access="3" # ZFSBootMenu timeout (no remote)
timeout_zbm_remote_access="45"   # ZFSBootMenu timeout (with remote)
quiet_boot="yes"             # Show boot sequence if "no"

# APT settings
mirror_archive=""            # ISO 3166-1 country code for mirror speed test
ubuntu_original="http://archive.ubuntu.com/ubuntu"
ipv6_apt_fix_live_iso="no"   # Enable if apt-get is slow in live ISO

# Misc
install_warning_level="PRIORITY=critical" # "PRIORITY=critical" or "FRONTEND=noninteractive"
extra_programs="no"          # Install cifs-utils, locate, man-db, openssh-server, tldr
sanoid_snapshots="yes"       # Install and enable sanoid for automated snapshots
locale="en_GB.UTF-8"         # Language setting
timezone="Europe/London"     # Timezone setting
