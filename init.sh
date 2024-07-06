#!/bin/bash

# Define the directory where your task scripts are located
SCRIPT_DIR="$(dirname "$0")/tasks"
ERROR_FILE="/tmp/setup_dotfiles_errors.log" 
: > "$ERROR_FILE"  # Clear the error file at the start

# Function to run a task script
run_task() {
    local script="$1"
    if [ -f "$script" ]; then
        bash "$script"
    else
        echo "[dotfiles::error] Task script $script not found!"
    fi
}

# Prompt the user for confirmation
echo "[dotfiles] This script will set up dotfiles on a new Arch Linux machine. Do you want to proceed? [(y)es/(n)o]"
read -r response

if [[ "$response" =~ ^(yes|y)$ ]]; then
    # List of task scripts to run
    tasks=(
        "setup-pacman.sh"
	"setup-bluetooth.sh"
        # Add more task scripts here
        # "another-task.sh"
    )

    # Run each task script
    for task in "${tasks[@]}"; do
        run_task "$SCRIPT_DIR/$task"
    done

    # Check if there were any errors in the task setup
    if [ -s "$ERROR_FILE" ]; then
        echo -e "\033[0;31m[dotfiles::error] There were some errors during the setup:"
        while IFS= read -r error; do
            echo -e "\033[0;31m$error"
        done < "$ERROR_FILE"
    else
	echo
        echo "[dotfiles] All tasks completed successfully with no errors."
    fi

    # Clean up the error file
    rm "$ERROR_FILE"
else
    echo "[dotfiles::exited] Setup aborted by the user."
    exit 1
fi
