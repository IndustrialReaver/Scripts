#!/bin/bash
owner_tag_value=${1:-"ben.helsley"}
new_duration=${2:-"8"}
verbose_mode=$3
debug_mode="--dry-run"
#aws ec2 describe-instances --filters "Name=tag:Owner,Values=ben.helsley" --region us-west-2 --output text | grep INSTANCE | cut -f8
instance_ids=$(aws ec2 describe-instances --filters "Name=tag:Owner,Values=$owner_tag_value" --region us-west-2 --output json | grep InstanceId | cut -d\" -f4)
new_expiration_date=$(date -v +"$new_duration"d "+%Y-%m-%d")

[[ $verbose_mode ]] && echo $owner_tag_value
[[ $verbose_mode ]] && echo $instance_ids
[[ $verbose_mode ]] && echo $new_expiration_date

aws ec2 create-tags $debug_mode --region us-west-2 --tags "Key=ExpirationDate,Value=$new_expiration_date" --resources $instance_ids