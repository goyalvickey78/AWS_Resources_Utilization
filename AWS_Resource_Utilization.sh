>status.txt
endTime=`date +%Y-%m-%dT%H:%M:%SZ`
yesterday=`expr \`date +%s\` - 86400`
startTime=`date -r $yesterday '+%Y-%m-%dT%H:%M:%SZ'`
minCPUTheshold=2
maxCPUTheshold=70
for region in `aws ec2 describe-regions --output text | cut -f4`
do
     count=`aws ec2 describe-instance-status --no-include-all-instances --region $region|grep InstanceId|cut -d ':' -f2|cut -d ',' -f1|wc -l|xargs` 
     echo -e "\nListing running instances in region: '$region'..."
     if [ $count -ne 0 ]; then
     	echo -e "Total running instances count: $count in region:'$region'..."
     	instance=`aws ec2 describe-instance-status --no-include-all-instances --region $region|grep InstanceId|cut -d ':' -f2|cut -d ',' -f1`
       	for item in $instance; do
         	cpuPercentage=`aws cloudwatch get-metric-statistics --metric-name CPUUtilization --start-time $startTime --end-time $endTime --period 86400 --namespace AWS/EC2 --statistics Maximum --dimensions Name=InstanceId,Value="$item" --region $region |grep Maximum|cut -d ':' -f2|cut -d ',' -f1|xargs`
         	cpuPercentage=`echo $cpuPercentage | awk '{print ($0-int($0)<0.499)?int($0):int($0)+1}'`
		if [ $cpuPercentage -le $minCPUTheshold ]; then
			echo "Maximum CPU Percentage ($cpuPercentage%) which is less then or euqal to $minCPUTheshold% of basic threshold in last 24 hours Region:$region, Instance_Id:$item." 
		fi
		if [ $cpuPercentage -ge $minCPUTheshold ]; then
                        echo "Maximum CPU Percentage ($cpuPercentage%) which is more then or euqal to $maxCPUTheshold% of basic threshold in last 24 hours Region:$region, Instance_Id:$item."
                fi
       	done
     else
	echo "No running instances in Region: $region"
     fi
     count=0
done >>status.txt
MESSAGE=`cat status.txt|grep Instance_Id|xargs`
#MESSAGE=$( echo ${MESSAGE} | sed 's/"/\"/g' | sed "s/'/\'/g" )
#echo ${MESSAGE}
COLOR="ff0000"
TITLE="CLOUD RESOURCE MONITORING"
#MESSAGE1="My Resource Utilization"
JSON="{\"title\": \"${TITLE}\", \"themeColor\": \"${COLOR}\", \"text\": \"${MESSAGE}\" }"

# Post to Microsoft Teams.
WEBHOOK_URL="https://outlook.office.com/webhook/d4ba9c0b-24a9-4104-a816-822d1c42f6e9@e9cb3c80-4156-4c39-a7fe-68fe427a3d46/IncomingWebhook/65b17a2f5ed3493b84dbfd6409a0e6ea/4983d14b-244b-469a-8c43-700fab5be63e"
curl -H "Content-Type: application/json" -d "${JSON}" "${WEBHOOK_URL}"
