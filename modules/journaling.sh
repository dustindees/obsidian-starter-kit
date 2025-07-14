#!/usr/bin/env bash

# Journaling module for Obsidian Starter Kit installer

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

# Setup journaling functionality
setup_journaling() {
    if [[ "$journaling_enabled" != "true" ]]; then
        return
    fi
    
    print_status "Setting up journaling functionality..."
    
    local vault_path="$1"
    create_journaling_moc "$vault_path"
}

# Create journaling MOC file
create_journaling_moc() {
    local vault_path="$1"
    local permanent_dir="$vault_path/300_Permanent"
    local filepath="$permanent_dir/0-Journaling.md"
    
    print_status "Creating journaling MOC file..."
    touch "$filepath"
    print_success "Created: $filepath"
}

# Show journaling setup summary
show_journaling_summary() {
    if [[ "$journaling_enabled" != "true" ]]; then
        return
    fi
    
    echo
    print_status "Journaling integration enabled with MOC file created."
}