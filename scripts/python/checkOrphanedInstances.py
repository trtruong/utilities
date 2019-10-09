#!/usr/bin/env python3
import boto3
import argparse
import os
import base64
from common_functions import getAllInstances, getDynamoDBItems
from common_jenkins import triggerJob
from common_kms import get_plaintext_key


parser = argparse.ArgumentParser()
parser.add_argument("-e", "--env", help="Staging or Production", type=str, required=True)
parser.add_argument("-t", "--dryrun", help="Displaying orphanedInstances only", required=False, action='store_true', default=False, dest='DryRun')
args = parser.parse_args()
jenkins_server_url = 'https://jenkins.cicd.cloud.fpdev.io'

if ((args.env).lower()).startswith("s"):
  tableName = 'dyn-use1-cpt-s-tenant-service-stage'
  os.system("okta-login pe-stg")
  # Assuming your AWS profile is pe-stg for DEP staging account
  session = boto3.Session(profile_name='pe-stg')
  jobname = 'GHE-CLDOPS/cpt-staging-deployment-pipelines/edge-ngfw'
  tokenHashed = 'AQICAHhYGEB1OYp+r8QB00qX9ggImKyc5paoUPZIsm20O94PvAEvbX7EICaGbwSMNqJIzaksAAAAfjB8BgkqhkiG9w0BBwagbzBtAgEAMGgGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQMYyMVNddcwLg/UsV9AgEQgDvkF7+q8nVEEh+94gDS9VxigULgdJE8mv/pQxK4ye/CkFyy5/Woo5QIQSS1J+2AEPc/iRGHxpomG71RwA=='
  token = str(base64.b64decode(get_plaintext_key(tokenHashed, 'us-east-2', session)), 'utf-8')
elif ((args.env).lower()).startswith("pe-pre"):
  tableName = 'dyn-use1-cpt-s-tenant-service-prestaging'
  os.system("okta-login pe-prestg")
  # Assuming your AWS profile is pe-stg for DEP staging account
  session = boto3.Session(profile_name='pe-prestg')
  jobname = 'GHE-CLDOPS/cpt-prestaging-deployment-pipelines/edge-ngfw'
  # tokenHashed = to be added once we have pre-staging setup
  token = str(base64.b64decode(get_plaintext_key(tokenHashed, 'us-east-2', session)), 'utf-8')
else:
  tableName = 'dyn-use1-cpt-p-tenant-service-production'
  os.system("okta-login pe-prod")
  # Assuming your AWS profile is pe-prod for DEP staging account
  session = boto3.Session(profile_name='pe-prod')
  jobname = 'GHE-CLDOPS/cpt-prod-deployment-pipelines/edge-ngfw'
  tokenHashed = 'AQICAHgNWkrfbqMq3gyhFfHoJjENYsopnb7sN2lR2l5wDhJHNgFxjPyfbu4LqjAKUAAX0vvKAAAAgDB+BgkqhkiG9w0BBwagcTBvAgEAMGoGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQMZmrQxioap7ALvPhEAgEQgD3zHoykyjj95EfzsiIn7GJWEPai+JAkmBKNEufifNOafTXMG0JVDT8KZW4ThV0km1Jx/0pCaqe8z7Bj16t3'
  token = str(base64.b64decode(get_plaintext_key(tokenHashed, 'us-east-2', session)), 'utf-8')
table = getDynamoDBItems(tableName, 'us-east-1', session)
instances = getAllInstances(session)
orphanedInstances = []
isValidTenant = False

for reservation in instances["Reservations"]:
  for instance in reservation["Instances"]:
    for item in table['Items']:
      try:
        for tag in instance['Tags']:
          if tag['Key'] == 'fp-tenant-id' and tag['Value'] == item['tenantId']:
            isValidTenant = True
            break
      except KeyError as error:
        print(error)
    if not isValidTenant:
      orphanedInstance = {}
      isEdge = False
      for tag in instance['Tags']:
        if "fp-tenant-id" in tag["Key"]:
          orphanedInstance["fp_tenant_id"] = tag['Value']
          orphanedInstance["InstanceId"] = instance["InstanceId"]
          orphanedInstance["LaunchTime"] = instance["LaunchTime"]
          orphanedInstance["Region"] = instance["Placement"]["AvailabilityZone"][:-1]
        if "fp-edge-id" == tag["Key"]:
          orphanedInstance["fp-edge-id"] = tag["Value"]
        if "Name" == tag["Key"] and "edge-ngfw670" in tag["Value"]:
          isEdge = True
      if isEdge:
        orphanedInstances.append(orphanedInstance)
    isValidTenant = False

if len(orphanedInstance) == 0:
  print("No orphaned Instances found")
else:
  print(f"There are {len(orphanedInstances)} orphaned instances")
  for inst in orphanedInstances:
    if not args.DryRun:
      params = {'REGION': inst["Region"], 'JOB_TYPE': 'destroy', 'TENANT_ID': inst["fp_tenant_id"], 'EDGE_ID': inst["fp-edge-id"]}
      triggerJob('trung.truong@forcepoint.com', token, jenkins_server_url, jobname, params)
    else:
      print("DryRun only.  No Action was taken")
    print(inst["InstanceId"] + " " + inst["fp_tenant_id"] + " " + inst["fp-edge-id"] + " " + inst["Region"])
