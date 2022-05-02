# Real Time DataWarehousing in AWS - 100% serverless stack.

## Pre-requisites:
- Have an AWS Account.
- Have an `Admin` role created for terraform.
- Have `terraform` installed. (v.0.12+ required)
- On MAC, prepare `~/.aws/credentials` file to contain:

```
[default]
aws_access_key_id=<access_key_id>
aws_secret_access_key=<secret_access_key>
region=<aws_region>

[test-datawarehouse]
role_arn = <arn for aws account named test>
source_profile = default

[sandbox-datawarehouse]
role_arn = <arn for aws account named sandbox>
source_profile = default
```

PS: `test` and `sandbox` are two different accounts to put a logical separation. You don't need two accounts to get started though. If you end up having just one account ensure it's settings are appropriate in the credentials file above.

# How to run?
- With pre-requisites satisfied, from root folder, `make tf/init`
- `make tf/plan`
- `make tf/apply`

# Components created

1. AWS Kinesis Firehose - event bus. 
2. AWS Lambda to pre-process aggregated data in firehose. 
3. AWS Storage - Transient storage. 
4. AWS Glue Crawler - Crawls transient storage & catalogs data from firehose.
5. AWS CloudWatch Event - Listens to successful completion of crawler from step 4 & triggers Lambda (Step 6)
6. AWS Lambda - Trigger Glue ETL (pyspark) job.
7. AWS Glue ETL - Pyspark ETL job, sink = s3 data lake.
8. AWS Glue Crawler - Catalog post ETL data.
9. AWS Storage - S3 data lake
10. AWS Athena - Enables SQL over S3 data lake. (step 9)
11. AWS XRay - For monitoring


