terraform {
 required_providers {
 minio = {
 source = "terraform-provider-minio/minio"
 version = ">= 3.1.0"
 }
 }
}
provider "minio" {
 minio_server = "127.0.0.1:9000"
 minio_user = "minioadmin"
 minio_password = "minioadmin"
 minio_ssl = false
}
resource "minio_s3_bucket" "tp1_bucket" {
 bucket = "tp1-cloud-bucket"
 acl = "private"
}