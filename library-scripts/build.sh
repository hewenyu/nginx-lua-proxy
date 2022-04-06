#!/usr/bin/env bash

set -e

PACKAGES_INSTALLED="false"

# 判断 ARM or x86
architecture="$(uname -m)"

case $architecture in
    x86_64) architecture="amd64";;
    aarch64 | armv8*) architecture="arm64";;
    aarch32 | armv7* | armvhf*) architecture="armv6l";;
    i?86) architecture="386";;
    *) echo "(!) Architecture $architecture unsupported"; exit 1 ;;
esac

echo $architecture

# Run install apt-utils to avoid debconf warning then verify presence of other common developer tools and dependencies
if [ "${PACKAGES_INSTALLED}" != "true" ]; then

    package_list="curl \
        gnupg \ 
        ca-certificates \
        make \
        gcc \
        libpcre3 \ 
        libpcre3-dev \ 
        zlib1g-dev \
        libssl-dev"
    
    apt_get_update_if_needed

    apt-get -y install --no-install-recommends ${package_list} 
fi


# Function to run apt-get if needed
apt_get_update_if_needed()
{
    if [ ! -d "/var/lib/apt/lists" ] || [ "$(ls /var/lib/apt/lists/ | wc -l)" = "0" ]; then
        echo "Running apt-get update..."
        apt-get update
    else
        echo "Skipping apt-get update."
    fi
}


# download openresty-1.21.4.1rc2.tar.gz
curl https://openresty.org/download/openresty-1.21.4.1rc2.tar.gz -o openresty.tar.gz


echo "Done!"
