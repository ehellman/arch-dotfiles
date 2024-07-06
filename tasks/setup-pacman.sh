#!/bin/bash

# Task name variable
TASK_NAME="pacman"

ERROR_FILE="/tmp/setup_dotfiles_errors.log"
PACMAN_CONF="/etc/pacman.conf"

log_msg() {
    echo "[task::$TASK_NAME] $1"
}

log_error() {
    local msg="[task::$TASK_NAME::error] $1"
    echo "$msg"
    echo "$msg" >> "$ERROR_FILE"
}

# Function to check and uncomment a key
check_and_uncomment() {
    local key=$1
    if grep -q "^# *$key" $PACMAN_CONF; then
        log_msg "$key is commented. Uncommenting it now..."
        if ! sudo sed -i "s/^# *$key/$key/" $PACMAN_CONF; then
            log_error "Failed to uncomment $key."
        fi
    elif grep -q "^$key" $PACMAN_CONF; then
        log_msg "$key is already enabled."
    else
        log_error "$key does not exist in $PACMAN_CONF."
    fi
}

log_msg "starting $TASK_NAME setup"

# Check and uncomment necessary keys
check_and_uncomment "Color"
check_and_uncomment "VerbosePkgLists"
check_and_uncomment "ParallelDownloads"

# Check and add ILoveCandy if it does not exist
if ! grep -q "^ILoveCandy" $PACMAN_CONF; then
    log_msg "Adding ILoveCandy to $PACMAN_CONF..."

    # Find the last occurrence of the necessary keys and insert ILoveCandy after it
    last_occurrence_line=$(grep -n -E "^(Color|VerbosePkgLists|ParallelDownloads)" $PACMAN_CONF | tail -1 | cut -d: -f1)
    if [ -n "$last_occurrence_line" ]; then
        if ! sudo sed -i "$((last_occurrence_line + 1))i ILoveCandy" $PACMAN_CONF; then
            log_error "Failed to add ILoveCandy to $PACMAN_CONF."
        fi
    else
        log_error "Could not find the appropriate place to insert ILoveCandy."
    fi
else
    log_msg "ILoveCandy is already present in $PACMAN_CONF."
fi

log_msg "finished $TASK_NAME task"

