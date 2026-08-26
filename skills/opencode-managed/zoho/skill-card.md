## Description: <br>
Interact with Zoho CRM, Projects, and Meeting APIs to manage deals, contacts, leads, tasks, projects, milestones, meeting recordings, and Zoho workspace data. <br>

This skill is ready for commercial/non-commercial use. <br>

## Publisher: <br>
[shreefentsar](https://clawhub.ai/user/shreefentsar) <br>

### License/Terms of Use: <br>
MIT <br>


## Use Case: <br>
Developers and business teams use this skill to let an agent query and update Zoho CRM and Projects data, retrieve meeting recordings, and prepare meeting or standup summaries from Zoho Meeting recordings. <br>

### Deployment Geography for Use: <br>
Global <br>

## Known Risks and Mitigations: <br>
Risk: The skill can create, update, or delete CRM and project records. <br>
Mitigation: Use a dedicated least-privilege Zoho OAuth app, request only needed scopes, and require explicit confirmation before write or delete operations. <br>
Risk: Long-lived Zoho refresh tokens and Gemini API keys are required for full operation. <br>
Mitigation: Store credentials in a protected environment, rotate them when access changes, and avoid sharing logs or configuration files that may expose secrets. <br>
Risk: Meeting recordings may be downloaded and sent to Google Gemini for transcription. <br>
Mitigation: Run meeting transcription only with organizational and participant approval, and avoid processing sensitive recordings unless policy permits third-party AI processing. <br>
Risk: The security review notes that the Zoho CLI wrapper should be reviewed or obtained before use. <br>
Mitigation: Install only after confirming the expected CLI wrapper is present, executable, and acceptable for the target environment. <br>


## Reference(s): <br>
- [Zoho CRM API Reference](references/crm-api.md) <br>
- [Zoho Projects API Reference](references/projects-api.md) <br>
- [Zoho Meeting API Reference](references/meeting-api.md) <br>
- [Zoho API Console](https://api-console.zoho.com/) <br>
- [ClawHub skill page](https://clawhub.ai/shreefentsar/skills/zoho) <br>


## Skill Output: <br>
**Output Type(s):** [text, markdown, shell commands, configuration, API calls, JSON] <br>
**Output Format:** [Markdown guidance with shell commands and JSON API responses] <br>
**Output Parameters:** [1D] <br>
**Other Properties Related to Output:** [May produce CRM or project write requests and meeting transcription output when configured with Zoho and Gemini credentials.] <br>

## Skill Version(s): <br>
2.0.2 (source: server release evidence) <br>

## Ethical Considerations: <br>
Users should evaluate whether this skill is appropriate for their environment, review any generated or modified files before relying on them, and apply their organization's safety, security, and compliance requirements before deployment. <br>
