import boto3
import os

def start_auto_scaling_group(asg_client, asg_name, desired_capacity):
    asg_client.update_auto_scaling_group(
        AutoScalingGroupName=asg_name,
        DesiredCapacity=desired_capacity,
    )
    print(f"Starting {asg_name} with desired capacity {desired_capacity}")

def stop_auto_scaling_group(asg_client, asg_name, desired_capacity):
    asg_client.update_auto_scaling_group(
        AutoScalingGroupName=asg_name,
        DesiredCapacity=desired_capacity,
    )
    print(f"Stopping {asg_name} with desired capacity {desired_capacity}")

def lambda_handler(event, context):
    region = os.getenv("AWS_REGION", "ap-southeast-3")
    asg_name = os.getenv("ASG_NAME")
    desired_capacity = int(os.getenv("DESIRED_CAPACITY", "1"))
    action = event.get("ACTION").lower()
    asg_client = boto3.client("autoscaling", region_name=region)

    if not asg_name:
        print("No ASG Provided")
        return {"status":"no_asg_name"}
    
    if action == "start":
        start_auto_scaling_group(asg_client, asg_name, desired_capacity)

    elif action == "stop":
        stop_auto_scaling_group(asg_client, asg_name, desired_capacity)
    else:
        print("Invalid Action")
        return {"status":"invalid_action", "received": action}
    return {"status":"done"}