import json
from pathlib import Path
from src.validate_invoice import validate_invoice

base = Path(__file__).resolve().parent
for filename in ('invoice-valid.json', 'invoice-review.json'):
    invoice = json.loads((base / 'sample-output' / filename).read_text())
    print(f'\n{filename}:')
    print(json.dumps(validate_invoice(invoice), indent=2))
