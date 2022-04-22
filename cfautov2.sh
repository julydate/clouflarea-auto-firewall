#!/bin/bash
#github https://github.com/CangShui/clouflarea-auto-firewall

apitoken="-25TrYMszGtWdXuq9NiJnDxgo"
rulesid1="298c45d2001049279271b5e91b0d9fba"
rulesid2="5ff77516a5a84a469fdcd2c2b7647540"
zoneid="5b5571f8c6e54740847247c9c94cc815"
mode="cpu"  #判断服务器负载方式 load负载法  cpu  CPU百分比法  只能选一个
keeptime=240   #开盾负载下降后持续多少秒，进行尝试关盾

if [ "$mode" = "cpu" ];
then
check=85   #5秒内CPU连续超过85 则开盾【可以根据您的服务器负荷情况调整】
#系统空闲时间
TIME_INTERVAL=5
time=$(date "+%Y-%m-%d %H:%M:%S")
LAST_CPU_INFO=$(cat /proc/stat | grep -w cpu | awk '{print $2,$3,$4,$5,$6,$7,$8}')
LAST_SYS_IDLE=$(echo $LAST_CPU_INFO | awk '{print $4}')
LAST_TOTAL_CPU_T=$(echo $LAST_CPU_INFO | awk '{print $1+$2+$3+$4+$5+$6+$7}')
sleep ${TIME_INTERVAL}
NEXT_CPU_INFO=$(cat /proc/stat | grep -w cpu | awk '{print $2,$3,$4,$5,$6,$7,$8}')
NEXT_SYS_IDLE=$(echo $NEXT_CPU_INFO | awk '{print $4}')
NEXT_TOTAL_CPU_T=$(echo $NEXT_CPU_INFO | awk '{print $1+$2+$3+$4+$5+$6+$7}')

#系统空闲时间
SYSTEM_IDLE=`echo ${NEXT_SYS_IDLE} ${LAST_SYS_IDLE} | awk '{print $1-$2}'`
#CPU总时间
TOTAL_TIME=`echo ${NEXT_TOTAL_CPU_T} ${LAST_TOTAL_CPU_T} | awk '{print $1-$2}'`
load=`echo ${SYSTEM_IDLE} ${TOTAL_TIME} | awk '{printf "%.2f", 100-$1/$2*100}'`
else
load=$(cat /proc/loadavg | colrm 5)
check=$(cat /proc/cpuinfo | grep "processor" | wc -l)

fi

if [ ! -f "/tmp/cfstatus.txt" ];then
echo "" > /tmp/cfstatus.txt
else
status=$(cat /tmp/cfstatus.txt)
echo $status
fi
now=$(date +%s)
time=$(date +%s -r /tmp/cfstatus.txt)



echo "当前$mode负载:$load"
if [[ $status -eq 1 ]]
then
echo "当前开盾中"
else
echo "当前未开盾"
fi

newtime=`expr $now - $time`
closetime=`expr $keeptime - $newtime`

if [[ `echo "$check > $load" | bc` -eq 1 ]]&&[[ $status -eq 1 ]]&&[[ $newtime -gt $keeptime ]]   
then
echo -e "\n$mode负载低于$check，当前已开盾超过$keeptime秒($newtime秒)，尝试关盾"
cResult=$(
	curl -X PUT \
     -H "Authorization: Bearer $apitoken" \
     -H "Content-Type: application/json" \
     -d '{
	  "id": "$rulesid1",
      "paused": true,
      "description": "全部都验证码",
      "action": "managed_challenge",
      "priority": 1000,
	  "filter": {
        "id": "'$rulesid2'"
      }
     }' "https://api.cloudflare.com/client/v4/zones/$zoneid/firewall/rules/$rulesid1"
	)
echo $cResult
size=${#cResult}
if [[ $size -gt 10 ]]
then
  echo 0 > /tmp/cfstatus.txt
  echo -e "\n关盾成功"
fi  
  
elif [[ `echo "$check > $load" | bc` -eq 1 ]]
then
echo -e "\n$mode负载低于$check，不做任何改变,$newtime秒"
if [[ $status -eq 1 ]]
then
  echo -e "将于$closetime秒后关盾"
fi                        
exit
                      
elif [[ `echo "$load > $check" | bc` -eq 1 ]] && [[ $status -eq 1 ]] && [[ $newtime -gt $keeptime ]]  
then
echo -e "\n$mode负载高于$check，当前已开盾超过$keeptime秒($newtime秒)，盾无效，请联系管理员定制其他方案"
exit
  
elif [[ `echo "$load > $check" | bc` -eq 1 ]] && [[ $status -eq 1 ]]
then
echo -e "\n$mode负载高于$check，当前已开盾($newtime秒)，请再观察"
exit  
                      
elif [[ `echo "$load > $check" | bc` -eq 1 ]]
then
echo -e "\n$mode负载高于$check，开启防御规则"  
cResult=$(
	  curl -X PUT \
     -H "Authorization: Bearer $apitoken" \
     -H "Content-Type: application/json" \
     -d '{
	  "id": "$rulesid1",
      "paused": false,
      "description": "全部都验证码",
      "action": "managed_challenge",
      "priority": 1000,
	  "filter": {
        "id": "'$rulesid2'"
      }
         }' "https://api.cloudflare.com/client/v4/zones/$zoneid/firewall/rules/$rulesid1"
	    )
echo $cResult
size=${#cResult}
if [[ $size -gt 10 ]]
then
  echo 1 > /tmp/cfstatus.txt
  echo -e "\n开盾成功"
fi    
else
echo 0 > /tmp/cfstatus.txt  
fi