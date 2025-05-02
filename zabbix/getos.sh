#!/bin/bash

# Mendapatkan informasi versi Ubuntu
if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "Distribusi: $NAME"
    echo "Versi: $VERSION"
    echo "Kode rilis (codename): $VERSION_CODENAME"
    ubuntu_version=$(echo "$VERSION_ID" | cut -d'.' -f1,2)
    echo "Versi Ubuntu (angka): $ubuntu_version"
else
    echo "Tidak dapat menemukan file /etc/os-release. Sistem mungkin bukan berbasis Ubuntu."
    exit 1
fi

