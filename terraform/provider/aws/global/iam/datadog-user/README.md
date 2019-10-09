# Datadog IAM role
This terraform will generate and externalID using Datadog API and input that into terraform to create the IAM role for Datadog

## Usage
* create backend.tfvars for your account with the following content
```bucket         = < bucket to store state file >
dynamodb_table = < DynamoDB table for locking >
region         = < region where S3 bucket was created >
key            = < S3 key/path to filename of the state file >
```
* terraform init
```terraform int -reconfig -backend-config=< backend.tfvars you just created >
terraform plan -var datadog_apikey=<api key> -var datadog_appkey=< app key > -var accountId=< accountId >
terraform apply -var datadog_apikey=<api key> -var datadog_appkey=< app key > -var accountId=< accountId >
```
