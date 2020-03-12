#!/usr/bin/env bash

# USAGE:
# Configure this PC with an IP address like 192.168.1.10, then run:
#
# ./config-dd-wrt.sh current-ap-ip stiege top-number channel-2.4Ghz channel-5GHz

# For top-number and stiege have a look at: https://docs.google.com/document/d/1PglX5TcNaH_ZIqJSVUVMM_mFxx2aE1yNXjn3ciF7-pI/edit
#
# The AP gets configured with an IP based on the ap-number. The first parameter
# is the IP the accesspoint is reachable on when the script is run.

current_ip=${1}
stiege=${2}
top_number=${3}
ap_channel_24GHz=${4}
ap_channel_5GHz=${5}

ap_number=${stiege}${top_number}
ap_ip=10.134.1.${ap_number}
# Locally administred MACS:
ap_mac_24GHz=32:37:86:2A:2${stiege}:${top_number}
ap_mac_5GHz=32:37:86:2A:5${stiege}:${top_number}

wpa_phrase=$(cat secure/wpa-phrase)

function sshAP {
      ssh root@${current_ip} -i secure/ap-key "$@"
}

function setOption {
  sshAP nvram set "$@"
}

ap_ip=10.134.1.${ap_number}
ssid_name="GM-GUEST"

while :
do
  #Script running on the router:
  sshAP <<EOF

  # Detect which wifi is which (on netgear it is the other way round as on tp-link):
  if (iwlist ath0 freq | grep -q 'Channel 100')
  then
    wifi_5Ghz=ath0
    wifi_24Ghz=ath1
  else
    wifi_24Ghz=ath0
    wifi_5Ghz=ath1
  fi

  # Have we configured BSSIDs yet? If not - make sure wifi is switched off, before
  # changing - otherwise turn it off and have us restarted.

  wifi_5Ghz_current_bssid=GET_BSSID_TODO
  wifi_24Ghz_current_bssid=GET_BSSID_TODO
  wifi_24Ghz_is_on=TODO
  wifi_5Ghz_is_on=TODO
  if [[ "\${wifi_5Ghz_current_bssid} != "${ap_mac_5GHz}" ]] || [[ "\${wifi_24Ghz_current_bssid} != "${ap_mac_24GHz}" ]]
  then
    if [[ wifi_24Ghz_is_on ]] || [[ wifi_5Ghz_is_on ]]
    then
      power off 24 Ghz TODO
      power off 5 Ghz  TODO
      echo "Commit powered off wifi"
      nvram commit
      # Can't reboot - has to be done from the outside
      # Signal to calling context, that this needs AP needs to be rebooted and
      # this script needs to be run again afterwards.
      exit 1
    else
      nvram set "TODO_24GHzbssid=${ap_mac_24GHz}"
      nvram set "TODO_24GHzbssid=${ap_mac_24GHz}"
      power on 24 Ghz TODO
      power on 5 Ghz  TODO
    fi
  fi

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

  if [[ $? == 0 ]]
  then
    break
  # Reboot needed:
  elif [[ $? == 1 ]]
    sshAP << EOF
      reboot
EOF
  fi
  sleep 10s
done



