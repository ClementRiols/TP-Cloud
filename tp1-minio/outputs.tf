output "bucket_name" {
  value       = minio_s3_bucket.web_bucket.bucket
  description = "Nom du bucket web créé"
}

output "bucket_url" {
  value       = minio_s3_bucket.web_bucket.bucket_domain_name
  description = "URL du bucket web"
}
