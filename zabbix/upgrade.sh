#!/bin/bash

# Script upgrade zabbix-agent otomatis dari repo resmi Zabbix
# Dokumentasi: https://repo.zabbix.com/zabbix/

set -e

# Mendapatkan informasi versi Ubuntu
if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "Distribusi: $NAME"
    echo "Versi: $VERSION"
    echo "Kode rilis (codename): $VERSION_CODENAME"
    ubuntu_version=$(echo "$VERSION_ID" | cut -d'.' -f1,2)
    echo "Versi Ubuntu (angka): $ubuntu_version"
    os_version="$ubuntu_version"
    echo "os_version: $os_version"
else
    echo "Tidak dapat menemukan file /etc/os-release. Sistem mungkin bukan berbasis Ubuntu."
    exit 1
fi

arch=$(dpkg --print-architecture)

echo "Mengambil daftar versi Zabbix yang tersedia..."
versions=$(wget -qO- https://repo.zabbix.com/zabbix/ | grep -oP '(?<=href=")[0-9]+\.[0-9]+(?=/")' | sort -Vr)

echo "Versi Zabbix yang tersedia:"
select zabbix_version in $versions; do
    if [[ -n "$zabbix_version" ]]; then
        echo "Anda memilih versi: $zabbix_version"
        break
    else
        echo "Pilihan tidak valid, silakan pilih lagi."
    fi
done

echo "Menghapus paket zabbix-release lama (jika ada)..."
sudo dpkg --purge zabbix-release || true

release_url="https://repo.zabbix.com/zabbix/${zabbix_version}/release/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_${zabbix_version}+ubuntu${os_server}_all.deb"
echo "Mengunduh paket zabbix-release: $release_url"
wget -O zabbix-release.deb "$release_url"

echo "Menginstal paket zabbix-release..."
sudo dpkg -i zabbix-release.deb

echo "Update repository..."
sudo apt update

echo "Upgrade zabbix-agent..."
sudo apt install --upgrade zabbix-agent

echo "Restart service zabbix-agent..."
sudo systemctl restart zabbix-agent.service

echo "Upgrade selesai. Silakan cek status dengan: systemctl status zabbix-agent.service"