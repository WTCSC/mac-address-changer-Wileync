#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0 -i <interface> -m <new-mac-address>"
    exit 1
}

# Function to validate MAC address
validate_mac() {
    local mac=$1
    if [[ $mac =~ ^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$ ]]; then
        return 0
    else
        return 1
    fi
}

# Function to handle errors
error_exit() {
    echo "Error: $1"
    exit 1
}

# Parse command-line arguments
while getopts ":i:m:" opt; do
    case $opt in
        i) INTERFACE=$OPTARG ;;
        m) NEW_MAC=$OPTARG ;;
        *) usage ;;
    esac
done

# Ensure both arguments are provided
if [ -z "$INTERFACE" ] || [ -z "$NEW_MAC" ]; then
    usage
fi

# Validate MAC address format
if ! validate_mac $NEW_MAC; then
    error_exit "Invalid MAC address format. Use format: XX:XX:XX:XX:XX:XX"
fi

# Ensure the network interface exists
if ! ip link show $INTERFACE > /dev/null 2>&1; then
    error_exit "Network interface $INTERFACE does not exist."
fi

# Bring the interface down
if ! sudo ip link set dev $INTERFACE down; then
    error_exit "Failed to bring down the interface $INTERFACE."
fi

# Change the MAC address
if ! sudo ip link set dev $INTERFACE address $NEW_MAC; then
    error_exit "Failed to change MAC address for $INTERFACE."
fi

# Bring the interface up
if ! sudo ip link set dev $INTERFACE up; then
    error_exit "Failed to bring up the interface $INTERFACE."
fi

# Success message
echo "MAC address for $INTERFACE successfully changed to $NEW_MAC."
