#!/bin/bash
# Script Hardening Linux Server Ubuntu 24.04 LTS

# Show Detail Hostname and IP Address
show_hostname_ip() {
    echo "========================================"
    echo "Hostname dan IP Address:"
    echo "========================================"
    hostname=$(hostname)
    ip_address=$(hostname -I | awk '{print $1}')
    echo "Hostname: $hostname"
    echo "IP Address: $ip_address"
}

# Fungsi Install Google Authenticator
install_google_authenticator() {
    echo "========================================"
    echo "Menginstall Google Authenticator..."
    echo "========================================"
    sudo apt-get install libpam-google-authenticator -y
    sudo apt-get install google-authenticator -y
    echo "Google Authenticator telah terinstall."
}

# Fungsi Install fail2ban
install_fail2ban() {
    echo "========================================"
    echo "Menginstall fail2ban..."
    echo "========================================"
    sudo apt-get install fail2ban -y
    echo "fail2ban telah terinstall."
}

# Fungsi Install sendmail
install_sendmail() {
    echo "========================================"
    echo "Menginstall sendmail..."
    echo "========================================"
    sudo apt-get install sendmail -y
    echo "sendmail telah terinstall."
}

# Fungsi Install logwatch
install_logwatch() {
    echo "========================================"
    echo "Menginstall logwatch..."
    echo "========================================"
    sudo apt-get install logwatch -y
    echo "logwatch telah terinstall."
}

# Fungsi install pam radius
install_pam_radius() {
    echo "========================================"
    echo "Menginstall pam radius..."
    echo "========================================"
    sudo apt-get install libpam-radius-auth -y
    echo "pam radius telah terinstall."
}

# Fungsi apt update & upgrade
apt_update_upgrade() {
    echo "========================================"
    echo "Melakukan update dan upgrade sistem..."
    echo "========================================"
    sudo apt-get update -y
    sudo apt-get upgrade -y
    echo "Update dan upgrade sistem telah selesai."
}

# Fungsi untuk instalasi lengkap
full_install() {
    install_google_authenticator
    install_fail2ban
    install_sendmail
    install_logwatch
    apt_update_upgrade
    echo "========================================"
    echo "Instalasi lengkap telah selesai."
    echo "========================================"
}

# Fungsi untuk menampilkan bantuan penggunaan
show_help() {
    echo "========================================"
    echo "Penggunaan: gas.sh [opsi]"
    echo "========================================"
    echo "Opsi:"
    echo "  -g, --google-auth    : Install Google Authenticator"
    echo "  -f, --fail2ban       : Install fail2ban"
    echo "  -s, --sendmail       : Install sendmail"
    echo "  -l, --logwatch       : Install logwatch"
    echo "  -u, --update         : Update dan upgrade sistem"
    echo "  -a, --all            : Instalasi lengkap"
    echo "  -h, --help           : Tampilkan bantuan ini"
    echo "  -i, --interactive    : Mode interaktif (menu)"
    echo ""
    echo "Contoh penggunaan dengan curl:"
    echo "curl -sL https://raw.githubusercontent.com/awankumay/tools/main/gas.sh | bash -s -- -a"
    echo "========================================"
}

# Fungsi untuk menampilkan menu menggunakaan while loop
while_loop_menu() {
    while true; do
        show_menu
        read -p "Pilih menu (1-7): " choice
        case $choice in
            1) install_google_authenticator ;;
            2) install_fail2ban ;;
            3) install_sendmail ;;
            4) install_logwatch ;;
            5) apt_update_upgrade ;;
            6) full_install ;;
            7) echo "Keluar dari program."; exit 0 ;;
            *) echo "Pilihan tidak valid. Silakan coba lagi." ;;
        esac
    done
}

show_menu() {
    # Show hostname and IP address
    show_hostname_ip
    echo "========================================"
    echo "Menu Utama"
    echo "========================================"
    echo "1. Install Google Authenticator"
    echo "2. Install fail2ban"
    echo "3. Install sendmail"
    echo "4. Install logwatch"
    echo "5. Update dan Upgrade Sistem"
    echo "6. Full Install"
    echo "7. Keluar"
}

# Fungsi utama untuk memproses argumen
main() {
    # Jika tidak ada argumen, jalankan mode interaktif
    if [ $# -eq 0 ]; then
        while_loop_menu
        exit 0
    fi

    # Memproses argumen
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -g|--google-auth)
                install_google_authenticator
                shift
                ;;
            -f|--fail2ban)
                install_fail2ban
                shift
                ;;
            -s|--sendmail)
                install_sendmail
                shift
                ;;
            -l|--logwatch)
                install_logwatch
                shift
                ;;
            -u|--update)
                apt_update_upgrade
                shift
                ;;
            -a|--all)
                full_install
                shift
                ;;
            -i|--interactive)
                while_loop_menu
                shift
                ;;
            -h|--help|*)
                show_help
                shift
                exit 0
                ;;
        esac
    done
}

# Jalankan fungsi utama dengan semua argumen
main "$@"