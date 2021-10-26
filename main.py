import plistlib
import os
import binascii

ACPI_ADD =  [{'Comment': '', 'Enabled': True, 'Path': 'SSDT-AWAC.aml'}, {'Comment': '', 'Enabled': True, 'Path': 'SSDT-EC-USBX-DESKTOP.aml'}, {'Comment': '', 'Enabled': True, 'Path': 'SSDT-PLUG-DRTNIA.aml'}, {'Comment': '', 'Enabled': True, 'Path': 'SSDT-PMC.aml'}]

Kernel_Add = [{'Arch': 'x86_64', 'BundlePath': 'Lilu.kext', 'Comment': 'Patch engine', 'Enabled': True, 'ExecutablePath': 'Contents/MacOS/Lilu', 'MaxKernel': '', 'MinKernel': '10.0.0', 'PlistPath': 'Contents/Info.plist'}, {'Arch': 'x86_64', 'BundlePath': 'VirtualSMC.kext', 'Comment': 'SMC emulator', 'Enabled': True, 'ExecutablePath': 'Contents/MacOS/VirtualSMC', 'MaxKernel': '', 'MinKernel': '10.0.0', 'PlistPath': 'Contents/Info.plist'}, {'Arch': 'Any', 'BundlePath': 'NVMeFix.kext', 'Comment': '', 'Enabled': True, 'ExecutablePath': 'Contents/MacOS/NVMeFix', 'MaxKernel': '', 'MinKernel': '', 'PlistPath': 'Contents/Info.plist'}, {'Arch': 'Any', 'BundlePath': 'SMCProcessor.kext', 'Comment': '', 'Enabled': True, 'ExecutablePath': 'Contents/MacOS/SMCProcessor', 'MaxKernel': '', 'MinKernel': '', 'PlistPath': 'Contents/Info.plist'}, {'Arch': 'Any', 'BundlePath': 'SMCSuperIO.kext', 'Comment': '', 'Enabled': True, 'ExecutablePath': 'Contents/MacOS/SMCSuperIO', 'MaxKernel': '', 'MinKernel': '', 'PlistPath': 'Contents/Info.plist'}, {'Arch': 'Any', 'BundlePath': 'USBMap.kext', 'Comment': '', 'Enabled': False, 'ExecutablePath': '', 'MaxKernel': '', 'MinKernel': '', 'PlistPath': 'Contents/Info.plist'}, {'Arch': 'x86_64', 'BundlePath': 'WhateverGreen.kext', 'Comment': 'Video patches', 'Enabled': True, 'ExecutablePath': 'Contents/MacOS/WhateverGreen', 'MaxKernel': '', 'MinKernel': '12.0.0', 'PlistPath': 'Contents/Info.plist'}, {'Arch': 'x86_64', 'BundlePath': 'AppleALC.kext', 'Comment': 'Audio patches', 'Enabled': True, 'ExecutablePath': 'Contents/MacOS/AppleALC', 'MaxKernel': '', 'MinKernel': '12.0.0', 'PlistPath': 'Contents/Info.plist'}, {'Arch': 'x86_64', 'BundlePath': 'IntelMausi.kext', 'Comment': 'Intel Ethernet LAN', 'Enabled': True, 'ExecutablePath': 'Contents/MacOS/IntelMausi', 'MaxKernel': '', 'MinKernel': '', 'PlistPath': 'Contents/Info.plist'}, {'Arch': 'Any', 'BundlePath': 'CPUFriendDataProvider.kext', 'Comment': '', 'Enabled': True, 'ExecutablePath': '', 'MaxKernel': '', 'MinKernel': '', 'PlistPath': 'Contents/Info.plist'}, {'Arch': 'Any', 'BundlePath': 'CPUFriend.kext', 'Comment': '', 'Enabled': True, 'ExecutablePath': 'Contents/MacOS/CPUFriend', 'MaxKernel': '', 'MinKernel': '', 'PlistPath': 'Contents/Info.plist'}]

