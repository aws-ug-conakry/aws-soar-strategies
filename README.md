# Introduction
Ce lab permet de mettre en place une stratégie SOAR (Automatisation de la réponse aux incidents)

# Pré-requis

- AWS CLI configuré.
- Permissions suffisantes : GuardDuty, Lambda, SNS, EC2, Auto Scaling, CloudWatch.
- Région AWS sélectionnée.

# Résultat attendu
- L’instance EC2 signalée par GuardDuty est isolée.
- Un email est envoyé à l’abonné SNS.
- L’instance est détachée de l’Auto Scaling Group et ses attributs modifiés pour la quarantaine.


# Generate findings 
https://docs.aws.amazon.com/guardduty/latest/ug/sample_findings.html#guardduty_findings-scripts


# Notes
La machine mise en quarantaire et les autres doivent dans le même VPC


# Nettoyer les ressources
clean.sh
