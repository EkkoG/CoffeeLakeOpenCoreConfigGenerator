#!/bin/bash

OPENCORE_VERSION=0.7.0

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
    local path=/tmp/$1
    rm -rf $path

    mkdir -p $path
    pushd /tmp/$1

    url=$2
    wget -q $url
    local filename="${url##*/}"
    unzip $filename

    popd
    cp -r "$path/$3" $4
}

function download_oc() {
    local path=/tmp/opencore
    rm -rf $path

    mkdir -p $path
    pushd $path

    url=$1
    wget -q $url
    local filename="${url##*/}"
    unzip $filename

    popd
    cp -r "$path/X64/EFI" $2
    cp -r "$path/Docs/Sample.plist" $2/EFI/OC/config.plist

}

mkdir -p tmp
download_oc https://github.com/acidanthera/OpenCorePkg/releases/download/${OPENCORE_VERSION}/OpenCore-${OPENCORE_VERSION}-RELEASE.zip tmp

wget https://github.com/acidanthera/OcBinaryData/raw/master/Drivers/HfsPlus.efi -O tmp/EFI/OC/Drivers/HfsPlus.efi 

download_kext lilu https://github.com/acidanthera/Lilu/releases/download/1.5.3/Lilu-1.5.3-RELEASE.zip Lilu.kext tmp/EFI/OC/Kexts
download_kext virtualsmc https://github.com/acidanthera/VirtualSMC/releases/download/1.2.4/VirtualSMC-1.2.4-RELEASE.zip Kexts/VirtualSMC.kext tmp/EFI/OC/Kexts
download_kext virtualsmc https://github.com/acidanthera/VirtualSMC/releases/download/1.2.4/VirtualSMC-1.2.4-RELEASE.zip Kexts/SMCSuperIO.kext tmp/EFI/OC/Kexts
download_kext virtualsmc https://github.com/acidanthera/VirtualSMC/releases/download/1.2.4/VirtualSMC-1.2.4-RELEASE.zip Kexts/SMCProcessor.kext tmp/EFI/OC/Kexts

download_kext whatevergreen https://github.com/acidanthera/WhateverGreen/releases/download/1.5.0/WhateverGreen-1.5.0-RELEASE.zip WhateverGreen.kext tmp/EFI/OC/Kexts

download_kext applealc https://github.com/acidanthera/AppleALC/releases/download/1.6.1/AppleALC-1.6.1-RELEASE.zip AppleALC.kext tmp/EFI/OC/Kexts
download_kext intelmaus https://github.com/acidanthera/IntelMausi/releases/download/1.0.6/IntelMausi-1.0.6-RELEASE.zip IntelMausi.kext tmp/EFI/OC/Kexts
download_kext nvmefix https://github.com/acidanthera/NVMeFix/releases/download/1.0.8/NVMeFix-1.0.8-RELEASE.zip NVMeFix.kext tmp/EFI/OC/Kexts

download_plain_file https://github.com/dortania/Getting-Started-With-ACPI/raw/master/extra-files/compiled/SSDT-PLUG-DRTNIA.aml tmp/EFI/OC/ACPI
download_plain_file https://github.com/dortania/Getting-Started-With-ACPI/raw/master/extra-files/compiled/SSDT-AWAC.aml tmp/EFI/OC/ACPI
download_plain_file https://github.com/dortania/Getting-Started-With-ACPI/raw/master/extra-files/compiled/SSDT-EC-USBX-DESKTOP.aml tmp/EFI/OC/ACPI
download_plain_file https://github.com/dortania/Getting-Started-With-ACPI/raw/master/extra-files/compiled/SSDT-PMC.aml tmp/EFI/OC/ACPI

source .env
python3 main.py
mv tmp.plist tmp/EFI/OC/config.plist