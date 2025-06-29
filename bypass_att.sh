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
  sudo cp /home/pi/wpa_supplicant/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf
  sudo systemctl restart firerouter_dhclient@eth0
fi
