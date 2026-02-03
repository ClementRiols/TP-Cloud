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
