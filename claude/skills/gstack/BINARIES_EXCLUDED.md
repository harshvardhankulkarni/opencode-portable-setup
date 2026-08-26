# gstack binaries — excluded for repo size

This folder's large built artifacts were excluded to keep the repo < 100 MB:

- make-pdf/dist/*.exe (~ 100 MB)
- design/dist/*.exe (~ 100 MB)
- browse/dist/*.exe + find-browse.exe (~ 100 MB)
- bin/gstack-global-discover.exe
- lib/diagram-render/dist/diagram-render.html (~40 MB)
- browse/test/fixtures/security-bench-haiku-responses.json (~100 MB)
- scripts/app/icon.icns
- .git/ and node_modules/

They are rebuilt on install via:

```bash
cd ~/.claude/skills/gstack
npm install   # or bun install
npm run build
# or: claude plugin update
```

The installer handles this if gstack is present.
