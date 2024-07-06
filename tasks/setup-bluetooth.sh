#!/bin/bash


log_msg() {
    echo "[task::bluetooth] $1"
}

log_msg "starting bluetooth setup"

# check if bluetooth.service is enabled
is_enabled=$(systemctl is-enabled bluetooth.service 2>/dev/null)
if [ "$is_enabled" != "enabled" ]; then
    log_msg "bluetooth.service is not enabled. Enabling it now..."
    sudo systemctl enable bluetooth.service
else
    log_msg "bluetooth.service is already enabled."
fi

# check if bluetooth.service is active (running)
is_active=$(systemctl is-active bluetooth.service 2>/dev/null)
if [ "$is_active" != "active" ]; then
    echo "bluetooth.service is not running. Starting it now..."
    log_msg systemctl start bluetooth.service
else
    log_msg "bluetooth.service is already running."
fi

log_msg "finished bluetooth setup"

