# Bypass/Replace AT&T router with Firewalla router

Instruction for how to replace BGW210 AT&T router with Firewalla router.
For this walkthrough, I am using Firewalla Gold Plus router.
I haven't tested with other Firewalla routers because I don't have them.

## Extract certificates from AT&T router

I am following https://github.com/0x888e/certs?tab=readme-ov-file documentation to extract a private root key and
certificates from AT&T router BGW210.

The current software version in the router is: Software Version 4.28.7.
I downloaded the firmware using [archive.org](https://archive.org/details/BGW210-700-Firmware-Collection) link.
Then I flashed using `spTurquoise210-700_3.18.2_ENG.bin`.

```shell
certs on  main via 🐍 v3.13.0 took 2s
❯ python download.py
[+] BGW-210 and BGW-320 mfg/calibration download (for bypass EAP certificates)
[+] ----------------------------------------
[+] Connect your machine directly to LAN1 on the BGW.
[+] Ensure no other interface on your machine is configured for the 192.168.1/24 subnet.
[+] Configure the IP address of the NIC on your machine to:
[+] IP: 192.168.1.11
[+] Subnet: 255.255.255.0
[+] Gateway: 192.168.1.254
[+] ----------------------------------------
[+] Press Ctrl+C to exit.
[+] ----------------------------------------
[+] Waiting for the BGW to come online...
[+] BGW is online. Determining eligibility...
[+] Firmware compatible. Configured model: BGW210
[+] ----------------------------------------
[+] *** REBOOT THE BGW210 NOW ***
[+] (This may take up to 3 minutes. After 3 minutes, keep this running and press and release the red reset button on the back of the BGW. NOTE: Do not hold this button down for more than a second as it will factory reset the BGW.)
[+] ----------------------------------------
[+] Worker 0 starting.
[+] Worker 1 starting.
[+] Worker 1 exiting.
[+] Worker 0 exiting.
[+] Download successful. File written to mfg.dat
```

Following https://github.com/abrender/mfgdat?tab=readme-ov-file documentation I ran the application directly using `go`
because the pre-built binary is not available for macOS with Apple Silicon.

```shell
mfgdat on  main via 🐹 v1.24.3
❯ go run . ../../0x888e/certs/mfg.dat
Copyright (C) 2025 Avi Brender.
License GPLv3+: GNU GPL version 3 or later <https://gnu.org/licenses/gpl.html>

This is free software; you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Build Release: unknown
Build Revision: unknown
Build Time: unknown

Reading input file: ../../0x888e/certs/mfg.dat

Found device model: BGW210-700
Found device certificate:
	Serial Number:	001E69-H91ING8R623638
	MAC Address:	42:69:2C:D5:5A:93
	Issuer:		ARRIS Group, Inc. Device Intermediate CA ATTCPE1

Found chain certificate: ARRIS Group, Inc. Device Intermediate CA ATTCPE1
Found chain certificate: ARRIS Group, Inc. Device Root CA ATTCPE1
Found RSA private key

Wrote output to /Users/luitel/go/src/github.com/abrender/mfgdat/001E69-H91ING8R623638.tar.gz

IMPORTANT: The file paths in wpa_supplicant.conf must be changed.
```

Certs are extracted.

Re-flashed the att router with `spTurquoise210-700_4.26.11.bin` version since I couldn't find anything else on
the internet.

Connected the cables to the att router and the internet is online.
I will see when the version gets updated to the latest.

## Set up Firewalla router with extracted certificate

[how to ssh into Firewalla]: https://help.firewalla.com/hc/en-us/articles/115004397274-How-to-access-Firewalla-using-SSH

To SSH to Firewalla router, see [how to ssh into Firewalla] router for SSH instruction.

### SCP extracted certs and config to firewalla

SCP the extracted contents from your local machine to the Firewalla router.

```shell
certs/extracted on  main [?]
❯ scp ./001E69-H91ING8R623638/* pi@192.168.50.133:/home/pi/wpa_supplicant/
pi@192.168.50.133's password:
ca_certs_001E69-H91ING8R623638.pem                                                                                                                                                  100% 3958   484.0KB/s   00:00
client_cert_001E69-H91ING8R623638.pem                                                                                                                                               100% 1131   176.8KB/s   00:00
private_key_001E69-H91ING8R623638.pem                                                                                                                                               100%  891   150.8KB/s   00:00
wpa_supplicant.conf
````

### SSH into Firewalla

```shell
❯ ssh pi@192.168.50.133
The authenticity of host '192.168.50.133 (192.168.50.133)' can't be established.
ED25519 key fingerprint is SHA256:GZmnVKBCk4ApqwqlHnb1y2293xPqBAy09z0vaqViZG8.
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '192.168.50.133' (ED25519) to the list of known hosts.
pi@192.168.50.133's password:
Permission denied, please try again.
pi@192.168.50.133's password:

 ▄▄▄▄▄▄ ▄▄▄▄▄  ▄▄▄▄▄  ▄▄▄▄▄▄▄     ▄   ▄▄   ▄      ▄        ▄▄
 █        █    █   ▀█ █     █  █  █   ██   █      █        ██
 █▄▄▄▄▄   █    █▄▄▄▄▀ █▄▄▄▄▄▀ █▀█ █  █  █  █      █       █  █
 █        █    █   ▀▄ █      ██ ██▀  █▄▄█  █      █       █▄▄█
 █      ▄▄█▄▄  █    ▀ █▄▄▄▄▄ █   █  █    █ █▄▄▄▄▄ █▄▄▄▄▄ █    █



Welcome to FIREWALLA GOLD 18.04.3 LTS (Bionic Beaver)  Ubuntu 18.04.3 LTS 4.15.0-70-generic

  System information as of Sat Jun 21 16:32:59 CDT 2025

  System load:    0.43      Processes:          216
  Usage of /home: unknown   Users logged in:    0
  Memory usage:   38%       IP address for br0: 192.168.50.133
  Swap usage:     0%
tmpfs-root /media/root-rw tmpfs rw,relatime,size=204800k 0 0
overlayroot / overlay rw,relatime,lowerdir=/media/root-ro,upperdir=/media/root-rw/overlay,workdir=/media/root-rw/overlay-workdir/_ 0 0
/dev/mmcblk0p3 /media/root-ro ext4 rw,relatime,data=ordered 0 0


The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

pi@firewalla:~ (Firewalla) $
```

Create a script to run wpa_supplicant dhcp hook at `/home/pi/wpa_supplicant/dhcp_enter_hook`.

```shell
pi@firewalla:~ (Firewalla) $ cat /home/pi/wpa_supplicant/dhcp_enter_hook
#!/bin/bash

printf '%s %s\n' "$(date ""+%T"")" "Executing dhcp_enter_hook script." >> /home/pi/logs/att_bypass.log
if pgrep -x wpa_supplicant > /dev/null
then
  printf '%s %s\n' "$(date ""+%T"")" "wpa_supplicant is already running." >> /home/pi/logs/att_bypass.log
else
  printf '%s %s\n' "$(date ""+%T"")" "Running wpa_supplicant binary." >> /home/pi/logs/att_bypass.log
  /sbin/wpa_supplicant -d -s -B -Dwired -ieth0 -c/etc/wpa_supplicant/wpa_supplicant.conf
fi
```

Chmod +x the script.

```shell
chmod +x /home/pi/wpa_supplicant/dhcp_enter_hook
```

Create another script, `/home/pi/wpa_supplicant/att_bypass.sh`.

```shell
#!/bin/bash

# check if wpa_supplicant is installed, of not, install it
if ! command -v wpa_supplicant &> /dev/null
then
  echo "wpa_supplicant could not be found, installing..."
  sudo apt-get update
  sudo apt-get remove -y libssl-dev
  sudo apt-get install -y libssl1.1
  sudo apt-get install -y libssl-dev
  sudo apt-get install -y wpasupplicant
  # check and wait for wpa_supplicant to start; then stop it.
  # this is to ensure that the wpa_supplicant service is not running when we run the script the first time.
  while ! pgrep -x wpa_supplicant > /dev/null; do
    sleep 1
  done
  sudo systemctl stop wpa_supplicant
fi

# check if wpa_supplicant is running, if not, run it.
if ! pgrep -x wpa_supplicant > /dev/null
then
  sudo cp /home/pi/wpa_supplicant/dhcp_enter_hook /etc/dhcp/dhclient-enter-hooks.d/att_bypass
  sudo systemctl restart firerouter_dhclient@eth0
fi
```

### Install wpa_supplicant

I am not able to use the wpa_supplicant that comes with Firewalla, because there isn't one installed.
Also, I am not able to install without getting the following warning from firewalla.

```shell
pi@firewalla:~ (Firewalla) $ sudo apt-get update

WARNING!

Firewalla uses a specific package set, and have dedicated customizations.
We do pay attention to those security updates but don't have the resource to
test every update. Upgrading packages here will much likely break things.

If you know what you are doing and wish to continue, use 'unalias apt'
and 'unalias apt-get' to hide this message.
```

That is the reason the script above checks if `wpa_supplicant` is installed, and if not, installs it along with the
required dependencies.

Also, when the router got updated, the manually installed `wpa_supplicant` was removed.
That is the reason I had to scriptize the installation.

### Prepare to run wpa_supplicant

#### Keep running the script between restarts

[keep the script running between system restarts]: https://help.firewalla.com/hc/en-us/articles/360054056754-Customized-Scripting

Following the Firewalla document to [keep the script running between system restarts] I created the directory
`/home/pi/.firewalla/config/post_main.d/` to place the script in.

```shell
pi@firewalla:~ (Firewalla) $ mkdir -p /home/pi/.firewalla/config/post_main.d/
pi@firewalla:~ (Firewalla) $ cd /home/pi/.firewalla/config/post_main.d/
pi@firewalla:~/.firewalla/config/post_main.d (Firewalla) $ sudo chmod +wr .
```

Move the script `att_bypass.sh` to the directory and run it to verify that it works.

```shell
pi@firewalla:~ (Firewalla) $ mv /home/pi/wpa_supplicant/att_bypass.sh /home/pi/.firewalla/config/post_main.d/
pi@firewalla:~ (Firewalla) $ sudo /home/pi/.firewalla/config/post_main.d/att_bypass.sh
```

Verify that the wpa_supplicant is running.

```shell
pi@firewalla:~/.firewalla/config/post_main.d (Firewalla) $ ps aux | grep supplicant
root      5124  0.0  0.1  62224  4108 ?        S    Jun15   0:00 sudo tail -F /var/log/wpa_supplicant.log
root      5126  0.0  0.0   6212   772 ?        S    Jun15   1:06 tail -F /var/log/wpa_supplicant.log
root     31881  0.0  0.0  45360   716 ?        Ss   15:03   0:00 /sbin/wpa_supplicant -d -s -B -Dwired -ieth0 -c/etc/wpa_supplicant/wpa_supplicant.conf
pi       32435  0.0  0.0  13136  1108 pts/0    S+   15:03   0:00 grep supplicant
```

I rebooted the Firewalla router from app to verify that the script runs on boot and it does.
The script will also take care of reinstalling `wpa_supplicant` if Firewalla is updated.

Done, that's it. I'll update once I connect the Firewalla directly to ONT and see if it works.

##### Verification

Verified, it worked, I am able to disconnect the AT&T router and connect the Firewalla directly to the ONT
and the internet is online.

```shell
Jun 27 21:00:01 firewalla wpa_supplicant[14671]: eth0: CTRL-EVENT-EAP-SUCCESS EAP authentication completed successfully
Jun 27 21:00:01 firewalla wpa_supplicant[14671]: EAPOL: IEEE 802.1X for plaintext connection; no EAPOL-Key frames required
Jun 27 21:00:01 firewalla wpa_supplicant[14671]: eth0: WPA: EAPOL processing complete
Jun 27 21:00:01 firewalla wpa_supplicant[14671]: eth0: Cancelling authentication timeout
Jun 27 21:00:01 firewalla wpa_supplicant[14671]: eth0: State: ASSOCIATED -> COMPLETED
Jun 27 21:00:01 firewalla wpa_supplicant[14671]: eth0: CTRL-EVENT-CONNECTED - Connection to 42:69:2C:D5:5A:93 completed [id=0 id_str=]
Jun 27 21:00:01 firewalla wpa_supplicant[14671]: EAPOL: SUPP_PAE entering state AUTHENTICATED
Jun 27 21:00:01 firewalla wpa_supplicant[14671]: EAPOL: Supplicant port status: Authorized
Jun 27 21:00:01 firewalla wpa_supplicant[14671]: EAPOL: SUPP_BE entering state RECEIVE
Jun 27 21:00:01 firewalla wpa_supplicant[14671]: EAPOL: SUPP_BE entering state SUCCESS
Jun 27 21:00:01 firewalla wpa_supplicant[14671]: EAPOL: SUPP_BE entering state IDLE
Jun 27 21:00:01 firewalla wpa_supplicant[14671]: EAPOL authentication completed - result=SUCCESS
Jun 27 21:00:31 firewalla wpa_supplicant[14671]: EAPOL: authWhile --> 0
Jun 27 21:00:31 firewalla wpa_supplicant[14671]: EAPOL: startWhen --> 0
Jun 27 21:01:01 firewalla wpa_supplicant[14671]: EAPOL: idleWhile --> 0
Jun 27 21:01:01 firewalla wpa_supplicant[14671]: EAPOL: disable timer tick
```
