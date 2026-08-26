# Skills Inventory

## Opencode Managed (in opencode/skills as real dirs)
- clonedeps, codemap, deepwork, graphify, oh-my-opencode-slim, rag-pipelines, reflect, simplify, verification-planning, worktrees, zoho, zoho-api, zoho-creator, zoho-crm-mcp (14)

These are managed via `oh-my-opencode-slim` plugin (skills-manifest.json). On new machine they are restored by the plugin automatically. A full copy is in `opencode-managed/` for offline restore.

## External Skills via .agents/skills (91)
These live in `~/.agents/skills` and are symlinked into `~/.config/opencode/skills/` for 33 firecrawl-* skills. Full copy in `external-full/`.

| Count | Source |
|-------|--------|
| 91 | `~/.agents/skills` (mattpocock/skills + huggingface/skills + vercel/* + firecrawl/* + custom) |

## Symlink Map (opencode/skills -> .agents/skills)

- firecrawl -> ../../../.agents/skills/firecrawl
- firecrawl-agent -> ../../../.agents/skills/firecrawl-agent
- firecrawl-build -> ../../../.agents/skills/firecrawl-build
- firecrawl-build-interact -> ../../../.agents/skills/firecrawl-build-interact
- firecrawl-build-onboarding -> ../../../.agents/skills/firecrawl-build-onboarding
- firecrawl-build-scrape -> ../../../.agents/skills/firecrawl-build-scrape
- firecrawl-build-search -> ../../../.agents/skills/firecrawl-build-search
- firecrawl-company-directories -> ../../../.agents/skills/firecrawl-company-directories
- firecrawl-competitive-intel -> ../../../.agents/skills/firecrawl-competitive-intel
- firecrawl-crawl -> ../../../.agents/skills/firecrawl-crawl
- firecrawl-dashboard-reporting -> ../../../.agents/skills/firecrawl-dashboard-reporting
- firecrawl-deep-research -> ../../../.agents/skills/firecrawl-deep-research
- firecrawl-demo-walkthrough -> ../../../.agents/skills/firecrawl-demo-walkthrough
- firecrawl-developer-index -> ../../../.agents/skills/firecrawl-developer-index
- firecrawl-download -> ../../../.agents/skills/firecrawl-download
- firecrawl-interact -> ../../../.agents/skills/firecrawl-interact
- firecrawl-knowledge-base -> ../../../.agents/skills/firecrawl-knowledge-base
- firecrawl-knowledge-ingest -> ../../../.agents/skills/firecrawl-knowledge-ingest
- firecrawl-lead-gen -> ../../../.agents/skills/firecrawl-lead-gen
- firecrawl-lead-research -> ../../../.agents/skills/firecrawl-lead-research
- firecrawl-map -> ../../../.agents/skills/firecrawl-map
- firecrawl-market-research -> ../../../.agents/skills/firecrawl-market-research
- firecrawl-monitor -> ../../../.agents/skills/firecrawl-monitor
- firecrawl-parse -> ../../../.agents/skills/firecrawl-parse
- firecrawl-qa -> ../../../.agents/skills/firecrawl-qa
- firecrawl-research-index -> ../../../.agents/skills/firecrawl-research-index
- firecrawl-research-papers -> ../../../.agents/skills/firecrawl-research-papers
- firecrawl-scrape -> ../../../.agents/skills/firecrawl-scrape
- firecrawl-search -> ../../../.agents/skills/firecrawl-search
- firecrawl-seo-audit -> ../../../.agents/skills/firecrawl-seo-audit
- firecrawl-shop -> ../../../.agents/skills/firecrawl-shop
- firecrawl-website-design-clone -> ../../../.agents/skills/firecrawl-website-design-clone
- firecrawl-workflows -> ../../../.agents/skills/firecrawl-workflows
