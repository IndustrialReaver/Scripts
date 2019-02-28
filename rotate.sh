#!/usr/bin/env bash

set -e

EXCLUDES="rean-master rbd"

for CREDENTIAL in $(aws-vault list | awk {'print $2}' | sed '1,2d' | sort | uniq | grep -v "^-" | grep -v "==========="); do
    for EXCLUDE in $EXCLUDES; do
        if [ "$CREDENTIAL" = "$EXCLUDE" ]; then
            echo "skipping $CREDENTIAL"
            continue 2
        fi
    done
  aws-vault rotate $CREDENTIAL
done
