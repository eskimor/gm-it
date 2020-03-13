# Re-configure all aps to new stiege/top-number numbers:

function stiege_top_per_old_ap_number {
  case "$1" in
    1) echo "1 34" ;;
    2) echo "1 32" ;;
    3) echo "2 27" ;;
    4) echo "1 33" ;;
    5) echo "2 13" ;;
    6) echo "2 06" ;;
    7) echo "1 11" ;;
    8) echo "2 17" ;;
    9) echo "2 21" ;;
    10) echo "2 04" ;;
    11) echo "1 36" ;;
    12) echo "1 37" ;;
    13) echo "1 35" ;;
    14) echo "1 08" ;;
    15) echo "2 08" ;;
    16) echo "1 17" ;;
    20) echo "2 26" ;;
    21) echo "2 24" ;;
    22) echo "1 13" ;;
    23) echo "1 23" ;;
    24) echo "0 01" ;;
    25) echo "1 05" ;;
    26) echo "1 21" ;;
    27) echo "2 11" ;;
    *)
      echo "Unknown AP number!"
      exit -1
      ;;
  esac
}

#Missing: 15 27
for ap_number in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 16 20 21 22 23 24 25 26
do
  echo "Configuring AP NUMBER: ${ap_number}"
  stiege_top=$(stiege_top_per_old_ap_number ${ap_number})
  new_ap_number="$(for i in ${stiege_top}; do echo -n $i;done)"
  # if ping -c1 10.134.1.${ap_number}
  # then
    # ./config-dd-wrt.sh 10.134.1.${ap_number} ${stiege_top}
    echo 10.134.1.${ap_number} ${stiege_top}
  # fi
done
