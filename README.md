# data-pipeline
Let's build a data pipeline!

# Overview

Here we build a data pipeline.

Everything has been Dockerized so that it works on your machine, heavy though that may seem.

CloudFormation creates the AWS resources.  See [cloudformation.yaml](./cloudformation.yaml)

Use [driver.sh](./driver.sh) to do things.

# Requirements

- [Docker](https://www.docker.com/products/docker-desktop)
  - This was written using version 19.03.5, build 633a0ea.
- [bash](https://www.gnu.org/software/bash/)
  - This was written using version 3.2.57(1)-release (x86_64-apple-darwin17).
- Environment Variables
  - AWS_ACCESS_KEY_ID
  - AWS_SECRET_ACCESS_KEY
  - AWS_DEFAULT_REGION

# Usage

0. Build the Docker image that plays the role of a build server.
```
bash driver.sh build_image
```

1. Create the CloudFormation stack.
```
bash drivers.sh create_stack
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

4. Click on the Items tab, and you should see the data.


TO DO:
https://aws.amazon.com/blogs/database/implementing-bulk-csv-ingestion-to-amazon-dynamodb/
https://github.com/aws-samples/csv-to-dynamodb/blob/master/CloudFormation/CSVToDynamo.template
https://medium.com/serverlessguru/how-to-convert-cloudformation-json-to-yaml-1c011331fae2

https://docs.aws.amazon.com/AmazonS3/latest/dev/example-bucket-policies-vpc-endpoint.html
https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-lambda-function-vpcconfig.html
