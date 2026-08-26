# Zoho CRM API (v6)

Base (US): `https://www.zohoapis.com/crm/v6` · Auth: `Zoho-oauthtoken` · Scope: `ZohoCRM.modules.ALL`

## Key endpoints
| Operation | Method + Path |
|---|---|
| List records | GET `/{module}?fields=...&per_page=200&page=1` (Leads, Contacts, Accounts, Deals, Tasks) |
| Get record | GET `/{module}/{id}?fields=...` |
| Create | POST `/{module}` body `{"data": [{...}]}` |
| Upsert | POST `/{module}/upsert` with `upsert_search_field` param |
| Update | PUT `/{module}/{id}` |
| Delete | DELETE `/{module}/{id}` (or `?ids=` bulk) |
| COQL query | POST `/coql` body `{"select_query": "select Last_Name, Phone from Contacts where ..."}` |
| Search | GET `/{module}/search?criteria=(Last_Name:equals:Smith)` |
| Related lists | GET `/{module}/{id}/{relatedList}` (Deals, Notes, Attachments) |
| Webhooks (channels) | POST `/actions/subscribe` (events: create/update/delete per module) |
| Notes/Attachments | GET/POST `/{module}/{id}/Notes`, `/Attachments` |

## Module key fields (API names)
- Leads/Contacts: Last_Name, First_Name, Phone, Email, Mobile, Owner
- Deals: Deal_Name, Amount, Stage, Closing_Date, Account_Name, Contact_Name
- Accounts: Account_Name, Website, Phone, Billing_Country

## COQL (best for complex reads)
```sql
select Deals.Name, Deals.Amount, Accounts.Account_Name
from Deals inner join Accounts on Deals.Account_Name = Accounts.id
where Deals.Amount > 100000 and Deals.Stage = 'Closed Won'
```
Limit 200 rows per call; paginate with `limit` + `offset` params in the COQL payload.

## Pitfalls
- POST/PUT accept arrays in `data` (max 100 per call)
- Dates: `yyyy-MM-dd`; timestamps ISO 8601
- Deleted records: special search via `triggers` or recycle bin API
- Rate limits: 250 requests per minute per client; daily quota based on plan
- Org base URL may be `www.zohoapis.{dc}` (com/eu/in/au/jp) - always derive from org's data center

Docs: https://www.zoho.com/crm/developer/docs/api/v6/
