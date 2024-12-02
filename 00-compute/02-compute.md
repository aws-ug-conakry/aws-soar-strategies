# Creer un key pair
```bash
aws ec2 create-key-pair \
    --key-name MyKeyPair \
    --query 'KeyMaterial' \
    --output text > MyKeyPair.pem
chmod 400 MyKeyPair.pem

```
# Créer un launch template 
```bash

aws ec2 create-launch-template \
    --launch-template-name MyLaunchTemplate \
    --version-description "Initial version" \
    --launch-template-data '{
        "SecurityGroupIds": ["sg-04a220a4887ad415e"],
        "InstanceType": "t2.micro",
        "ImageId": "ami-0013b6db63dc8ec39",
        "KeyName": "MyKeyPair"
    }'
aws ec2 describe-launch-templates --query "LaunchTemplates[*].LaunchTemplateName" 


```

# Creer un Auto Scaling Group
```bash 
aws autoscaling create-auto-scaling-group \
    --auto-scaling-group-name MyASG \
    --launch-template LaunchTemplateName=MyLaunchTemplate,Version=1 \
    --min-size 1 --max-size 1 \
    --desired-capacity 1 \
    --vpc-zone-identifier "subnet-042de26c81bdb19d9"
```



# Créer manuellement les instance

```bash
aws ec2 run-instances \
    --image-id ami-0013b6db63dc8ec39 \
    --count 1 \
    --instance-type t2.micro \
    --key-name MyKeyPair \
    --security-group-ids sg-04a220a4887ad415e \
    --subnet-id subnet-042de26c81bdb19d9
```


# Se connecter à la VM

```bash
ssh -i MyKeyPair.pem ec2-user@<Public-IP-of-Instance>
```

