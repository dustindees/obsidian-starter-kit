#!/usr/bin/env bash

# Daily notes module for Obsidian Starter Kit installer

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

# Setup daily notes functionality
setup_daily_notes() {
    if [[ "$daily_notes_enabled" != "true" ]]; then
        return
    fi
    
    print_status "Setting up daily notes functionality..."
    
    # Add daily notes directories
    local vault_path="$1"
    mkdir -p "$vault_path/900_Routines"
    mkdir -p "$vault_path/997_Automation"
    print_success "Created daily notes directories"
    
    create_scripts_directory
    create_automation_files "$vault_path"
}

# Create external scripts directory
create_scripts_directory() {
    local scripts_dir="${vault_name}_scripts"
    
    print_status "Creating external scripts directory: $scripts_dir"
    mkdir -p "$scripts_dir"
    print_success "Created: $scripts_dir"
}

# Create automation files for building daily notes
create_automation_files() {
    local vault_path="$1"
    local automation_dir="$vault_path/997_Automation"
    
    print_status "Creating automation files..."
    
    # Create files for selected routine categories
    for category in "${routine_categories[@]}"; do
        local filename=$(echo "$category" | sed 's/[[:space:]]/_/g')
        local filepath="$automation_dir/${filename}_Daily.md"
        touch "$filepath"
        print_success "Created: $filepath"
    done
    
    # Create default automation files
    local default_files=(
        "Inbox_Weekly.md"
        "Recurring_Tasks_Weekly.md"
        "Recurring_Tasks_Monthly.md"
        "Recurring_Tasks_Quarterly.md"
        "Recurring_Tasks_Biannually.md"
        "Recurring_Tasks_Annually.md"
    )
    
    for file in "${default_files[@]}"; do
        local filepath="$automation_dir/$file"
        touch "$filepath"
        print_success "Created: $filepath"
    done
}

# Show daily notes setup summary
show_daily_notes_summary() {
    if [[ "$daily_notes_enabled" != "true" ]]; then
        return
    fi
    
    echo
    print_status "Daily notes integration enabled with automation files created."
    print_status "Scripts directory: ${vault_name}_scripts"
}