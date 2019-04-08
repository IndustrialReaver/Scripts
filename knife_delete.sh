#!/bin/bash

cookbook="${1}"
version="${2}"

knife block use staging
knife cookbook delete ${cookbook} ${version} -y

knife block use production
knife cookbook delete ${cookbook} ${version} -y
