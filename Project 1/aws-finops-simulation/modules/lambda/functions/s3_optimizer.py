import boto3
import os
from datetime import datetime, timedelta, timezone

# AWS Clients
s3 = boto3.client('s3')
cw = boto3.client('cloudwatch')
sns = boto3.client('sns')

def lambda_handler(event, context) :
    # Environment Variables
    bucket_name = os.environ.get('S3_BUCKET_NAME')
    sns_topic_arn = os.environ['SNS_TOPIC_ARN']
    
    # 1. Check previous last 3 days total requests (AllRequests)
    metric = cw.get_metric_data(
            MetricDataQueries=[
                {
                    'Id': 's3_get_requests',
                    'MetricStat': {
                        'Metric': {
                            'Namespace': 'AWS/S3',
                            'MetricName': 'GetRequests',  # ✅ GET requests
                            'Dimensions': [
                                {
                                    'Name': 'BucketName',
                                    'Value': bucket_name
                                },
                                {
                                    'Name': 'FilterId',
                                    'Value': 'EntireBucket'
                                }
                            ]
                        },
                        'Period': 86400*3,  # 3 Days
                        'Stat': 'Sum'
                    },
                },
                {
                    'Id': 's3_put_requests',
                    'MetricStat': {
                        'Metric': {
                            'Namespace': 'AWS/S3',
                            'MetricName': 'PutRequests',  # ✅ PUT requests
                            'Dimensions': [
                                {
                                    'Name': 'BucketName',
                                    'Value': bucket_name
                                },
                                {
                                    'Name': 'FilterId',
                                    'Value': 'EntireBucket'
                                }
                            ]
                        },
                        'Period': 86400*3,  # 3 Days
                        'Stat': 'Sum'
                    },
                },
                {
                    'Id': 's3_list_requests',
                    'MetricStat': {
                        'Metric': {
                            'Namespace': 'AWS/S3',
                            'MetricName': 'ListRequests',  # ✅ LIST requests
                            'Dimensions': [
                                {
                                    'Name': 'BucketName',
                                    'Value': bucket_name
                                },
                                {
                                    'Name': 'FilterId',
                                    'Value': 'EntireBucket'
                                }
                            ]
                        },
                        'Period': 86400*3,  # 3 Days
                        'Stat': 'Sum'
                    },
                }
            ],
            StartTime=datetime.now(timezone.utc) - timedelta(hours=1),
            EndTime=datetime.now(timezone.utc),
    )
    
    get_requests = 0
    put_requests = 0
    list_requests = 0
    
    for result in metric['MetricDataResults']:
        metric_id = result['Id']
        values = result.get('Values', [])
        
        # Sum all values for the 3-day period
        total = sum(values) if values else 0
        
        if metric_id == 's3_get_requests':
            get_requests = int(total)
            print(f"GET Requests (3 days): {get_requests}")
        
        elif metric_id == 's3_put_requests':
            put_requests = int(total)
            print(f"PUT Requests (3 days): {put_requests}")
        
        elif metric_id == 's3_list_requests':
            list_requests = int(total)
            print(f"LIST Requests (3 days): {list_requests}")
            

    total_requests = get_requests + put_requests + list_requests
    
    print(f"Bucket: {bucket_name}, Total Requests in last 3 days: {total_requests}")
    
    # --- HYBRID LOGIC START ---
    
    #Scenario 1: Zero activity for 3 days -> Delete all objects (Cleanup)
    if total_requests == 0 :
        print(f"No activity detected for 3 days. Cleaning up all objects in {bucket_name}...")
        
        paginator = s3.get_paginator('list_objects_v2')
        for page in paginator.paginate(Bucket=bucket_name):
            if 'Contents' in page:
                send_sns_notification(
                    topic_arn=sns_topic_arn,
                    bucket_name=bucket_name,
                    object_count=count_objects(bucket_name)
                    )
                delete_keys = [{'Key': obj['Key']} for obj in page['Contents']]
                s3.delete_objects(Bucket=bucket_name, Delete={'Objects': delete_keys})
        print("Cleanup completed.")
    
    # Scenario 2: Active bucket -> Apply Multi-Tier Lifecycle Policy
    else :
        print(f"Activity detected. Applying Multi-Tier Lifecycle Policy to {bucket_name}...")
        
        lifecycle_policy = {
            'Rules' : [
                {
                    'ID': 'MultiTierOptimizationRule',
                    'Status': 'Enabled',
                    'Filter': {
                        'Prefix': ''  # Apply to all objects
                    },
                    'Transitions': [
                        {
                            # 30 days -> Glacier Instant Retrieval
                            'Days': 30,
                            'StorageClass': 'GLACIER_IR'  
                        },
                        {
                            # 90 days -> Glacier Flexible Retrieval (Pehle 'GLACIER' kehte the)
                            'Days': 90,
                            'StorageClass': 'GLACIER'
                        },
                        {
                            # 180 days -> Glacier Deep Archive
                            'Days': 180,
                            'StorageClass': 'DEEP_ARCHIVE'
                        }
                    ],
                    'Expiration': {
                        # 365 days -> Permanent Delete
                        'Days': 365
                    }
                }
            ]
        }
        
        s3.put_bucket_lifecycle_configuration(
            Bucket=bucket_name,
            LifecycleConfiguration=lifecycle_policy
        )
        
        print("Multi-tier Lifecycle policy updated successfully.")
        
        return {
            'statusCode': 200,
            'body': f"Optimization check finished for {bucket_name}"
        }
        

def send_sns_notification(topic_arn,bucket_name, object_count):
    """Send SNS notification before cleanup"""
    try:
        subject = f"S3 Bucket Cleanup Alert - {bucket_name}"
        message = f"""
            S3 Bucket Cleanup Notification
            
            Bucket Name: {bucket_name}
            Total Objects to be Deleted: {object_count}
            Action: Automatic cleanup initiated due to no activity for 3 days
            Timestamp: {datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M:%S')}
            
            This notification is sent before cleanup process begins.
            Please verify if this action is intended.
        """
        
        response = sns.publish(
            TopicArn=topic_arn,
            Subject=subject,
            Message=message
        )
        print(f"SNS notification sent. Message ID: {response['MessageId']}")
        return True
    
    except Exception as e:
        print(f"Error sending SNS notification: {str(e)}")
        return False

def count_objects(bucket_name):
    """Count total objects in bucket"""
    count = 0
    paginator = s3.get_paginator('list_objects_v2')
    for page in paginator.paginate(Bucket=bucket_name):
        if 'Contents' in page:
            count += len(page['Contents'])
    return count