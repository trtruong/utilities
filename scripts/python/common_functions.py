#!/usr/bin/env python3
import boto3
import argparse


def getAllInstances(session=None):
  regions = ['us-east-1', 'us-east-2', 'us-west-1', 'us-west-2', 'eu-west-1', 'eu-west-2']
  instances = {}
  filters = [{'Name': 'instance-state-name', 'Values': ['running']}]
  for region in regions:
    # If session is passed in, otherwise read from ENV for AWS creds.
    if session:
      client = session.client('ec2', region_name=region)
    else:
      client = boto3.client('ec2', region_name=region)
    if not instances:
      instances = client.describe_instances(Filters=filters)
    else:
      instances["Reservations"] += client.describe_instances(Filters=filters)["Reservations"]
  return instances


def getDynamoDBItems(tableName, Region, session=None):
  if session:
    dynamodb = session.resource('dynamodb', Region)
  else:
    dynamodb = client.resource('dynamodb', Region)
  table = dynamodb.Table(tableName)
  response = table.scan(
    ProjectionExpression="tenantDomain, tenantId"
  )
  return response
