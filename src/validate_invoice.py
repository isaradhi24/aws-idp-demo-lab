from datetime import date
from decimal import Decimal, InvalidOperation

REQUIRED = ('invoice_number', 'vendor_name', 'invoice_date', 'total_amount', 'currency')

def validate_invoice(invoice):
    errors = []
    for key in REQUIRED:
        value = invoice.get(key)
        if value is None or (isinstance(value, str) and not value.strip()):
            errors.append(f'Missing required field: {key}')
    if invoice.get('invoice_date'):
        try:
            date.fromisoformat(invoice['invoice_date'])
        except (ValueError, TypeError):
            errors.append('Invalid invoice_date: expected YYYY-MM-DD')
    if invoice.get('total_amount') is not None:
        try:
            total = Decimal(str(invoice['total_amount']))
            if not total.is_finite() or total <= 0:
                errors.append('total_amount must be a positive finite number')
        except (InvalidOperation, ValueError, TypeError):
            errors.append('Invalid total_amount')
    if invoice.get('currency') and invoice['currency'] not in ('USD', 'EUR', 'GBP'):
        errors.append('Unsupported currency')
    return {'document_id': invoice.get('document_id'), 'status': 'VALIDATED' if not errors else 'REVIEW_REQUIRED', 'validation_errors': errors}

def lambda_handler(event, context):
    return validate_invoice(event)
