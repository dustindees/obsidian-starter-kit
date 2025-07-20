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

# Get recurring routine content from user for each selected frequency
get_recurring_routine_content() {
    if [[ ${#recurring_routine_frequencies[@]} -eq 0 ]]; then
        return
    fi
    
    echo
    print_status "Now let's fill in your recurring routines..."
    print_status "For each frequency, you can add:"
    print_status "  1) Checkbox items (queriable): '- [ ] Review monthly goals'"
    print_status "  2) Colon-delineated fields (queriable): 'Budget Review: Complete'"
    print_status "  3) Any other content you want"
    echo
    
    # Initialize associative array for recurring routine contents
    declare -gA recurring_routine_contents
    
    for frequency in "${recurring_routine_frequencies[@]}"; do
        echo
        print_status "Setting up $frequency recurring routines:"
        
        local content=""
        
        # Get checkbox items
        echo
        print_status "Checkbox items for $frequency routines:"
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
        print_status "Colon-delineated fields for $frequency routines:"
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
        print_status "Any other content for $frequency routines:"
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
            recurring_routine_contents["$frequency"]="$content"
            print_success "Added content for $frequency routines"
        else
            print_warning "No content added for $frequency routines"
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
        local header="# $category"
        if [[ -n "${routine_contents[$category]}" ]]; then
            echo -e "$header\n\n${routine_contents[$category]}" > "$filepath"
        else
            echo "$header" > "$filepath"
        fi
        print_success "Created: $filepath"
    done
    
    # Create recurring routine files for selected frequencies
    for frequency in "${recurring_routine_frequencies[@]}"; do
        local filename="Recurring_Tasks_${frequency}.md"
        local filepath="$automation_dir/$filename"
        
        # Create file with recurring routine content if available
        local header="# Recurring Tasks $frequency"
        if [[ -n "${recurring_routine_contents[$frequency]}" ]]; then
            echo -e "$header\n\n${recurring_routine_contents[$frequency]}" > "$filepath"
        else
            echo "$header" > "$filepath"
        fi
        print_success "Created: $filepath"
    done
    
    # Create default automation files if not already created by recurring routines
    local default_files=(
        "Inbox_Weekly.md"
    )
    
    # Add default files for frequencies not selected by user
    local all_frequencies=("Weekly" "Monthly" "Quarterly" "Biannually" "Annually")
    for freq in "${all_frequencies[@]}"; do
        local freq_selected=false
        for selected_freq in "${recurring_routine_frequencies[@]}"; do
            if [[ "$freq" == "$selected_freq" ]]; then
                freq_selected=true
                break
            fi
        done
        
        if [[ "$freq_selected" == "false" ]]; then
            default_files+=("Recurring_Tasks_${freq}.md")
        fi
    done
    
    for file in "${default_files[@]}"; do
        local filepath="$automation_dir/$file"
        
        # Determine appropriate header based on filename
        local header=""
        if [[ "$file" == "Inbox_Weekly.md" ]]; then
            header="# Inbox"
        elif [[ "$file" =~ ^Recurring_Tasks_(.+)\.md$ ]]; then
            local freq="${BASH_REMATCH[1]}"
            header="# Recurring Tasks $freq"
        fi
        
        if [[ -n "$header" ]]; then
            echo "$header" > "$filepath"
        else
            touch "$filepath"
        fi
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
    
    if [[ ${#recurring_routine_frequencies[@]} -gt 0 ]]; then
        echo
        print_status "Recurring routines configured for: ${recurring_routine_frequencies[*]}"
    fi
}