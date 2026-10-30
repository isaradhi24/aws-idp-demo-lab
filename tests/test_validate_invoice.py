import unittest
from src.validate_invoice import validate_invoice

BASE = {'document_id':'DOC-1001','invoice_number':'INV-1001','vendor_name':'ABC Technologies','invoice_date':'2026-10-21','total_amount':'1250.00','currency':'USD'}

class InvoiceValidationTests(unittest.TestCase):
    def test_valid(self):
        self.assertEqual(validate_invoice(BASE)['status'], 'VALIDATED')
    def test_missing_number(self):
        self.assertEqual(validate_invoice({**BASE, 'invoice_number':''})['status'], 'REVIEW_REQUIRED')
    def test_invalid_calendar_date(self):
        self.assertEqual(validate_invoice({**BASE, 'invoice_date':'2026-02-30'})['status'], 'REVIEW_REQUIRED')
    def test_negative_amount(self):
        self.assertEqual(validate_invoice({**BASE, 'total_amount':'-1'})['status'], 'REVIEW_REQUIRED')
    def test_nan_amount(self):
        self.assertEqual(validate_invoice({**BASE, 'total_amount':'NaN'})['status'], 'REVIEW_REQUIRED')

if __name__ == '__main__':
    unittest.main()
