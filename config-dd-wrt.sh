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

ssid_name="GM-GUEST"

# Common wifi settings:

for card in ath0 ath1
do
  echo "Setting regdomain to Austria"
  setOption "${card}_regdomain=AUSTRIA"

  echo "Setting txpwr to 30dBm"
  setOption "${card}_txpwrdbm=30"

  echo "Setting ssid to ${ssid_name}"
  setOption "${card}_ssid=${ssid_name}"

  echo "Setting up wpa2 and wpa3"
  setOption "${card}_security_mode=wpa"
  setOption "${card}_akm=psk2 psk3"
  setOption "${card}_wpa_gt_rekey=3600"
  setOption "${card}_ccmp=1"
  setOption "${card}_psk2=1"
  setOption "${card}_psk3=1"

  echo "Setting wifi password"
  setOption "${card}_wpa_psk=${wpa_phrase}"

  echo "Setting mode to AP"
  setOption "${card}_mode=ap"

  echo "Maximising bandwidth"
  setOption "${card}_channelbw=2040"

  echo "Enabling beam forming"
  setOption "${card}_mubf=1"
  setOption "${card}_subf=1"
done

setOption "wl0_ssid=${ssid_name}"
setOption "wl0_mode=ap"
setOption "wl_mode=ap"


sshAP nvram commit
sshAP reboot





