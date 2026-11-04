# AWS Intelligent Document Processing (IDP) + Bedrock Data Automation (BDA)

**Project:** `aws-idp-demo-lab`  
**Purpose:** AWS Cloud Engineer interview revision  
**Region:** `us-east-1`

## 1. Architecture

```text
Invoice PDF → S3 incoming/
    → EventBridge (Object Created, prefix filter)
    → Lambda (Python/boto3)
    → Step Functions Standard workflow
    → Bedrock Data Automation (BDA project + custom invoice blueprint)
    → S3 processed/ (structured JSON)
    → Validation (required fields, formats, confidence)
    ├── VALID → downstream processing
    └── REVIEW_REQUIRED → human review
```

**Implementation boundary:** S3 → EventBridge → Lambda → Step Functions was independently verified. BDA asynchronous extraction → S3 JSON was independently verified via CLI. The Step Functions-to-BDA integration, validation Lambda, and downstream routing are **proposed production enhancements**, not completed end-to-end integrations.

## 2. Configuration and implementation steps

1. **Terraform:** Provisioned S3 document bucket with encryption, versioning, and public-access block. Bootstrapped separate S3 Terraform state bucket and GitHub Actions IAM role using an existing shared GitHub OIDC provider.
2. **S3:** Used `incoming/` and `processed/` object prefixes; enabled EventBridge notifications.
3. **EventBridge:** Created an `Object Created` rule filtered to `incoming/` and routed it to Lambda.
4. **Lambda:** Created `aws-idp-demo-lab-start-workflow` to parse S3 event details and start Step Functions with boto3.
5. **IAM:** Configured service execution roles and `states:StartExecution` permission.
6. **Step Functions:** Created `aws-idp-demo-lab-document-processing` Standard state machine; tested placeholder orchestration.
7. **Bedrock Data Automation:** Created a BDA project and custom invoice extraction blueprint, associated the blueprint, and used the `LIVE` stage.
8. **BDA Runtime:** Invoked asynchronous extraction using AWS CLI and S3 input/output paths; polled the invocation status.
9. **Results:** BDA succeeded in approximately 28 seconds and wrote structured JSON to S3. Some fields were missing or low-confidence, demonstrating the need for validation.
10. **Validation:** Implemented local Python invoice validation and confirmed five passing unit tests.

## 3. Lambda → Step Functions example

```python
import boto3
import json
import os

sfn = boto3.client("stepfunctions")

def lambda_handler(event, context):
    bucket = event["detail"]["bucket"]["name"]
    key = event["detail"]["object"]["key"]

    response = sfn.start_execution(
        stateMachineArn=os.environ["STATE_MACHINE_ARN"],
        input=json.dumps({"bucket": bucket, "key": key})
    )
    return {"executionArn": response["executionArn"]}
```

## 4. BDA invocation and status

Replace placeholders with your own project/profile ARNs and bucket name. The commands are illustrative; do not commit live credentials.

```bash
aws bedrock-data-automation-runtime invoke-data-automation-async \
  --region us-east-1 \
  --input-configuration 's3Uri=s3://<bucket>/incoming/invoice.pdf' \
  --output-configuration 's3Uri=s3://<bucket>/processed/' \
  --data-automation-configuration 'dataAutomationProjectArn=<project-arn>,stage=LIVE' \
  --data-automation-profile-arn '<profile-arn>'

aws bedrock-data-automation-runtime get-data-automation-status \
  --region us-east-1 \
  --invocation-arn '<invocation-arn>'
```

Observed example values included invoice date `2024-05-13`, total amount `16051.35`, and currency `INR`. Missing vendor/account data and a low-confidence date highlight that **BDA success does not guarantee business validation success**.

## 5. Proposed production workflow

1. S3 upload emits an EventBridge event.
2. EventBridge invokes Lambda; Lambda starts Step Functions.
3. Step Functions invokes BDA asynchronously.
4. Wait → check BDA status → Choice: continue, wait again, or handle failure.
5. Read extracted JSON from S3 and validate required fields, dates, amounts, and confidence thresholds.
6. Route valid documents to downstream processing and incomplete documents to human review.
7. Add retries/backoff, error handling, logging, alerts, and idempotency based on S3 object identity/version. Use DLQs where supported by the asynchronous integration.

Security: least-privilege IAM, S3 encryption, no hard-coded credentials, CloudWatch observability.

## 6. BDA vs Textract

| Topic | Bedrock Data Automation | Amazon Textract |
|---|---|---|
| Purpose | Structured multimodal extraction | OCR and document analysis |
| Invoice customization | Custom blueprints | AnalyzeExpense, queries and post-processing |
| Supported content | Documents, images, audio, video | Documents and images |
| Asynchronous approach | InvokeDataAutomationAsync + status polling | Start APIs + completion notification/Get APIs |
| My experience | Hands-on POC | Conceptual knowledge |

**Interview wording:** "My hands-on implementation was with BDA. I'm familiar with Textract's AnalyzeExpense and asynchronous extraction architecture, but I haven't implemented Textract in this lab."

## 7. Common interview Q&A

**Why EventBridge instead of direct S3 → Lambda?**  
EventBridge supports flexible filtering and routing to multiple consumers, reducing tight coupling.

**Why Step Functions?**  
It coordinates multi-step and long-running processes and provides Wait, Choice, Retry, Catch, and execution history.

**Why invoke BDA asynchronously?**  
Document extraction can take time. The API returns an invocation ARN that can be checked until completion.

**How do you handle failures or low confidence?**  
Retry transient errors with backoff, validate required fields and confidence, and send exceptions to manual review.

**How do you prevent duplicates?**  
Use an idempotency key from the S3 bucket/key/version and track processing state in DynamoDB (proposed design).

## 8. 90-second interview explanation

> I implemented an AWS Intelligent Document Processing proof of concept using S3, EventBridge, Lambda, Step Functions, and Amazon Bedrock Data Automation. I provisioned the document S3 bucket with Terraform and enabled EventBridge notifications. When an invoice was uploaded under the incoming prefix, EventBridge triggered a Python Lambda, which extracted the object location and started a Step Functions Standard workflow using boto3.
>
> Separately, I configured a Bedrock Data Automation project and custom invoice blueprint. I invoked BDA asynchronously through the AWS CLI, monitored its status, and retrieved structured JSON from S3. The extraction completed in approximately 28 seconds. Some fields were missing or low-confidence, so I built local Python validation logic and verified five tests.
>
> The event-driven orchestration and BDA extraction were independently tested. In production I would integrate BDA polling into Step Functions, add validation and human-review routing, and strengthen observability, retries, and idempotency.

## 9. Cleanup completed

- Main Terraform-managed infrastructure destroyed (4 resources).
- Bootstrap Terraform-managed infrastructure destroyed (6 resources).
- EventBridge rule/target, Lambda, and Step Functions workflow deleted.
- BDA project deletion confirmed; blueprint deletion requested without error.
- Lambda CloudWatch log group deleted.
- Shared GitHub OIDC provider and default EventBridge event bus intentionally preserved.
- Console-created IAM roles should be checked and deleted if not used elsewhere.

**Reminder:** Deleting AWS infrastructure does not remove GitHub repository code. Terraform state files, credentials, and secrets must remain outside Git.
