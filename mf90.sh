#!/bin/bash
#copyright by @Lynch115
# Konfigurasi modem
MODEM_IP="192.168.8.1"
USERNAME="admin"
PASSWORD="admin"
LOGIN_URL="http://$MODEM_IP/goform/goform_set_cmd_process"
DISCONNECT_URL="http://$MODEM_IP/goform/goform_set_cmd_process"
USER_AGENT="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36"

# Header untuk request
HEADERS=(
    -H "Host: $MODEM_IP"
    -H "Origin: http://$MODEM_IP"
    -H "Referer: http://$MODEM_IP/index.html"
    -H "User-Agent: $USER_AGENT"
    -H "X-Requested-With: XMLHttpRequest"
    -H "Content-Type: application/x-www-form-urlencoded; charset=UTF-8"
)

# Fungsi untuk login
login() {
    echo "Mencoba login ke modem..."
    ENCODED_PASS=$(echo -n "$PASSWORD" | base64)
    LOGIN_DATA="isTest=false&goformId=LOGIN&password=$ENCODED_PASS"

    RESPONSE=$(curl -X POST "$LOGIN_URL" \
        "${HEADERS[@]}" \
        --data "$LOGIN_DATA" \
        --cookie-jar cookies.txt \
        --silent)

    echo "Respon dari modem saat login: $RESPONSE"

    if [[ "$RESPONSE" == *'"result":"0"'* ]]; then
        echo "Login berhasil!"
        sleep 2
        return 0
    else
        echo "Gagal login!"
        return 1
    fi
}

# Fungsi untuk memutus koneksi internet
disable_internet() {
    echo "Memutuskan koneksi internet..."
    DISCONNECT_DATA="goformId=DISCONNECT_NETWORK&isTest=false&notCallback=true"

    RESPONSE=$(curl -X POST "$DISCONNECT_URL" \
        "${HEADERS[@]}" \
        --data "$DISCONNECT_DATA" \
        --cookie cookies.txt \
        --silent)

    echo "Respon dari modem saat disconnect: $RESPONSE"

    if [[ "$RESPONSE" == *'"result":"success"'* ]]; then
        echo "Internet berhasil dimatikan!"
        sleep 3
        return 0
    else
        echo "Gagal mematikan internet!"
        return 1
    fi
}

# Fungsi untuk mengubah jaringan ke 3G only
set_3g_only() {
    echo "Mengubah jaringan ke 3G Only (WCDMA)..."
    DATA="isTest=false&goformId=SET_BEARER_PREFERENCE&BearerPreference=Only_WCDMA"

    RESPONSE=$(curl -X POST "$LOGIN_URL" \
        "${HEADERS[@]}" \
        --data "$DATA" \
        --cookie cookies.txt \
        --silent)

    echo "Respon dari modem saat ubah jaringan: $RESPONSE"

    if [[ "$RESPONSE" == *'"result":"success"'* ]]; then
        echo "Berhasil mengubah jaringan ke 3G Only!"
        sleep 3
        return 0
    else
        echo "Gagal mengubah jaringan!"
        return 1
    fi
}

# Fungsi untuk mengubah jaringan ke 4G only (LTE)
set_4g_only() {
    echo "Mengubah jaringan ke 4G Only (LTE)..."
    DATA="isTest=false&goformId=SET_BEARER_PREFERENCE&BearerPreference=Only_LTE"

    RESPONSE=$(curl -X POST "$LOGIN_URL" \
        "${HEADERS[@]}" \
        --data "$DATA" \
        --cookie cookies.txt \
        --silent)

    echo "Respon dari modem saat ubah jaringan: $RESPONSE"

    if [[ "$RESPONSE" == *'"result":"success"'* ]]; then
        echo "Berhasil mengubah jaringan ke 4G Only!"
        sleep 3
        return 0
    else
        echo "Gagal mengubah jaringan!"
        return 1
    fi
}

# Fungsi untuk menghubungkan kembali internet
enable_internet() {
    echo "Menghubungkan kembali internet..."
    CONNECT_DATA="goformId=CONNECT_NETWORK&isTest=false&notCallback=true"

    RESPONSE=$(curl -X POST "$DISCONNECT_URL" \
        "${HEADERS[@]}" \
        --data "$CONNECT_DATA" \
        --cookie cookies.txt \
        --silent)

    echo "Respon dari modem saat connect: $RESPONSE"

    if [[ "$RESPONSE" == *'"result":"success"'* ]]; then
        echo "Internet berhasil dihubungkan kembali!"
        sleep 2
        return 0
    else
        echo "Gagal menghubungkan internet!"
        return 1
    fi
}

# Eksekusi utama
if login; then
    disable_internet
    set_3g_only
    set_4g_only
    enable_internet  # Menambahkan perintah untuk menghubungkan internet kembali
else
    exit 1
fi

# Bersihkan file cookies
rm -f cookies.txt
