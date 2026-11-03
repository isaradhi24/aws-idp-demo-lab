terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region              = "us-east-1"
  allowed_account_ids = ["149703445367"]

  default_tags {
    tags = {
      Project     = "aws-idp-demo-lab"
      Environment = "dev"
      ManagedBy   = "Terraform"
    }
  }
}