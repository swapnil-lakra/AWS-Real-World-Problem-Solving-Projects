# WHY:
# boto3 is used to interact with AWS services programmatically inside the Lambda function.
# os is used to securely access environment variables and datetime supports timestamp logging.

import boto3
import os
from datetime import datetime, timezone

# WHY:
# Creates an RDS client for performing automated database operations.
# This client is used to stop the RDS instance during idle conditions.

rds = boto3.client('rds')

# WHY:
# lambda_handler is the main execution function triggered by EventBridge automation.
# It handles automatic shutdown of idle RDS instances for cost optimization.

def lambda_handler(event, context):

    # WHY:
    # Reads the RDS instance identifier securely from environment variables.
    # This avoids hardcoding database identifiers inside the source code.

    db_id = os.environ['DB_INSTANCE_ID']

    try:

        # WHY:
        # Stops the RDS instance automatically when idle conditions are detected.
        # This helps reduce unnecessary infrastructure cost during low usage periods.

        rds.stop_db_instance(
            DBInstanceIdentifier=db_id
        )

        # WHY:
        # Successful execution can be tracked through Lambda invocation status and CloudWatch logs.

    except Exception as e:

        # WHY:
        # Captures and logs errors if the RDS stop operation fails.
        # Helps simplify debugging and operational troubleshooting.

        error_msg = f"❌ Error stopping RDS: {str(e)}"

        print(error_msg)