data "aws_iam_policy_document" "github_deploy" {
  statement {
    sid = "TerraformStateBucket"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.tfstate.arn
    ]
  }

  statement {
    sid = "TerraformStateObjects"

    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.tfstate.arn}/aws-idp-demo-lab/dev/terraform.tfstate"
    ]
  }

  statement {
    sid = "TerraformStateLock"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      "${aws_s3_bucket.tfstate.arn}/aws-idp-demo-lab/dev/terraform.tfstate.tflock"
    ]
  }

  statement {
    sid = "IDPDocumentBucketManagement"

    actions = [
      # Bucket lifecycle
      "s3:CreateBucket",
      "s3:DeleteBucket",
      "s3:ListBucket",
      "s3:ListBucketVersions",

      # Bucket configuration reads
      "s3:GetBucket*",
      "s3:GetAccelerateConfiguration",
      "s3:GetLifecycleConfiguration",
      "s3:GetReplicationConfiguration",
      "s3:GetEncryptionConfiguration",
      "s3:GetBucketPublicAccessBlock",

      # Bucket configuration changes
      "s3:PutBucket*",
      "s3:DeleteBucket*",
      "s3:PutEncryptionConfiguration",
      "s3:PutBucketPublicAccessBlock",
      "s3:DeleteBucketPublicAccessBlock",

      # Object management
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion"
    ]

    resources = [
      "arn:aws:s3:::aws-idp-demo-lab-149703445367-us-east-1",
      "arn:aws:s3:::aws-idp-demo-lab-149703445367-us-east-1/*"
    ]
  }
}

resource "aws_iam_role_policy" "github_deploy" {
  name   = "aws-idp-demo-lab-deployment-policy"
  role   = aws_iam_role.github_actions.id
  policy = data.aws_iam_policy_document.github_deploy.json
}