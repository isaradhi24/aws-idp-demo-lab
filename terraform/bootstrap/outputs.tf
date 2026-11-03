output "tfstate_bucket_name" {
  description = "Terraform remote state bucket"
  value       = aws_s3_bucket.tfstate.id
}
output "github_actions_role_arn" {
  description = "GitHub Actions OIDC deployment role"
  value       = aws_iam_role.github_actions.arn
}