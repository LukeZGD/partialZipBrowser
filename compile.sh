#!/usr/bin/env bash
set -x
PREFIX="/usr/local"

if [[ $(uname) == "Darwin" ]]; then
    export MACOSX_DEPLOYMENT_TARGET=10.11
    mkdir -p tmp
    cd tmp

    git clone --filter=blob:none https://github.com/lukezgd/libgeneral
    git clone --filter=blob:none https://github.com/lukezgd/libfragmentzip

    cd libgeneral
    ./autogen.sh --disable-shared --enable-universal
    make
    sudo make install
    cd ..

    cd libfragmentzip
    export SDKDIR="$(xcrun --sdk macosx --show-sdk-path)"
    ./autogen.sh --disable-shared --enable-universal curl_CFLAGS="-I$SDKDIR/usr/include" curl_LIBS="-lcurl" libgeneral_CFLAGS="-I$PREFIX/include -stdlib=libc++" libgeneral_LIBS="-L$PREFIX/lib -lgeneral" zlib_CFLAGS="-I$SDKDIR/usr/include" zlib_LIBS="-lz"
    make
    sudo make install
    cd ..

    cd ..
    rm -rf tmp
    ./autogen.sh --enable-universal libfragmentzip_CFLAGS="-I$PREFIX/include" libfragmentzip_LIBS="-L$PREFIX/lib -lfragmentzip"
    make LIBS="-lcurl -lz"

    exit
fi

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
