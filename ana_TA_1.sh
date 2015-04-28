#!/bin/bash
logs_dir='/home/hugh/tmp/TA_14042015/TA_CELLTRACE_14042015'
ls $logs_dir| while read enb
do
	eNB_name=${enb:10:10}
	echo $eNB_name
done | xargs -I {} -P 4 ./dec_TA05_1.sh {} $logs_dir
