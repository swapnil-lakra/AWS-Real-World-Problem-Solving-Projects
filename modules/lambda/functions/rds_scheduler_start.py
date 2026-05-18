# WHY:
# boto3 is used to interact with AWS services programmatically from the Lambda function.
# os is used for securely reading environment variables and datetime helps generate timestamps.

import boto3
import os
from datetime import datetime, timezone

# WHY:
# Creates AWS service clients for RDS and SNS.
# These clients are used to automate database operations and send notifications.

rds = boto3.client('rds')
sns = boto3.client('sns')

# WHY:
# lambda_handler is the main entry point executed whenever the Lambda function is triggered.
# It handles automated RDS start operations and notification workflows.

def lambda_handler(event, context):

    # WHY:
    # Reads the RDS instance identifier and SNS topic ARN from Lambda environment variables.
    # This avoids hardcoding sensitive or environment-specific values inside the code.

    db_id = os.environ['DB_INSTANCE_ID']
    sns_topic_arn = os.environ['SNS_TOPIC_ARN']

    try:

        # WHY:
        # Sends a notification before starting the RDS instance.
        # This provides operational visibility that automation has started successfully.

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

        # WHY:
        # Logs operational events into CloudWatch Logs for debugging and observability.

        print(f"[{datetime.now(timezone.utc).isoformat()}] Starting RDS: {db_id}")

        # WHY:
        # Starts the RDS database instance automatically using the AWS SDK.
        # This enables scheduled database availability during business hours.

        rds.start_db_instance(
            DBInstanceIdentifier=db_id
        )

        # WHY:
        # Sends a success notification after the RDS instance starts successfully.
        # This confirms successful automation execution to operators.

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

        # WHY:
        # Returns a structured success response for operational tracking and debugging.

        return {
            'statusCode': 200,
            'message': f'✅ Started {db_id}',
            'timestamp': datetime.now(timezone.utc).isoformat()
        }

    except Exception as e:

        # WHY:
        # Captures unexpected failures during RDS start operations.
        # Helps improve troubleshooting and operational reliability.

        error_msg = f"❌ Error starting RDS: {str(e)}"

        print(error_msg)

        # WHY:
        # Sends failure notifications when automation execution fails.
        # This ensures operators are alerted immediately for investigation.

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

        # WHY:
        # Returns structured error details for monitoring, debugging, and incident handling.

        return {
            'statusCode': 500,
            'error': error_msg,
            'timestamp': datetime.now(timezone.utc).isoformat()
        }