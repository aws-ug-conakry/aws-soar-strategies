import boto3

sns_client = boto3.client('sns')
ec2_client = boto3.client('ec2')
autoscaling_client = boto3.client('autoscaling')

SNS_TOPIC_ARN = "arn:aws:sns:us-east-1:615299742853:QuarantineNotifications"

def lambda_handler(event, context):
    instance_id = event['detail']['resource']['instanceDetails']['instanceId']
    print(f"Quarantining instance: {instance_id}")

    # Detach instance from Auto Scaling Group
    try:
        response = autoscaling_client.describe_auto_scaling_instances(InstanceIds=[instance_id])
        asg_name = response['AutoScalingInstances'][0]['AutoScalingGroupName']

        autoscaling_client.detach_instances(
            InstanceIds=[instance_id],
            AutoScalingGroupName=asg_name,
            ShouldDecrementDesiredCapacity=False
        )
        print(f"Detached instance {instance_id} from Auto Scaling Group {asg_name}")

        # Modify instance security group to isolate it
        ec2_client.modify_instance_attribute(
            InstanceId=instance_id,
            Groups=["sg-0235f10511c4c0cf9"]  # Security Group for quarantine
        )

        # Notify via SNS
        sns_client.publish(
            TopicArn=SNS_TOPIC_ARN,
            Message=f"Instance {instance_id} has been quarantined."
        )
    except Exception as e:
        print(f"Error processing instance {instance_id}: {str(e)}")
        sns_client.publish(
            TopicArn=SNS_TOPIC_ARN,
            Message=f"Failed to quarantine instance {instance_id}: {str(e)}"
        )
