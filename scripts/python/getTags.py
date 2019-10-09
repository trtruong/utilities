#!/usr/bin/env python3
import boto3
import csv


output_file_path = "/tmp/tagged-resources.csv"
field_names = ['ResourceArn', 'TagKey', 'TagValue']


def writeToCsv(writer, tag_list):
    for resource in tag_list:
        print("Extracting tags for resource: " +
              resource['ResourceARN'] + "...")
        for tag in resource['Tags']:
            row = dict(
                ResourceArn=resource['ResourceARN'], TagKey=tag['Key'], TagValue=tag['Value'])
            writer.writerow(row)


def extract_tags():
  region_names = ["us-east-1", "us-east-2", "us-west-1", "us-west-2", "eu-west-1", "eu-west-2"]
  for region in region_names:
    restag = boto3.client('resourcegroupstaggingapi', region_name=region)
    with open(output_file_path, 'a') as csvfile:
        writer = csv.DictWriter(csvfile, quoting=csv.QUOTE_ALL,
                                delimiter=',', dialect='excel', fieldnames=field_names)
        writer.writeheader()
        response = restag.get_resources(ResourcesPerPage=50)
        writeToCsv(writer, response['ResourceTagMappingList'])
        while 'PaginationToken' in response and response['PaginationToken']:
            token = response['PaginationToken']
            response = restag.get_resources(
                ResourcesPerPage=50, PaginationToken=token)
            writeToCsv(writer, response['ResourceTagMappingList'])
    print("Gerenated file: {}".format(output_file_path))


def handler(event, context):
    extract_tags()
    return "Done extracting tags! Use provided Python3 script 'aws-tags-querier.py' (https://github.com/marcilio/aws-tag-explorer) to run SQL queries against your tags CSV file in S3."


def main():
    handler({},{})

if __name__ == '__main__':
    main()
