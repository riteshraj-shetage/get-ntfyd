#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

check_services() {
    cd "$PROJECT_DIR"
    if ! docker compose ps ntfy | grep -q "running"; then
        echo "Error: ntfy service is not running"
        return 1
    fi
    return 0
}

user_add() {
    read -p "Username: " username
    [ -z "$username" ] && { echo "Error: Username cannot be empty"; return 1; }
    
    echo "  1) Admin"
    echo "  2) User"
    read -p "Choice [1-2]: " role_choice
    
    case $role_choice in
        1) docker exec -it ntfy ntfy user add --role=admin "$username" ;;
        2) docker exec -it ntfy ntfy user add "$username" ;;
        *) echo "Error: Invalid choice"; return 1 ;;
    esac
}

user_list() {
    docker exec -it ntfy ntfy user list
}

user_change_password() {
    docker exec -it ntfy ntfy user list
    read -p "Username: " username
    [ -z "$username" ] && { echo "Error: Username cannot be empty"; return 1; }
    docker exec -it ntfy ntfy user change-pass "$username"
}

user_delete() {
    docker exec ntfy ntfy user list
    read -p "Username to delete: " username
    [ -z "$username" ] && { echo "Error: Username cannot be empty"; return 1; }
    read -p "Are you sure you want to delete '$username'? (y/N) " -n 1 -r
    echo
    [[ ! $REPLY =~ ^[Yy]$ ]] && return 0
    docker exec -it ntfy ntfy user del "$username"
}

user_change_role() {
    docker exec ntfy ntfy user list
    read -p "Username: " username
    [ -z "$username" ] && { echo "Error: Username cannot be empty"; return 1; }
    
    echo "  1) Admin"
    echo "  2) User"
    read -p "Choice [1-2]: " role_choice
    
    case $role_choice in
        1) docker exec -it ntfy ntfy user change-role "$username" admin ;;
        2) docker exec -it ntfy ntfy user change-role "$username" user ;;
        *) echo "Error: Invalid choice"; return 1 ;;
    esac
}

user_management() {
    while true; do
        clear
        echo "User Management"
        echo ""
        echo "  1) Add new user"
        echo "  2) List users"
        echo "  3) Change user password"
        echo "  4) Change user role"
        echo "  5) Delete user"
        echo "  0) Back to main menu"
        echo ""
        read -p "Enter choice [0-5]: " choice
        echo ""
        
        case $choice in
            1) user_add ;;
            2) user_list ;;
            3) user_change_password ;;
            4) user_change_role ;;
            5) user_delete ;;
            0) return ;;
            *) echo "Error: Invalid choice" ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
    done
}

token_add() {
    docker exec ntfy ntfy user list
    read -p "Username: " username
    [ -z "$username" ] && { echo "Error: Username cannot be empty"; return 1; }
    read -p "Token label: " label
    [ -z "$label" ] && label="token-$username-$(date +%Y%m%d-%H%M%S)"
    docker exec -it ntfy ntfy token add --label="$label" "$username"
}

token_list() {
    docker exec ntfy ntfy user list
    read -p "Username (or press Enter for all): " username
    if [ -z "$username" ]; then
        docker exec -it ntfy ntfy token list
    else
        docker exec -it ntfy ntfy token list "$username"
    fi
}

token_remove() {
    docker exec ntfy ntfy user list
    read -p "Username: " username
    [ -z "$username" ] && { echo "Error: Username cannot be empty"; return 1; }
    docker exec ntfy ntfy token list "$username"
    read -p "Token to remove: " token
    [ -z "$token" ] && { echo "Error: Token cannot be empty"; return 1; }
    docker exec -it ntfy ntfy token remove "$username" "$token"
}

token_management() {
    while true; do
        clear
        echo "Token Management"
        echo ""
        echo "  1) Create access token"
        echo "  2) List tokens"
        echo "  3) Remove token"
        echo "  0) Back to main menu"
        echo ""
        read -p "Enter choice [0-3]: " choice
        echo ""
        
        case $choice in
            1) token_add ;;
            2) token_list ;;
            3) token_remove ;;
            0) return ;;
            *) echo "Error: Invalid choice" ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
    done
}

service_status() {
    cd "$PROJECT_DIR"
    docker compose ps
}

backup_create() {
    cd "$PROJECT_DIR"
    [ ! -f "./scripts/backup.sh" ] && { echo "Error: backup.sh not found"; return 1; }
    ./scripts/backup.sh
}

backup_restore() {
    cd "$PROJECT_DIR"
    [ ! -f "./scripts/restore.sh" ] && { echo "Error: restore.sh not found"; return 1; }
    ls -lh backup/*.tar.gz 2>/dev/null || echo "No backups found"
    read -p "Backup file path: " backup_file
    [ -z "$backup_file" ] && { echo "Error: Backup file path cannot be empty"; return 1; }
    ./scripts/restore.sh "$backup_file"
}

generate_webpush_keys() {
    docker exec -it ntfy ntfy webpush keys
    echo "Copy these keys to your .env file and restart the service"
}

backup_operations() {
    while true; do
        clear
        echo "Backup & Restore"
        echo ""
        echo "  1) Create backup"
        echo "  2) Restore from backup"
        echo "  0) Back to main menu"
        echo ""
        read -p "Enter choice [0-2]: " choice
        echo ""
        
        case $choice in
            1) backup_create ;;
            2) backup_restore ;;
            0) return ;;
            *) echo "Error: Invalid choice" ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
    done
}

main_menu() {
    while true; do
        clear
        echo "ntfy Service Manager"
        
        cd "$PROJECT_DIR"
        if docker compose ps ntfy 2>/dev/null | grep -q "running"; then
            echo "Status: Running"
        else
            echo "Status: Stopped"
        fi
        
        echo ""
        echo "  1) View status"
        echo "  2) User management"
        echo "  3) Token management"
        echo "  4) Backup/Restore"
        echo "  5) Generate Web Push keys"
        echo "  0) Exit"
        echo ""
        
        read -p "Enter choice [0-5]: " choice
        echo ""
        
        case $choice in
            1) service_status; echo ""; read -p "Press Enter to continue..." ;;
            2) check_services && user_management || read -p "Press Enter to continue..." ;;
            3) check_services && token_management || read -p "Press Enter to continue..." ;;
            4) backup_operations ;;
            5) check_services && { generate_webpush_keys; echo ""; read -p "Press Enter to continue..."; } || read -p "Press Enter to continue..." ;;
            0) exit 0 ;;
            *) echo "Error: Invalid choice"; read -p "Press Enter to continue..." ;;
        esac
    done
}

cd "$PROJECT_DIR"

if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed"
    exit 1
fi

main_menu
