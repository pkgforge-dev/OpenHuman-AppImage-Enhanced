#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm libnss_nis nss-mdns nss xdotool

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

# Comment this out if you need an AUR package
#make-aur-package PACKAGENAME

echo "Getting binary..."
echo "---------------------------------------------------------------"
case "$ARCH" in
	x86_64)  farch=amd64;;
	aarch64) farch=arm64;;
esac
link=$(wget https://api.github.com/repos/tinyhumansai/openhuman/releases -O - \
	| sed 's/[()",{} ]/\n/g' | grep -o -m 1 "https.*/OpenHuman_.*_$farch.deb")
wget --retry-connrefused --tries=30 "$link" -O /tmp/temp.deb
ar x /tmp/temp.deb
tar -xvf ./data.tar.gz
rm -f ./*.tar.gz /tmp/temp.deb

mkdir -p ./AppDir/bin
cp -vr ./usr/share/OpenHuman/* ./AppDir/bin

# upstream depends on an older version of xdotool
patchelf --replace-needed libxdo.so.3 libxdo.so.4 ./AppDir/bin/OpenHuman

cp -v ./usr/share/applications/*.desktop ./AppDir
cp -v ./usr/share/icons/hicolor/128x128/apps/OpenHuman.png ./AppDir
cp -v ./usr/share/icons/hicolor/128x128/apps/OpenHuman.png ./AppDir/.DirIcon

echo "$link" | awk -F'/' '{print $(NF-1)}' > ~/version
