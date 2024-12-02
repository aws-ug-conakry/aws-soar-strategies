#### 1. **Créer une IAM Role pour Lambda**
1. Créez un rôle avec la politique suivante pour Lambda :
   ```bash
   aws iam create-role \
    --role-name LambdaQuarantineRole \
    --assume-role-policy-document file://trust-policy.json
   ```
### 2. **Attacher les policies au rôle 
```bash
aws iam attach-role-policy --role-name LambdaQuarantineRole --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess
aws iam attach-role-policy --role-name LambdaQuarantineRole --policy-arn arn:aws:iam::aws:policy/AmazonSNSFullAccess
aws iam attach-role-policy --role-name LambdaQuarantineRole --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
aws iam attach-role-policy --role-name LambdaQuarantineRole --policy-arn arn:aws:iam::aws:policy/AutoScalingFullAccess
```
3. Notez l'ARN du rôle.

---

### 3. **Créer la fonction Lambda**
1. Créez un fichier `quarantine_function.py` :

2. Zippez la fonction :
   ```bash
   zip quarantine_function.zip quarantine_function.py
   ```

3. Créez la fonction Lambda :
   ```bash
   aws lambda create-function \
       --function-name QuarantineFunction \
       --runtime python3.9 \
       --role arn:aws:iam::615299742853:role/LambdaQuarantineRole \
       --handler quarantine_function.lambda_handler \
       --zip-file fileb://quarantine_function.zip
   ```

4. Notez l’ARN de la fonction Lambda.


### 4.Creer une règle pour le findings GuarDuty
```bash
aws events put-rule \
    --name GuardDutyFinding \
    --event-pattern '{
        "source": ["aws.guardduty"],
        "detail-type": ["GuardDuty Finding"]
    }'
```
ou 

```bash
   aws events put-rule \
       --name GuardDutyFinding \
       --event-pattern file://event-pattern.json
```

### 5.Ajouter lambda comme une cible
```bash
aws events put-targets \
    --rule GuardDutyFinding \
    --targets "Id"="1","Arn"="<Lambda ARN>"
```

aws events put-targets \
    --rule GuardDutyFinding \
    --targets "Id"="1","Arn"="arn:aws:lambda:us-east-1:615299742853:function:QuarantineFunction"
    
aws logs describe-log-groups --log-group-name-prefix "/aws/lambda/QuarantineFunction"

aws logs get-log-events \
    --log-group-name "/aws/lambda/QuarantineFunction" \
    --log-stream-name "<Log-Stream-Name>"

aws autoscaling describe-auto-scaling-groups

### 6.Ajouter les permissions à CLoudWatch pour invoquer lambda
```bash 
aws lambda add-permission \
    --function-name QuarantineFunction \
    --statement-id AllowCloudWatchEvents \
    --action "lambda:InvokeFunction" \
    --principal events.amazonaws.com \
    --source-arn arn:aws:events:us-east-1:615299742853:rule/GuardDutyFinding
```


### 7. tester la lambda
aws lambda invoke \
    --function-name QuarantineFunction \
    --payload file://test-event.json \
    output.json


### 8. tester 
```bash
aws guardduty create-sample-findings --detector-id <detector-id>
```


# Troubleshooting 
### Confirmez que l'instance existe :
aws ec2 describe-instances \
    --instance-ids i-0bee5a6543004427e \
    --query "Reservations[*].Instances[*].[InstanceId,State.Name]" --output text

### Vérifiez si l'instance est associée à un Auto Scaling Group :
aws autoscaling describe-auto-scaling-instances \
    --instance-ids i-0bee5a6543004427e
