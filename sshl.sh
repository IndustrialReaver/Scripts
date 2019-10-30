#!/bin/bash

# last_ssh=$(awk -F" " '$1 == "ssh" { print }' ~/.bash_history | tail -1 | cut -d' ' -f 2-)
# ssh ${last_ssh}

# ssh $(awk -F" " '$1 == "ssh" { print }' ~/.bash_history | tail -1 | cut -d' ' -f 2-)
history_file="${1}"
echo "${history_file}"
target=$(awk -F" " '$1 == "ssh" && $2 != "" { print $2 }' "${history_file}" | tail -1)
echo ${target}
ssh ${target}