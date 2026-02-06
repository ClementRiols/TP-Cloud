# TP Cloud 2 – Infrastructure as Code avec OpenTofu et LocalStack

## 1. Objectif pédagogique

L’objectif de ce TP est d’approfondir la pratique de l’Infrastructure as Code (IaC) en utilisant OpenTofu et LocalStack pour simuler un environnement Cloud AWS complet. Ce TP permettra de comprendre la logique de déploiement de ressources cloud (buckets S3, instances EC2, etc.) dans un environnement local sans coût ni dépendance externe.

OpenTofu: permet de gérer des infrastructures de manière déclarative et reproductible. LocalStack: émule la majorité des services AWS (S3, EC2, Lambda, SNS, etc.) localement, permettant de tester les configurations avant un déploiement réel.




---

## 2. Rendu

- Les fichiers main.tf, variables.tf et outputs.tf fonctionnels.
- Un README documentant les étapes de configuration et de test.
- Les captures d’écran des résultats de vérification (buckets, instances, etc.).


---
## 3. Étapes

## 3.1 Installation des outils

Prérequis:
- OpenTofu
- LocalStack
- AWS CLI 
- Python 3.8

---

## 3.2 Configuration et lancement de LocalStack

Télécharger l’image Docker de LocalStack:
```bash
docker pull localstack/localstack
```

Sortie :
```text
Using default tag: latest
latest: Pulling from localstack/localstack
5224c262b89b: Pull complete
36695484add7: Pull complete
...
Digest: sha256:38da30062489e1bb0a4eea0e7331f4d18eb621ab44c953c7cb9843ef9407595a
Status: Downloaded newer image for localstack/localstack:latest
docker.io/localstack/localstack:latest
```

Lancement du conteneur LocalStack:
```powershell
docker run -d --name localstack `
  -p 4566:4566 -p 4571:4571 `
  -e SERVICES=s3,ec2,lambda,dynamodb,cloudformation,sqs `
  -e DEBUG=1 `
  localstack/localstack
```

Vérification que le conteneur tourne :
```bash
docker ps
```

Sortie :
```text
CONTAINER ID    IMAGE                    COMMAND                  STATUS       PORTS                                                 NAMES
6bc3d2de019d    localstack/localstack    "docker-entrypoint.sh"   Up 40 seconds        0.0.0.0:4566->4566/tcp,0.0.0.0:4571->4571/tcp  localstack
```

---

## 3.3 Configuration AWS CLI

```bash
pip install awscli-local
aws configure
```

Configuration :
```text
AWS Access Key ID [None]: test
AWS Secret Access Key [None]: test
Default region name [None]: us-east-1
Default output format [None]: json
```

---

## 3.4 Configuration du provider AWS pour OpenTofu

Créer le répertoire projet
```bash
mkdir tp2-localstack
cd tp2-localstack
```

Fichier `main.tf` initial:

```hcl
provider "aws" {
  access_key                  = "test"
  secret_key                  = "test"
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  endpoints {
    s3 = "http://localhost:4566"
    ec2 = "http://localhost:4566"
  }
  s3_use_path_style = true
}

resource "aws_s3_bucket" "tp2_bucket" {
  bucket = "tp2-cloud-bucket"
}

resource "aws_instance" "tp2_instance" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"
  tags = {
    Name = "tp2-instance"
  }
}
```

---

## 3.5 Initialisation et déploiement

### 1. Initialiser le projet
```bash
tofu init
```
**Sortie console :**
```text
Initializing the backend...
Initializing provider plugins...
- Installing hashicorp/aws v6.28.0
OpenTofu has been successfully initialized!
```

### 2. Vérifier le plan
```bash
tofu plan
```
**Extrait :**
```text
OpenTofu will perform the following actions:
  # aws_instance.tp2_instance will be created
  # aws_s3_bucket.tp2_bucket will be created
Plan: 2 to add, 0 to change, 0 to destroy.
```

### 3. Appliquer la configuration
```bash
tofu apply
```

**Extrait de sortie :**
```text
aws_s3_bucket.tp2_bucket: Creation complete [id=tp2-cloud-bucket]
aws_instance.tp2_instance: Creation complete [id=i-2464d26c5c5e50871]
Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:
ec2_instance_id = "i-2464d26c5c5e50871"
ec2_instance_name = "tp2-instance"
s3_bucket_name = "tp2-cloud-bucket"
```

### 4. Vérification du bucket S3
```bash
aws s3 ls --endpoint-url=http://localhost:4566
```
**Sortie :**
```text
2026-01-24 23:32:29 tp2-cloud-bucket
```

### 5. Vérification des logs EC2 dans LocalStack
```bash
docker logs -f localstack
```
**Extrait :**
```text
AWS ec2.RunInstances => 200
AWS ec2.DescribeInstances => 200
AWS s3.HeadBucket => 200
```

C'est compris. Voici l'intégralité du texte que tu as fourni, formaté proprement en Markdown et regroupé dans un seul bloc de code pour ton fichier README.md.

