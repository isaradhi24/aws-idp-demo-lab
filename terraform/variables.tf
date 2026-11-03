variable "aws_region" {
  description = "AWS deployment region"
  type        = string
  default     = "us-east-1"
}

variable "aws_account_id" {
  description = "Target AWS account"
  type        = string
  default     = "149703445367"
}

variable "project_name" {
  description = "Project naming prefix"
  type        = string
  default     = "aws-idp-demo-lab"
}

variable "bda_project_arn" {
  description = "Existing Bedrock Data Automation project ARN"
  type        = string
  default     = "arn:aws:bedrock:us-east-1:149703445367:data-automation-project/5e9a6d947b9b"
}