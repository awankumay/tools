#!/bin/bash
# Date : 22 Mei 2025
# Script Setup Timezone Asia/Jakarta
# Author : Awankumay

# Fungsi Set timezone Asia/Jakarta

set_timezone() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        os_name="$NAME"
        os_version="$VERSION_ID"
    else
        echo "Invalid OS"
        exit 1
    fi

    if [[ "$os_name" == *"Ubuntu"* || "$os_name" == *"Debian"* ]]; then
        sudo timedatectl set-timezone Asia/Jakarta
    else
        echo "Invalid"
        exit 1
    fi
}

set_timezone
