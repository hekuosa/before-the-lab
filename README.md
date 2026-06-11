# Before the Lab

Pre-lab setup guide for the **Data Security Hack To Build**.

## Reading order

The repo covers two pre-lab paths. Pick the one that matches how you will run the lab:
- **Path A — Microsoft 365 Developer Subscription** (preferred)
- **Path B — CDX demo tenant***

### Path A — Microsoft 365 Developer Subscription

For partners running the lab on their own Visual Studio–activated E5 sandbox.

| # | Doc | What you'll do | Time |
|---|-----|----------------|------|
| 00 | [Overview](M365-E5-Developer-Subscription/docs/00-overview.md) | Understand the end state and prerequisites | 5 min |
| 01 | [Assign Visual Studio licenses](M365-E5-Developer-Subscription/docs/01-assign-visual-studio-licenses.md) | Activate VS Enterprise benefit in Partner Center | 10 min |
| 02 | [Set up the developer subscription](M365-E5-Developer-Subscription/docs/02-set-up-developer-subscription.md) | Provision the M365 E5 Instant Sandbox | 15–30 min |
| 03 | [Prepare the developer subscription](M365-E5-Developer-Subscription/docs/03-prepare-the-developer-subscription.md) | Edge profile, M365 groups, audit, container labels | 30 min |

### Path B — CDX demo tenant

For partners running the lab on a Microsoft Customer Demo Experience tenant.

| # | Doc | What you'll do |
|---|-----|----------------|
| 01 | [Create a CDX environment](CDX-Environment/docs/01-create-a-cdx-environment.md) | Provision the Microsoft Purview Data Security demo tenant |
| 02 | [Create Edge profiles](CDX-Environment/docs/02-create-edge-profiles.md) | Set up dedicated Edge profiles for admin and lab users |
| 03 | [Prepare the CDX environment](CDX-Environment/docs/03-prepare-the-cdx-environment.md) | HR group, enable audit, modern label scheme |


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
