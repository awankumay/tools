#!/bin/bash

# Fungsi untuk mengambil user dengan home di /home
get_user_list() {
    getent passwd | awk -F: '$6 ~ /^\/home/ {print $1}'
}

check_user() {
    echo "========================================"
    echo "Daftar user dengan home directory di /home:"
    echo "========================================"

    user_list=($(get_user_list))
    for i in "${!user_list[@]}"; do
        echo "$((i+1)). ${user_list[$i]}"
    done
    echo "========================================"

}

select_user() {
    echo "========================================"
    echo "Pilih user:"
    user_list=($(get_user_list))
    for i in "${!user_list[@]}"; do
        echo "$((i+1)). ${user_list[$i]}"
    done
    echo "========================================"
    read -p "Pilih nomor user: " nomor
    if [[ "$nomor" =~ ^[0-9]+$ ]] && [ "$nomor" -ge 1 ] && [ "$nomor" -le "${#user_list[@]}" ]; then
        selected_user="${user_list[$((nomor-1))]}"
    else
        echo "Pilihan tidak valid."
        selected_user=""
    fi
}

terminate_user() {
    echo "Pilih user yang ingin dikunci (terminated/locked):"
    select_user
    if [ -n "$selected_user" ]; then
        sudo usermod -L "$selected_user"
        echo "User $selected_user telah dikunci (locked)."
    fi
}

delete_user() {
    echo "Pilih user yang ingin dihapus:"
    select_user
    if [ -n "$selected_user" ]; then
        read -p "Hapus juga home directory user? (y/n) [n]: " confirm
        confirm=${confirm:-n}
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            sudo userdel -r "$selected_user"
            echo "User $selected_user dan home directory-nya telah dihapus."
        else
            sudo userdel "$selected_user"
            echo "User $selected_user telah dihapus (home directory tidak dihapus)."
        fi
    fi
}

while true; do
    echo ""
    echo "========================================"
    echo "Pilih fitur:"
    echo "1. Check User"
    echo "2. Terminated User (Lock User)"
    echo "3. Deleted User"
    echo "4. Keluar"
    echo "========================================"
    read -p "Masukkan pilihan : " choice
    

    case $choice in
        1) check_user ;;
        2) terminate_user ;;
        3) delete_user ;;
        4) echo "Keluar."; break ;;
        *) echo "Pilihan tidak valid." ;;
    esac
done