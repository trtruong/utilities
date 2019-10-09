#!/usr/bin/env bash

ENV=$1
if [ "${ENV}" == "prod" ]; then
  source okta-login pe-prod
  keyenv="p"
  keyfile="cloudops-dep-prod_rsa"
else
  source okta-login pe-stg
  keyenv="s"
  keyfile="cloudops-dep-stg_rsa"
fi
REGIONS=(us-east-1 us-east-2 us-west-1 us-west-2 eu-west-1 eu-west-2)

ssh-keygen -t rsa -b 4096 -f ~/.ssh/${keyfile} -C "CloudOps DEP May2019" -N ""
PRIVATE_KEY=`cat ~/.ssh/$keyfile`

aws ssm put-parameter --region us-east-2 --name "/NGFW/ssh-keypairs/cloudops-dep_private" --value "$PRIVATE_KEY" --type "SecureString" --overwrite

for r in "${REGIONS[@]}"; do
  geo=`echo $r | cut -d "-" -f 1`
  cardinal=`echo $r | cut -d "-" -f 2 | head -c 1`
  numeric=`echo $r | cut -d "-" -f 3`
  keyname="keyp-${geo}${cardinal}${numeric}-cpt-${keyenv}-dep"

  aws ec2 --region ${r} import-key-pair --key-name ${keyname} --public-key-material file://~/.ssh/${keyfile}.pub
done
