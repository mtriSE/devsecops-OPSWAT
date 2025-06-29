#!/bin/bash

# Create S3 bucket and DynamoDB table
BUCKET_NAME="coffeeshop-state-$(date +%s)"
aws s3 mb s3://$BUCKET_NAME --region us-west-2
aws dynamodb create-table \
    --table-name terraform-state-lock \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --region us-west-2

# sed -i "s/coffeeshop-terraform-state-bucket/$BUCKET_NAME/g" terraform/backend.tf
sed -i "s/coffeeshop-terraform-state-bucket/$BUCKET_NAME/g" terraform/main.tf