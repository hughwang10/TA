#!/bin/bash
logs_dir='/home/donal/tmp/TA_CELLTRACE_12052015'
ls $logs_dir| while read enb
do
	eNB_name=${enb:10:10}
	echo $eNB_name
done | xargs -I {} -P 4 ./dec_TA05_1.sh {} $logs_dir
