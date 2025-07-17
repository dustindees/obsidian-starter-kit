#!/usr/bin/env bash

# Menu module for Obsidian Starter Kit installer

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

# Show main installation menu and get user choices
show_installation_menu() {
    echo "================================================"
    echo "     Obsidian Starter Kit Installer"
    echo "================================================"
    echo
    
    # Initialize global variables
    daily_notes_enabled=false
    moc_enabled=false
    journaling_enabled=false
    calendar_enabled=false
    entertainment_enabled=false
    backup_enabled=false
    local_backup_enabled=false
    remote_backup_enabled=false
    local_backup_dir=""
    git_repo_url=""
    routine_categories=()
    moc_categories=()
    calendar_categories=()
    entertainment_categories=()
    
    check_fzf
    get_vault_name
    
    # Get user preferences for each module
    ask_daily_notes
    if [[ "$daily_notes_enabled" == "true" ]]; then
        get_routine_categories
        # Source daily_notes.sh to access get_routine_content function
        source "$(dirname "${BASH_SOURCE[0]}")/daily_notes.sh"
        get_routine_content
    fi
    
    ask_moc_integration
    if [[ "$moc_enabled" == "true" ]]; then
        get_moc_categories
    fi
    
    ask_journaling_integration
    ask_calendar_integration
    if [[ "$calendar_enabled" == "true" ]]; then
        get_calendar_categories
    fi
    
    ask_entertainment_integration
    if [[ "$entertainment_enabled" == "true" ]]; then
        get_entertainment_categories
    fi
    
    ask_backup_integration
}

# Ask about daily notes integration
ask_daily_notes() {
    echo
    print_status "Do you want to integrate daily notes functionality?"
    
    choice=$(echo -e "Yes\nNo" | fzf --prompt="Daily notes integration: " --height=5)
    
    if [[ "$choice" == "Yes" ]]; then
        daily_notes_enabled=true
        print_success "Daily notes integration enabled"
    else
        daily_notes_enabled=false
        print_success "Daily notes integration disabled"
    fi
}

