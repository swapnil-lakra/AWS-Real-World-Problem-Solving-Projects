import boto3
import os
from datetime import datetime, timedelta, timezone
import json

rds = boto3.client('rds')
cw = boto3.client('cloudwatch')
sns = boto3.client('sns')

def lambda_handler(event, context):
    # Validate environment variables
    db_instance_id = os.environ.get('RDS_INSTANCE_ID')
    sns_topic_arn = os.environ.get('SNS_TOPIC_ARN')
    
    if not db_instance_id or not sns_topic_arn:
        raise ValueError("Missing required environment variables")
    
    try:
        # 1. Get RDS status
        response = rds.describe_db_instances(DBInstanceIdentifier=db_instance_id)
        instance = response['DBInstances'][0]
        status = instance['DBInstanceStatus']
        
        print(f"Checking RDS: {db_instance_id}, Status: {status}")
        
        # 2. Get CPU metrics (last hour)
        metric = cw.get_metric_statistics(
            Namespace='AWS/RDS',
            MetricName='CPUUtilization',
            Dimensions=[{'Name': 'DBInstanceIdentifier', 'Value': db_instance_id}],
            StartTime=datetime.now(timezone.utc) - timedelta(hours=1),
            EndTime=datetime.now(timezone.utc),
            Period=1500,
            Statistics=['Average']
        )
        
        # Calculate average CPU
        if not metric['Datapoints']:
            print("⚠️ No CloudWatch metrics - skipping check")
            return {'statusCode': 200, 'body': 'No metrics available'}
        
        cpu_avg = sum(dp['Average'] for dp in metric['Datapoints']) / len(metric['Datapoints'])
        print(f"Average CPU: {cpu_avg:.2f}%")
        
        # Case A: Low CPU and running
        if cpu_avg < 5 and status == 'available':
            print(f"CPU idle ({cpu_avg:.2f}%). Stopping instance...")
            
            send_sns_notification(
                topic_arn=sns_topic_arn,
                subject=f"RDS {db_instance_id} - Low CPU Alert",
                message=f"Instance stopped due to {cpu_avg:.2f}% CPU utilization",
                instance_details=instance
            )
            
            rds.stop_db_instance(DBInstanceIdentifier=db_instance_id)
            
            rds.add_tags_to_resource(
                ResourceName=instance['DBInstanceArn'],
                Tags=[{'Key': 'IdleSince', 'Value': datetime.now(timezone.utc).strftime('%Y-%m-%d')}]
            )
        
        # Case B: Instance stopped - check idle duration
        elif status == 'stopped':
            tags = rds.list_tags_for_resource(ResourceName=instance['DBInstanceArn'])['TagList']
            idle_since_str = next((tag['Value'] for tag in tags if tag['Key'] == 'IdleSince'), None)
            
            if idle_since_str:
                idle_since_date = datetime.strptime(idle_since_str, '%Y-%m-%d').replace(tzinfo=timezone.utc)
                days_idle = (datetime.now(timezone.utc) - idle_since_date).days
                
                print(f"Instance idle for {days_idle} days")
                
                if days_idle >= 3:
                    print("⚠️ 3-day limit reached. Deleting instance...")
                    
                    send_sns_notification(
                        topic_arn=sns_topic_arn,
                        subject=f"⚠️ RDS {db_instance_id} - DELETION",
                        message=f"Instance deleted after {days_idle} idle days",
                        instance_details=instance
                    )
                    
                    snapshot_id = f"final-snapshot-{db_instance_id}-{datetime.now(timezone.utc).strftime('%Y%m%d%H%M')}"
                    rds.delete_db_instance(
                        DBInstanceIdentifier=db_instance_id,
                        SkipFinalSnapshot=False,
                        FinalDBSnapshotIdentifier=snapshot_id
                    )
            else:
                print("No 'IdleSince' tag found")
        
        else:
            print(f"Instance in '{status}' state - no action needed")
        
        return {
            'statusCode': 200,
            'body': json.dumps({'instance': db_instance_id, 'status': status, 'cpu': cpu_avg})
        }
        
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        raise


def send_sns_notification(topic_arn, subject, message, instance_details=None):
    try:
        full_message = message
        
        if instance_details:
            full_message += f"""
                    ---
                    Instance Details:
                    - ID: {instance_details['DBInstanceIdentifier']}
                    - Engine: {instance_details['Engine']}
                    - Class: {instance_details['DBInstanceClass']}
                    - Storage: {instance_details['AllocatedStorage']} GB
                """
        
        response = sns.publish(TopicArn=topic_arn, Subject=subject, Message=full_message)
        print(f"✅ SNS sent: {response['MessageId']}")
        return response
        
    except Exception as e:
        print(f"❌ SNS error: {str(e)}")
        raise
