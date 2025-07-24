#!/usr/bin/env bash

# Entertainment module for Obsidian Starter Kit installer

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

# Setup entertainment functionality
setup_entertainment() {
    if [[ "$entertainment_enabled" != "true" ]]; then
        return
    fi
    
    print_status "Setting up entertainment functionality..."
    
    local vault_path="$1"
    create_entertainment_moc "$vault_path"
    create_entertainment_lists "$vault_path"
}

# Create entertainment MOC file
create_entertainment_moc() {
    local vault_path="$1"
    local permanent_dir="$vault_path/300_Permanent"
    local filepath="$permanent_dir/0-Entertainment.md"
    
    print_status "Creating entertainment MOC file..."
    touch "$filepath"
    print_success "Created: $filepath"
}

# Create entertainment category list files
create_entertainment_lists() {
    local vault_path="$1"
    local permanent_dir="$vault_path/300_Permanent"
    
    print_status "Creating entertainment list files..."
    
    for category in "${entertainment_categories[@]}"; do
        local filename
        filename="${category// /_}"
        local filepath="$permanent_dir/${filename}_List.md"
        
        # Create the file with the template content
        cat > "$filepath" << EOF
Associated MOCs: [[0-Entertainment]]

---

# On Deck 


# Ongoing


# TODO 


# Completed 2025


EOF
        
        print_success "Created: $filepath"
    done
}

# Show entertainment setup summary
show_entertainment_summary() {
    if [[ "$entertainment_enabled" != "true" ]]; then
        return
    fi
    
    echo
    print_status "Entertainment integration enabled with MOC and list files created."
}