#!/usr/bin/env bash

# Backup module for Obsidian Starter Kit installer

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

# Ask about backup integration
ask_backup_integration() {
    echo
    print_status "Do you want to set up automatic backups for your vault?"
    
    choice=$(echo -e "Yes\nNo" | fzf --prompt="Backup integration: " --height=5)
    
    if [[ "$choice" == "Yes" ]]; then
        backup_enabled=true
        print_success "Backup integration enabled"
        get_backup_options
    else
        backup_enabled=false
        print_success "Backup integration disabled"
    fi
}

# Get backup options from user
get_backup_options() {
    echo
    print_status "Select your backup options (use TAB to select multiple):"
    
    local backup_options=("Local backup" "Remote backup (Git)")
    local selected_options
    selected_options=$(printf '%s\n' "${backup_options[@]}" | fzf --multi --prompt="Select backup types: " --height=10)
    
    # Initialize backup type variables
    local_backup_enabled=false
    remote_backup_enabled=false
    
    if [[ -n "$selected_options" ]]; then
        while IFS= read -r option; do
            case "$option" in
                "Local backup")
                    local_backup_enabled=true
                    ;;
                "Remote backup (Git)")
                    remote_backup_enabled=true
                    ;;
            esac
        done <<< "$selected_options"
    fi
    
    # Get additional configuration if needed
    if [[ "$local_backup_enabled" == "true" ]]; then
        get_local_backup_config
    fi
    
    if [[ "$remote_backup_enabled" == "true" ]]; then
        get_remote_backup_config
    fi
}

# Get local backup configuration
get_local_backup_config() {
    echo
    print_status "Configuring local backup..."
    
    # Get backup directory
    print_status "Enter the directory where local backups should be stored:"
    print_status "(Default: ~/obsidian-backups)"
    read -p "> " local_backup_dir
    
    if [[ -z "$local_backup_dir" ]]; then
        local_backup_dir="$HOME/obsidian-backups"
    fi
    
    # Expand ~ to full path
    local_backup_dir="${local_backup_dir/#\~/$HOME}"
    
    print_success "Local backup directory set to: $local_backup_dir"
}

# Get remote backup configuration
get_remote_backup_config() {
    echo
    print_status "Configuring remote backup (Git)..."
    
    # Get git repository URL
    print_status "Enter the Git repository URL for remote backups:"
    print_status "(e.g., https://github.com/username/my-obsidian-vault.git)"
    read -p "> " git_repo_url
    
    if [[ -z "$git_repo_url" ]]; then
        print_error "Git repository URL cannot be empty for remote backup."
        get_remote_backup_config
        return
    fi
    
    print_success "Git repository URL set to: $git_repo_url"
    
    # Ask about git credentials
    echo
    print_status "Git authentication will be handled by your system's git configuration."
    print_status "Make sure you have proper SSH keys or credential helper configured."
}

# Setup backup functionality
setup_backup() {
    local vault_path="$1"
    
    if [[ "$backup_enabled" != "true" ]]; then
        return
    fi
    
    print_status "Setting up backup functionality..."
    
    # Create or use existing scripts directory
    local scripts_dir="${vault_name}_scripts"
    ensure_scripts_directory "$scripts_dir"
    
    if [[ "$local_backup_enabled" == "true" ]]; then
        create_local_backup_script "$vault_path" "$scripts_dir"
        setup_local_backup_cron "$vault_path" "$scripts_dir"
    fi
    
    if [[ "$remote_backup_enabled" == "true" ]]; then
        create_remote_backup_script "$vault_path" "$scripts_dir"
        setup_remote_backup_cron "$vault_path" "$scripts_dir"
    fi
    
    print_success "Backup functionality configured successfully"
}

# Ensure scripts directory exists
ensure_scripts_directory() {
    local scripts_dir="$1"
    
    if [[ ! -d "$scripts_dir" ]]; then
        print_status "Creating scripts directory: $scripts_dir"
        mkdir -p "$scripts_dir"
        print_success "Created: $scripts_dir"
    else
        print_status "Using existing scripts directory: $scripts_dir"
    fi
}

