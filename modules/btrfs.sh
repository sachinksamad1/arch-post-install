#!/usr/bin/env bash

# ──────────────────────────────────────────────────────────────────────────────
# Module: btrfs.sh
# Description: Configures automated Btrfs snapshot management using Snapper
#              and snap-pac for rollbacks and disaster recovery.
# ──────────────────────────────────────────────────────────────────────────────

# /**
#  * is_btrfs_root()
#  * Checks if the root filesystem is Btrfs.
#  */
is_btrfs_root() {
    local root_fstype
    root_fstype="$(findmnt -n -o FSTYPE / 2>/dev/null || true)"
    [[ "${root_fstype}" == "btrfs" ]]
}

# /**
#  * setup_btrfs_snapshots()
#  * Configures Snapper and snap-pac for automated pre/post pacman snapshots.
#  */
setup_btrfs_snapshots() {
    log_step "Configuring Btrfs snapshot management"

    if ! is_btrfs_root; then
        log_info "Root filesystem is not Btrfs. Skipping Snapper setup."
        return 0
    fi

    log_info "Btrfs root filesystem detected"

    # Ensure required packages are installed
    local -a pkgs_to_install=()
    for pkg in snapper snap-pac; do
        if ! pacman -Q "${pkg}" &>/dev/null; then
            pkgs_to_install+=("${pkg}")
        fi
    done

    if [[ ${#pkgs_to_install[@]} -gt 0 ]]; then
        log_info "Installing Snapper utilities: ${pkgs_to_install[*]}"
        sudo pacman -S --needed --noconfirm "${pkgs_to_install[@]}" 2>&1 | tee -a "${LOG_FILE}"
    fi

    # Initialize Snapper config for root if not already configured
    if ! sudo snapper list-configs 2>/dev/null | grep -qw "root"; then
        log_info "Creating Snapper configuration for root (/)"
        
        # If /.snapshots exists as a subvolume or regular dir, handle safely
        if [[ -d "/.snapshots" ]]; then
            sudo umount /.snapshots 2>/dev/null || true
            sudo rm -rf /.snapshots 2>/dev/null || true
        fi
        
        sudo snapper -c root create-config / 2>&1 | tee -a "${LOG_FILE}"
        
        # Configure standard snapshot retention limits
        if [[ -f "/etc/snapper/configs/root" ]]; then
            sudo sed -i 's/^TIMELINE_CREATE=".*"/TIMELINE_CREATE="yes"/' /etc/snapper/configs/root
            sudo sed -i 's/^TIMELINE_LIMIT_HOURLY=".*"/TIMELINE_LIMIT_HOURLY="5"/' /etc/snapper/configs/root
            sudo sed -i 's/^TIMELINE_LIMIT_DAILY=".*"/TIMELINE_LIMIT_DAILY="7"/' /etc/snapper/configs/root
            sudo sed -i 's/^TIMELINE_LIMIT_WEEKLY=".*"/TIMELINE_LIMIT_WEEKLY="0"/' /etc/snapper/configs/root
            sudo sed -i 's/^TIMELINE_LIMIT_MONTHLY=".*"/TIMELINE_LIMIT_MONTHLY="0"/' /etc/snapper/configs/root
            sudo sed -i 's/^TIMELINE_LIMIT_YEARLY=".*"/TIMELINE_LIMIT_YEARLY="0"/' /etc/snapper/configs/root
            log_success "Snapper retention policy configured"
        fi
    else
        log_success "Snapper 'root' configuration already exists"
    fi

    # Enable and start Snapper maintenance timers
    for timer in snapper-timeline.timer snapper-cleanup.timer; do
        if systemctl cat "${timer}" &>/dev/null; then
            sudo systemctl enable --now "${timer}" 2>&1 | tee -a "${LOG_FILE}"
            log_success "Enabled timer: ${timer}"
        fi
    done

    log_success "Btrfs snapshot automation configured successfully"
}
