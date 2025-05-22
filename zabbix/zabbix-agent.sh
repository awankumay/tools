#!/bin/bash
# Date : 22 Mei 2025
# Script Install Zabbix Agent
# Author : Awankumay

# Fungsi Get Version Ubuntu / Linux & Arch
get_version() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        ubuntu_version=$(echo "$VERSION_ID" | cut -d'.' -f1,2)
        os_version="$ubuntu_version"
        arch=$(dpkg --print-architecture)
    else
        echo "Invalid OS version. Please run this script on Ubuntu or Debian."
        exit 1
    fi
    
}

# Fungsi Get Zabbix Version
get_zabbix_version() {
    versions=$(wget -qO- https://repo.zabbix.com/zabbix/ | grep -oP '(?<=href=")[0-9]+\.[0-9]+(?=/")' | sort -Vr)
    zabbix_version=$(echo "$versions" | head -n1)
}

# Fungsi Download Zabbix Release
download_zabbix_release() {
    release_url="https://repo.zabbix.com/zabbix/${zabbix_version}/release/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_${zabbix_version}+ubuntu${os_version}_all.deb"
    wget -q "$release_url" -O /tmp/zabbix-release.deb
}

# Fungsi Install Zabbix Release
install_zabbix_release() {
    sudo dpkg -i /tmp/zabbix-release.deb
    sudo apt update
}

# Fungsi Install Zabbix Agent
install_zabbix_agent() {
    sudo apt install zabbix-agent2 -y
}

# Fungsi Configure Zabbix Agent
configure_zabbix_agent() {
    sudo sed -i "s/^Server=.*/Server=$1/" /etc/zabbix/zabbix_agent2.conf
    sudo sed -i "s/^ServerActive=.*/ServerActive=$1/" /etc/zabbix/zabbix_agent2.conf
    sudo sed -i "s/^Hostname=.*/Hostname=$2/" /etc/zabbix/zabbix_agent2.conf
}

# Fungsi Start Zabbix Agent
start_zabbix_agent() {
    sudo systemctl enable zabbix-agent2
    sudo systemctl start zabbix-agent2
}

# Fungsi Get Hostname
get_hostname() {
    hostname=$(hostname)
    if [ -z "$hostname" ]; then
        echo "Invalid hostname. Please set the hostname."
        exit 1
    fi
}

# Fungsi Get IP Address
get_ip_address() {
    ip_address=$(hostname -I | awk '{print $1}')
    if [ -z "$ip_address" ]; then
        echo "Invalid IP address. Please set the IP address."
        exit 1
    fi
}

# Fungsi Cek Sudo
check_sudo() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "Please run as sudo"
        exit 1
    fi
}

# Fungsi Main
main() {
    # Check sudo first
    check_sudo
    
    if [ "$#" -ne 1 ]; then
        echo "Usage: $0 <Zabbix Server IP>"
        echo ""
        echo "Contoh penggunaan via curl:"
        echo "curl -sSL https://raw.githubusercontent.com/awankumay/tools/main/zabbix/zabbix-agent.sh | sudo bash -s <Zabbix Server IP>"
        exit 1
    fi

    zabbix_server_ip="$1"
    
    get_version
    get_zabbix_version
    download_zabbix_release
    install_zabbix_release
    install_zabbix_agent
    get_hostname
    get_ip_address
    
    # Gunakan hostname yang didapat secara otomatis
    configure_zabbix_agent "$zabbix_server_ip" "$hostname"
    start_zabbix_agent

    echo "Install & Configure Zabbix Agent Completed"
    echo "Zabbix Agent is running on $hostname with IP address $ip_address"
}

# Call Main Function
main "$@"
# End of Script