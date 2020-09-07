#!/bin/bash

set -euo pipefail

IMAGE_TAG=devops_image
ENVIRONMENT=dev
STACK_NAME=${ENVIRONMENT}-devops-data-pipeline
S3_BUCKET=devops-data-pipeline-bucket
DATA=./data/DEVOPS_TEST_DATA.csv
DYNAMO_DB=test-db


COMMAND=${1:-}
if [[ $COMMAND != "docker_clean_unused" ]] && \
   [[ $COMMAND != "build" ]] && \
   [[ $COMMAND != "create_stack" ]] && \
   [[ $COMMAND != "upload_data" ]] && \
   [[ $COMMAND != "jupyter" ]] && \
   [[ $COMMAND != "stop" ]] && \
   [[ $COMMAND != "shell" ]]; then
  echo
  echo "COMMAND must be one of docker_clean_unused, build, create_stack, upload_data, jupyter, stop, shell!"
  echo "Exiting."
  exit 1
fi

case $COMMAND in

  docker_clean_unused)
  echo
  echo "Removing all unused Docker images."
  docker system prune --all --force --volumes
  ;;

  build)
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
  --parameter-overrides S3=$S3_BUCKET Dynamo=$DYNAMO_DB
  ;;

  upload_data)
  echo
  echo "Uploading $DATA to s3://$S3_BUCKET."
  docker run --env AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
  --env AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
  --env AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION \
  $IMAGE_TAG aws s3 cp $DATA s3://$S3_BUCKET
  ;;

  jupyter)
  echo
  echo "Starting Jupyter server in $IMAGE_TAG container."
  docker run --publish 8888:8888 --volume $(pwd)/notebooks:/workspace/notebooks --detach $IMAGE_TAG jupyter
  ;;

  stop)
  echo
  echo "Stopping $IMAGE_TAG container."
  docker container stop $(docker ps -q --filter ancestor=$IMAGE_TAG)
  ;;

  shell)
  echo
  echo "Opening a shell in $IMAGE_TAG container."
  docker run --interactive --tty $IMAGE_TAG /bin/sh
  ;;

esac
