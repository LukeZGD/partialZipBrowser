#!/usr/bin/env bash
set -x

sudo apt update
sudo apt install -y build-essential autoconf automake libtool pkg-config
sudo apt remove -y libssl-dev

git clone --filter=blob:none https://github.com/libimobiledevice/libplist
git clone --filter=blob:none https://github.com/tihmstar/libgeneral
git clone --filter=blob:none https://github.com/tihmstar/libfragmentzip
# 7_65_3 for old ssl, 8_17_0 for pre-3.0 ssl, 8_21_0 for latest
git clone --filter=blob:none https://github.com/curl/curl -b curl-7_65_3

sslver="2.2.9"
aria2c https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-$sslver.tar.gz
echo "Building libressl..."
tar -zxvf libressl-$sslver.tar.gz
cd libressl-$sslver
./configure
make
sudo make install
cd ..

cd curl
autoreconf -fi
./configure --disable-werror --disable-shared --with-openssl --without-libpsl
make
sudo make install
cd ..

cd libplist
./autogen.sh --disable-shared
make
sudo make install
cd ..

cd libgeneral
./autogen.sh --disable-shared
make
sudo make install
cd ..

cd libfragmentzip
./autogen.sh --disable-shared
make
sudo make install
cd ..

rm -rf curl libressl* libplist libgeneral libfragmentzip
