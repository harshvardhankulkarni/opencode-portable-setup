# Zoho Books API (v3)

Base (US): `https://www.zohoapis.com/books/v3` · Auth: `Zoho-oauthtoken` · Scope: `ZohoBooks.fullaccess.all` · Every call needs `organization_id` (query param). Get orgs: GET `/organization`.

## Key endpoints (all require organization_id)
| Operation | Method + Path |
|---|---|
| List orgs | GET `/organization` |
| Customers | GET/POST `/contacts?contact_type=customer`, PUT `/contacts/{id}` |
| Invoices | GET/POST `/invoices`, GET `/{invoice_id}/pdf` |
| Payments | POST `/payments`, GET `/payments` |
| Expenses | GET/POST `/expenses` |
| Items | GET/POST `/items` (products/services for invoice lines) |
| Sales orders | GET/POST `/salesorders` |
| Bills (AP) | GET/POST `/bills` |
| Chart of accounts | GET `/chartofaccounts` |
| Reports | GET `/reports/profitandloss?from_date=...&to_date=...`, `/reports/balancesheet` |

## Create invoice (minimal payload)
```json
{
  "customer_id": "1234560000001",
  "line_items": [
    {"item_id": "9876540000001", "quantity": 2, "rate": 1500}
  ],
  "date": "2026-08-03",
  "due_date": "2026-09-02"
}
```

## Pitfalls
- `organization_id` is mandatory on every request; wrong org = 403
- Invoice line items: use `item_id` from `/items` or send `name`/`rate` directly
- Decimal money fields come as strings in JSON responses
- PDF generation: GET `/invoices/{id}/pdf` returns base64 in `invoice` object (`invoice_pdf` field)
- Reports accept `from_date`/`to_date` as yyyy-MM-dd; use `filter_by=Date` variants for period grouping

Docs: https://www.zoho.com/books/api/v3/
