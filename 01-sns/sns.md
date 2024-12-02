#### **Configurer SNS**
1. Créez un sujet SNS :
   ```bash
   aws sns create-topic --name QuarantineNotifications
   ```

2. Ajoutez une souscription (par exemple, une adresse email) :
   ```bash
   aws sns subscribe \
       --topic-arn arn:aws:sns:us-east-1:615299742853:QuarantineNotifications \
       --protocol email \
       --notification-endpoint linsan.saliou@gmail.com
   ```
3. Valider la subscription par mail 

4. Notez l'ARN du sujet SNS.

5. Tester le SNS
```bash
aws sns publish \
    --topic-arn arn:aws:sns:us-east-1:615299742853:QuarantineNotifications \
    --message "Test message"
```
