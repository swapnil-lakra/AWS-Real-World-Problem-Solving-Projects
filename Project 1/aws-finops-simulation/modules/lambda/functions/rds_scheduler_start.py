import boto3
import os
from datetime import datetime, timezone

rds = boto3.client('rds')
sns = boto3.client('sns')

def lambda_handler(event, context):
    db_id = os.environ['DB_INSTANCE_ID']
    sns_topic_arn = os.environ.get('SNS_TOPIC_ARN')
    
    try:
        # 1. Send notification BEFORE starting
        if sns_topic_arn:
            sns.publish(
                TopicArn=sns_topic_arn,
                Subject=f"🚀 RDS Start Initiated: {db_id}",
                Message=f"""
                    RDS Instance Start Operation
                    
                    Database: {db_id}
                    Status: STARTING
                    Timestamp: {datetime.now(timezone.utc).isoformat()}
                    
                    This RDS instance is being started now...
                """
            )
        
        print(f"[{datetime.now(timezone.utc).isoformat()}] Starting RDS: {db_id}")
        
        # 2. Start the RDS instance
        rds.start_db_instance(DBInstanceIdentifier=db_id)
        
        # 3. Send success notification
        if sns_topic_arn:
            sns.publish(
                TopicArn=sns_topic_arn,
                Subject=f"✅ RDS Started Successfully: {db_id}",
                Message=f"""
                    RDS Instance Start Successful
                    
                    Database: {db_id}
                    Status: STARTED
                    Timestamp: {datetime.now(timezone.utc).isoformat()}
                    
                    The RDS instance has been started successfully.
                """
            )
        
        return {
            'statusCode': 200,
            'message': f'✅ Started {db_id}',
            'timestamp': datetime.now(timezone.utc).isoformat()
        }
        
    except Exception as e:
        error_msg = f"❌ Error starting RDS: {str(e)}"
        print(error_msg)
        
        # 4. Send failure notification
        if sns_topic_arn:
            sns.publish(
                TopicArn=sns_topic_arn,
                Subject=f"❌ RDS Start FAILED: {db_id}",
                Message=f"""
                    RDS Instance Start Failed
                    
                    Database: {db_id}   
                    Status: FAILED
                    Error: {str(e)}
                    Timestamp: {datetime.now(timezone.utc).isoformat()}
                    
                    Please check the Lambda logs for more details.
                """
            )
        
        return {
            'statusCode': 500,
            'error': error_msg,
            'timestamp': datetime.now(timezone.utc).isoformat()
        }