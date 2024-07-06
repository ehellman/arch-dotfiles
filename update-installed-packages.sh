#!/bin/bash

OUTPUT_FILE_PACMAN="installed_packages_pacman.txt"
OUTPUT_FILE_AUR="installed_packages_aur.txt"
TEMP_FILE="temp_installed_packages.txt"

log_msg() {
    echo "[task::update-packages] $1"
}

log_msg "Retrieving the list of explicitly installed packages..."
# Get the list of explicitly installed packages
pacman -Qqet > "$TEMP_FILE"

log_msg "Retrieving the list of all available official repository packages..."
# Get the list of all available official repository packages
official_repo_packages=$(pacman -Slq)

log_msg "Separating official repository packages from AUR packages..."
# Separate official repository packages from AUR packages using comm
official_packages=$(comm -12 <(sort "$TEMP_FILE") <(echo "$official_repo_packages" | sort))
aur_packages=$(comm -23 <(sort "$TEMP_FILE") <(echo "$official_repo_packages" | sort))

# Function to compare and update package list
update_package_list() {
    local output_file=$1
    local new_packages=$2
    local temp_file="temp_${output_file}"
    echo "$new_packages" | tr ' ' '\n' > "$temp_file"

    if [ -f "$output_file" ]; then
        log_msg "Comparing new package list with existing $output_file..."
        # Read the existing and new package lists
        existing_packages=$(cat "$output_file")
        new_packages=$(cat "$temp_file")

        # Calculate the differences
        removed_packages=$(comm -23 <(echo "$existing_packages" | tr ' ' '\n' | sort) <(echo "$new_packages" | tr ' ' '\n' | sort))
        added_packages=$(comm -13 <(echo "$existing_packages" | tr ' ' '\n' | sort) <(echo "$new_packages" | tr ' ' '\n' | sort))

        # Check if there are any differences
        if [ -z "$removed_packages" ] && [ -z "$added_packages" ]; then
            log_msg "No changes in the list of explicitly installed packages in $output_file."
            rm "$temp_file"
        else
            # Display the differences
            if [ -n "$removed_packages" ]; then
		echo
                echo "Packages removed from $output_file:"
                echo "$removed_packages" | sed 's/^/- /'
            fi
            if [ -n "$added_packages" ]; then
		echo
                echo "Packages added to $output_file:"
                echo "$added_packages" | sed 's/^/- /'
            fi

            # Prompt for confirmation
	    echo
            read -p "Is this okay? [(y)es/(n)o] " response
            if [[ "$response" =~ ^(yes|y)$ ]]; then
                mv "$temp_file" "$output_file"
		echo
                log_msg "The list of explicitly installed packages has been updated in $output_file."
            else
	        echo
                echo "No changes made."
                rm "$temp_file"
            fi
        fi
    else
        # No existing file, so just move the temp file to the output file
        mv "$temp_file" "$output_file"
	echo
        log_msg "The list of explicitly installed packages has been saved to $output_file."
    fi
}

# Update the package lists
echo
log_msg "Updating the list of official packages..."
update_package_list "$OUTPUT_FILE_PACMAN" "$official_packages"
echo
log_msg "Updating the list of AUR packages..."
update_package_list "$OUTPUT_FILE_AUR" "$aur_packages"

# Clean up temporary files
rm "$TEMP_FILE"
echo
log_msg "Cleanup complete. Script finished."