# Create local backup script
create_local_backup_script() {
    local vault_path="$1"
    local scripts_dir="$2"
    local script_path="$scripts_dir/local-backup.sh"
    
    cat > "$script_path" << 'EOF'
#!/usr/bin/env bash

# Local backup script for Obsidian vault
# This script will be implemented later

VAULT_PATH="VAULT_PATH_PLACEHOLDER"
BACKUP_DIR="BACKUP_DIR_PLACEHOLDER"

echo "Local backup script - Implementation pending"
echo "Vault path: $VAULT_PATH"
echo "Backup directory: $BACKUP_DIR"

# TODO: Implement local backup functionality
# - Check if vault has changed since last backup
# - Create timestamped backup if changes detected
# - Manage backup retention policy
EOF
    
    # Replace placeholders
    sed -i "s|VAULT_PATH_PLACEHOLDER|$(realpath "$vault_path")|g" "$script_path"
    sed -i "s|BACKUP_DIR_PLACEHOLDER|$local_backup_dir|g" "$script_path"
    
    chmod +x "$script_path"
    print_success "Created local backup script: $script_path"
}

# Create remote backup script
create_remote_backup_script() {
    local vault_path="$1"
    local scripts_dir="$2"
    local script_path="$scripts_dir/remote-backup.sh"
    
    cat > "$script_path" << 'EOF'
#!/usr/bin/env bash

# Remote backup script for Obsidian vault
# This script will be implemented later

VAULT_PATH="VAULT_PATH_PLACEHOLDER"
GIT_REPO_URL="GIT_REPO_URL_PLACEHOLDER"

echo "Remote backup script - Implementation pending"
echo "Vault path: $VAULT_PATH"
echo "Git repository: $GIT_REPO_URL"

# TODO: Implement remote backup functionality
# - Initialize git repository if not exists
# - Check for changes in vault
# - Commit and push changes to remote repository
# - Handle merge conflicts gracefully
EOF
    
    # Replace placeholders
    sed -i "s|VAULT_PATH_PLACEHOLDER|$(realpath "$vault_path")|g" "$script_path"
    sed -i "s|GIT_REPO_URL_PLACEHOLDER|$git_repo_url|g" "$script_path"
    
    chmod +x "$script_path"
    print_success "Created remote backup script: $script_path"
}

# Setup cron job for local backup
setup_local_backup_cron() {
    local vault_path="$1"
    local scripts_dir="$2"
    local script_path="$scripts_dir/local-backup.sh"
    
    # Add cron job to run daily at 2 AM
    local cron_entry="0 2 * * * $script_path"
    
    # Check if cron job already exists
    if crontab -l 2>/dev/null | grep -F "$script_path" >/dev/null; then
        print_warning "Local backup cron job already exists"
    else
        (crontab -l 2>/dev/null; echo "$cron_entry") | crontab -
        print_success "Added local backup cron job (daily at 2:00 AM)"
    fi
}

# Setup cron job for remote backup
setup_remote_backup_cron() {
    local vault_path="$1"
    local scripts_dir="$2"
    local script_path="$scripts_dir/remote-backup.sh"
    
    # Add cron job to run daily at 3 AM
    local cron_entry="0 3 * * * $script_path"
    
    # Check if cron job already exists
    if crontab -l 2>/dev/null | grep -F "$script_path" >/dev/null; then
        print_warning "Remote backup cron job already exists"
    else
        (crontab -l 2>/dev/null; echo "$cron_entry") | crontab -
        print_success "Added remote backup cron job (daily at 3:00 AM)"
    fi
}

# Show backup summary
show_backup_summary() {
    if [[ "$backup_enabled" != "true" ]]; then
        return
    fi
    
    echo
    print_status "=== Backup Configuration ==="
    
    if [[ "$local_backup_enabled" == "true" ]]; then
        echo "✓ Local backup enabled"
        echo "  - Backup directory: $local_backup_dir"
        echo "  - Schedule: Daily at 2:00 AM"
    fi
    
    if [[ "$remote_backup_enabled" == "true" ]]; then
        echo "✓ Remote backup enabled"
        echo "  - Git repository: $git_repo_url"
        echo "  - Schedule: Daily at 3:00 AM"
    fi
    
    echo
    print_status "Note: Backup scripts are placeholders and will need to be implemented."
    print_status "Scripts location: ${vault_name}_scripts/"
    echo
}