import boto3
import os
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def update_auto_scaling(asg_client, asg_name, action):
    try:
        if action == "start":
            response = asg_client.update_auto_scaling_group(
                AutoScalingGroupName=asg_name,
                MinSize=1,
                DesiredCapacity=1,
                MaxSize=5
            )
            logger.info(f"Started ASG '{asg_name}' with min=1, desired=1, max=5")
        elif action == "stop":
            response = asg_client.update_auto_scaling_group(
                AutoScalingGroupName=asg_name,
                MinSize=0,
                DesiredCapacity=0,
                MaxSize=1
            )
            logger.info(f"Stopped ASG '{asg_name}' with min=0, desired=0, max=1")
        return {"status": "success", "asg_name": asg_name, "action": action}
    except Exception as e:
        logger.error(f"Failed to {action} ASG '{asg_name}': {e}")
        return {"status": "error", "message": str(e)}

def lambda_handler(event, context):
    region = os.getenv("AWS_REGION", "ap-southeast-3")
    asg_name = os.getenv("ASG_NAME")
    action = event.get("ACTION", "").lower()

    if not asg_name:
        logger.error("No ASG_NAME environment variable provided")
        return {"status": "no_asg_name"}

    if action not in ["start", "stop"]:
        logger.error(f"Invalid action received: {action}")
        return {"status": "invalid_action", "received": action}

    asg_client = boto3.client("autoscaling", region_name=region)
    return update_auto_scaling(asg_client, asg_name, action)
