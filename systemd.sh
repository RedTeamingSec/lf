#!/bin/bash
set -e
cd /sources

echo -e "\n[1/5] 🔧 Mengekstrak semua source tarball..."

for archive in *.tar.*; do
    dir="${archive%.tar.*}"
    if [ ! -d "$dir" ]; then
        echo "[+] Mengekstrak $archive..."
        tar -xf "$archive"
    else
        echo "[=] Sudah diekstrak: $dir"
    fi
done

echo -e "\n[2/5] 📦 Menginstal semua dependensi..."

# Fungsi builder standar
build_package() {
    name="$1"
    cd "$name"*
    echo "[*] Membangun $name ..."
    ./configure --prefix=/usr
    make -j$(nproc)
    make install
    cd ..
}

# 1. gperf
build_package gperf

# 2. intltool
cd intltool*
./configure --prefix=/usr
make
make install
cd ..

# 3. libcap
cd libcap*
make prefix=/usr lib=lib
make prefix=/usr lib=lib install
cd ..

# 4. libseccomp
build_package libseccomp

# 5. xz (jika belum full install)
cd xz*
./configure --prefix=/usr --disable-static
make
make install
cd ..

# 6. zstd
cd zstd*
make -j$(nproc)
make install
cd ..

# 7. dbus
build_package dbus

# 8. libidn2
build_package libidn2

# 9. glib
cd glib*
mkdir -v build
cd build
meson setup --prefix=/usr ..
ninja
ninja install
cd ../..

echo -e "\n[3/5] 🧱 Menginstal systemd..."

# 10. systemd
cd systemd*
mkdir -v build
cd build

meson setup .. \
  --prefix=/usr \
  --sysconfdir=/etc \
  --localstatedir=/var \
  -Ddefault-hierarchy=unified \
  -Dmode=release \
  -Dman=false -Dhtml=false \
  -Drc-local=false \
  -Dgnu-efi=false \
  -Dinstall-tests=false \
  -Dldconfig=false

ninja
ninja install

cd ../..

echo -e "\n[4/5] 🔗 Menyambungkan systemd sebagai init..."

# Buat user & group systemd
getent group systemd-journal >/dev/null || groupadd -g 190 systemd-journal
getent passwd systemd-network >/dev/null || useradd -u 192 -g systemd-journal -d / -s /usr/bin/nologin -c "systemd Network" systemd-network
getent passwd systemd-resolve >/dev/null || useradd -u 193 -g systemd-journal -d / -s /usr/bin/nologin -c "systemd Resolver" systemd-resolve
getent passwd systemd-timesync >/dev/null || useradd -u 194 -g systemd-journal -d / -s /usr/bin/nologin -c "systemd Time Sync" systemd-timesync

# Symlink systemd sebagai init
ln -sf /lib/systemd/systemd /sbin/init
ln -sf /lib/systemd/systemd /init

echo -e "\n[5/5] ✅ Konfigurasi systemd selesai!"

echo -e "\n\033[1;32m[SUKSES] Systemd telah berhasil diinstal dan disiapkan sebagai init.\033[0m"
