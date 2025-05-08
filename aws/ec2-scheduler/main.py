import boto3
import os
import logging
from botocore.exceptions import ClientError

# Set up logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def start_instances(ec2, instance_ids):
    try:
        ec2.start_instances(InstanceIds=instance_ids)
        logger.info(f"Started EC2 Instances: {instance_ids}")
    except ClientError as e:
        logger.error(f"Failed to start EC2 Instances {instance_ids}: {e}")
        raise Exception(f"Failed to start EC2 Instances: {e}")

def stop_instances(ec2, instance_ids):
    try:
        ec2.stop_instances(InstanceIds=instance_ids)
        logger.info(f"Stopped EC2 Instances: {instance_ids}")
    except ClientError as e:
        logger.error(f"Failed to stop EC2 Instances {instance_ids}: {e}")
        raise Exception(f"Failed to stop EC2 Instances: {e}")

def lambda_handler(event, context):
    region = os.getenv("AWS_REGION", "ap-southeast-3")
    ec2 = boto3.client("ec2", region_name=region)
    instance_ids = os.getenv("INSTANCE_IDS", "").split(",")
    action = event.get("ACTION")

    if not instance_ids or instance_ids == [""]:
        logger.warning("No EC2 instance IDs provided")
        return {"status": "no_instance_ids"}

    if action == "start":
        start_instances(ec2, instance_ids)
    elif action == "stop":
        stop_instances(ec2, instance_ids)
    else:
        logger.error(f"Invalid Action: {action}")
        return {"status": "invalid_action"}

    return {"status": "done"}
