# Plan (CLI-first ALM)

1) Authenticate using PAC CLI.
2) Initialize a solution project locally.
3) Import the solution to Dataverse.
4) Create coffee tables + model-driven admin app + canvas taster app in the Maker portal (inside the solution).
5) Export and unpack the solution to source control.
6) (Optional) Download/unpack the canvas app sources for diff-friendly changes.
7) Run solution checker before release.

## Missing items to confirm
- Publisher name and prefix for solution
- Solution unique name
- App names (canvas + model-driven)
- Whether you want to add flows or only apps

## Permissions checklist
- Power Platform environment maker or system customizer
- Dataverse create/update table permissions
- App creation rights
- If using Copilot MCP: local port access + sign-in to Dataverse
