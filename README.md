# AWS IDP Interview Lab — Phase 1

Local-first reference project for a production-style invoice IDP architecture.

## Architecture (planned)
S3 input → EventBridge → SQS → Lambda → Step Functions → BDA **or** Textract → normalize → validate → S3 results / DynamoDB status → SNS / human review.

BDA and Textract are alternative extraction branches; they are not automatically run together.

## Run locally

Requires Python 3.10+; no AWS credentials or resources are needed.

```bash
python3 run_demo.py
python3 -m unittest discover -s tests -v
```

On Windows, use `python` or `py -3` instead of `python3` if needed.

## Phase 1 contents
- `src/validate_invoice.py`: deterministic validation and Lambda-compatible handler
- `sample-output/`: simulated normalized invoice records (not actual AWS extraction output)
- `tests/`: unit tests for valid and invalid invoices
- `run_demo.py`: offline demo

## Current limits
This is **not** a deployed IDP pipeline. No BDA/Textract integration, S3 event triggers, Step Functions orchestration, ERP posting, or full invoice line-item reconciliation has been implemented yet. Later phases will add those components. Never present simulated JSON as an actual BDA response.
