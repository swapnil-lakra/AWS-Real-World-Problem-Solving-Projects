import boto3
import os
from datetime import datetime,timezone

rds = boto3.client('rds')
sns = boto3.client('sns')

def lambda_handler(event, context):
    db_id = os.environ['DB_INSTANCE_ID']
    sns_topic_arn = os.environ.get('SNS_TOPIC_ARN')
    
    try:
        # 1. Send notification BEFORE stopping
        if sns_topic_arn:
            sns.publish(
                TopicArn=sns_topic_arn,
                Subject=f"⏹️ RDS Stop Initiated: {db_id}",
                Message=f"""
                    RDS Instance Stop Operation
                    
                    Database: {db_id}
                    Status: STOPPING
                    Timestamp: {datetime.now(timezone.utc).isoformat()}
                    
                    This RDS instance is being stopped now...
                """
            )
        
        print(f"[{datetime.now(timezone.utc).isoformat()}] Stopping RDS: {db_id}")
        
        # 2. Stop the RDS instance
        rds.stop_db_instance(DBInstanceIdentifier=db_id)
        
        # 3. Send success notification
        if sns_topic_arn:
            sns.publish(
                TopicArn=sns_topic_arn,
                Subject=f"✅ RDS Stopped Successfully: {db_id}",
                Message=f"""
                    RDS Instance Stop Successful
                    
                    Database: {db_id}
                    Status: STOPPED
                    Timestamp: {datetime.now(timezone.utc).isoformat()}
                    
                    The RDS instance has been stopped successfully.
                    Cost savings: Running stopped instances does not incur charges.
                """
            )
        
        return {
            'statusCode': 200,
            'message': f'✅ Stopped {db_id}',
            'timestamp': datetime.now(timezone.utc).isoformat()
        }
        
    except Exception as e:
        error_msg = f"❌ Error stopping RDS: {str(e)}"
        print(error_msg)
        
        # 4. Send failure notification
        if sns_topic_arn:
            sns.publish(
                TopicArn=sns_topic_arn,
                Subject=f"❌ RDS Stop FAILED: {db_id}",
                Message=f"""
                    RDS Instance Stop Failed
                    
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