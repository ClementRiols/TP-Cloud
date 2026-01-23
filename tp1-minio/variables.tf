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
