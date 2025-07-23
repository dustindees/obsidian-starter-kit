#!/usr/bin/env bash

# Shared utilities for Obsidian Starter Kit modules

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
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check core dependencies required for installation
check_core_dependencies() {
    print_status "Checking core dependencies..."
    check_fzf
    print_success "All core dependencies are available"
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

# Check if git is installed
check_git() {
    if ! command -v git &> /dev/null; then
        print_error "git is not installed. Git is required for remote backup functionality."
        print_status "On Ubuntu/Debian: sudo apt install git"
        print_status "On macOS: brew install git"
        print_status "On other systems: https://git-scm.com/downloads"
        return 1
    fi
    return 0
}

# Check if crontab is available and user can create crontab entries
check_crontab() {
    if ! command -v crontab &> /dev/null; then
        print_error "crontab is not installed. Crontab is required for local backup scheduling."
        print_status "On Ubuntu/Debian: sudo apt install cron"
        print_status "On macOS: crontab should be available by default"
        return 1
    fi
    
    # Test if user can access crontab
    if ! crontab -l &> /dev/null && [[ $? -ne 0 ]]; then
        # Try to create an empty crontab to test permissions
        if ! (echo "" | crontab -) &> /dev/null; then
            print_error "Cannot create or modify crontab entries. This may be due to:"
            print_status "- Missing permissions (contact your system administrator)"
            print_status "- Cron service not running: sudo systemctl start cron"
            print_status "- User not allowed to use cron: check /etc/cron.allow and /etc/cron.deny"
            return 1
        fi
    fi
    
    return 0
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

# Create basic directory structure
create_base_directories() {
    local vault_path="$1"
    local dirs=(
        "100_Inbox"
        "300_Permanent" 
        "998_Attachments"
        "999_Templates"
    )
    
    print_status "Creating vault directory: $vault_path"
    mkdir -p "$vault_path"
    
    print_status "Creating base subdirectories..."
    for dir in "${dirs[@]}"; do
        mkdir -p "$vault_path/$dir"
        print_success "Created: $vault_path/$dir"
    done
    
    # Copy default templates to 999_Templates directory
    local templates_source="$SCRIPT_DIR/modules/templates/999_Templates"
    if [[ -d "$templates_source" ]]; then
        print_status "Copying default templates..."
        cp "$templates_source"/*.md "$vault_path/999_Templates/" 2>/dev/null || true
        local template_count
        template_count=$(find "$vault_path/999_Templates/" -name "*.md" | wc -l)
        if [[ $template_count -gt 0 ]]; then
            print_success "Copied $template_count template files to 999_Templates"
        fi
    fi
}