# This file is supposed to be sourced by other scripts in order to get access to channels_per_ap_number:

# Returns the 2,4 GHz freqency and the 5 GHz frequency for a given AP number:
# TODO: Basement is missing:
function channels_per_ap_number {
  case "$1" in
    001) echo 3  36 ;;
    032) echo 8 52 ;;
    033) echo 3 44 ;;
    105) echo 3 40 ;;
    108) echo 13 60 ;;
    111) echo 8 56 ;;
    113) echo 3 36 ;;
    117) echo 13 52 ;;
    121) echo 8 48 ;;
    123) echo 13 56 ;;
    132) echo 13 60 ;;
    133) echo 8 52 ;;
    134) echo 3 48 ;;
    135) echo 13 64 ;;
    136) echo 8 44 ;;
    137) echo 8 36 ;;
    138) echo 13 56 ;;
    204) echo 3 60 ;;
    206) echo 13 40 ;;
    208) echo 8 48 ;;
    211) echo 13 56 ;;
    213) echo 8 64 ;;
    217) echo 13 44 ;;
    221) echo 3 48 ;;
    224) echo 13 64 ;;
    225) echo 3 56 ;;
    226) echo 8 36 ;;
    227) echo 13 40 ;;
    232) echo 3 36
      ;;
    *) echo "Warning - unknown accesspoint, using auto channels." >&2
       echo 0 0
     ;;
  esac
}


function freq_per_channel {
  case "$1" in
    1) echo 2412 ;;
    2) echo 2417 ;;
    3) echo 2422 ;;
    4) echo 2427 ;;
    5) echo 2432 ;;
    6) echo 2437 ;;
    7) echo 2442 ;;
    8) echo 2447 ;;
    9) echo 2452 ;;
    10) echo 2457 ;;
    11) echo 2462 ;;
    12) echo 2467 ;;
    13) echo 2472 ;;
    36) echo 5180 ;;
    40) echo 5200 ;;
    44) echo 5220 ;;
    48) echo 5240 ;;
    52) echo 5260 ;;
    56) echo 5280 ;;
    60) echo 5300 ;;
    64) echo 5320 ;;
    100) echo 5500 ;;
    104) echo 5520 ;;
    108) echo 5540 ;;
    112) echo 5560 ;;
    116) echo 5580 ;;
    120) echo 5600 ;;
    124) echo 5620 ;;
    128) echo 5640 ;;
    132) echo 5660 ;;
    136) echo 5680 ;;
    140) echo 5700 ;;
    *)   echo 0 ;;
  esac
}

# We need frequencies not channel numbers:
function freqs_per_ap_number {
  channels=$(channels_per_ap_number $1)
  for chan in $channels
  do
    echo -n "$(freq_per_channel $chan) "
  done
  echo
}

function guest_ssid_5Ghz_per_ap_numer {
  case "$1" in
    135) echo "GM-GUEST-5GHz" ;;
    *) echo "GM-GUEST"
     ;;
  esac
}
