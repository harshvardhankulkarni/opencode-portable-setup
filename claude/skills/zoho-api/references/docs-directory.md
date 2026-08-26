# Zoho Official Documentation Directory (all applications)

Complete reference of official Zoho API and product documentation. Links verified 2026-08-03. Format: HTTP status — URL.

## Core / Shared

- 200 Developer portal (all products): https://www.zoho.com/developer/
- 200 API docs portal (apidocs): https://apidocs.zoho.com/
- 200 Developer console (create OAuth clients): https://api-console.zoho.com/
- 200 Deluge scripting reference: https://www.zoho.com/deluge/help/
- 403 OAuth 2.0 protocol: https://www.zoho.com/accounts/protocol/oauth/
- 200 Help portal (all products KB): https://help.zoho.com/portal/en/kb/

## Data center / region

- US: accounts.zoho.com / api.zoho.com
- EU: accounts.zoho.eu / api.zoho.eu
- IN: accounts.zoho.in / api.zoho.in
- AU: accounts.zoho.com.au / api.zoho.com.au
- JP: accounts.zoho.jp / api.zoho.jp

## Application API docs

| App | Link | Status |
|---|---|---|
| CRM | https://www.zoho.com/crm/developer/docs/api/v6/ | 200 |
| Creator | https://www.zoho.com/creator/help/api/v2/ | 200 |
| Books | https://www.zoho.com/books/api/v3/ | 200 |
| Inventory | https://www.zoho.com/inventory/api/v1/ | 200 |
| Invoice | https://www.zoho.com/invoice/api/ | 200 |
| Billing | https://www.zoho.com/billing/api/ | 200 |
| Subscriptions | https://www.zoho.com/subscriptions/api/v1/ | 200 |
| Expense | https://www.zoho.com/expense/api/v1/ | 200 |
| Desk | https://desk.zoho.com/support/APIDocument.do | 200 |
| Recruit | https://www.zoho.com/recruit/api/ | 200 |
| Projects | https://www.zoho.com/projects/api/ | 200 |
| Analytics | https://www.zoho.com/analytics/api/ | 200 |
| Mail | https://www.zoho.com/mail/api/ | 200 |
| Sign | https://www.zoho.com/sign/api/ | 200 |
| Bigin | https://www.zoho.com/bigin/api/v1/ | 200 |
| Vault | https://www.zoho.com/vault/api/ | 200 |
| People | https://www.zoho.com/people/api/ | 403 (valid, bot-blocked) |
| Calendar | https://www.zoho.com/calendar/api/ | 403 (valid, bot-blocked) |
| Social | https://www.zoho.com/social/api/ | 403 (valid, bot-blocked) |
| Payroll | https://www.zoho.com/payroll/api/ | 403 (valid, bot-blocked) |
| Catalyst | https://catalyst.zoho.com/help/api/ | 403 (valid, bot-blocked) |

## Apps with help-portal docs (KB) instead of standalone API pages

| App | KB link |
|---|---|
| Flow | https://help.zoho.com/portal/en/kb/flow/ |
| Tables | https://help.zoho.com/portal/en/kb/tables/ |
| SalesIQ | https://help.zoho.com/portal/en/kb/salesiq/ |
| Survey | https://help.zoho.com/portal/en/kb/survey/ |
| Forms | https://help.zoho.com/portal/en/kb/forms/ |
| Cliq | https://help.zoho.com/portal/en/kb/cliq/ |
| WorkDrive | https://help.zoho.com/portal/en/kb/workdrive/ |
| Bookings | https://help.zoho.com/portal/en/kb/bookings/ |
| ZeptoMail | https://help.zoho.com/portal/en/kb/zeptomail/ |
| Meeting | https://help.zoho.com/portal/en/kb/meeting/ |
| Campaigns | https://help.zoho.com/portal/en/kb/campaigns/ |

## Note on 403 status

Zoho blocks non-browser user agents (curl, wget) on some pages — a 403 with a browser User-Agent means the page is real and loadable in a browser. A 404 means the URL does not exist. Always fetch docs with a real browser (or browser tool) when scripting is needed.

## Usage

1. Start at https://www.zoho.com/developer/ for product discovery
2. Use apidocs.zoho.com for interactive API testing
3. Use https://help.zoho.com/portal/en/kb/ for product KB, workflows, and configuration
4. Check the app's API doc page for scopes, rate limits, and version
5. Confirm the org's data center (accounts URL) before coding — see main SKILL.md auth section
