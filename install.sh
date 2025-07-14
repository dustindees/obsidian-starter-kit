#!/usr/bin/env bash

# Obsidian Starter Kit Installer

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source all modules
source "$SCRIPT_DIR/modules/utils.sh"
source "$SCRIPT_DIR/modules/menu.sh"
source "$SCRIPT_DIR/modules/daily_notes.sh"
source "$SCRIPT_DIR/modules/moc.sh"
source "$SCRIPT_DIR/modules/journaling.sh"
source "$SCRIPT_DIR/modules/calendar.sh"


main() {
    # Base vault and menu
    show_installation_menu
    create_base_directories "$vault_name"
    
    # Setup modules based on user choices
    setup_daily_notes "$vault_name"
    setup_moc "$vault_name"
    setup_journaling "$vault_name"
    setup_calendar "$vault_name"
    
    # Show completion summary
    echo
    print_success "Vault '$vault_name' created successfully!"
    echo
    print_status "Directory structure:"
    tree "$vault_name" 2>/dev/null || ls -la "$vault_name"
    
    # Show module summaries
    show_daily_notes_summary
    show_moc_summary
    show_journaling_summary
    show_calendar_summary
    
    echo
    print_status "You can now open this vault in Obsidian by selecting the '$vault_name' folder."
}

# Run the installer
main "$@"