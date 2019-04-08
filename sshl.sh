#!/bin/bash

# last_ssh=$(awk -F" " '$1 == "ssh" { print }' ~/.bash_history | tail -1 | cut -d' ' -f 2-)
# ssh ${last_ssh}

ssh $(awk -F" " '$1 == "ssh" { print }' ~/.bash_history | tail -1 | cut -d' ' -f 2-)