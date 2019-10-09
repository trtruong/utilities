#!/usr/bin/env bash
################################################
# This script is use to setup aws accounts with
# S3 public access block
# ec2 encryption region wide
################################################

### Require an environment argument to execute
if [[ $# -eq 0 ]]; then
    echo "execute $0 with either staging or prod"
    exit 1
fi

ENV=$(echo ${1,,})
PUBLIC_ACCESS_CONFIG="BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true, RestrictPublicBuckets=true"
REGIONS=(us-west-1 us-west-2 us-east-1 us-east-2 eu-west-1 eu-west-2)

case $ENV in
  'stage'|'stg'|'staging')
    ACCOUNT_ID='475405070684'
    ;;
  "pre-staging"|"pre-stg"|"acceptance"|"pre")
    ACCOUNT_ID='060620138744'
    ;;
  'prod'|'production')
    ACCOUNT_ID='874338527059'
    ;;
  *)
    exit 1
    ;;
esac

# Enable S3 public blocking
aws s3control put-public-access-block --account-id $ACCOUNT_ID --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

### Enable EBS encryption region wide
for r in "${REGIONS[@]}"; do
  aws --region ${r} ec2 enable-ebs-encryption-by-default --no-dry-run
done
