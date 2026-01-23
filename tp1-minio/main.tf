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
resource "minio_s3_bucket" "web_bucket" {
  bucket = "webbucket"
  acl    = "public-read"
}

resource "minio_s3_object" "index_html" {
  bucket_name = minio_s3_bucket.web_bucket.bucket
  object_name = "index.html"
  source      = "index.html"
  acl         = "public-read"
}

resource "minio_s3_object" "style_css" {
  bucket_name = minio_s3_bucket.web_bucket.bucket
  object_name = "style.css"
  source      = "style.css"
  acl         = "public-read"
}