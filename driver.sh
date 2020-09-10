#!/bin/bash

set -euo pipefail

# This is the tag of the Docker image in which AWS CLI commands are run.
IMAGE_TAG=data_pipeline

ENVIRONMENT=dev

# Prefix for all AWS resources.
PREFIX=data-pipeline

# CloudFormation stack name.
STACK_NAME=${ENVIRONMENT}-${PREFIX}

# These are passed in as CloudFormation parameters.
VPC_CIDR=10.192.0.0/16
PRIVATE_SUBNET_CIDR=10.192.20.0/24
S3_BUCKET=${PREFIX}-s3-bucket
S3_OBJECT_KEY=DEVOPS_TEST_DATA.csv
LAMBDA_FUNCTION_NAME=${PREFIX}-lambda-function
DYNAMODB_TABLE_NAME=${PREFIX}-dynamodb-table


COMMAND=${1:-}
if [[ $COMMAND != "delete_image" ]] && \
   [[ $COMMAND != "build_image" ]] && \
   [[ $COMMAND != "create_stack" ]] && \
   [[ $COMMAND != "upload_data" ]] && \
   [[ $COMMAND != "jupyter" ]] && \
   [[ $COMMAND != "stop_container" ]] && \
   [[ $COMMAND != "container_shell" ]]; then
  echo
  echo "COMMAND must be one of delete_image, build_image, create_stack, upload_data, jupyter, stop_container, container_shell!"
  echo "Exiting."
  exit 1
fi

case $COMMAND in

  delete_image)
  echo
  echo "Deleting the $IMAGE_TAG image."
  docker rmi $(docker images --filter=reference=$IMAGE_TAG --quiet) --force
  ;;

  build_image)
  echo
  echo "Building $IMAGE_TAG image."
  docker build --tag $IMAGE_TAG .
  ;;

  create_stack)
  echo
  echo "Creating the $STACK_NAME CloudFormation stack."
  docker run --env AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
  --env AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
  --env AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION \
  $IMAGE_TAG aws cloudformation deploy --template-file cloudformation.yaml \
  --stack-name $STACK_NAME \
  --capabilities CAPABILITY_NAMED_IAM \
  --region $AWS_DEFAULT_REGION  \
  --parameter-overrides  IPADDRESS=${IP_ADDRESS} VPCCIDR=$VPC_CIDR \
  PrivateSubnetCIDR=$PRIVATE_SUBNET_CIDR S3BucketName=$S3_BUCKET \
  S3ObjectKey=$S3_OBJECT_KEY LambdaFunctionName=$LAMBDA_FUNCTION_NAME \
  DynamoDBTableName=$DYNAMODB_TABLE_NAME
  ;;

  upload_data)
  echo
  docker run --env AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
  --env AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
  --env AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION \
  $IMAGE_TAG aws s3 cp ./data/$S3_OBJECT_KEY s3://$S3_BUCKET
  ;;

  jupyter)
  echo
  echo "Starting Jupyter server in $IMAGE_TAG container."
  docker run --publish 8888:8888 --volume $(pwd)/notebooks:/workspace/notebooks --detach $IMAGE_TAG jupyter
  ;;

  stop_container)
  echo
  echo "Stopping $IMAGE_TAG container."
  docker container stop $(docker ps -q --filter ancestor=$IMAGE_TAG)
  ;;

  container_shell)
  echo
  echo "Opening a shell in $IMAGE_TAG container."
  docker run --interactive --tty $IMAGE_TAG /bin/sh
  ;;

esac
