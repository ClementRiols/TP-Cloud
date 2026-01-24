# TP Cloud 1 : Introduction au Cloud avec OpenTofu et MinIO

## 1. Objectif pédagogique
L'objectif de ce TP est de découvrir les concepts fondamentaux du Cloud Computing en utilisant des outils open source exécutés localement. Ce TP introduit les notions d'Infrastructure as Code (IaC) et de stockage objet via **OpenTofu** et **MinIO** :

- **OpenTofu** : alternative libre à Terraform permettant de gérer de manière déclarative des ressources d'infrastructure via des fichiers de configuration.
- **MinIO** : solution open source de stockage objet compatible S3, permettant de manipuler des objets dans des buckets comme sur une plateforme cloud publique.

---

## 3.1 Outils installés

Avant de débuter, j'ai installé les outils suivant :

- [OpenTofu](https://opentofu.org/docs/)
- [MinIO](https://dl.min.io/server/minio/release/)
- AWS CLI (facultatif)

---

## 3.2 Lancement du serveur MinIO

1. Création d'un dossier de travail pour stocker les données MinIO :

```powershell
PS C:\Users\cleme\Miage\Developpement_Cloud> mkdir C:\Users\cleme\Miage\Developpement_Cloud\minio-data
```
**Résultat :** création du dossier `minio-data`.

2. Lancement du serveur MinIO avec la console web sur le port 9001 :

```powershell
PS C:\Users\cleme\Miage\Developpement_Cloud> .\minio.exe server C:\Users\cleme\Miage\Developpement_Cloud\minio-data --console-address ":9001"
```

**Sortie console :**
```text
MinIO Object Storage Server
WebUI: [http://127.0.0.1:9001](http://127.0.0.1:9001)
RootUser: minioadmin
RootPass: minioadmin
```

**Vérification :** j'ai pu accéder à la console MinIO via `http://localhost:9001` avec les identifiants par défaut.

---

## 3.3 Création de la configuration OpenTofu

1. Création du répertoire de projet :

```powershell
PS C:\Users\cleme\Miage\Developpement_Cloud\TP-Cloud> mkdir tp1-minio
PS C:\Users\cleme\Miage\Developpement_Cloud\TP-Cloud> cd tp1-minio
```

2. Création du fichier `main.tf` pour définir l'infrastructure initiale :

```hcl
terraform {
  required_providers {
    minio = {
      source  = "terraform-provider-minio/minio"
      version = ">= 3.1.0"
    }
  }
}

provider "minio" {
  minio_server   = "127.0.0.1:9000"
  minio_user      = "minioadmin"
  minio_password = "minioadmin"
  minio_ssl      = false
}

resource "minio_s3_bucket" "tp1_bucket" {
  bucket = "tp1-cloud-bucket"
  acl    = "private"
}
```

---

## 3.4 Initialisation et déploiement avec OpenTofu

1. Initialisation du projet :

```powershell
PS C:\Users\cleme\Miage\Developpement_Cloud\TP-Cloud\tp1-minio> tofu init
```
**Résultat :** OpenTofu a initialisé le backend et téléchargé le provider MinIO.

2. Prévisualisation des modifications :

```powershell
PS C:\Users\cleme\Miage\Developpement_Cloud\TP-Cloud\tp1-minio> tofu plan
```

3. Application des changements pour créer le bucket :

```powershell
PS C:\Users\cleme\Miage\Developpement_Cloud\TP-Cloud\tp1-minio> tofu apply
```

**Sortie console :**
```text
minio_s3_bucket.tp1_bucket: Creating...
minio_s3_bucket.tp1_bucket: Creation complete after 0s [id=tp1-cloud-bucket]
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

Le bucket `tp1-cloud-bucket` est désormais visible et fonctionnel dans MinIO.

## 3.5 Transformation du bucket en site web statique

L'objectif de cette étape est de faire évoluer l'infrastructure pour transformer le bucket MinIO en site web statique accessible publiquement.

### 3.5.1 Création des fichiers du site web

Création de deux nouveaux fichiers :

**Fichier `index.html` :**
```html
<!DOCTYPE html>
<html>
<head>
  <title>TP Cloud</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>
  <h1>Voici mon site web statique MinIO !</h1>
</body>
</html>
```

**Fichier `style.css` :**
```css
body {
  font-family: Arial, sans-serif;
  text-align: center;
  background-color: #f0f0f0;
}

h1 {
  color: #007acc;
}
```

### 3.5.2 Modification de la configuration OpenTofu

Le fichier `main.tf` a été mis à jour pour créer un bucket public et y ajouter index.html et style.css :

```hcl
resource "minio_s3_bucket" "web_bucket" {
  bucket = "webbucket"
  acl    = "public-read"
}

resource "minio_s3_object" "index_html" {
  bucket_name = minio_s3_bucket.web_bucket.bucket
  object_name = "index.html"
  source      = "index.html"
  content_type = "text/html"
  acl         = "public-read"
}

resource "minio_s3_object" "style_css" {
  bucket_name = minio_s3_bucket.web_bucket.bucket
  object_name = "style.css"
  source      = "style.css"
  content_type = "text/css"
  acl         = "public-read"
}
```

### 3.5.3 Déploiement du site web

Exécution des commandes de mise à jour :

```powershell
tofu plan
tofu apply
```

**Résultat :**
- Suppression de l’ancien bucket `tp1-cloud-bucket`.
- Création du nouveau bucket `webbucket`.
- Ajout des objets `index.html` et `style.css`.

Le bucket `webbucket` est visible dans la console MinIO

---

## 3.5 Mise en place des variables et des secrets

Pour sécuriser le site web, les valeurs ont été déplacées dans des fichiers dédiés.

### 3.5.1 Fichier `variables.tf`

Ce fichier permet de définir des variables pour éviter de coder les valeurs en dur :

```hcl
variable "minio_server" {
  description = "Adresse du serveur MinIO"
  type        = string
  default     = "127.0.0.1:9000"
}

variable "minio_user" {
  description = "Utilisateur MinIO"
  type        = string
  default     = "minioadmin"
}

variable "minio_password" {
  description = "Mot de passe MinIO"
  type        = string
  sensitive   = true
  default     = "minioadmin"
}

variable "bucket_name" {
  description = "Nom du bucket web"
  type        = string
  default     = "webbucket"
}
```

### 3.5.2 Fichier `outputs.tf`

Ce fichier permet d'afficher les informations utiles après chaque déploiement :

```hcl
output "bucket_name" {
  value       = minio_s3_bucket.web_bucket.bucket
  description = "Nom du bucket web créé"
}

output "bucket_url" {
  value       = "http://${var.minio_server}/${minio_s3_bucket.web_bucket.bucket}/index.html"
  description = "URL du site web statique"
}
```

### 3.5.3 Utilisation dans `main.tf`

Le provider utilise désormais ces nouvelles variables :

```hcl
provider "minio" {
  minio_server   = var.minio_server
  minio_user      = var.minio_user
  minio_password = var.minio_password
  minio_ssl      = false
}
```

Après un `tofu apply`, OpenTofu affiche proprement les outputs :

**Sortie console :**
```text
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

bucket_name = "webbucket"
bucket_url = "[http://127.0.0.1:9000/webbucket/index.html](http://127.0.0.1:9000/webbucket/index.html)"
```

Le bucket MinIO est bien devenue un site web statique configurable et reproductible avec OpenTofu.

## 3.6 Optimisation de la sécurité du bucket

L’objectif de cette étape est d'optimiser les ACLs de votre bucket afin que seulement les fichier important soient accessible. Le bucket devient privé, mais les fichiers nécessaires au site restent publics.

### 3.6.1 Principe de sécurité appliqué

- Bucket MinIO : Configuré en `private`
- `index.html` et `style.css` : Configurés en `public-read` pour permettre l'affichage du   site.

### 3.6.2 Modification du fichier `main.tf`

Mise à jour de la ressource bucket et des objets :

```hcl
resource "minio_s3_bucket" "web_bucket" {
  bucket = var.bucket_name
  acl    = "private" # Le bucket lui-même n'est plus public
}

resource "minio_s3_object" "index_html" {
  bucket_name = minio_s3_bucket.web_bucket.bucket
  object_name = "index.html"
  source      = "index.html"
  content_type = "text/html"
  acl         = "public-read" # Seul le fichier est public
}

resource "minio_s3_object" "style_css" {
  bucket_name = minio_s3_bucket.web_bucket.bucket
  object_name = "style.css"
  source      = "style.css"
  content_type = "text/css"
  acl         = "public-read" # Seul le fichier est public
}
```

### 3.6.3 Application et résultats

Commandes exécutées :
```powershell
tofu plan
tofu apply
```

**Résultat :** Le bucket est désormais sécurisé. Le site web continue de fonctionner car les fichiers individuels possèdent leurs propres droits d'accès.

---

## 3.7 Validation et nettoyage de l’infrastructure

Cette étape valide le cycle de vie complet de l’Infrastructure as Code (IaC) : création, destruction et reconstruction.

### 3.7.1 Destruction de l’infrastructure

Pour supprimer proprement toutes les ressources créées :
```powershell
tofu destroy
```
> **Sortie console :** `Plan: 0 to add, 0 to change, 3 to destroy.`  
> **Résultat :** Le bucket et les fichiers ont été supprimés de MinIO.

### 3.7.2 Reconstruction complète

Pour vérifier la reproductibilité, on relance le déploiement :
```powershell
tofu apply
```
**Résultat :** L'intégralité de l'environnement (bucket, fichiers, politiques de sécurité) est reconstruite à l'identique.

---

## Conclusion

Ce TP a permis de valider les compétences suivantes :
1. **Déploiement d'une infrastructure locale** via MinIO et OpenTofu.
2. **Gestion de l'Infrastructure as Code (IaC)** : Utilisation de providers, ressources, variables et outputs.
3. **Hébergement statique** : Transformation d'un stockage objet en serveur web simple.
4. **Sécurisation** : Application de politiques d'accès fines (ACL) pour protéger les données.

L’ensemble de l’infrastructure est désormais **reproductible, versionnée et sécurisée**, répondant aux standards modernes du Cloud Computing.