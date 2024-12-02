#!/bin/bash

# Auto Scaling Group
aws autoscaling update-auto-scaling-group --auto-scaling-group-name MyASG --desired-capacity 0
aws autoscaling delete-auto-scaling-group --auto-scaling-group-name MyASG --force-delete

# Launch Template
aws ec2 delete-launch-template --launch-template-name MyLaunchTemplate

# EC2 Instances
INSTANCE_IDS=$(aws ec2 describe-instances --query "Reservations[*].Instances[*].InstanceId" --output text)
if [ ! -z "$INSTANCE_IDS" ]; then
  aws ec2 terminate-instances --instance-ids $INSTANCE_IDS
fi

# Security Groups
SECURITY_GROUP_IDS=$(aws ec2 describe-security-groups --query "SecurityGroups[*].GroupId" --output text)
for GROUP_ID in $SECURITY_GROUP_IDS; do
  aws ec2 delete-security-group --group-id $GROUP_ID
done

# Key Pair
aws ec2 delete-key-pair --key-name MyKeyPair
rm -f MyKeyPair.pem

# Lambda Function
aws lambda delete-function --function-name QuarantineFunction
aws iam detach-role-policy --role-name LambdaQuarantineRole --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess
aws iam detach-role-policy --role-name LambdaQuarantineRole --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
aws iam detach-role-policy --role-name LambdaQuarantineRole --policy-arn arn:aws:iam::aws:policy/AutoScalingFullAccess
aws iam detach-role-policy --role-name LambdaQuarantineRole --policy-arn arn:aws:iam::aws:policy/AmazonSNSFullAccess
aws iam delete-role --role-name LambdaQuarantineRole

# SNS
TOPIC_ARN=$(aws sns list-topics --query "Topics[?contains(TopicArn, 'QuarantineNotifications')].TopicArn" --output text)
if [ ! -z "$TOPIC_ARN" ]; then
  aws sns delete-topic --topic-arn $TOPIC_ARN
fi

# CloudWatch Rules
aws events remove-targets --rule GuardDutyFinding --ids "1"
aws events delete-rule --name GuardDutyFinding

# GuardDuty
DETECTOR_ID=$(aws guardduty list-detectors --query "DetectorIds[0]" --output text)
if [ ! -z "$DETECTOR_ID" ]; then
  aws guardduty delete-detector --detector-id $DETECTOR_ID
fi

echo "All resources have been cleaned up."
