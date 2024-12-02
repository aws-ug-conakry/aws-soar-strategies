Créer un **VPC** et un **Security Group (SG)** avec tout le trafic **Ingress (entrant)** et **Egress (sortant)** bloqué, pour les cas de mise en quarantaine.

---
vpc-02289fa6146d7e671

### Étape 1 : Créer un Security Group pour la quarantaine

1. **Créer le Security Group dans le VPC** :
   ```bash
   aws ec2 create-security-group \
       --group-name QuarantineSG \
       --description "Security group for quarantined instances" \
       --vpc-id vpc-02289fa6146d7e671
   ```

   Cette commande retournera l'ID du SG, par exemple : `sg-0235f10511c4c0cf9`.

---

### Étape 3 : Bloquer tout le trafic (Ingress et Egress)

1. **Supprimer toutes les règles par défaut (si applicables)** :
   - **Pour Egress (trafic sortant)** :
     Par défaut, le SG permet tout le trafic sortant. Supprimez cette règle par défaut :
     ```bash
     aws ec2 revoke-security-group-egress \
         --group-id sg-0235f10511c4c0cf9 \
         --protocol all \
         --port all \
         --cidr 0.0.0.0/0
     ```

   - **Pour Ingress (trafic entrant)** :
     Par défaut, aucun trafic entrant n'est autorisé, donc aucune action n'est nécessaire pour Ingress.

2. **Vérifier la configuration** :
   ```bash
   aws ec2 describe-security-groups \
       --group-ids sg-0235f10511c4c0cf9
   ```

   Vous devriez voir :
   - Aucune règle d'entrée (Ingress).
   - Aucune règle de sortie (Egress).

---

### Résultat attendu
- Un **VPC** nommé `QuarantineVPC` est créé.
- Un **Security Group** nommé `QuarantineSG` est configuré dans ce VPC.
- Ce SG bloque tout le trafic entrant et sortant, isolant complètement toute instance EC2 associée.

---

### Utilisation du SG
Lorsqu'une instance doit être mise en quarantaine, attribuez ce Security Group à l'instance via Lambda ou AWS CLI.

**Exemple avec Lambda** :
```python
ec2_client.modify_instance_attribute(
    InstanceId=instance_id,
    Groups=["sg-0235f10511c4c0cf9"]
)
```

**Exemple avec AWS CLI** :
```bash
aws ec2 modify-instance-attribute \
    --instance-id i-0069e2ffd9f1c447f \
    --groups sg-0235f10511c4c0cf9
```