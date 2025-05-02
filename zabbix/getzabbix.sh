#!/bin/bash

# Script untuk memeriksa apakah zabbix-agent atau zabbix-agent2 yang terpasang di server

echo "Cek instalasi Zabbix Agent..."

if dpkg -l | grep -qw zabbix-agent2; then
    echo "zabbix-agent2 terdeteksi."
    echo "Status service zabbix-agent2:"
    systemctl status zabbix-agent2.service --no-pager
elif dpkg -l | grep -qw zabbix-agent; then
    echo "zabbix-agent (klasik) terdeteksi."
    echo "Status service zabbix-agent:"
    systemctl status zabbix-agent.service --no-pager
else
    echo "Tidak ditemukan zabbix-agent maupun zabbix-agent2 di server ini."
    exit 1
fi

# Dokumentasi:
# - Script ini digunakan untuk mengetahui jenis Zabbix Agent yang terpasang di server.
# - Jalankan dengan perintah: bash check_zabbix_agent.sh
# - Output akan menampilkan agent yang terpasang dan status servicenya.