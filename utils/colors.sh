#!/bin/bash

# colors.sh
# Description: Utility functions for colored terminal output
# Usage: source utils/colors.sh

# Color definitions
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export MAGENTA='\033[0;35m'
export CYAN='\033[0;36m'
export WHITE='\033[1;37m'
export NC='\033[0m' # No Color

# Print functions
print_red() {
    echo -e "${RED}$1${NC}"
}

print_green() {
    echo -e "${GREEN}$1${NC}"
}

print_yellow() {
    echo -e "${YELLOW}$1${NC}"
}

print_blue() {
    echo -e "${BLUE}$1${NC}"
}

print_magenta() {
    echo -e "${MAGENTA}$1${NC}"
}

print_cyan() {
    echo -e "${CYAN}$1${NC}"
}

# Status functions
print_error() {
    print_red "❌ ERROR: $1"
}

print_success() {
    print_green "✅ SUCCESS: $1"
}

print_warning() {
    print_yellow "⚠️  WARNING: $1"
}

print_info() {
    print_blue "ℹ️  INFO: $1"
}
