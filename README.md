# Power Platform CLI App Bootstrap (Canvas + Model-driven)

Status: Microsoft Learn access is rate-limited (HTTP 429). The steps below are based on live CLI help output from `pac` 1.52.1. I will retry Learn and update this file when access is restored.

## Target environment
- User: James@solanit.com
- URL: https://orgfe8637fb.crm11.dynamics.com

## Goal
Create a solution-based app package that includes:
- Dataverse tables for coffee tasting notes
- A model-driven admin app
- A canvas app for tasters
- Environment variables + connection references
- CLI-first ALM workflow (pack/import/export/check)

## Quick start (CLI)
1) Authenticate and select environment
   - Run scripts/01-auth.ps1
2) Initialize a solution project
   - Run scripts/02-solution-init.ps1
3) Import the empty solution to Dataverse
   - Run scripts/03-import-solution.ps1
4) Create the Dataverse tables + both apps in Maker portal
   - Use scripts/00-open-maker.ps1 (optional)
5) Export and unpack for source control
   - Run scripts/04-export-solution.ps1
6) (Optional) Download/Unpack the canvas app sources
   - Run scripts/05-canvas-source.ps1

## Best-practice notes
- Keep both apps inside the same solution for ALM.
- Use environment variables for anything environment-specific (URLs, queue IDs, etc.).
- Use connection references for connectors.
- Run solution checker before export for release.

## Theme
- Primary color: #ff6f00
- Use for header, buttons, and accent elements in the canvas app.

## CLI MCP server (Copilot MCP)
- `pac copilot mcp --run` starts the local MCP server.
- Use this when integrating VS Code copilot workflows with Dataverse copilots.

## Docs to verify (pending Learn access)
- Power Platform CLI overview
- Canvas app pack/unpack
- Solution project pack/import/export

See docs/APP_IDEA.md and docs/PLAN.md for the detailed plan.
