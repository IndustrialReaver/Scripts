#! /bin/bash

query_term="${1}"
exclude_term="${2}"
bucket_list=( $(aws s3 ls | cut -d' ' -f3) )
#echo "${bucket_list}"

for bucket_name in "${bucket_list[@]}"
do
	if [[ ! ${bucket_name} == ${exclude_term} ]]
	then
		echo "${bucket_name}"
		aws s3 ls s3://${bucket_name} --recursive | grep "${query_term}"
	fi
done
