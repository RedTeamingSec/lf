#!/bin/bash
set -e

# Direktori sumber
SRC_DIR="/mnt/lfs/sources"
cd "$SRC_DIR"

echo "[+] Mengunduh systemd dan dependensinya untuk LFS..."

# Format: name|version|url
PKGS=(
"gperf|3.1|https://ftp.gnu.org/gnu/gperf/gperf-3.1.tar.gz"
"intltool|0.51.0|https://launchpad.net/intltool/trunk/0.51.0/+download/intltool-0.51.0.tar.gz"
"libcap|2.69|https://mirrors.edge.kernel.org/pub/linux/libs/security/linux-privs/libcap2/libcap-2.69.tar.xz"
"libseccomp|2.5.5|https://github.com/seccomp/libseccomp/releases/download/v2.5.5/libseccomp-2.5.5.tar.gz"
"xz|5.4.6|https://tukaani.org/xz/xz-5.4.6.tar.xz"
"zstd|1.5.5|https://github.com/facebook/zstd/releases/download/v1.5.5/zstd-1.5.5.tar.gz"
"dbus|1.14.10|https://dbus.freedesktop.org/releases/dbus/dbus-1.14.10.tar.xz"
"libidn2|2.3.4|https://ftp.gnu.org/gnu/libidn/libidn2-2.3.4.tar.gz"
"glib|2.78.0|https://download.gnome.org/sources/glib/2.78/glib-2.78.0.tar.xz"
"systemd|254|https://github.com/systemd/systemd/archive/refs/tags/v254.tar.gz"
)

for pkg in "${PKGS[@]}"; do
    IFS="|" read -r name ver url <<< "$pkg"
    file=$(basename "$url")

    if [ ! -f "$file" ]; then
        echo "[*] Mengunduh $name-$ver ..."
        curl -LO "$url"
    else
        echo "[=] Sudah ada: $file"
    fi
done

echo -e "\n\033[1;32m[SUKSES] Semua source code systemd dan dependensinya telah diunduh ke $SRC_DIR\033[0m"
