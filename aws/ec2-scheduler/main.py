import boto3
import os


def lambda_handler(event, context):
    region = os.getenviron.get("AWS_REGION", "ap-southeast-3")
    ec2 = boto3.client("ec2", region_name=region)
    instance_ids = os.getenviront.get("INSTANCE_IDS", "".split(","))
    action = get.event("ACTION")

    if not instance_ids or instance_ids == [""]:
        print("No EC2 instance ids provided")
        return {"status":"no_instance_ids"}