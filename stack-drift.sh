#!/bin/bash

# Search through all CFT stacks in a given environment and return any drift.
# This script relies on jq, aws-vault, and the aws-cli

# We'll assume it's prod if you don't say, it's just detection, what's the worst that ould happen?
env=${1:-production}

# Get some lists of stacks
stacks_updated=$(aws-vault exec ${env} --no-session -- aws cloudformation list-stacks --query 'StackSummaries[?StackStatus==`UPDATE_COMPLETE`].StackName' --output text)
stacks_created=$(aws-vault exec ${env} --no-session -- aws cloudformation list-stacks --query 'StackSummaries[?StackStatus==`CREATE_COMPLETE`].StackName' --output text)

# Set a whitelist of resource types to ignore
allowed_drift=( "AWS::ElasticLoadBalancingV2::Listener" ) # This array could be set from a tag that could be set on individual stacks?
# echo "${allowed_drift[@]}"

# Return true if element not contianed in array
array_not_contains(){ 
    local seeking="${1}"; shift
    local in="0"
    #echo "${element}"
    #echo "${seeking}"
    for element; do
        if [[ "${element}" == "${seeking}" ]]; then
            in="1"
            break
        fi
    done
    echo "${in}"
}

# Loop through stacks
for stack in ${stacks_updated} ${stacks_created}; do
  echo "========================================"
  echo "${stack}"
  
  # Call drift detection, record ID, and wait for detection to complete
  detection_id=$(aws-vault exec ${env} --no-session -- aws cloudformation detect-stack-drift --stack-name ${stack} --output text)
  until [[ ! "$(aws-vault exec ${env} --no-session -- aws cloudformation describe-stack-drift-detection-status --stack-drift-detection-id ${detection_id} --output text | cut -f1)" == "DETECTION_IN_PROGRESS" ]]; do
  	sleep 2
  	printf "."
  done
  printf "\n"  

  # Get the JSON result of drift detection, this will minimize API calls
  result_json=$(aws-vault exec ${env} --no-session -- aws cloudformation describe-stack-drift-detection-status --stack-drift-detection-id ${detection_id})
  echo "${result_json}"
  status=$(echo $result_json | jq -r '.StackDriftStatus')
  
  # Check status, and do stuff if drifted
  if [[ ${status} == "DRIFTED" ]]; then
    needs_updated=false
    offending_resources=()
    drifted_resources=$(aws-vault exec ${env} --no-session -- aws cloudformation describe-stack-resource-drifts --stack-name ${stack} --output json)
    
    # Loop through drifted resources, we base64 encode the json to prevent unexpected bash loops
    for drifted_resource in $(echo "${drifted_resources}" | jq -r '.StackResourceDrifts[] | @base64'); do
      
      # Function to decode and print specific elements
      _jq() {
        echo "${drifted_resource}" | base64 --decode | jq -r ${1}
      }
      
      # Record some resource info
      resource_status=$(_jq '.StackResourceDriftStatus')
      resource_type=$(_jq '.ResourceType')
      resrouce_name=$(_jq '.LogicalResourceId')

      # echo "${resrouce_name} | ${resource_status} | ${resource_type}"
      
      # Check if the resource is not in sync, then if it is not in the whitelist
      if [[ ! "${resource_status}" == "IN_SYNC" ]]; then
        if [[ "$(array_not_contains "${resource_type}" "${allowed_drift[@]}")" == "0" ]]; then
          needs_updated=true
          offending_resources+=( "${resrouce_name}" )
        fi
      fi
    done
    # Print results per stack to prove it works!
    if [[ "${needs_updated}" == "true" ]]; then
      echo "Stack ${stack} needs to be updated!"
      echo "Offending resources: ${offending_resources[@]}"
    fi
  fi
done



# aws-vault exec ${env} -- aws cloudformation describe-stack-drift-detection-status --stack-drift-detection-id 03c11200-6529-11e9-a39b-0a545e22b5be