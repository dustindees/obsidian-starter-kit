#!/usr/bin/env bash

# MOC (Maps of Content) module for Obsidian Starter Kit installer

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

# Setup MOC functionality
setup_moc() {
    if [[ "$moc_enabled" != "true" ]]; then
        return
    fi
    
    print_status "Setting up MOC (Maps of Content) functionality..."
    
    local vault_path="$1"
    create_moc_files "$vault_path"
}

# Create MOC files
create_moc_files() {
    local vault_path="$1"
    local permanent_dir="$vault_path/300_Permanent"
    
    print_status "Creating MOC files..."
    
    for category in "${moc_categories[@]}"; do
        local filename=$(echo "$category" | sed 's/[[:space:]]/_/g')
        local filepath="$permanent_dir/0-${filename}.md"
        touch "$filepath"
        print_success "Created: $filepath"
    done
}

# Show MOC setup summary
show_moc_summary() {
    if [[ "$moc_enabled" != "true" ]]; then
        return
    fi
    
    echo
    print_status "MOC integration enabled with category files created."
}