#!/bin/bash

tenantId=$1
REGIONS=(us-east-1 us-east-2 us-west-1 us-west-2 eu-west-1 eu-west-2)

count=0
echo $tenantId
for REGION in ${REGIONS[@]}; do 
  ((count+=`aws ec2 describe-instances --filters Name=tag:fp-tenant-id,Values=$tenantId --region ${REGION} | jq '.Reservations[].Instances[].InstanceId' | wc -l`))
done

if [ "$count" -eq "0" ]; then
  echo $count
  echo "$tenantId is Inactive"
else
  echo $count
  echo "$tenantId is active"
fi
