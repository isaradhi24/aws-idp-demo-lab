terraform {
  backend "s3" {
    bucket       = "aws-idp-demo-lab-tfstate-149703445367"
    key          = "aws-idp-demo-lab/dev/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}