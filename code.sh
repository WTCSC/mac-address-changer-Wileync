#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0 -i <interface> -m <new-mac-address>" #sets up the format for running the script
    exit 1 #exits
}

# Function to validate MAC address
validate_mac() { #starts function
    local mac=$1 #sets local variable
    if [[ $mac =~ ^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$ ]]; then #validates that the MAC Address is in the correct format and length
        return 0 #returns 0 if no fails
    else
        return 1 #returns 1 if there was a fail.
    fi
}

# Function to handle errors
error_exit() { #checks if variable $1 has returned 1 meaning there was an error.
    echo "Error: $1" #says Error
    exit 1 #exits
}

# Parse command-line arguments
while getopts ":i:m:" opt; do  #while the Interface and Mac address are variables
    case $opt in
        i) INTERFACE=$OPTARG ;; #sets i
        m) NEW_MAC=$OPTARG ;; #sets m
        *) usage ;;
    esac #ends case
done

# Ensure both arguments are provided
if [ -z "$INTERFACE" ] || [ -z "$NEW_MAC" ]; then #checks that we were given both arguments
    usage
fi

# Validate MAC address format
if ! validate_mac $NEW_MAC; then #checks new mac address
    error_exit "Invalid MAC address format. Use format: XX:XX:XX:XX:XX:XX" #compares given MAC Address to the correct format it should be in
fi

# Ensure the network interface exists
if ! ip link show $INTERFACE > /dev/null 2>&1; then #checks if the network given is real
    error_exit "Network interface $INTERFACE does not exist." #returns that error that the network doesnt exist if it doesn't
fi

# Bring the interface down
if ! sudo ip link set dev $INTERFACE down; then #checks if the Interface was successfully brought down
    error_exit "Failed to bring down the interface $INTERFACE." #returns error message if we couldnt bring it down
fi

# Change the MAC address
if ! sudo ip link set dev $INTERFACE address $NEW_MAC; then #checks if we can change the MAC Address successfully
    error_exit "Failed to change MAC address for $INTERFACE." #returns failure message if we fail to change it
fi

# Bring the interface up
if ! sudo ip link set dev $INTERFACE up; then #checks that we can bring the Interface back up
    error_exit "Failed to bring up the interface $INTERFACE." #returns error if we couldnt bring the interface back up
fi

# Success message
echo "MAC address for $INTERFACE successfully changed to $NEW_MAC." #if successfully changed, returns success message.
