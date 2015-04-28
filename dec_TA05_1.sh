#!/bin/bash

site_name=`echo $1|tr "[:lower:]" "[:upper:]"`
file_dir=$2
tmp_dir="/home/tmp/TA"
results_dir="/results"
translators=$tmp_dir"/translators"
Final_file=$tmp_dir"/Final.txt"
Network_Results=$tmp_dir"/Network_Results.txt"

function process_rops {
	echo ">>> handling "$logfile
    ltng -f $file_name -t $translators |grep -v "EVENT_ARRAY_TA unavailable" |flowfox -i INTERNAL_PER_RADIO_UE_MEASUREMENT_TA -g EVENT_ARRAY_TA -w|\
	awk '{ printf ("%5s\t%s\n", $2, $12)}' |grep "EVENT_ARRAY_TA:" | sed '/^$/d' |sed 's/EVENT_ARRAY_TA://g' |\
	awk '{distance=$2*(9.73/2) ; print $1, "\t" int(distance)}' >> $Final_file
}

function group_bins {
	#Group into bins
	awk    '$2 >= 0 && $2 <= 1000 { print $1, $2, "AA_0-->1000"}
			$2 >= 1000 && $2 <= 1500 { print $1, $2, "AB_1000-->1500"}
			$2 >= 1500 && $2 <= 2000 { print $1, $2, "AC_1500-->2000"}
			$2 >= 2000 && $2 <= 2500 { print $1, $2, "AD_2000-->2500"}
			$2 >= 2500 && $2 <= 3000 { print $1, $2, "AE_2500-->3000"}
			$2 >= 3000 && $2 <= 3500 { print $1, $2, "AF_3000-->3500"}
			$2 >= 3500 && $2 <= 4000 { print $1, $2, "AG_3500-->4000"}
			$2 >= 4000 && $2 <= 4500 { print $1, $2, "AH_4000-->4500"}
			$2 >= 4500 && $2 <= 5000 { print $1, $2, "AI_4500-->5000"}
			$2 >= 5000 && $2 <= 5500 { print $1, $2, "AJ_5000-->5500"}
			$2 >= 5500 && $2 <= 6000 { print $1, $2, "AK_5500-->6000"}
			$2 >= 6000 && $2 <= 6500 { print $1, $2, "AL_6000-->6500"}
			$2 >= 6500 && $2 <= 7000 { print $1, $2, "AM_6500-->7000"}
			$2 >= 7000 && $2 <= 7500 { print $1, $2, "AN_7000-->7500"}
			$2 >= 7500 && $2 <= 8000 { print $1, $2, "AO_7500-->8000"}
			$2 >= 8000 && $2 <= 8500 { print $1, $2, "AP_8000-->8500"}
			$2 >= 8500 && $2 <= 9000 { print $1, $2, "AQ_8500-->9000"}
			$2 >= 9000 && $2 <= 9500 { print $1, $2, "AR_9000-->9500"}
			$2 >= 9500 && $2 <= 10000 { print $1, $2, "AS_9500-->10000"}
			$2 >= 10000 && $2 <= 10500 { print $1, $2, "AT_10000-->10500"}
			$2 >= 10500 && $2 <= 11000 { print $1, $2, "AU_10500-->11000"}
			$2 >= 11000 && $2 <= 11500 { print $1, $2, "AV_11000-->11500"}
			$2 >= 11500 && $2 <= 12000 { print $1, $2, "AW_11500-->12000"}
			$2 >= 12000 && $2 <= 12500 { print $1, $2, "AX_12000-->12500"}
			$2 >= 12500 && $2 <= 13000 { print $1, $2, "AY_12500-->13000"}
			$2 >= 13000 && $2 <= 13500 { print $1, $2, "AZ_13000-->13500"}
			$2 >= 13500 && $2 <= 14000 { print $1, $2, "BA_13500-->14000"}
			$2 >= 14000 && $2 <= 14500 { print $1, $2, "BB_14000-->14500"}
			$2 >= 14500 && $2 <= 15000 { print $1, $2, "BC_14500-->15000"}
			$2 >= 15000 && $2 <= 20000 { print $1, $2, "BD_15000-->20000"}
			$2 >= 20000 && $2 <= 25000 { print $1, $2, "BE_20000-->25000"}
			$2 >= 25000 { print $1, $2, "BG_25000-->UPWARDS"}
			END {}' $Final_file |\
			awk '{a[$1"  "$3]++}END{for (item in a)print item "\t",a[item]}' |\
			awk '{print $0 | "sort -n"}' > $Network_Results
}

full_dir=$file_dir"/MeContext="$site_name
>$Final_file
echo ">>> Started, please wait..."
ls $full_dir | grep .bin.gz | while read logfile
do
    file_name=$full_dir"/"$logfile
	process_rops
done
echo ">>> group bins..."
group_bins
rm $Final_file
mv $Network_Results $results_dir"/"$site_name".txt"
#unix2dos $results_dir"/"$site_name".txt"
echo ">>> Done!"
