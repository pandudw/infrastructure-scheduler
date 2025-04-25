import boto3
import os

def start_instances(ec2, instance_ids):
    ec2.start_instances(InstanceIds=instance_ids)
    print(f"Starting EC2 Instance {instance_ids}")

def stop_instance(ec2, instance_ids):
    ec2.stop_instances(InstanceIds=instance_ids)
    print(f"Stopping EC2 Instance {instance_ids}")

def lambda_handler(event, context):
    region = os.getenv("AWS_REGION", "ap-southeast-3")
    ec2 = boto3.client("ec2", region_name=region)
    instance_ids = os.getenv("INSTANCE_IDS", "").split(",")  
    action = event.get("ACTION")  

    if not instance_ids or instance_ids == [""]:
        print("No EC2 instance ids provided")
        return {"status": "no_instance_ids"}

    if action == "start":
        start_instances(ec2, instance_ids)
    elif action == "stop":
        stop_instance(ec2, instance_ids)
    else:
        print(f"Invalid Action!")
        return {"status": "invalid_action"}

    return {"status": "done"}
