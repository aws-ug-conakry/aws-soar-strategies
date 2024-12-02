# Activez GuardDuty 
```bash
aws guardduty create-detector --enable
```
# Noter l'identifiant du detector
```bash
aws guardduty list-detectors
```


aws events put-rule \
    --name TargetInstanceFinding \
    --event-pattern file://event-pattern.json


aws events put-targets \
    --rule GuardDutyFinding \
    --targets "Id"="1","Arn"="arn:aws:lambda:us-east-1:615299742853:function:QuarantineFunction"

    
# **Tester le lab**
1. Générer un faux finding dans GuardDuty :
   ```bash
   aws guardduty create-sample-findings --detector-id 5ec9c3e4fc187292200c720504d51487
   ```
# Liste des findings 
aws guardduty list-findings --detector-id dec9c3a1c39683b9b2eca39aba4c5a3a


aws guardduty get-findings \
    --detector-id 24c9c227ba9e4c971e4c2a4598a69eab \
    --finding-ids 00948d80237c4e158533ecca8162047e

a4b84f40ba0c42d2becca7a4159db090

# tester event
aws events test-event-pattern \
    --event-pattern file://test-event.json \
    --event file://test-event.json

Vérifiez si la fonction Lambda a été invoquée, l’instance EC2 mise en quarantaine, et un email SNS envoyé.
