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

get_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}

mkdir -p tmp
download_oc https://github.com/acidanthera/OpenCorePkg/releases/download/${OPENCORE_VERSION}/OpenCore-${OPENCORE_VERSION}-RELEASE.zip tmp

wget https://github.com/acidanthera/OcBinaryData/raw/master/Drivers/HfsPlus.efi -O tmp/EFI/OC/Drivers/HfsPlus.efi 

lilu_latest=$(get_latest_release "acidanthera/Lilu")
download_kext lilu https://github.com/acidanthera/Lilu/releases/download/${lilu_latest}/Lilu-${lilu_latest}-RELEASE.zip Lilu.kext tmp/EFI/OC/Kexts
virtualsmc_latest=$(get_latest_release "acidanthera/VirtualSMC")
download_kext virtualsmc https://github.com/acidanthera/VirtualSMC/releases/download/${virtualsmc_latest}/VirtualSMC-${virtualsmc_latest}-RELEASE.zip Kexts/VirtualSMC.kext tmp/EFI/OC/Kexts
download_kext virtualsmc https://github.com/acidanthera/VirtualSMC/releases/download/${virtualsmc_latest}/VirtualSMC-${virtualsmc_latest}-RELEASE.zip Kexts/SMCSuperIO.kext tmp/EFI/OC/Kexts
download_kext virtualsmc https://github.com/acidanthera/VirtualSMC/releases/download/${virtualsmc_latest}/VirtualSMC-${virtualsmc_latest}-RELEASE.zip Kexts/SMCProcessor.kext tmp/EFI/OC/Kexts

whatevergreen_latest=$(get_latest_release "acidanthera/WhateverGreen")
download_kext whatevergreen https://github.com/acidanthera/WhateverGreen/releases/download/${whatevergreen_latest}/WhateverGreen-${whatevergreen_latest}-RELEASE.zip WhateverGreen.kext tmp/EFI/OC/Kexts

applealc_latest=$(get_latest_release "acidanthera/AppleALC")
download_kext applealc https://github.com/acidanthera/AppleALC/releases/download/${applealc_latest}/AppleALC-${applealc_latest}-RELEASE.zip AppleALC.kext tmp/EFI/OC/Kexts
intelmausi_latest=$(get_latest_release "acidanthera/IntelMausi")
download_kext intelmaus https://github.com/acidanthera/IntelMausi/releases/download/${intelmausi_latest}/IntelMausi-${intelmausi_latest}-RELEASE.zip IntelMausi.kext tmp/EFI/OC/Kexts
nvmefix_latest=$(get_latest_release "acidanthera/NVMeFix")
download_kext nvmefix https://github.com/acidanthera/NVMeFix/releases/download/${nvmefix_latest}/NVMeFix-${nvmefix_latest}-RELEASE.zip NVMeFix.kext tmp/EFI/OC/Kexts

download_plain_file https://github.com/dortania/Getting-Started-With-ACPI/raw/master/extra-files/compiled/SSDT-PLUG-DRTNIA.aml tmp/EFI/OC/ACPI
download_plain_file https://github.com/dortania/Getting-Started-With-ACPI/raw/master/extra-files/compiled/SSDT-AWAC.aml tmp/EFI/OC/ACPI
download_plain_file https://github.com/dortania/Getting-Started-With-ACPI/raw/master/extra-files/compiled/SSDT-EC-USBX-DESKTOP.aml tmp/EFI/OC/ACPI
download_plain_file https://github.com/dortania/Getting-Started-With-ACPI/raw/master/extra-files/compiled/SSDT-PMC.aml tmp/EFI/OC/ACPI

source .env
python3 main.py
mv tmp.plist tmp/EFI/OC/config.plist