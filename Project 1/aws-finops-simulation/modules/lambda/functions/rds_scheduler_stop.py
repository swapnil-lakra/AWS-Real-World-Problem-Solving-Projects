# WHY:
# boto3 is used to interact with AWS services programmatically from the Lambda function.
# os is used for environment variable access and datetime is used for timestamp generation.

import boto3
import os
from datetime import datetime, timezone

# WHY:
# Creates AWS service clients for RDS and SNS.
# These clients are used for database automation and operational notifications.

rds = boto3.client('rds')
sns = boto3.client('sns')

# WHY:
# lambda_handler is the main execution function triggered by EventBridge Scheduler.
# It automates RDS stop operations during idle business hours.

def lambda_handler(event, context):

    # WHY:
    # Reads the database identifier and SNS topic ARN securely from environment variables.
    # This avoids hardcoding infrastructure-specific values inside the source code.

    db_id = os.environ['DB_INSTANCE_ID']
    sns_topic_arn = os.environ['SNS_TOPIC_ARN']

    try:

        # WHY:
        # Sends a notification before stopping the RDS instance.
        # This provides operational visibility that the automation workflow has started.

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

        # WHY:
        # Writes operational logs into CloudWatch Logs for monitoring and debugging.

        print(f"[{datetime.now(timezone.utc).isoformat()}] Stopping RDS: {db_id}")

        # WHY:
        # Stops the RDS instance automatically using the AWS SDK.
        # This helps reduce infrastructure cost during non-business hours.

        rds.stop_db_instance(
            DBInstanceIdentifier=db_id
        )

        # WHY:
        # Sends a success notification after the RDS instance stops successfully.
        # Confirms cost optimization automation completed correctly.

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

        # WHY:
        # Returns structured success information for observability and troubleshooting.

        return {
            'statusCode': 200,
            'message': f'✅ Stopped {db_id}',
            'timestamp': datetime.now(timezone.utc).isoformat()
        }

    except Exception as e:

        # WHY:
        # Captures unexpected failures during the RDS stop operation.
        # Helps improve incident handling and operational reliability.

        error_msg = f"❌ Error stopping RDS: {str(e)}"

        print(error_msg)

        # WHY:
        # Sends failure notifications immediately when automation execution fails.
        # This allows operators to investigate issues quickly.

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

        # WHY:
        # Returns structured error details useful for monitoring and debugging workflows.

        return {
            'statusCode': 500,
            'error': error_msg,
            'timestamp': datetime.now(timezone.utc).isoformat()
        }