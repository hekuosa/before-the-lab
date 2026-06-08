# Before the Lab

Word version of the **Before the Lab** guide from the Data Security Hack, with the PowerShell tenant-baseline toolkit it references.

## Contents

- `01-before-the-lab.docx` — the lab pre-work guide (Word).
- `scripts/` — Purview tenant-baseline toolkit.
  - `Deploy-PurviewBestPractice.ps1` — orchestrator (entry point).
  - `Config/PurviewConfig.psd1` — tenant-setting toggles.
  - `Modules/Connect-PurviewServices.ps1` — EXO + IPPS + SPO + Graph (Beta) sign-in.
  - `Modules/Setup-TenantSettings.ps1` — idempotent Set-* helpers.
  - `Modules/Invoke-WithTransientRetry.ps1` — shared retry helper.

## Usage

```powershell
cd scripts
.\Deploy-PurviewBestPractice.ps1
```

See `01-before-the-lab.docx` for parameters and prerequisites.
