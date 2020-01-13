#!/usr/bin/env bash

# USAGE:
# Configure this PC with the IP address 192.168.1.10.

# Then run:
#
# For netgear r7800:
# ./setup-dd-wrt.sh r7800 ap-number
# For tp-link, when already flashed with dd-wrt:
# ./setup-dd-wrt.sh c7 ap-number
#

model="${1}"
ap_number="${2}"
router_ip="192.168.1.1"

############## FLASH ####################

case "${model}" in
  "c7")
    router_fw_uri="ftp://ftp.dd-wrt.com/betas/2020/01-09-2020-r41954/tplink_archer-c7-v5/factory-to-ddwrt.bin"
    imgFile=./factory-to-ddwrt.bin
    ;;
  "r7800")
    router_ip="192.168.1.1"
    router_fw_uri=https://download1.dd-wrt.com/dd-wrtv2/downloads/betas/2019/08-06-2019-r40559/netgear-r7800/factory-to-ddwrt.img
    imgFile=./factory-to-ddwrt.img
    ;;
  *)
    echo "Unsupported router model!"
    exit -1
esac

mkdir ${model}
router_fw="${model}/factory-to-ddwrt.bin"


if [[ ! -e ${router_fw} ]]
then
  #Be reasonably sure we only use fully downloaded files:
  #A hash check ala nix would definitely be better ... hmm, maybe I should nixify this.
  mkdir .dl
  cd .dl
  wget ${router_fw_uri}
  mv ${imgFile} ../${router_fw}
  cd ..
  rmdir .dl
fi

case "${model}" in
  "c7")
    echo "Please visit 192.168.0.1, go to admin - firmware upgrade and upload ${router_fw} (you can skip most of the install wizard):"
    echo "Press Ctrl+D when you are done."
    firefox "http://192.168.0.1"
    cat
    ;;
  "r7800")
    tftp ${router_ip} <<EOF
    binary
    put ${router_fw}
EOF
    sleep 90s
    ;;
  *)
  echo "Unsupported router model!"
  exit -1
esac

############## FLASH END ####################

mapfile -t array < ./secure/ap-password
user=${array[0]}
pw=${array[1]}
ssh_pub_key="$(cat ./secure/ap-key.pub)"
ssh_pub_key_quoted=$(echo \'${ssh_pub_key}\')


# Set password:
curl -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "submit_button=index&submit_type=changepass&next_page=Info.htm&change_action=gozila_cgi&action=Apply&http_username=${user}&http_passwd=${pw}&http_passwdConfirm=${pw}" http://192.168.1.1/apply.cgi --referer http://192.168.1.1/

function authCurl {
  curl -X POST -H "Content-Type: application/x-www-form-urlencoded" --user "${user}:${pw}" "$@"
}


# userpwAuth=$(echo -n "${user}:${pw}" | base64)

# Enable ssh service:

authCurl --data-urlencode submit_button=services --data-urlencode action=ApplyTake --data-urlencode commit=1 --data-urlencode sshd_enable=1 --data-urlencode sshd_passwd_auth=0 --data-urlencode sshd_authorized_keys="${ssh_pub_key}" --referer http://192.168.1.1/Services.asp http://192.168.1.1/applyuser.cgi

sed -i 's/192.168.1.1.*$//1' ~/.ssh/known_hosts
echo "Waiting for ssh to come up ..."
sleep 40s
./config-dd-wrt.sh ${ap_number} init
