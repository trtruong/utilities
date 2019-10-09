#!/usr/bin/env bash

# this function takes 3 argument
# workspace name or "no-workspace" if you're not using terraform workspace
# backend-config file to initialize terraform s3 backend
# env varible to specify which environment you're deploying to

function deployTerraform() {
  echo "Deploying in ${1} region"
  if [ ! -d .terraform ]; then
    echo "yes" | terraform init -backend-config=${2}
  fi
  if [ "$1" != "no-workspace" ]; then
    terraform workspace select ${1} || terraform workspace new ${1}
  fi
  terraform plan -var env=${3} -out ${1}.plan -detailed-exitcode || status=$?
  if [ $status -eq 2 ]; then
    terraform apply ${1}.plan
  elif [ $status -eq 1 ]; then
    echo "terraform plan failed"
    exit 1
  else
    echo "No changes, skipping apply"
  fi
}
