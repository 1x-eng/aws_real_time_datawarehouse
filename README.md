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

1. AWS Kinesis Firehose for acknowledging streaming data. 
2. AWS Lambda to pre-process aggregated data in firehose before landing it in storage. 
3. AWS Storage - Transient storage where firehose lands the data. 
4. AWS Glue Crawler - Crawls transient storage & catalogs data recieved from firehose.
5. AWS CloudWatch Event - Listens to successful completion of crawler from step 4 & triggers Lambda (Step 6)
6. AWS Lambda - to acknowledge cloudwatch event trigger and in turn trigger Glue ETL (pyspark) job.
7. AWS Glue ETL - Pyspark job that reads data from glue catalog (transient storage), applies mapping & transforms in parquet & lands it in data lake (Step 8). Also, post completing ETL, this job also triggers another glue crawler to catalog post etl data in a dedicated catalog database.
8. AWS Glue Crawler - To catalog post ETL data.
9. AWS Storage - S3 bucket acting as a data-lake where parquet data post ETL lands.
10. AWS Athena - SQL interface over data stored in data-lake. (step 9)
11. AWS XRay - Monitorning serverless lambda's (similar to Jaeger)


