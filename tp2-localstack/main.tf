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
