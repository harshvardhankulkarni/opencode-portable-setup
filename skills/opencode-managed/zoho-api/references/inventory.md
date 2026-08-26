# Zoho Inventory API (v1)

Base (US): `https://www.zohoapis.com/inventory/v1` · Auth: `Zoho-oauthtoken` · Scope: `ZohoInventory.fullaccess.all` · Requires `organization_id` on every call (same as Books).

## Key endpoints
| Operation | Method + Path |
|---|---|
| Items | GET/POST `/items`, GET `/{item_id}`, PUT `/{item_id}` |
| Item groups | GET/POST `/itemgroups` |
| Sales orders | GET/POST `/salesorders`, GET `/{id}/fulfill` (convert to package) |
| Invoices | GET/POST `/invoices` |
| Purchase orders | GET/POST `/purchaseorders` |
| Bills | GET/POST `/bills` |
| Warehouses | GET `/warehouses` |
| Stock adjustment | POST `/inventoryadjustments` |
| Reorder settings | GET/POST `/reorderlevel` |

## Create item (minimal)
```json
{
  "name": "Widget A",
  "sku": "WGT-A-001",
  "rate": 250.00,
  "initial_stock": 100,
  "unit": "nos",
  "status": "active"
}
```

## Pitfalls
- `organization_id` mandatory everywhere (same org model as Books)
- Stock fields: `initial_stock` only on create; adjust via inventoryadjustments after
- SKU is unique per org - upsert by SKU to avoid duplicates
- Currency is org-level, not per item

Docs: https://www.zoho.com/inventory/api/v1/
