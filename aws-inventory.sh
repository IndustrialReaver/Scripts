#! /bin/bash
# personal inventory script

KEY="Owner"
VALUE="ben.helsley"
MODE="LIST"
VERBOSE=""
DEBUG=""
TAB='    '

usage(){
	echo "scriptname [-k key][-v value][-m mode][-h][-v]"
	echo "    -k    :    The tag key to query for"
	echo "    -v    :    The tag value to query for"
	echo "    -m    :    The mode to run in"
	echo "                   \"list\"  -- lists all instances(default)"
	echo "                   \"stop\"  -- stops all running instances"
	echo "                   \"start\" -- starts all stopped instances"
	echo "    -h    :    Display this message"
	echo "    -V    :    Run in VERBOSE mode"
	exit 1
}

exists(){
	local f="$FileName"
	[[ -f "$f" ]] && return 0 || return 1
}

while getopts ":k:v:m:hVd" opt; do
	case $opt in
		v)
			VALUE=$OPTARG
			;;
		k)
			KEY=$OPTARG
			;;
		m)
			case $OPTARG in
				[lL][iI][sS][tT])
					MODE="LIST"
					;;
				[sS][tT][aA][rR][tT])
					MODE="START"
					;;
				[sS][tT][oO][pP])
					MODE="STOP"
					;;
				*)
					echo "ERROR: Invalid mode: $OPTARG"
					usage
					;;
			esac
			;;
		h)
			usage
			;;
		V)
			VERBOSE="ON"
			;;
		d)
			DEBUG="ON"
			;;
		\?)
			echo "ERROR: Invalid option: -$OPTARG" >&2
			usage
			;;
		:)
			echo "Option -$OPTARG requires an argument." >&2
			usage
			;;
	esac
done

[[ $DEBUG || $VERBOSE ]] && echo "SCRIPT START..."
[[ $DEBUG || $VERBOSE ]] && echo "MODE SET TO: $MODE"
[[ $DEBUG || $VERBOSE ]] && echo "QUERY KEY SET TO: $KEY"
[[ $DEBUG || $VERBOSE ]] && echo "QUERY VALUE SET TO: $VALUE"

regions=$(aws ec2 describe-regions --output text | cut -f3)
[[ $DEBUG ]] && echo "REGIONS LIST: "$regions

instance_total=0
running_total=0
stopped_total=0

for region in $regions
do
	
	region_info=$(aws ec2 describe-instances --filters "Name=tag:$KEY,Values=$VALUE" --region $region --output text)
	count=$(echo "$region_info" | grep INSTANCES | wc -l)
	running=$(echo "$region_info" | grep running | wc -l)
	stopped=$(echo "$region_info" | grep stopped | wc -l)

	#[[ $DEBUG ]] && echo '(( count += $(aws ec2 describe-instances --filters "Name=tag:'$KEY',Values='$VALUE'" --region $region --output text | grep INSTANCES | wc -l) ))'
	#(( count += $(aws ec2 describe-instances --filters "Name=tag:$KEY,Values=$VALUE" --region $region --output text | grep INSTANCES | wc -l) ))
	[[ $DEBUG || $VERBOSE ]] && echo $region::
	[[ $DEBUG || $VERBOSE ]] && echo "$TAB""T: "$count
	[[ $DEBUG || $VERBOSE ]] && echo "$TAB""R: "$running
	[[ $DEBUG || $VERBOSE ]] && echo "$TAB""S: "$stopped

	(( instance_total += count ))
	(( running_total += running ))
	(( stopped_total += stopped ))

	case $MODE in
		START)
			if [[ $stopped > 0 ]]; then
				stopped_instances=$(echo "$region_info" | grep stopped -B 12 | grep INSTANCES | cut -f8)
				[[ $DEBUG || $VERBOSE ]] && echo "$TAB""IDS TO START: $stopped_instances"
				errors=$errors$(aws ec2 start-instances --instance-ids $stopped_instances)
				[[ $DEBUG || $VERBOSE ]] && echo "$TAB""RESULT: $error"
				(( changed += stopped ))
				[[ $DEBUG || $VERBOSE ]] && echo "$TAB""CHANGED: $stopped"
			else
				[[ $DEBUG || $VERBOSE ]] && echo "NO INSTANCES TO START"
			fi
			;;
		STOP)
			
			;;
	esac



done

[[ $DEBUG || $VERBOSE ]] && echo "COMPILING RESULTS..."
echo "<><><><>|EC2 RESULTS|<><><><>"
echo "Instances with [ $KEY = $VALUE ]:"
echo "$TAB""TOTAL:   $instance_total"
echo "$TAB""RUNNING: $running_total"
echo "$TAB""STOPPED: $stopped_total"
[[ ! $MODE == "LIST" ]] && echo "+++++++++++++++++++++++++++++"
[[ ! $MODE == "LIST" ]] && echo " TOTAL $MODE"
[[ ! $MODE == "LIST" ]] && echo " CHANGED: $changed"
[[ ! $MODE == "LIST" ]] && echo " ERRORS: $errors"
[[ ! $MODE == "LIST" ]] && echo "+++++++++++++++++++++++++++++"
[[ $DEBUG || $VERBOSE ]] && echo "SCRIPT COMPLETE"























