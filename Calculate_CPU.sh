#!/bin/bash

grep 'cpu ' /proc/stat | sed 's/cpu  //g' > /root/cpu1
TotalTime1=$(echo $(($(cat /root/cpu1 | sed 's/ / + /g'))))
IdleTime1=$(cat /root/cpu1 | awk -F ' ' '{print $4}')

sleep 60

grep 'cpu ' /proc/stat | sed 's/cpu  //g' > /root/cpu2
TotalTime2=$(echo $(($(cat /root/cpu2 | sed 's/ / + /g'))))
IdleTime2=$(cat /root/cpu2 | awk -F ' ' '{print $4}')

TotalTimeDiff=$(( ${TotalTime2} - ${TotalTime1} ))
IdleTimeDiff=$(( ${IdleTime2} - ${IdleTime1} ))

CPU_Usage=$(awk -v TotalDiff="${TotalTimeDiff}" -v IdleDiff="${IdleTimeDiff}" 'BEGIN {printf "%.4f\n", (1 - (IdleDiff / TotalDiff)) * 100}')

echo ${CPU_Usage}%



if [[ $(echo "$CPU_Usage}" "75.00" | awk '{print ($1 > $2)}') == 1 ]]
then
	echo "Subject: HMT Email Alert | CPU Threshold Breach" >> /root/HMT_Email_Alert_$(date "+%Y-%m-%d%H:%M").txt
	echo " " >> /root/HMT_Email_Alert_$(date "+%Y-%m-%d%H:%M").txt 
	echo " " >> /root/HMT_Email_Alert_$(date "+%Y-%m-%d%H:%M").txt
	echo "CPU Utilization is now ${CPU_Usage}%" >> /root/HMT_Email_Alert_$(date "+%Y-%m-%d%H:%M").txt
	echo "Time of Occurrence: $(date "+%Y-%m-%d%H:%M")" >> /root/HMT_Email_Alert_$(date "+%Y-%m-%d%H:%M").txt
	/usr/bin/sendmail.ssmtp deguzmancaptain@gmail.com < /root/HMT_Email_Alert_$(date "+%Y-%m-%d%H:%M").txt
fi

