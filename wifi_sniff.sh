# OS VERSION :
#Linux raspberrypi 3.18.11-v7+ #781 SMP PREEMPT Tue Apr 21 18:07:59 BST 2015 armv7l

#### REMOVE GUI #####
sudo apt-get remove --purge x11-common
sudo apt-get autoremove
# BEFORE : /dev/root        3683656 2601004    882740  75% /
# AFTER : /dev/root        3683656 1444868   2038876  42% /
#### END REMOVE GUI #####

#### CONFIGURE NETWORK ####
sudo nano /etc/wpa_supplicant/wpa_supplicant.conf 

#### EDIT FILE ####
	ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
	update_config=1

	network={
		ssid="YOUR_SSID"
		psk="YOUR_PASSWORD"
	}
#### END FILE ####

sudo nano /etc/network/interfaces

#### EDIT FILE ####
	auto lo
	iface lo inet loopback

	auto eth0
	allow-hotplug eth0
	iface eth0 inet static
	  address 192.168.1.250
	  network 192.168.1.0
	  netmask 255.255.255.0
	  gateway 192.168.1.1

	auto wlan0
	iface wlan0 inet static
	  address 192.168.1.251
	  network 192.168.1.0 
	  netmask 255.255.255.0
	  gateway 192.168.1.1
	wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf
#### END FILE ####

sudo nano /etc/default/ifplugd 

#### EDIT FILE ####
	#INTERFACES="auto"
	#HOTPLUG_INTERFACES="all"
	#ARGS="-q -f -u0 -d10 -w -I"
	#SUSPEND_ACTION="stop"
	INTERFACES="eth0"
	HOTPLUG_INTERFACES="eth0"
	ARGS="-q -f -u0 -d10 -w -I"
	SUSPEND_ACTION="stop"
#### END FILE ####

sudo nano /etc/rc.local

#### EDIT FILE ####
	#!/bin/sh -e

	# Print the IP address
	_IP=$(hostname -I) || true
	if [ "$_IP" ]; then
	  printf "IP address is %s\n" "$_IP"
	fi

	# Disable the ifplugd eth0
	sudo ifplugd eth0 --kill
	sudo ifup wlan0

	exit 0
#### END FILE ####
#### END NETWORK SETTINGS ####

#### INSTALL SNIFFERS ####
wget http://download.aircrack-ng.org/aircrack-ng-1.2-rc2.tar.gz
tar -zxvf aircrack-ng-1.2-rc2.tar.gz
cd aircrack-ng-1.2-rc2/
sudo apt-get update
sudo apt-get -y install libnl-dev
sudo apt-get install libssl-dev
sudo make
sudo make install
sudo apt-get install ethtool
sudo airodump-ng-oui-update
sudo apt-get install iw
sudo airmon-ng start wlan0
sudo apt-get install tshark
#### END INSTALL SNIFFERS ####

#### BEGIN SNIFFING ####
sudo ifconfig wlan0 down
sudo iwconfig wlan0 mode monitor
iwconfig # should display wlan0 in monitor mode
sudo ifconfig wlan0 up
#https://ask.wireshark.org/questions/24249/decrypt-wpa-with-tshark
sudo tshark -o wlan.enable_decryption:TRUE -o "uat:80211_keys:\"wpa-pwd\",\"YOUR_PASSWORD:YOUR_SSIS\"" -R "http" -i wlan0
#### END SNIFFING ####


