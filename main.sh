#!/bin/bash -e

OPENCORE_VERSION=0.7.2

function download_plain_file() {
    local path=/tmp
    pushd /tmp

    local url=$1
    local filename="${url##*/}"
    rm -f $filename
    wget -q $url
    popd
    cp /tmp/$filename $2/${filename}
}

function download_kext() {
    local url=$1
    local kext_filename=$2

    local tmp_dir=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 13 ; echo '')
   
    local path=/tmp/$tmp_dir
    rm -rf $path

    mkdir -p $path
    pushd /tmp/$tmp_dir

    wget -q $url
    local filename="${url##*/}"
    unzip $filename > /dev/null
    ls

    popd
    cp -r "$path/$kext_filename" dist/EFI/OC/Kexts
}

function get_latest_release() {
    local url=https://api.github.com/repos/$1/releases/latest

    curl --silent "$url" | # Get latest release from GitHub api
        grep '"tag_name":' |                                            # Get tag line
        sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}

function download_oc() {
    local path=/tmp/opencore
    rm -rf $path

    mkdir -p $path
    pushd $path

    url=$1
    wget $url
    local filename="${url##*/}"
    unzip $filename > /dev/null

    popd
    cp -r "$path/X64/EFI" $2
    cp -r "$path/Docs/Sample.plist" $2/EFI/OC/config.plist

}

function download_acidanthera_kext() {
    local kext=$1
    local filename=$2

    if [ -z $2 ]; then
        filename=$1.kext
    fi
    
    local latest=$(get_latest_release acidanthera/$kext)
    echo "$kext latest version $latest"
    download_kext https://github.com/acidanthera/${kext}/releases/download/${latest}/${kext}-${latest}-RELEASE.zip $filename
}

rm -rf dist
mkdir -p dist

download_oc https://github.com/acidanthera/OpenCorePkg/releases/download/${OPENCORE_VERSION}/OpenCore-${OPENCORE_VERSION}-RELEASE.zip dist

download_source() {

    download_acidanthera_kext Lilu
    download_acidanthera_kext VirtualSMC Kexts/VirtualSMC.kext
    download_acidanthera_kext VirtualSMC Kexts/SMCSuperIO.kext
    download_acidanthera_kext VirtualSMC Kexts/SMCProcessor.kext
    download_acidanthera_kext WhateverGreen 
    download_acidanthera_kext AppleALC 
    download_acidanthera_kext IntelMausi 
    download_acidanthera_kext NVMeFix 
    download_acidanthera_kext CPUFriend 

    download_plain_file https://github.com/acidanthera/OcBinaryData/raw/master/Drivers/HfsPlus.efi dist/EFI/OC/Drivers
    download_plain_file https://github.com/dortania/Getting-Started-With-ACPI/raw/master/extra-files/compiled/SSDT-PLUG-DRTNIA.aml dist/EFI/OC/ACPI
    download_plain_file https://github.com/dortania/Getting-Started-With-ACPI/raw/master/extra-files/compiled/SSDT-AWAC.aml dist/EFI/OC/ACPI
    download_plain_file https://github.com/dortania/Getting-Started-With-ACPI/raw/master/extra-files/compiled/SSDT-EC-USBX-DESKTOP.aml dist/EFI/OC/ACPI
    download_plain_file https://github.com/dortania/Getting-Started-With-ACPI/raw/master/extra-files/compiled/SSDT-PMC.aml dist/EFI/OC/ACPI
}

download_source

if [ -d kexts ]; then
    cp -r kexts/* dist/EFI/OC/Kexts
fi

source .env
python3 main.py
mv tmp.plist dist/EFI/OC/config.plist