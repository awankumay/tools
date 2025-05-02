#!/bin/bash

# Script upgrade zabbix-agent otomatis dari repo resmi Zabbix
# Dokumentasi: https://repo.zabbix.com/zabbix/
# Penggunaan:
#   curl -sL <url-script> | bash -s -- [versi_zabbix]
#   Contoh: curl -sL https://raw.githubusercontent.com/awankumay/tools/main/zabbix/upgrade.sh | bash -s -- 7.2

set -e

# Mendapatkan informasi versi Ubuntu
if [ -f /etc/os-release ]; then
    . /etc/os-release
    ubuntu_version=$(echo "$VERSION_ID" | cut -d'.' -f1,2)
    os_version="$ubuntu_version"
else
    echo "Tidak dapat menemukan file /etc/os-release. Sistem mungkin bukan berbasis Ubuntu."
    exit 1
fi

arch=$(dpkg --print-architecture)

echo "Mengambil daftar versi Zabbix yang tersedia..."
versions=$(wget -qO- https://repo.zabbix.com/zabbix/ | grep -oP '(?<=href=")[0-9]+\.[0-9]+(?=/")' | sort -Vr)

# Ambil parameter versi dari argumen, jika ada
if [ -n "$1" ]; then
    zabbix_version="$1"
    # Validasi apakah versi tersedia
    if ! echo "$versions" | grep -qx "$zabbix_version"; then
        echo "Versi Zabbix $zabbix_version tidak ditemukan di repo."
        echo "Versi yang tersedia: $versions"
        exit 1
    fi
    echo "Menggunakan versi Zabbix dari parameter: $zabbix_version"
else
    # Pilih versi terbaru jika tidak ada parameter
    zabbix_version=$(echo "$versions" | head -n1)
    echo "Tidak ada parameter versi. Menggunakan versi terbaru: $zabbix_version"
fi

echo "Menghapus paket zabbix-release lama (jika ada)..."
sudo dpkg --purge zabbix-release || true

release_url="https://repo.zabbix.com/zabbix/${zabbix_version}/release/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_${zabbix_version}+ubuntu${os_version}_all.deb"
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

# Dokumentasi:
# - Script ini dapat dijalankan secara non-interaktif, cocok untuk penggunaan via curl -sL ... | bash
# - Jika ingin memilih versi tertentu, tambahkan versi sebagai parameter (misal: 7.0)
# - Jika tidak ada parameter, script otomatis memilih versi terbaru dari repo Zabbix