# Get routine categories from user
get_routine_categories() {
    echo
    print_status "Select your preferred daily routine categories:"
    
    local default_categories=("Morning" "Health" "Inbox" "Recurring Tasks" "Night")
    local selected_categories=()
    
    # Multi-select from defaults
    print_status "Select from default categories (use TAB to select multiple):"
    local selected_defaults
    selected_defaults=$(printf '%s\n' "${default_categories[@]}" | fzf --multi --prompt="Select categories: " --height=10)
    
    if [[ -n "$selected_defaults" ]]; then
        while IFS= read -r category; do
            selected_categories+=("$category")
        done <<< "$selected_defaults"
    fi
    
    # Ask for custom categories
    echo
    print_status "Enter any custom routine categories (one per line, empty line to finish):"
    while true; do
        read -p "> " custom_category
        if [[ -z "$custom_category" ]]; then
            break
        fi
        selected_categories+=("$custom_category")
    done
    
    routine_categories=("${selected_categories[@]}")
    
    if [[ ${#routine_categories[@]} -gt 0 ]]; then
        print_success "Selected routine categories: ${routine_categories[*]}"
    else
        print_warning "No routine categories selected"
    fi
}

# Ask about MOC integration
ask_moc_integration() {
    echo
    print_status "Do you want to integrate MOC (Maps of Content) functionality?"
    
    choice=$(echo -e "Yes\nNo" | fzf --prompt="MOC integration: " --height=5)
    
    if [[ "$choice" == "Yes" ]]; then
        moc_enabled=true
        print_success "MOC integration enabled"
    else
        moc_enabled=false
        print_success "MOC integration disabled"
    fi
}

# Get MOC categories from user
get_moc_categories() {
    echo
    print_status "Select your preferred MOC (Maps of Content) categories:"
    
    local default_categories=("Profession" "Personal Finance" "Health & Fitness" "History" "Language" "Science")
    local selected_categories=()
    
    # Multi-select from defaults
    print_status "Select from default categories (use TAB to select multiple):"
    local selected_defaults
    selected_defaults=$(printf '%s\n' "${default_categories[@]}" | fzf --multi --prompt="Select MOC categories: " --height=10)
    
    if [[ -n "$selected_defaults" ]]; then
        while IFS= read -r category; do
            selected_categories+=("$category")
        done <<< "$selected_defaults"
    fi
    
    # Ask for custom categories
    echo
    print_status "Enter any custom MOC categories (one per line, empty line to finish):"
    while true; do
        read -p "> " custom_category
        if [[ -z "$custom_category" ]]; then
            break
        fi
        selected_categories+=("$custom_category")
    done
    
    moc_categories=("${selected_categories[@]}")
    
    if [[ ${#moc_categories[@]} -gt 0 ]]; then
        print_success "Selected MOC categories: ${moc_categories[*]}"
    else
        print_warning "No MOC categories selected"
    fi
}

# Ask about journaling integration
ask_journaling_integration() {
    echo
    print_status "Do you want to integrate journaling functionality?"
    
    choice=$(echo -e "Yes\nNo" | fzf --prompt="Journaling integration: " --height=5)
    
    if [[ "$choice" == "Yes" ]]; then
        journaling_enabled=true
        print_success "Journaling integration enabled"
    else
        journaling_enabled=false
        print_success "Journaling integration disabled"
    fi
}

# Ask about calendar integration
ask_calendar_integration() {
    echo
    print_status "Do you want to integrate calendar functionality?"
    
    choice=$(echo -e "Yes\nNo" | fzf --prompt="Calendar integration: " --height=5)
    
    if [[ "$choice" == "Yes" ]]; then
        calendar_enabled=true
        print_success "Calendar integration enabled"
    else
        calendar_enabled=false
        print_success "Calendar integration disabled"
    fi
}

# Get calendar categories from user
get_calendar_categories() {
    echo
    print_status "Select your preferred calendar categories:"
    
    local default_categories=("Work" "Personal" "Social")
    local selected_categories=()
    
    # Multi-select from defaults
    print_status "Select from default categories (use TAB to select multiple):"
    local selected_defaults
    selected_defaults=$(printf '%s\n' "${default_categories[@]}" | fzf --multi --prompt="Select categories: " --height=10)
    
    if [[ -n "$selected_defaults" ]]; then
        while IFS= read -r category; do
            selected_categories+=("$category")
        done <<< "$selected_defaults"
    fi
    
    # Ask for custom categories
    echo
    print_status "Enter any custom calendar categories (one per line, empty line to finish):"
    while true; do
        read -p "> " custom_category
        if [[ -z "$custom_category" ]]; then
            break
        fi
        selected_categories+=("$custom_category")
    done
    
    calendar_categories=("${selected_categories[@]}")
    
    if [[ ${#calendar_categories[@]} -gt 0 ]]; then
        print_success "Selected calendar categories: ${calendar_categories[*]}"
    else
        print_warning "No calendar categories selected"
    fi
}

# Ask about entertainment integration
ask_entertainment_integration() {
    echo
    print_status "Do you want to integrate entertainment functionality?"
    
    choice=$(echo -e "Yes\nNo" | fzf --prompt="Entertainment integration: " --height=5)
    
    if [[ "$choice" == "Yes" ]]; then
        entertainment_enabled=true
        print_success "Entertainment integration enabled"
    else
        entertainment_enabled=false
        print_success "Entertainment integration disabled"
    fi
}

# Get entertainment categories from user
get_entertainment_categories() {
    echo
    print_status "Select your preferred entertainment categories:"
    
    local default_categories=("TV shows" "Movies" "Video games" "Anime" "Podcasts" "Books" "Boardgames")
    local selected_categories=()
    
    # Multi-select from defaults
    print_status "Select from default categories (use TAB to select multiple):"
    local selected_defaults
    selected_defaults=$(printf '%s\n' "${default_categories[@]}" | fzf --multi --prompt="Select categories: " --height=10)
    
    if [[ -n "$selected_defaults" ]]; then
        while IFS= read -r category; do
            selected_categories+=("$category")
        done <<< "$selected_defaults"
    fi
    
    # Ask for custom categories
    echo
    print_status "Enter any custom entertainment categories (one per line, empty line to finish):"
    while true; do
        read -p "> " custom_category
        if [[ -z "$custom_category" ]]; then
            break
        fi
        selected_categories+=("$custom_category")
    done
    
    entertainment_categories=("${selected_categories[@]}")
    
    if [[ ${#entertainment_categories[@]} -gt 0 ]]; then
        print_success "Selected entertainment categories: ${entertainment_categories[*]}"
    else
        print_warning "No entertainment categories selected"
    fi
}

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