Markdown
## 3.5 Suppression et amélioration de l’infrastructure

Après avoir vérifié que l’infrastructure a été correctement déployée, il est important de tester la **réversibilité du déploiement** en supprimant toutes les ressources créées.

### Suppression de l’infrastructure
Pour détruire toutes les ressources, exécutez la commande :

```powershell
PS C:\Users\cleme\Miage\Developpement_Cloud\TP-Cloud\tp2-localstack> tofu destroy
```

**Exemple de sortie console :**

```text
aws_s3_bucket.tp2_bucket: Refreshing state... [id=tp2-cloud-bucket]
aws_instance.tp2_instance: Refreshing state... [id=i-2464d26c5c5e50871]

OpenTofu used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  - destroy

Plan: 0 to add, 0 to change, 2 to destroy.

Do you really want to destroy all resources?
  OpenTofu will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

aws_s3_bucket.tp2_bucket: Destroying... [id=tp2-cloud-bucket]
aws_instance.tp2_instance: Destroying... [id=i-2464d26c5c5e50871]
aws_s3_bucket.tp2_bucket: Destruction complete after 0s
aws_instance.tp2_instance: Destruction complete after 10s

Destroy complete! Resources: 2 destroyed.
```

Cette étape permet de libérer l’environnement et de s’assurer que la configuration IaC est réversible.

### Ajout de variables pour plus de flexibilité
Pour rendre le projet plus paramétrable, nous avons créé un fichier `variables.tf` :

```hcl
variable "aws_region" {
  description = "Région AWS simulée par LocalStack"
  type        = string
  default     = "us-east-1"
}

variable "s3_bucket_name" {
  description = "Nom du bucket S3"
  type        = string
  default     = "tp2-cloud-bucket"
}

variable "instance_ami" {
  description = "AMI simulée pour l'instance EC2"
  type        = string
  default     = "ami-12345678"
}

variable "instance_type" {
  description = "Type d'instance EC2"
  type        = string
  default     = "t2.micro"
}

variable "instance_name" {
  description = "Nom de l'instance EC2"
  type        = string
  default     = "tp2-instance"
}
```

### Ajout des outputs
Pour faciliter la récupération des informations des ressources créées, nous avons créé `outputs.tf` :

```hcl
output "s3_bucket_name" {
  description = "Nom du bucket S3 créé"
  value       = aws_s3_bucket.tp2_bucket.bucket
}

output "ec2_instance_id" {
  description = "ID de l'instance EC2 simulée"
  value       = aws_instance.tp2_instance.id
}

output "ec2_instance_name" {
  description = "Nom de l'instance EC2"
  value       = aws_instance.tp2_instance.tags["Name"]
}
```

### Modification de main.tf pour utiliser les variables
Le fichier `main.tf` a été mis à jour pour exploiter les variables déclarées :

```hcl
provider "aws" {
  access_key                  = "test"
  secret_key                  = "test"
  region                      = var.aws_region

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    s3  = "http://localhost:4566"
    ec2 = "http://localhost:4566"
  }

  s3_use_path_style = true
}

resource "aws_s3_bucket" "tp2_bucket" {
  bucket = var.s3_bucket_name
}

resource "aws_instance" "tp2_instance" {
  ami           = var.instance_ami
  instance_type = var.instance_type

  tags = {
    Name = var.instance_name
  }
}
```

### Vérification du déploiement avec les variables

**Initialiser le projet :**
```powershell
PS C:\Users\cleme\Miage\Developpement_Cloud\TP-Cloud\tp2-localstack> tofu init
```

**Vérifier le plan :**
```powershell
PS C:\Users\cleme\Miage\Developpement_Cloud\TP-Cloud\tp2-localstack> tofu plan
```

**Sortie indicative :**
```text
Plan: 2 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + ec2_instance_id   = (known after apply)
  + ec2_instance_name = "tp2-instance"
  + s3_bucket_name    = "tp2-cloud-bucket"
```

**Appliquer la configuration :**
```powershell
PS C:\Users\cleme\Miage\Developpement_Cloud\TP-Cloud\tp2-localstack> tofu apply
```

**Sortie indicative :**
```text
aws_s3_bucket.tp2_bucket: Creation complete after 0s [id=tp2-cloud-bucket]
aws_instance.tp2_instance: Creation complete after 11s [id=i-b322d910516321134]

Outputs:

ec2_instance_id = "i-b322d910516321134"
ec2_instance_name = "tp2-instance"
s3_bucket_name = "tp2-cloud-bucket"
```

**Vérifier que le bucket S3 est bien créé :**
```powershell
PS C:\Users\cleme\Miage\Developpement_Cloud\TP-Cloud\tp2-localstack> aws s3 ls --endpoint-url=http://localhost:4566
2026-02-03 13:30:04 tp2-cloud-bucket
```

**Supprimer de nouveau l’infrastructure :**
```powershell
PS C:\Users\cleme\Miage\Developpement_Cloud\TP-Cloud\tp2-localstack> tofu destroy
```

