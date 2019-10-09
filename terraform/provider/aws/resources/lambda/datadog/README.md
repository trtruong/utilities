# Datadog lambda function
This terraform will deploy the datadog lambda function using KMS to encrypt the datadog api key

## Usage
* create backend.tfvars for your account with the following content
```bucket         = < bucket to store state file >
dynamodb_table = < DynamoDB table for locking >
region         = < region where S3 bucket was created >
key            = < S3 key/path to filename of the state file >
```
* terraform init
```terraform int -reconfig -backend-config=< backend.tfvars you just created >
```
* select/create workspace (Region name case)
```terraform workspace select <region/us-east-1> || terraform workspace new  <region/us-east-1>
```
* terraform plan and apply
terraform plan -var dd_api_key=<api key> -var env=< Environment >
terraform apply -var dd_api_key=<api key> -var env=< Environment >
```
