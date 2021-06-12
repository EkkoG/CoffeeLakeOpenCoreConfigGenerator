Auomate script follow by https://dortania.github.io/OpenCore-Install-Guide/config.plist/coffee-lake.html

For Coffee Lake CPUs, test on 8700K+Z370m-D3H

#Usage

first create a `.env` file, with content like this

```
export MLB=
export SystemProductName=
export SystemSerialNumber=
export SystemUUID=
export ROM=
```
and then run command

Normaly, `ROM` is your MAC address without `:`, like your MAC is `00:45:36:45:f2:00 `, and your ROM var is `00453645f200`

```
cd CoffeeLakeOpenCoreAutuConfig
./main.sh
```

after do these, a EFI will located at `tmp/EFI`

check you config, and fix your ROM https://dortania.github.io/OpenCore-Post-Install/universal/iservices.html#fixing-rom

Enjoy!