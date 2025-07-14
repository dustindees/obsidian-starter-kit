#!/usr/bin/env bash

# Obsidian Starter Kit Installer
# Creates a new Obsidian vault with custom directory structure

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"3
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if fzf is installed
check_fzf() {
    if ! command -v fzf &> /dev/null; then
        print_error "fzf is not installed. Please install fzf first."
        print_status "On Ubuntu/Debian: sudo apt install fzf"
        print_status "On macOS: brew install fzf"
        print_status "On other systems: https://github.com/junegunn/fzf#installation"
        exit 1
    fi
}

# Get vault name from user
get_vault_name() {
    echo
    print_status "Enter your desired vault name:"
    read -p "> " vault_name
    
    # Validate input
    if [[ -z "$vault_name" ]]; then
        print_error "Vault name cannot be empty."
        get_vault_name
        return
    fi
    
    # Remove any trailing spaces and replace spaces with underscores
    vault_name=$(echo "$vault_name" | sed 's/[[:space:]]*$//' | sed 's/[[:space:]]/_/g')
    
    # Check if directory already exists
    if [[ -d "$vault_name" ]]; then
        print_warning "Directory '$vault_name' already exists."
        echo "Choose an option:"
        echo "1) Use a different name"
        echo "2) Continue anyway (will create subdirectories in existing folder)"
        
        choice=$(echo -e "Use different name\nContinue anyway" | fzf --prompt="Select option: " --height=5)
        
        if [[ "$choice" == "Use different name" ]]; then
            get_vault_name
            return
        fi
    fi
    
    print_success "Vault name set to: $vault_name"
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
    if [[ "$daily_notes_enabled" != "true" ]]; then
        return
    fi
    
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
    if [[ "$calendar_enabled" != "true" ]]; then
        return
    fi
    
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

# Create directory structure
create_directories() {
    local vault_path="$1"
    local dirs=(
        "100_Inbox"
        "300_Permanent" 
        "998_Attachments"
        "999_Templates"
    )
    
    # Add daily notes directories if enabled
    if [[ "$daily_notes_enabled" == "true" ]]; then
        dirs+=("900_Routines" "997_Automation")
    fi
    
    # Add calendar directory if enabled
    if [[ "$calendar_enabled" == "true" ]]; then
        dirs+=("200_Calendar")
    fi
    
    print_status "Creating vault directory: $vault_path"
    mkdir -p "$vault_path"
    
    print_status "Creating subdirectories..."
    for dir in "${dirs[@]}"; do
        mkdir -p "$vault_path/$dir"
        print_success "Created: $vault_path/$dir"
    done
}

# Create external scripts directory
create_scripts_directory() {
    if [[ "$daily_notes_enabled" != "true" ]]; then
        return
    fi
    
    local scripts_dir="${vault_name}_scripts"
    
    print_status "Creating external scripts directory: $scripts_dir"
    mkdir -p "$scripts_dir"
    print_success "Created: $scripts_dir"
}

# Create automation files for building daily notes
create_automation_files() {
    if [[ "$daily_notes_enabled" != "true" ]]; then
        return
    fi
    
    local automation_dir="$vault_name/997_Automation"
    
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

# Create calendar category subdirectories
create_calendar_categories() {
    if [[ "$calendar_enabled" != "true" ]]; then
        return
    fi
    
    local calendar_dir="$vault_name/200_Calendar"
    
    print_status "Creating calendar category subdirectories..."
    
    for category in "${calendar_categories[@]}"; do
        local category_dir="$calendar_dir/$category"
        mkdir -p "$category_dir"
        print_success "Created: $category_dir"
    done
}

# Main installation function
main() {
    echo "================================================"
    echo "     Obsidian Starter Kit Installer"
    echo "================================================"
    echo
    
    # Global variables
    daily_notes_enabled=false
    calendar_enabled=false
    routine_categories=()
    calendar_categories=()
    
    check_fzf
    get_vault_name
    ask_daily_notes
    get_routine_categories
    ask_calendar_integration
    get_calendar_categories
    create_directories "$vault_name"
    create_scripts_directory
    create_automation_files
    create_calendar_categories
    
    echo
    print_success "Vault '$vault_name' created successfully!"
    echo
    print_status "Directory structure:"
    tree "$vault_name" 2>/dev/null || ls -la "$vault_name"
    
    if [[ "$daily_notes_enabled" == "true" ]]; then
        echo
        print_status "Daily notes integration enabled with automation files created."
        print_status "Scripts directory: ${vault_name}_scripts"
    fi
    
    if [[ "$calendar_enabled" == "true" ]]; then
        echo
        print_status "Calendar integration enabled with category subdirectories created."
    fi
    
    echo
    print_status "You can now open this vault in Obsidian by selecting the '$vault_name' folder."
}

# Run the installer
main "$@"