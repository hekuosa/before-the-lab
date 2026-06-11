# Before the Lab

Pre-lab setup guide for the **Data Security Hack To Build** — getting a Microsoft 365 tenant ready for the lab exercises.

Browse online: <https://hekuosa.github.io/before-the-lab/HTML/>

## Contents

The repo covers two pre-lab paths. Pick the one that matches how you will run the lab.

### Path A — Microsoft 365 Developer Subscription *(preferred)*

For partners running the lab on their own Visual Studio–activated E5 sandbox.

- [00 – Overview](1-M365DevSub/docs/00-overview.md)
- [01 – Assign Visual Studio licenses](1-M365DevSub/docs/01-assign-visual-studio-licenses.md)
- [02 – Set up the developer subscription](1-M365DevSub/docs/02-set-up-developer-subscription.md)
- [03 – Prepare the developer subscription](1-M365DevSub/docs/03-prepare-the-developer-subscription.md)

### Path B — CDX demo tenant

For partners running the lab on a Microsoft Customer Demo Experience tenant.

- [01 – Create a CDX environment](2-CDXEnv/docs/01-create-a-cdx-environment.md)
- [02 – Create Edge profiles](2-CDXEnv/docs/02-create-edge-profiles.md)
- [03 – Prepare the CDX environment](2-CDXEnv/docs/03-prepare-the-cdx-environment.md)

## Tenant-baseline scripts

PowerShell toolkit that applies the Path A tenant settings (audit, sensitivity-label support, container labels) idempotently. See [`1-M365DevSub/scripts/`](1-M365DevSub/scripts/).

## Source

Companion to the main lab guide: [hekuosa/DSH-lab-guide](https://github.com/hekuosa/DSH-lab-guide).
