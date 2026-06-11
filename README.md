# Before the Lab

Pre-lab setup guide for the **Data Security Hack**. Walks a Microsoft partner from a fresh Visual Studio Enterprise subscription through a fully prepared Microsoft 365 E5 sandbox tenant, ready to begin the lab exercises.

Companion to the parent guide: [hekuosa/Data-Security-Hack](https://github.com/hekuosa/Data-Security-Hack).

## Reading order

The repo covers two pre-lab paths. Pick the one that matches how you will run the lab:

### Path A — Microsoft 365 Developer Subscription

For partners running the lab on their own Visual Studio–activated E5 sandbox.

| # | Doc | What you'll do | Time |
|---|-----|----------------|------|
| 00 | [Overview](M365-E5-Developer-Subscription/00-overview.md) | Understand the end state and prerequisites | 5 min |
| 01 | [Assign Visual Studio licenses](M365-E5-Developer-Subscription/01-assign-visual-studio-licenses.md) | Activate VS Enterprise benefit in Partner Center | 10 min |
| 02 | [Set up the developer subscription](M365-E5-Developer-Subscription/02-set-up-developer-subscription.md) | Provision the M365 E5 Instant Sandbox | 15–30 min |
| 03 | [Prepare the developer subscription](M365-E5-Developer-Subscription/03-prepare-the-developer-subscription.md) | Edge profile, M365 groups, audit, container labels | 30 min |

### Path B — CDX demo tenant

For partners running the lab on a Microsoft Customer Demo Experience tenant.

| # | Doc | What you'll do |
|---|-----|----------------|
| 01 | [Create a CDX environment](CDX-Environment/docs/01-create-a-cdx-environment.md) | Provision the Microsoft Purview Data Security demo tenant |
| 02 | [Create Edge profiles](CDX-Environment/docs/02-create-edge-profiles.md) | Set up dedicated Edge profiles for admin and lab users |
| 03 | [Prepare the CDX environment](CDX-Environment/docs/03-prepare-the-cdx-environment.md) | HR group, enable audit, modern label scheme |

## Prerequisites

- Microsoft AI Cloud Partner Program membership with available Visual Studio Enterprise subscriptions ([benefit table](M365-E5-Developer-Subscription/01-assign-visual-studio-licenses.md#visual-studio-enterprise-subscriptions-by-program))
- Microsoft Edge browser
- PowerShell 7+ (`pwsh`) for the tenant baseline script
- A tenant admin account on the new sandbox (created in step 02)

## Repository layout

```
M365-E5-Developer-Subscription/    # Path A — M365 Developer subscription
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

CDX-Environment/                   # Path B — CDX demo tenant
├── docs/
│   ├── 01-create-a-cdx-environment.md
│   ├── 02-create-edge-profiles.md
│   └── 03-prepare-the-cdx-environment.md
└── images/

HTML/                              # Static viewer for the markdown docs
└── index.html
```

## License

[MIT](LICENSE)
