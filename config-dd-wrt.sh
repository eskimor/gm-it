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
ssid_name="GM-GUEST"

#Script running on the router:
sshAP <<EOF
echo "Setting IP to ${ap_ip}"
nvram set "lan_ipaddr=${ap_ip}"
nvram set "lan_netmask=255.255.0.0"

ap_hostname="gm-ap-${ap_number}"
echo "Setting router name to ${ap_hostname}"
nvram set "router_name=${ap_hostname}"

echo "Disabling DHCP server"
nvram set "lan_proto=static"

# Common wifi settings:

for card in ath0 ath1
do
  echo "Setting regdomain to Austria"
  nvram set "\${card}_regdomain=AUSTRIA"

  echo "Setting txpwr to 30dBm"
  nvram set "\${card}_txpwrdbm=30"

  echo "Setting ssid to ${ssid_name}"
  nvram set "\${card}_ssid=${ssid_name}"

  echo "Setting up wpa2 and wpa3"
  nvram set "\${card}_security_mode=wpa"
  nvram set "\${card}_akm=psk2 psk3"
  nvram set "\${card}_wpa_gt_rekey=3600"
  nvram set "\${card}_ccmp=1"
  nvram set "\${card}_psk2=1"
  nvram set "\${card}_psk3=1"

  echo "Setting wifi password"
  nvram set "\${card}_wpa_psk=${wpa_phrase}"

  echo "Setting mode to AP"
  nvram set "\${card}_mode=ap"

  echo "Enabling beam forming"
  nvram set "\${card}_mubf=1"
  nvram set "\${card}_subf=1"
done

# Detect which wifi is which (on netgear it is the other way round as on tp-link):
if (iwlist ath0 freq | grep -q 'Channel 100')
then
  wifi_5Ghz=ath0
  wifi_24Ghz=ath1
else
  wifi_24Ghz=ath0
  wifi_5Ghz=ath1
fi

echo "Setting channel bandwidth:"
nvram set "\${wifi_5Ghz}_channelbw=40"
nvram set "\${wifi_24Ghz}_channelbw=20"


nvram set "wl0_ssid=${ssid_name}"
nvram set "wl0_mode=ap"
nvram set "wl_mode=ap"
echo "Commit and reboot"
nvram commit
reboot
EOF




