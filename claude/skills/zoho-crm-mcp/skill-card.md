## Description: <br>
Connects an agent to Zoho CRM through MCP so it can search contacts, list accounts, query records with COQL, and use helper scripts for common CRM operations. <br>

This skill is ready for commercial/non-commercial use. <br>

## Publisher: <br>
[sprintcx](https://clawhub.ai/user/sprintcx) <br>

### License/Terms of Use: <br>
MIT-0 <br>


## Use Case: <br>
Employees, external users, and developers use this skill to let an agent read and query Zoho CRM data through a configured Zoho MCP endpoint. It is most useful for contact lookup, account listing, generic CRM module search, and COQL-based record queries. <br>

### Deployment Geography for Use: <br>
Global <br>

## Known Risks and Mitigations: <br>
Risk: The skill connects an agent to a user-provided Zoho CRM MCP endpoint and can expose sensitive CRM data if scopes are too broad. <br>
Mitigation: Install only when CRM access is intended, start with read-only OAuth scopes, and grant only the modules and actions the agent needs. <br>
Risk: ZOHO_MCP_URL contains credential-bearing access to the CRM endpoint. <br>
Mitigation: Treat ZOHO_MCP_URL like a password and prefer per-session secret injection over storing it permanently in a shell profile. <br>
Risk: Optional write and delete CRM actions can modify or remove records if enabled unnecessarily. <br>
Mitigation: Enable create, update, upsert, and note actions only for workflows that require them, and avoid delete actions unless specifically needed. <br>


## Reference(s): <br>
- [ClawHub skill page](https://clawhub.ai/sprintcx/skills/zoho-crm-mcp) <br>
- [Zoho MCP portal](https://mcp.zoho.eu) <br>


## Skill Output: <br>
**Output Type(s):** [text, markdown, code, shell commands, configuration, guidance] <br>
**Output Format:** [Markdown guidance with shell commands and Python helper scripts; helper script output can be tables or JSON.] <br>
**Output Parameters:** [1D] <br>
**Other Properties Related to Output:** [Requires a user-provided ZOHO_MCP_URL and an installed mcporter CLI.] <br>

## Skill Version(s): <br>
1.4.1 (source: server release evidence) <br>

## Ethical Considerations: <br>
Users should evaluate whether this skill is appropriate for their environment, review any generated or modified files before relying on them, and apply their organization's safety, security, and compliance requirements before deployment. <br>
