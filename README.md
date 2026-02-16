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
