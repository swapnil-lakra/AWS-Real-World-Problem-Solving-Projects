import boto3
import os
from datetime import datetime,timezone

rds = boto3.client('rds')

def lambda_handler(event, context):
    db_id = os.environ['DB_INSTANCE_ID']
    
    try:
        rds.stop_db_instance(DBInstanceIdentifier=db_id)
    except Exception as e:
        error_msg = f"❌ Error stopping RDS: {str(e)}"
        print(error_msg)