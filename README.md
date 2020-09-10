# data-pipeline
Let's build a data pipeline!

# Overview

Here is a simple data pipeline.

It consists of an S3 bucket, a lambda function, and a DynamoDB table.

The input into the pipeline is [a csv](./data/DEVOPS_TEST_DATA.csv), which, when uploaded into the S3 bucket, triggers the lambda function, which writes the data into the DynamoDB table.

CloudFormation creates the AWS resources.  See [cloudformation.yaml](./cloudformation.yaml).

Use [driver.sh](./driver.sh) to do things, all of which happen in Docker, heavy though that may seem, to ensure portability.

# Requirements

- [Docker](https://www.docker.com/products/docker-desktop)
  - This was written using version 19.03.5, build 633a0ea.
- [bash](https://www.gnu.org/software/bash/)
  - This was written using version 3.2.57(1)-release (x86_64-apple-darwin17).
- Environment Variables
  - AWS_ACCESS_KEY_ID
  - AWS_SECRET_ACCESS_KEY
  - AWS_DEFAULT_REGION
  - IP_ADDRESS:  The IP address from which the AWS resources will be created.

# Usage

0. Build the Docker image that plays the role of a build server, so to speak.
```
bash driver.sh build_image
```

1. Create the CloudFormation stack.
```
bash driver.sh create_stack
```

Creating the dev-data-pipeline CloudFormation stack.

Waiting for changeset to be created..
Waiting for stack create/update to complete
Successfully created/updated stack - dev-data-pipeline

2. Upload the data to S3.
```
bash driver.sh upload_data
```

upload: data/DEVOPS_TEST_DATA.csv to s3://data-pipeline-s3-bucket/DEVOPS_TEST_DATA.csv

3. Go to CloudFormation > Stacks > dev-data-pipeline, click on "Resources", find the data-pipeline-dynamodb-table, and click on it.

4. Click on the "Items" tab, and you should see the data.
