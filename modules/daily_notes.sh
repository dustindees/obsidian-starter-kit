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

# Get routine content from user for each selected category
get_routine_content() {
    if [[ ${#routine_categories[@]} -eq 0 ]]; then
        return
    fi
    
    echo
    print_status "Now let's fill in your daily routines..."
    print_status "For each routine category, you can add:"
    print_status "  1) Checkbox items (queriable): '- [ ] Water'"
    print_status "  2) Colon-delineated fields (queriable): 'Pushups: 80'"
    print_status "  3) Any other content you want"
    echo
    
    # Initialize associative array for routine contents
    declare -gA routine_contents
    
    for category in "${routine_categories[@]}"; do
        echo
        print_status "Setting up routines for: $category"
        
        local content=""
        
        # Get checkbox items
        echo
        print_status "Checkbox items for $category:"
        print_status "Enter checkbox field names (press Enter on empty line to finish):"
        while true; do
            read -p "Checkbox field: " checkbox_field
            if [[ -z "$checkbox_field" ]]; then
                break
            fi
            
            # Add newline if content already exists
            if [[ -n "$content" ]]; then
                content="$content\n"
            fi
            
            content="$content- [ ] $checkbox_field"
        done
        
        # Get colon-delineated fields
        echo
        print_status "Colon-delineated fields for $category:"
        print_status "Enter field names (press Enter on empty line to finish):"
        while true; do
            read -p "Field name: " field_name
            if [[ -z "$field_name" ]]; then
                break
            fi
            
            read -p "Default value (optional): " field_value
            
            # Add newline if content already exists
            if [[ -n "$content" ]]; then
                content="$content\n"
            fi
            
            if [[ -n "$field_value" ]]; then
                content="$content$field_name: $field_value"
            else
                content="$content$field_name: "
            fi
        done
        
        # Get any other content
        echo
        print_status "Any other content for $category:"
        print_status "Enter additional items (press Enter on empty line to finish):"
        while true; do
            read -p "Additional item: " additional_item
            if [[ -z "$additional_item" ]]; then
                break
            fi
            
            # Add newline if content already exists
            if [[ -n "$content" ]]; then
                content="$content\n"
            fi
            
            content="$content$additional_item"
        done
        
        if [[ -n "$content" ]]; then
            routine_contents["$category"]="$content"
            print_success "Added content for $category"
        else
            print_warning "No content added for $category"
        fi
    done
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
        
        # Create file with routine content if available
        if [[ -n "${routine_contents[$category]}" ]]; then
            echo -e "${routine_contents[$category]}" > "$filepath"
        else
            touch "$filepath"
        fi
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