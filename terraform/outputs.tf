output "documents_bucket_name" {
  description = "S3 bucket for IDP input and output"
  value       = aws_s3_bucket.documents.id
}

output "bda_project_arn" {
  description = "Existing BDA project ARN"
  value       = var.bda_project_arn
}