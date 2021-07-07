import plistlib

with open('/Volumes/EFI/EFI/OC/config.plist','rb') as f:
    r = plistlib.load(f)
    print(r['Kernel']['Add'])
