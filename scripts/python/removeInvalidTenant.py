#!/usr/bin/env python3
import boto3
import argparse
from common_functions import getAllInstances, getDynamoDBItems


def getApiId(APIGATEWAY_NAME, REGION):
  api = boto3.client('apigateway', region_name=REGION)
  response = api.get_rest_apis()
  apiId = ''
  for item in response['items']:
    if item['name'] == APIGATEWAY_NAME:
      apiId = item['id']
  return apiId


def getApiResourceId(apiId, path, REGION):
  api = boto3.client('apigateway', region_name=REGION)
  response = api.get_resources(restApiId=apiId)
  resourceId = ''
  for item in response['items']:
    if item['path'] == path:
      resourceId = item['id']
  return resourceId


def removeTenant(tenant, apiId, resourceId, REGION):
  api = boto3.client('apigateway', region_name=REGION)
  response = api.test_invoke_method(
    restApiId = apiId,
    resourceId = resourceId,
    httpMethod = 'DELETE',
    body = '{"tenantDomain": "' + tenant + '"}'
  )
  return response['status']


parser = argparse.ArgumentParser()
parser.add_argument("--tableName", help="DynamoDB Table Name", type=str)
args = parser.parse_args()
APIGATEWAY_NAME = 'agw-cf-use1-cpt-s-tenant-service_stage'
path = '/api/v1/tenant'
apiId = getApiId(APIGATEWAY_NAME, 'us-east-1')
resourceId = getApiResourceId(apiId, path, 'us-east-1')
table = getDynamoDBItems(args.tableName, 'us-east-1')
instances = getAllInstances()
invalidTenant = []
isValidTenant = False
for item in table['Items']:
  for reservation in instances["Reservations"]:
    for instance in reservation["Instances"]:
      print(instance)
      try:
        for tag in instance['Tags']:
          if tag['Key'] == 'fp-tenant-id' and tag['Value'] == item['tenantId']:
            isValidTenant = True
      except KeyError as error:
        print(error)
  if not isValidTenant:
    invalidTenant.append(item['tenantDomain'])
    print(item['tenantDomain'] + " " + apiId + " " + resourceId + ' us-east-1')
    print(removeTenant(item['tenantDomain'], apiId, resourceId, 'us-east-1'))
  isValidTenant = False
print("the following tenantDomains was removed from DynamoDB and Cognito {} ".format( ' '.join(invalidTenant)))
