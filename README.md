# Before the Lab

Pre-lab setup guide for the **Data Security Hack**. Walks a Microsoft partner from a fresh Visual Studio Enterprise subscription through a fully prepared Microsoft 365 E5 sandbox tenant, ready to begin the lab exercises.

Companion to the parent guide: [hekuosa/Data-Security-Hack](https://github.com/hekuosa/Data-Security-Hack).

## Reading order

| # | Doc | What you'll do | Time |
|---|-----|----------------|------|
| 00 | [Overview](docs/00-overview.md) | Understand the end state and prerequisites | 5 min |
| 01 | [Assign Visual Studio licenses](docs/01-assign-visual-studio-licenses.md) | Activate VS Enterprise benefit in Partner Center | 10 min |
| 02 | [Set up the developer subscription](docs/02-set-up-developer-subscription.md) | Provision the M365 E5 Instant Sandbox | 15–30 min |
| 03 | [Prepare the developer subscription](docs/03-prepare-the-developer-subscription.md) | Edge profile, M365 groups, audit, container labels | 30 min |

## Prerequisites

- Microsoft AI Cloud Partner Program membership with available Visual Studio Enterprise subscriptions ([benefit table](docs/01-assign-visual-studio-licenses.md#visual-studio-enterprise-subscriptions-by-program))
- Microsoft Edge browser
- PowerShell 7+ (`pwsh`) for the tenant baseline script
- A tenant admin account on the new sandbox (created in step 02)

## Repository layout

```
docs/
├── 00-overview.md
├── 01-assign-visual-studio-licenses.md
├── 02-set-up-developer-subscription.md
├── 03-prepare-the-developer-subscription.md
├── images/
└── scripts/                       # PowerShell tenant-baseline toolkit
    ├── README.md
    ├── Deploy-TenantBaseline.ps1
    ├── Config/
    └── Modules/
```

## License

[MIT](LICENSE)
