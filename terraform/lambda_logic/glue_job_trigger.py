import boto3
import datetime
import json
import os
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

client = boto3.client('glue')

def handler(event, context):
    try:
        logger.info('## TRIGGERED BY CLOUDWATCH EVENT @ UTC - {}'.format(datetime.datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S')))
        
        _current_utc_hour = datetime.datetime.utcnow().strftime('%H')
        _current_utc_day = datetime.datetime.utcnow().strftime('%d')
        _current_utc_month = datetime.datetime.utcnow().strftime('%m')
        _current_utc_year = datetime.datetime.utcnow().strftime('%Y')

        meta_information = client.get_table(
            DatabaseName=event['catalogDatabaseName'],
            Name=event['catalogTableName']
        )
        # If whole meta information is required by ETL jb in future - remember to serialize datetime objects in the response payload. JSON does not accept datetime as is.
        
        table_meta_information = meta_information['Table']['StorageDescriptor']['Columns']
        partition_keys_meta_information = meta_information['Table']['PartitionKeys']

        mapping_meta_information = {
            'table': table_meta_information,
            'partition_keys': partition_keys_meta_information
        }

        response = client.start_job_run(
            JobName = event['targetGlueJobName'],
            Arguments = {
                '--temp_storage_bucket_name': event['tempStorageBucketName'],
                '--region_of_operation': event['regionOfOperation'],
                '--source_storage_bucket_name': event['sourceStorageBucketName'],
                '--destination_storage_bucket_name': event['destinationStorageBucketName'],
                '--source_storage_folder_prefix': event['sourceStorageFolderPrefix'],
                '--catalog_crawler_database_name': event['catalogDatabaseName'],
                '--catalog_crawler_table_name': event['catalogTableName'],
                '--catalog_meta_information': json.dumps(mapping_meta_information),
                '--name_of_post_etl_crawler': event['postEtlCrawlerName'],
                '--year_partition_key': _current_utc_year,
                '--month_parition_key': _current_utc_month,
                '--date_partition_key': _current_utc_day,
                '--hour_partition_key': _current_utc_hour
            })
        logger.info('## STARTED GLUE JOB: ' + event['targetGlueJobName'])
        logger.info('## GLUE JOB RUN ID: ' + response['JobRunId'])
        return response

    except Exception as e:
        logger.error('** LAMBDA HANDLER IN EXCEPTION. Exception details to follow.')
        logger.error(str(e))
