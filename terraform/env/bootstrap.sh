#!/usr/bin/env bash

ENV=$1
echo "AWS_PROFILE=$ENV-datawarehouse"
TERRAFORM_BUCKET=etika.$ENV.datawarehouse.terraform
#TGW_ID=$(cat ../variables.json | jq .tgw_id -r)

aws s3api create-bucket \
  --acl private \
  --region ap-southeast-2 \
  --create-bucket-configuration LocationConstraint=ap-southeast-2 \
  --bucket $TERRAFORM_BUCKET \
  --profile $ENV-datawarehouse
 
aws dynamodb create-table \
  --table-name TerraformStateLock \
  --region ap-southeast-2 \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --profile $ENV-datawarehouse

#AWS_PROFILE=default aws ec2 accept-transit-gateway-vpc-attachment \
#  --transit-gateway-attachment-id $TGW_ID
