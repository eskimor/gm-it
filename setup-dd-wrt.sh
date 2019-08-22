#!/usr/bin/env bash

# USAGE:

# ./setup-dd-wrt.sh path/to/img ap-number
#

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
