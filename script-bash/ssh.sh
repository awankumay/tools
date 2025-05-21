#!/bin/bash
# Get SSH - Jumphost Server Ubuntu 24.04 LTS

# Fungsi SSH ke Server 1
ssh_server_10() {
    ssh 10.244.244.10 -p 22
}

# Fungsi SSH ke Server 2
ssh_server_11() {
    ssh 10.244.244.11 -p 22
}

# Fungsi SSH ke Server 3
ssh_server_12() {
    ssh 10.244.244.12 -p 22
}

# Fungsi SSH ke Server 4
ssh_server_13() {
    ssh 10.244.244.13 -p 22
}

# Fungsi SSH ke Server 5
ssh_server_14() {
    ssh 10.244.244.14 -p 22
}

# Fungsi SSH ke Server 5
ssh_server_15() {
    ssh 10.244.244.15 -p 2215
}

# Fungsi SSH ke Server 5
ssh_server_16() {
    ssh 10.244.244.16 -p 22
}

# Fungsi SSH ke Server 5
ssh_server_100() {
    ssh 10.244.244.100 -p 22
}


# Fungsi Menu List Server
while_loop_menu() {
    echo "========================================"
    echo "Daftar Server SSH:"
    echo "========================================"
    echo "10. 10.244.244.10"
    echo "11. 10.244.244.11"
    echo "12. 10.244.244.12"
    echo "13. 10.244.244.13"
    echo "14. 10.244.244.14"
    echo "15. 10.244.244.15"
    echo "16. 10.244.244.16"
    echo "100. 10.244.244.100"
    echo "========================================"
    echo "Pilih server yang ingin diakses:"
    read -p "Masukkan nomor server : " server_choice
    case $server_choice in
        10) ssh_server_10;;
        11) ssh_server_11;;
        12) ssh_server_12;;
        13) ssh_server_13;;
        14) ssh_server_14;;
        15) ssh_server_15;;
        16) ssh_server_16;;
        100) ssh_server_100;;
        *) echo "Pilihan tidak valid." ;;
    esac
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
            -10|--server10)
                ssh_server_10
                shift
                ;;
            -11|--server11)
                ssh_server_11
                shift
                ;;
            -12|--server12)
                ssh_server_12
                shift
                ;;
            -13|--server13)
                ssh_server_13
                shift
                ;;
            -14|--server14) 
                ssh_server_14
                shift
                ;;
            -15|--server15)
                ssh_server_15
                shift
                ;;
            -16|--server16)
                ssh_server_16
                shift
                ;;
            -100|--server100)
                ssh_server_100
                shift
                ;;
            *)
                echo "Pilihan tidak valid."
                exit 1
                ;;
        esac
    done
}

# Jalankan fungsi utama dengan semua argumen
main "$@"