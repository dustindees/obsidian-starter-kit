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
}