DeviceProperties_ADD = {'PciRoot(0x0)/Pci(0x1b,0x0)': {'layout-id': b'\x01\x00\x00\x00'}, 'PciRoot(0x0)/Pci(0x2,0x0)': {'AAPL,ig-platform-id': b'\x03\x00\x91>', 'framebuffer-patch-enable': b'\x01\x00\x00\x00', 'framebuffer-stolenmem': b'\x00\x000\x01'}}

with open('dist/EFI/OC/config.plist','rb') as f:
    r = plistlib.load(f)

    r['ACPI']['Add'] = ACPI_ADD

    r['Booter']['Quirks']['DevirtualiseMmio'] = True
    r['Booter']['Quirks']['EnableWriteUnprotector'] = False
    r['Booter']['Quirks']['ProtectUefiServices'] = True
    r['Booter']['Quirks']['RebuildAppleMemoryMap'] = True
    r['Booter']['Quirks']['SyncRuntimePermissions'] = True

    r['DeviceProperties']['Add'] = DeviceProperties_ADD

    r['Kernel']['Quirks']['AppleCpuPmCfgLock'] = False
    r['Kernel']['Quirks']['AppleXcpmCfgLock'] = True
    r['Kernel']['Quirks']['CustomSMBIOSGuid'] = False
    r['Kernel']['Quirks']['DisableIoMapper'] = True
    r['Kernel']['Quirks']['LapicKernelPanic'] = False
    r['Kernel']['Quirks']['PanicNoKextDump'] = True
    r['Kernel']['Quirks']['PowerTimeoutKernelPanic'] = True
    r['Kernel']['Quirks']['XhciPortLimit'] = False

    r['Kernel']['Add'] = Kernel_Add

    r['Misc']['Debug']['AppleDebug'] = True
    r['Misc']['Debug']['ApplePanic'] = True
    r['Misc']['Debug']['Target'] = 67
    r['Misc']['Debug']['DisableWatchDog'] = True

    r['Misc']['Security']['AllowNvramReset'] = True
    r['Misc']['Security']['AllowSetDefault'] = True
    r['Misc']['Security']['ScanPolicy'] = 0
    r['Misc']['Security']['SecureBootModel'] = 'Disabled'
    r['Misc']['Security']['Vault'] = 'Optional'

    r['NVRAM']['Add']['7C436110-AB2A-4BBB-A880-FE41995C9F82']['boot-args'] = 'debug=0x100 keepsyms=1 alcid=1'
    # r['NVRAM']['Add']['7C436110-AB2A-4BBB-A880-FE41995C9F82']['csr-active-config'] = bytearray.fromhex('67000000')
    r['NVRAM']['Add']['7C436110-AB2A-4BBB-A880-FE41995C9F82']['prev-lang:kbd'] = b''
    r['NVRAM']['WriteFlash'] = True

    r['PlatformInfo']['Generic']['MLB'] = os.environ['MLB']
    r['PlatformInfo']['Generic']['ROM'] = binascii.unhexlify(os.environ['ROM'])
    r['PlatformInfo']['Generic']['SystemProductName'] = os.environ['SystemProductName']
    r['PlatformInfo']['Generic']['SystemSerialNumber'] = os.environ['SystemSerialNumber']
    r['PlatformInfo']['Generic']['SystemUUID'] = os.environ['SystemUUID']

    # print(r['Kernel']['Add'])
    drivers = [dict(Arguments='',Enabled=True,Path='HfsPlus.efi'), dict(Arguments='',Enabled=True,Path='OpenRuntime.efi')]

    r['UEFI']['Drivers'] = drivers
    r['UEFI']['Quirks']['UnblockFsConnect'] = False 

    # print(r['UEFI'])

    with open('tmp.plist', 'wb') as ff:
        plistlib.dump(r, ff)
