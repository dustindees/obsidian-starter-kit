#!/usr/bin/env bash

# Calendar module for Obsidian Starter Kit installer

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

# Setup calendar functionality
setup_calendar() {
    if [[ "$calendar_enabled" != "true" ]]; then
        return
    fi
    
    print_status "Setting up calendar functionality..."
    
    local vault_path="$1"
    
    # Add calendar directory
    mkdir -p "$vault_path/200_Calendar"
    print_success "Created calendar directory"
    
    create_calendar_categories "$vault_path"
}

# Create calendar category subdirectories
create_calendar_categories() {
    local vault_path="$1"
    local calendar_dir="$vault_path/200_Calendar"
    
    print_status "Creating calendar category subdirectories..."
    
    for category in "${calendar_categories[@]}"; do
        local category_dir="$calendar_dir/$category"
        mkdir -p "$category_dir"
        print_success "Created: $category_dir"
    done
}

# Show calendar setup summary
show_calendar_summary() {
    if [[ "$calendar_enabled" != "true" ]]; then
        return
    fi
    
    echo
    print_status "Calendar integration enabled with category subdirectories created."
}