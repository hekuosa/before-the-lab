# Tenant baseline scripts

PowerShell toolkit that configures the foundational Microsoft Purview and tenant settings required by the Data Security Hack lab.

Run from step [03 — Prepare the developer subscription](../03-prepare-the-developer-subscription.md#option-2--powershell-orchestrator-recommended).

## Files

| Path | Purpose |
|------|---------|
| `Deploy-TenantBaseline.ps1` | Orchestrator. Loads modules, signs in to EXO/IPPS/SPO/Graph, applies all baseline settings idempotently. Supports `-WhatIf`. |
| `Config/PurviewConfig.psd1` | Static configuration values consumed by the orchestrator (e.g., feature toggles, retry policy). |
| `Modules/Connect-PurviewServices.ps1` | Handles interactive sign-in and module loading for Exchange Online, Security & Compliance (IPPS), SharePoint Online, and Microsoft Graph. |
| `Modules/Setup-TenantSettings.ps1` | Applies the actual tenant settings: Unified Audit Log, `EnableAIPIntegration`, `EnableLabelCoauth`, `Group.Unified` `EnableMIPLabels`. |
| `Modules/Invoke-WithTransientRetry.ps1` | Helper that retries transient failures (throttling, network blips) with exponential backoff. |

## Quick start

```powershell
cd <repo-root>\docs\scripts
.\Deploy-TenantBaseline.ps1 -TenantAdminUpn admin@<yourtenant>.onmicrosoft.com -AutoInstallModules -WhatIf
```

Re-run without `-WhatIf` to apply. Requires **PowerShell 7+** and a tenant admin account.

See [03 — Prepare the developer subscription](../03-prepare-the-developer-subscription.md) for full prerequisites, expected output, and what each step does.
