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
