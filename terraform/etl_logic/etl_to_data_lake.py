import boto3
import sys
import json
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

print("GLUE ETL is starting up...")

## @params:
args = getResolvedOptions(sys.argv, [
    'JOB_NAME',
    'region_of_operation',
    'temp_storage_bucket_name',
    'source_storage_bucket_name',
    'destination_storage_bucket_name',
    'source_storage_folder_prefix',
    'catalog_crawler_database_name',
    'catalog_crawler_table_name',
    'catalog_meta_information',
    'name_of_post_etl_crawler',
    'year_partition_key',
    'month_parition_key',
    'date_partition_key',
    'hour_partition_key'
])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

## Create dynamic mapping of columns + partition keys as obtained from hive metastore/glue catalog.
## Mapping is a list of tuples each consisting of - (source column, source type, target column, target type)
catalog_meta_information = json.loads(args['catalog_meta_information'])
_ = [("`{}`".format(column['Name']), column['Type'], "`processed_{}`".format(column['Name']), column['Type']) for column in catalog_meta_information['table']]
_1 = [(p_key['Name'], p_key['Type'], "rawdata_partition_{}".format(p_key['Name']), p_key['Type']) for p_key in catalog_meta_information['partition_keys']]

mapping_with_partitions = _ + _1

## @type: DataSource
## @args: [database = <catalog_database_name>, table_name = <catalog_table_name>, transformation_ctx = "datasource0"]
## @return: datasource0
## @inputs: []
datasource0 = glueContext.create_dynamic_frame.from_catalog(database = args['catalog_crawler_database_name'], table_name = args['catalog_crawler_table_name'], transformation_ctx = "datasource0")

print('Cound of records in incoming catalogued data: {}'.format(datasource0.count()))
print('Schema of incoming catalogued data...')
datasource0.printSchema()

## @type: ApplyMapping
## @args: [mapping = [(<source_column_name>, <source_column_type>, <destination_column_name>, <destination_column_type>)], transformation_ctx = "applymapping1"]
## @return: applymapping1
## @inputs: [frame = datasource0]
applymapping1 = ApplyMapping.apply(frame = datasource0, mappings = mapping_with_partitions, transformation_ctx = "applymapping1")

## @type: ResolveChoice
## @args: [choice = "make_struct", transformation_ctx = "resolvechoice2"]
## @return: resolvechoice2
## @inputs: [frame = applymapping1]

resolvechoice2 = ResolveChoice.apply(frame = applymapping1, choice = "make_struct", transformation_ctx = "resolvechoice2")

## @type: DropNullFields
## @args: [transformation_ctx = "dropnullfields3"]
## @return: dropnullfields3
## @inputs: [frame = resolvechoice2]
dropnullfields3 = DropNullFields.apply(frame = resolvechoice2, transformation_ctx = "dropnullfields3")

## Repartition to reduce EMR partitions into one output file.
dynamicFrameRepartitioned = dropnullfields3.repartition(1)

## If required, can also relationalize if normalization is requirement.

## Use DataSink to leverage Glue library to write to s3 as parquet. However, Glue will not allow overwrite but Spark can. Hence, if overwrite is required, convert dynamic frame to spark df & save to parquet.
## Eg. <dynamic_frame>.toDF().mode('overwrite).format('parquet').save('s3://<path>.parquet)
## @type: DataSink
## @args: [connection_type = "s3", connection_options = {"path": "s3://<data-lake-storage-bucket-name>"}, format = "parquet", transformation_ctx = "datasink4"]
## @return: datasink4
## @inputs: [frame = dropnullfields3]
datasink4 = glueContext.write_dynamic_frame.from_options(
    frame = dynamicFrameRepartitioned, 
    connection_type = "s3", 
    connection_options = {"path": "s3://{}/Glue_ETL_Processed/{}/".format(args['destination_storage_bucket_name'], args['catalog_crawler_table_name'])}, 
    format = "parquet", 
    transformation_ctx = "datasink4")

## To leverage overwrite, using spark instead of glue library.
# _df = dropnullfields3.toDF()
# _df.write.mode('overwrite').parquet('s3://{}/Glue_ETL_Processed/{}/'.format(args['destination_storage_bucket_name'], args['catalog_crawler_table_name']))

job.commit()

## Start POST ETL crawler to catalog data post ETL.
glue_crawler = boto3.client('glue', region_name=args['region_of_operation'])
glue_crawler.start_crawler(Name=args['name_of_post_etl_crawler'])
