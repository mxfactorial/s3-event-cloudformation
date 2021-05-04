custom cloudformation resource python lambda preserves existing s3 event notification configuration while adding `s3:ObjectCreated:*`

avoids:

> Important: The following steps apply only to S3 notification configurations for S3 buckets that don't have existing notification configurations. If your S3 bucket already has an existing or manually-created notification configuration, the following steps override those configurations.

https://aws.amazon.com/premiumsupport/knowledge-center/cloudformation-s3-notification-lambda/

 1. `make test` to install deps and run unit tests
 1. assign `ARTIFACT_BUCKET` makefile variable
 1. `make deploy` to zip python artifact as `s3-event-src.zip` and put in s3 `ARTIFACT_BUCKET`
 1. change `YOUR-BUCKET-NAME` and `YOUR-LAMBDA-ARN` values in minimal `cloudformation.yml`, and repeat `Type: Custom::CustomResourceLambdaS3EventConfiguration` for each s3 event notification config
 1. create cloudformation stack:
 ```
 aws cloudformation create-stack \
  --timeout-in-minutes 5 \
  --capabilities CAPABILITY_NAMED_IAM \
  --stack-name s3-event-demo \
  --template-body file://$(pwd)/cloudformation.yml
 ```

expedite custom cloudformation resource delete on error:

1. navigate to custom cloudformation resource lambda cloudwatch log, example `s3-event-faas`
1. search logs for `Received event` described in [docs](https://aws.amazon.com/premiumsupport/knowledge-center/cloudformation-lambda-resource-delete/)
1. assign `Received event` values `makefile` variables:
    ```
    SERVICE_TOKEN=
    RESPONSE_URL=
    STACK_ID=
    REQUEST_ID=
    LOGICAL_RESOURCE_ID=
    PHYSICAL_RESOURCE_ID=
    RESOURCE_TYPE=
    OBJECT_NAME=
    ```
1. `make delete`

\*on "Layer version .. does not exist." error, change `arn:aws:lambda:us-east-1:770693421928:layer:Klayers-python38-requests:$VERSION`to [current version](https://github.com/keithrozario/Klayers/tree/master/deployments/python3.8/arns) in `cloudformation.yml`