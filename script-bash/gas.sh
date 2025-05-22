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

# Fungsi untuk mengatur SSH dengan port kustom
setup_sshd_config() {
    echo "========================================"
    echo "Mengatur konfigurasi SSH..."
    echo "========================================"
    
    # Mendapatkan alamat IP
    ip_address=$(hostname -I | awk '{print $1}')
    
    # Mengambil 2 digit terakhir dari IP address
    last_two_digits=$(echo "$ip_address" | awk -F'.' '{print $4}' | grep -o '..$')
    
    # Jika IP address berakhiran dengan angka kurang dari 10, tambahkan 0 di depan
    if [ ${#last_two_digits} -eq 1 ]; then
        last_two_digits="0$last_two_digits"
    fi
    
    # Membuat port baru (22 + 2 digit terakhir IP)
    new_port="22$last_two_digits"
    
    echo "IP Address: $ip_address"
    echo "2 Digit terakhir IP: $last_two_digits"
    echo "Port SSH baru: $new_port"
    
    # Backup file sshd_config dan ssh.socket
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
    echo "Backup file konfigurasi SSH berhasil dibuat di /etc/ssh/sshd_config.bak"
    
    if [ -f /usr/lib/systemd/system/ssh.socket ]; then
        cp /usr/lib/systemd/system/ssh.socket /usr/lib/systemd/system/ssh.socket.bak
        echo "Backup file socket SSH berhasil dibuat di /usr/lib/systemd/system/ssh.socket.bak"
    fi
    
    # URL template dan file temporary
    template_url="https://raw.githubusercontent.com/awankumay/tools/main/script-bash/config/sshd_config"
    temp_config="/tmp/sshd_config_template"
    
    # Download template dari GitHub
    echo "Mengunduh template konfigurasi SSH dari GitHub..."
    if wget -q "$template_url" -O "$temp_config"; then
        echo "Template berhasil diunduh."
        
        # Mengganti variabel placeholder dengan nilai sebenarnya
        sed -e "s/\$new_port/$new_port/g" -e "s/\${ip_address}/$ip_address/g" "$temp_config" > /etc/ssh/sshd_config
        
        echo "File konfigurasi SSH berhasil diterapkan dari template!"
        
        # Hapus file temporary
        rm -f "$temp_config"
    else
        echo "Gagal mengunduh template dari $template_url."
        echo "Menggunakan metode konfigurasi manual..."
        
        # Mengubah port SSH di sshd_config
        sed -i "s/^#Port 22/Port $new_port/" /etc/ssh/sshd_config
        
        # Jika port belum diubah (mungkin formatnya berbeda), tambahkan port baru
        if ! grep -q "^Port $new_port" /etc/ssh/sshd_config; then
            sed -i "s/^Port 22/Port $new_port/" /etc/ssh/sshd_config
            
            # Jika masih belum ada pengaturan port, tambahkan di awal file
            if ! grep -q "^Port $new_port" /etc/ssh/sshd_config; then
                sed -i "1i Port $new_port" /etc/ssh/sshd_config
            fi
        fi
        
        # Meningkatkan keamanan sshd_config
        sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
        sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    fi
    
    # Mengubah port di file socket untuk Ubuntu 24.04
    if [ -f /usr/lib/systemd/system/ssh.socket ]; then
        sed -i "s/^ListenStream=22/ListenStream=$new_port/" /usr/lib/systemd/system/ssh.socket
        echo "Port SSH diubah di file socket"
    fi
    
    # Reload systemd daemon untuk menerapkan perubahan
    systemctl daemon-reload
    
    # Restart layanan SSH
    if systemctl is-active --quiet ssh.socket; then
        echo "Menggunakan systemd socket SSH..."
        systemctl restart ssh.socket
    else
        echo "Menggunakan layanan SSH standar..."
        systemctl restart sshd
    fi
    
    echo "Konfigurasi SSH telah diperbarui!"
    echo "Port SSH baru: $new_port"
    echo "PERHATIAN: Pastikan untuk membuka port $new_port di firewall jika diperlukan!"
    echo "PERINGATAN: Koneksi SSH saat ini akan tetap terhubung, tetapi koneksi baru harus menggunakan port $new_port"
}

# Fungsi Install Google Authenticator
install_google_authenticator() {
    echo "========================================"
    echo "Menginstall Google Authenticator..."
    echo "========================================"
    apt-get install libpam-google-authenticator google-authenticator -y
    echo "Google Authenticator telah terinstall."
}

# Fungsi Install Network Tools
install_network_tools() {
    echo "========================================"
    echo "Menginstall Network Tools..."
    echo "========================================"
    apt-get install net-tools traceroute -y
    echo "Network Tools telah terinstall."
}



# Fungsi Install fail2ban
install_fail2ban() {
    echo "========================================"
    echo "Menginstall fail2ban..."
    echo "========================================"
    apt-get install fail2ban -y
    echo "fail2ban telah terinstall."
}

# Fungsi Install sendmail
install_sendmail() {
    echo "========================================"
    echo "Menginstall sendmail..."
    echo "========================================"
    apt-get install sendmail -y
    echo "sendmail telah terinstall."
}

# Fungsi Install logwatch
install_logwatch() {
    echo "========================================"
    echo "Menginstall logwatch..."
    echo "========================================"
    apt-get install logwatch -y
    echo "logwatch telah terinstall."
}

# Fungsi install pam radius
install_pam_radius() {
    echo "========================================"
    echo "Menginstall pam radius..."
    echo "========================================"
    apt-get install libpam-radius-auth -y
    echo "pam radius telah terinstall."
}

# Fungsi apt update & upgrade
apt_update_upgrade() {
    echo "========================================"
    echo "Melakukan update dan upgrade sistem..."
    echo "========================================"
    apt-get update -y
    apt-get upgrade -y
    echo "Update dan upgrade sistem telah selesai."
}

# Fungsi untuk instalasi lengkap
full_install() {
    apt_update_upgrade
    install_google_authenticator
    install_fail2ban
    install_sendmail
    install_logwatch
    # setup_sshd_config
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
    echo "  -p, --port-ssh       : Konfigurasi port SSH"
    echo "  -a, --all            : Instalasi lengkap"
    echo "  -h, --help           : Tampilkan bantuan ini"
    echo "  -i, --interactive    : Mode interaktif (menu)"
    echo ""
    echo "Contoh penggunaan dengan curl dan sudo:"
    echo "curl -sL https://raw.githubusercontent.com/awankumay/tools/main/script-bash/gas.sh | sudo bash -s -- -a"
    echo "========================================"
}

# Fungsi untuk menampilkan menu menggunakaan while loop
while_loop_menu() {
    while true; do
        show_menu
        read -p "Pilih menu (1-8): " choice
        case $choice in
            1) install_google_authenticator ;;
            2) install_fail2ban ;;
            3) install_sendmail ;;
            4) install_logwatch ;;
            5) setup_sshd_config ;;
            6) apt_update_upgrade ;;
            7) full_install ;;
            8) echo "Keluar dari program."; exit 0 ;;
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
    echo "5. Konfigurasi Port SSH"
    echo "6. Update dan Upgrade Sistem"
    echo "7. Full Install"
    echo "8. Keluar"
}

# Fungsi untuk memeriksa apakah script dijalankan dengan sudo
check_sudo() {
    if [ "$EUID" -ne 0 ]; then
        echo "========================================"
        echo "ERROR: Script ini memerlukan akses root!"
        echo "Jalankan dengan: sudo ./gas.sh"
        echo "Atau: curl -sL https://raw.githubusercontent.com/awankumay/tools/main/script-bash/gas.sh | sudo bash -s -- [opsi]"
        echo "========================================"
        exit 1
    fi
}

# Fungsi utama untuk memproses argumen
main() {
    # Periksa apakah script dijalankan dengan sudo
    check_sudo
    
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
            -p|--port-ssh)
                setup_sshd_config
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