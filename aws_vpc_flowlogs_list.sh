outloc=/tmp/fl_list_o.json
echo "" > $outloc
for region in $(aws ec2 describe-regions --output text | cut -f3); do
	vpc_vpc_id_list=$(aws ec2 describe-vpcs --output text --region $region | grep VPCS | cut -f7 | sort -u)
	flowlog_vpc_list=$(aws ec2 describe-flow-logs --output text --region $region | grep ACTIVE | cut -f8 | sort -u)
	# loop through vpc id's from the list of vpc's in the list
	for vpc_id in $vpc_vpc_id_list; do
		vpc_pass="false"
		# loop through the vpc id's for the vpc's associated with flowlogs 
		for flow_vpc in $flowlog_vpc_list; do
			# if the vpc id mathces an id from a flowlog, the vpc is good
			if [[ "$vpc_id" == "$flow_vpc" ]]; then
				vpc_pass="true"
				echo "$vpc_id,cis_4_3,1" >> $outloc
			fi
		done
		if [[ $vpc_pass == "false" ]]; then
			echo "$vpc_id,cis_4_3,0" >> $outloc
			continue
		fi
	done
done
cat $outloc