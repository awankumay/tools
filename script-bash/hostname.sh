#!/bin/bash

# Ambil hostname sekarang
CURRENT_HOSTNAME=$(hostname)

# Cek apakah sudah diawali dengan 'laowl'
if [[ $CURRENT_HOSTNAME == laowl* ]]; then
  echo "Hostname sudah benar: $CURRENT_HOSTNAME"
  exit 0
fi

# Cek apakah diawali 'la'
if [[ $CURRENT_HOSTNAME == la* ]]; then
  # Ganti prefix 'la' dengan 'laowl'
  NEW_HOSTNAME="laowl${CURRENT_HOSTNAME:2}"
  echo "Hostname sekarang: $CURRENT_HOSTNAME"
  echo "Akan diubah menjadi: $NEW_HOSTNAME"

  # Set hostname baru
  sudo hostnamectl set-hostname "$NEW_HOSTNAME"

  # Update /etc/hosts juga (opsional, untuk local resolution)
  if grep -q "$CURRENT_HOSTNAME" /etc/hosts; then
    sudo sed -i "s/$CURRENT_HOSTNAME/$NEW_HOSTNAME/g" /etc/hosts
  fi

  echo "Hostname berhasil diubah menjadi $NEW_HOSTNAME"
  echo "Silakan logout & login kembali, atau reboot jika perlu."
else
  echo "Hostname tidak diawali 'la', tidak ada perubahan."
fi