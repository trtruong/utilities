#!/usr/bin/env bash
set -ex

source ./deploy_terraform.sh

REGIONS=(us-west-1 us-west-2 us-east-1 us-east-2 eu-west-1 eu-west-2)
case $1 in
  "stg"|"staging")
    backendConfig='staging_backend.tfvars'
    env='staging'
    ;;
  "pre-staging"|"pre-stg"|"acceptance"|"pre")
    backendConfig='prestaging_backend.tfvars'
    env='pre-staging'
    ;;
  "prod"|"production")
    backendConfig='prod_backend.tfvars'
    env='production'
    ;;
esac

### Creating IAM role for DLM to use
pushd ../../terraform/provider/aws/global/iam/dlm-role/
if [ -d .terraform ]; then
  rm -rf .terraform
fi
deployTerraform 'no-workspace' $backendConfig $env
popd

### Echo Deploy EBS DLM
pushd ../../terraform/provider/aws/resources/dlm/edges-lifecycle/
rm -rf .terraform
for r in "${REGIONS[@]}"; do
  deployTerraform $r $backendConfig $env
done
popd
