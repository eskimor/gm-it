#!/usr/bin/env bash

# USAGE:
# Configure this PC with an IP address like 192.168.1.10, then run:
#
# ./config-dd-wrt.sh ap-number [init]
#
# Pass init, if this is the initial configuration (AP still hast 192.168.1.1 address).

ap_number=${1}
wpa_phrase=$(cat secure/wpa-phrase)
do_init=${2}
ap_ip=10.134.1.${ap_number}

function sshAP {
  if [[ x == x${do_init} ]]
    then
      ssh root@${ap_ip} -i secure/ap-key "$@"
    else
      ssh root@192.168.1.1 -i secure/ap-key "$@"
    fi
}

function setOption {
  sshAP nvram set "$@"
}

ap_ip=10.134.1.${ap_number}

echo "Setting IP to ${ap_ip}"
setOption "lan_ipaddr=${ap_ip}"
setOption "lan_netmask=255.255.0.0"

ap_hostname="gm-ap-${ap_number}"
echo "Setting router name to ${ap_hostname}"
setOption "router_name=${ap_hostname}"

echo "Disabling DHCP server"
setOption "lan_proto=static"

echo "Setting regdomain to Austria"
setOption "ath0_regdomain=AUSTRIA"
setOption "ath1_regdomain=AUSTRIA"

echo "Setting txpwr to 30dBm"
setOption "ath0_txpwrdbm=30"
setOption "ath1_txpwrdbm=30"


ssid_name="GM-GUEST"
echo "Setting ssid to ${ssid_name}"
setOption "ath0_ssid=${ssid_name}"
setOption "ath1_ssid=${ssid_name}"
setOption "wl0_ssid=${ssid_name}"

echo "Setting wifi password"
setOption "ath0_wpa_psk=${wpa_phrase}"
setOption "ath1_wpa_psk=${wpa_phrase}"

echo "Setting mode to AP"
setOption "ath0_mode=ap"
setOption "ath1_mode=ap"
setOption "wl0_mode=ap"
setOption "wl_mode=ap"

echo "Maximising bandwidth"
setOption "ath0_channelbw=2040"
setOption "ath1_channelbw=2040"

echo "Enabling beam forming"
setOption "ath0_mubf=1"
setOption "ath1_mubf=1"
setOption "ath0_subf=1"
setOption "ath1_subf=1"


sshAP nvram commit
sshAP reboot





