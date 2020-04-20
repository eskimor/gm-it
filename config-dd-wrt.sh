#!/usr/bin/env bash

# USAGE:
# Configure this PC with an IP address like 192.168.1.10, then run:
#
# ./config-dd-wrt.sh current-ap-ip stiege top-number

# For top-number and stiege have a look at: https://docs.google.com/document/d/1PglX5TcNaH_ZIqJSVUVMM_mFxx2aE1yNXjn3ciF7-pI/edit
#
# The AP gets configured with an IP based on the ap-number. The first parameter
# is the IP the accesspoint is reachable on when the script is run.
set -x
current_ip=${1}
stiege=${2}
top_number=${3}

ap_number=${stiege}${top_number}

source ./config-lookup.sh
freqs=( $(freqs_per_ap_number ${ap_number}) )

#Frequency, e.g. 2427 / 0 for auto
wifi_channel_24Ghz=${freqs[0]}
#Frequency, e.g. 5240 / 0 for auto
wifi_channel_5Ghz=${freqs[1]}

ap_hostname="gm-ap-${ap_number}"
ap_ip=10.134.1.${ap_number}
# Locally administred MACS:

wpa_phrase=$(cat secure/wpa-phrase)

function sshAP {
      ssh root@${current_ip} -i secure/ap-key "$@"
}

function setOption {
  sshAP nvram set "$@"
}

ap_ip=10.134.1.${ap_number}
ssid_name_24Ghz="GM-GUEST"
ssid_name_5Ghz=$(guest_ssid_5Ghz_per_ap_numer ${ap_number})

# While loop so we can switch off wifi before changing BSSIDs as otherwise clients might get severly confused (Windows machines at least):
while :
do
  #Script running on the router:
  sshAP <<EOF
    set -e
    # Detect which wifi is which (on netgear it is the other way round as on tp-link):
    if (iw phy  phy0 info | grep -q '5500 MHz')
    then
      ap_model=r7800
      wifi_bssid_24Ghz=32:78:00:00:2${stiege}:${top_number}
      wifi_bssid_5Ghz=32:78:00:00:5${stiege}:${top_number}
      wifi_5Ghz=ath0
      wifi_24Ghz=ath1
    else
      ap_model=c7
      wifi_bssid_24Ghz=32:00:C7:00:2${stiege}:${top_number}
      wifi_bssid_5Ghz=32:00:C7:00:5${stiege}:${top_number}
      wifi_24Ghz=ath0
      wifi_5Ghz=ath1
    fi


    # Have we configured BSSIDs yet? If not - make sure wifi is switched off, before
    # changing - otherwise turn it off and have us restarted.

    wifi_current_bssid_24Ghz="\$(nvram get \${wifi_24Ghz}_config | sed 's/bssid=//1')"
    wifi_current_bssid_5Ghz="\$(nvram get \${wifi_5Ghz}_config | sed 's/bssid=//1')"
    wifi_is_on_24Ghz="[[ \$(nvram get \${wifi_24Ghz}_net_mode) != disabled ]]"
    wifi_is_on_5Ghz="[[ \$(nvram get \${wifi_5Ghz}_net_mode) != disabled ]]"

    if [[ "x\${wifi_current_bssid_5Ghz}" != "x\${wifi_bssid_5Ghz}" ]] || [[ "x\${wifi_current_bssid_24Ghz}" != "x\${wifi_bssid_24Ghz}" ]]
    then
      if \${wifi_is_on_24Ghz} || \${wifi_is_on_5Ghz}
      then
        nvram set "\${wifi_24Ghz}_net_mode=disabled"
        nvram set "\${wifi_5Ghz}_net_mode=disabled"
        echo "Commit powered off wifi"
        nvram commit
        # Can't reboot - has to be done from the outside
        # Signal to calling context, that this AP needs to be rebooted and
        # this script needs to be run again afterwards.
        exit 1
      else
        nvram set "\${wifi_24Ghz}_config=bssid=\${wifi_bssid_24Ghz}"
        nvram set "\${wifi_5Ghz}_config=bssid=\${wifi_bssid_5Ghz}"
        nvram set "\${wifi_24Ghz}_net_mode=mixed"
        nvram set "\${wifi_5Ghz}_net_mode=mixed"
      fi
    fi

    echo "Setting IP to ${ap_ip}"
    nvram set "lan_ipaddr=${ap_ip}"
    nvram set "lan_netmask=255.255.0.0"

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

      echo "Setting up wpa2 and disable wpa3"
      nvram set "\${card}_security_mode=wpa"

      # Old Apple hardware does not seem to like WPA3:
      # nvram set "\${card}_akm=psk2 psk3"
      nvram set "\${card}_akm=psk2"

      nvram set "\${card}_wpa_gt_rekey=3600"
      nvram set "\${card}_ccmp=1"
      nvram set "\${card}_psk2=1"

      # Old Apple hardware does not seem to like WPA3:
      # nvram set "\${card}_psk3=1"
      nvram set "\${card}_psk3=0"

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

    echo "Setting 5 GHz to use upper extension band:"
    nvram set "\${wifi_5Ghz}_nctrlsb=ull"

    echo "Setting 2.4GHz ssid to ${ssid_name_24Ghz}"
    nvram set "\${wifi_5Ghz}_ssid=${ssid_name_24Ghz}"

    echo "Setting 5GHz ssid to ${ssid_name_5Ghz}"
    nvram set "\${wifi_24Ghz}_ssid=${ssid_name_5Ghz}"

    echo "Setting channels:"
    nvram set \${wifi_24Ghz}_channel=${wifi_channel_24Ghz}
    nvram set \${wifi_5Ghz}_channel=${wifi_channel_5Ghz}


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
  else if [[ $? == 1 ]]
    then
      sshAP reboot
    fi
  fi
  sleep 25s
done