**Sortie indicative :**
```text
Destroy complete! Resources: 2 destroyed.
```

## 3.5 Suppression et amélioration de l’infrastructure

Après avoir vérifié que l’infrastructure a été correctement déployée, il est important de tester la réversibilité du déploiement en supprimant toutes les ressources créées.

Suppression de l’infrastructure:
Pour détruire toutes les ressources, exécutez la commande :

```powershell
PS C:\Users\cleme\Miage\Developpement_Cloud\TP-Cloud\tp2-localstack> tofu destroy
```

Sortie console :

```text
aws_s3_bucket.tp2_bucket: Refreshing state... [id=tp2-cloud-bucket]
aws_instance.tp2_instance: Refreshing state... [id=i-2464d26c5c5e50871]

OpenTofu used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  - destroy

Plan: 0 to add, 0 to change, 2 to destroy.

Do you really want to destroy all resources?
  OpenTofu will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

aws_s3_bucket.tp2_bucket: Destroying... [id=tp2-cloud-bucket]
aws_instance.tp2_instance: Destroying... [id=i-2464d26c5c5e50871]
aws_s3_bucket.tp2_bucket: Destruction complete after 0s
aws_instance.tp2_instance: Destruction complete after 10s

Destroy complete! Resources: 2 destroyed.
```

Cette étape permet de s’assurer que la configuration IaC est réversible.

### Ajout de variables

Création d'un fichier `variables.tf` :

```hcl
variable "aws_region" {
  description = "Région AWS simulée par LocalStack"
  type        = string
  default     = "us-east-1"
}

variable "s3_bucket_name" {
  description = "Nom du bucket S3"
  type        = string
  default     = "tp2-cloud-bucket"
}

variable "instance_ami" {
  description = "AMI simulée pour l'instance EC2"
  type        = string
  default     = "ami-12345678"
}

variable "instance_type" {
  description = "Type d'instance EC2"
  type        = string
  default     = "t2.micro"
}

variable "instance_name" {
  description = "Nom de l'instance EC2"
  type        = string
  default     = "tp2-instance"
}
```

### Ajout des outputs
Création d'un fichier `outputs.tf` :

```hcl
output "s3_bucket_name" {
  description = "Nom du bucket S3 créé"
  value       = aws_s3_bucket.tp2_bucket.bucket
}

output "ec2_instance_id" {
  description = "ID de l'instance EC2 simulée"
  value       = aws_instance.tp2_instance.id
}

output "ec2_instance_name" {
  description = "Nom de l'instance EC2"
  value       = aws_instance.tp2_instance.tags["Name"]
}
```

### Modification de main.tf pour utiliser les variables
Le fichier `main.tf` a été mis à jour pour exploiter les variables déclarées :

```hcl
provider "aws" {
  access_key                  = "test"
  secret_key                  = "test"
  region                      = var.aws_region

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    s3  = "http://localhost:4566"
    ec2 = "http://localhost:4566"
  }

  s3_use_path_style = true
}

resource "aws_s3_bucket" "tp2_bucket" {
  bucket = var.s3_bucket_name
}

resource "aws_instance" "tp2_instance" {
  ami           = var.instance_ami
  instance_type = var.instance_type

  tags = {
    Name = var.instance_name
  }
}
```

### Vérification du déploiement avec les variables

Initialiser le projet :

```powershell
PS C:\Users\cleme\Miage\Developpement_Cloud\TP-Cloud\tp2-localstack> tofu init
```

Vérifier le plan :

```powershell
PS C:\Users\cleme\Miage\Developpement_Cloud\TP-Cloud\tp2-localstack> tofu plan
```

Sortie:

```text
Plan: 2 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + ec2_instance_id   = (known after apply)
  + ec2_instance_name = "tp2-instance"
  + s3_bucket_name    = "tp2-cloud-bucket"
```

Appliquer la configuration :

```powershell
PS C:\Users\cleme\Miage\Developpement_Cloud\TP-Cloud\tp2-localstack> tofu apply
```

Sortie:

```text
aws_s3_bucket.tp2_bucket: Creation complete after 0s [id=tp2-cloud-bucket]
aws_instance.tp2_instance: Creation complete after 11s [id=i-b322d910516321134]

Outputs:

ec2_instance_id = "i-b322d910516321134"
ec2_instance_name = "tp2-instance"
s3_bucket_name = "tp2-cloud-bucket"
```

Vérication de la création du bucket S3:

```powershell
PS C:\Users\cleme\Miage\Developpement_Cloud\TP-Cloud\tp2-localstack> aws s3 ls --endpoint-url=http://localhost:4566
```

Sortie :
```text
2026-02-03 13:30:04 tp2-cloud-bucket
```

Supprimer de nouveau l’infrastructure :

```powershell
PS C:\Users\cleme\Miage\Developpement_Cloud\TP-Cloud\tp2-localstack> tofu destroy
```

Sortie:

```text
Destroy complete! Resources: 2 destroyed.
```