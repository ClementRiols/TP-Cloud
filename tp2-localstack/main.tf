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
