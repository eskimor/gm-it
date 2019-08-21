Manage configs of all APs via a simple command:

Initial setup (custom image? ):
- Flash openwrt
- Set initial password/ssh key(s)
- Maybe already configure ssids/passwords/vlans
- Retrieve MAC address and associate it with given AP name -> Put in table. (Retrieve via simple ssh command)

Eventuell zu Beginn auch gleich SSIDs/VLANs und

Create DNS/DHCP entries for each AP.

With list of IP addresses:

- Configure SSIDs/availble VLANs and mappings to SSIDs
- Wifi passwords for ssids


Command for putting the generated list into the DHCP/DNS server config.

Alternativ: openWISP, eventuell Overkill, aber nice.


Generated list of MAC addresses/device name -> make DHCP/DNS entries for them.
