# Local Binaries

These are platform-specific executables from the source Windows machine:

| Binary | Source | Linux/macOS alternative |
|--------|--------|-------------------------|
| codebase-memory-mcp.exe (273 MB) | `C:/Users/PilzIndia/.local/bin/codebase-memory-mcp.exe` | Build from source or `cargo install` if available, or download appropriate binary |
| graphify.exe / graphify-mcp.exe (46 KB) | `C:/Users/PilzIndia/.local/bin/` | Same - platform specific |
| officecli.exe (33 MB) | `C:/Users/PilzIndia/bin/officecli.exe` | Download from officecli releases |
| specify.exe | `C:/Users/PilzIndia/.local/bin/` | npm package |
| nano-pdf.exe |  | npm package |

The installer scripts will attempt to re-download / rebuild these. If a binary is missing, the related MCP server will be disabled until you install it.

For codebase-memory-mcp: https://github.com/... (update with actual repo if known)
For graphify: https://github.com/... 
For officecli: https://github.com/.../officecli

On new system, check `config/opencode.json` -> `mcp.codebase-memory-mcp.command` and update path.
