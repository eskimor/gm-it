# Re-configure all known aps


for stiege_top in "0 01" "1 05" "1 08" "1 11" "1 13" "1 17" "1 21" "1 23" "1 32" "1 33" "1 34" "1 35" "1 36" "1 37" "2 04" "2 06" "2 08" "2 11" "2 13" "2 17" "2 21" "2 24" "2 25" "2 26" "2 27"
do
  ap_number=$(echo ${stiege_top} | sed 's/ //g')
  echo "Configuring AP NUMBER: ${ap_number}"
  if ping -c1 10.134.1.${ap_number}
  then
    ./config-dd-wrt.sh 10.134.1.${ap_number} ${stiege_top}
    # echo 10.134.1.${ap_number} ${stiege_top}
  fi
done
