# Zoho Desk API (v1)

Base (US): `https://desk.zoho.com/api/v1` · Auth: `Zoho-oauthtoken` · Scope: `ZohoDesk.tickets.ALL` · Needs `orgId` header or org URL context (use header `orgId: <id>`).

## Key endpoints
| Operation | Method + Path |
|---|---|
| List tickets | GET `/tickets?limit=100&from=0` (filter: `status=Open`, `subject=`, `priority=`) |
| Get ticket | GET `/tickets/{id}` |
| Create ticket | POST `/tickets` body `{"subject": "...", "departmentId": "...", "contactId": "...", "description": "..."}` |
| Update ticket | PATCH `/tickets/{id}` |
| Add comment | POST `/tickets/{id}/comments` body `{"content": "...", "isPublic": true}` |
| Agents | GET `/agents` |
| Departments | GET `/departments` |
| Webhooks | POST `/webhooks` (events: ticket.creation, ticket.update, etc.) |
| Attachments | POST `/tickets/{id}/attachments` |

## Ticket create (minimal)
```json
{
  "subject": "Login issue on portal",
  "departmentId": "6000000000001",
  "contactId": "7000000000001",
  "description": "User cannot log in after password reset",
  "priority": "High"
}
```

## Pitfalls
- `departmentId` and `contactId` are mandatory on create; fetch valid IDs first from `/departments` and `/contacts`
- Status/priority values are org-defined: GET `/tickets/fields` or use common values (Open, Closed, High, Medium, Low)
- Comments support markdown; use `isPublic:false` for internal notes
- Webhook signature: `X-Zoho-Signature` HMAC with your client secret - verify before processing

Docs: https://desk.zoho.com/support/APIDocument.do
