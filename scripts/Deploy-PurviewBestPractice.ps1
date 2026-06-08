#requires -Version 7.0
<#
.SYNOPSIS
    Orchestrator for the Purview tenant-baseline toolkit.

.DESCRIPTION
    One-command entry point that:
      1. Loads tenant-setting toggles from PurviewConfig.psd1.
      2. Signs in to Exchange Online, Security & Compliance (IPPS),
         SharePoint Online, and Microsoft Graph (Beta) via
         Modules/Connect-PurviewServices.ps1.
      3. Applies every tenant setting via Modules/Setup-TenantSettings.ps1.
      4. Prints a deployment summary with elapsed time.

    Idempotent: every setting is read first and skipped if already in the
    desired state. Supports -WhatIf for a dry run.

.PARAMETER TenantAdminUpn
    UPN of the tenant admin used for sign-in (e.g. admin@contoso.onmicrosoft.com).
    Must hold Global Administrator, or the combination Compliance + SharePoint +
    Groups Administrator.

.PARAMETER ConfigPath
    Path to PurviewConfig.psd1. Defaults to .\Config\PurviewConfig.psd1
    (relative to this script).

.PARAMETER SharePointAdminUrl
    Optional override for the SPO admin URL. Auto-derived from the admin UPN
    when omitted (rare — only needed for multi-geo / vanity domains).

.PARAMETER AutoInstallModules
    Install missing PowerShell modules (ExchangeOnlineManagement,
    Microsoft.Online.SharePoint.PowerShell, Microsoft.Graph.*) to CurrentUser
    scope without prompting.

.PARAMETER NonInteractive
    Skip the y/N confirmation prompt before applying changes (CI / unattended).

.EXAMPLE
    .\Deploy-PurviewBestPractice.ps1 `
        -TenantAdminUpn admin@contoso.onmicrosoft.com `
        -AutoInstallModules `
        -WhatIf

    Preview every change without touching the tenant.

.EXAMPLE
    .\Deploy-PurviewBestPractice.ps1 `
        -TenantAdminUpn admin@contoso.onmicrosoft.com `
        -AutoInstallModules

    Apply all settings interactively.
#>
[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'None')]
param(
    [Parameter(Mandatory)]
    [string] $TenantAdminUpn,

    [Parameter()]
    [string] $ConfigPath,

    [Parameter()]
    [string] $SharePointAdminUrl,

    [Parameter()]
    [switch] $AutoInstallModules,

    [Parameter()]
    [switch] $NonInteractive
)

$ErrorActionPreference = 'Stop'
$startedAt = Get-Date

# ---------------------------------------------------------------------------
# PS 7+ guard with actionable install hint (Windows PowerShell 5.1 is not
# supported — several Graph SDK cmdlets and the SPO MSAL path require PS 7).
# ---------------------------------------------------------------------------
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Host ""
    Write-Host "ERROR: This toolkit requires PowerShell 7 or later." -ForegroundColor Red
    Write-Host "       Current session: $($PSVersionTable.PSEdition) $($PSVersionTable.PSVersion)" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "Install PowerShell 7 and re-run from a fresh pwsh window:" -ForegroundColor Yellow
    Write-Host "  winget install --id Microsoft.PowerShell --source winget" -ForegroundColor DarkGray
    Write-Host ""
    exit 1
}

# ---------------------------------------------------------------------------
# Resolve paths
# ---------------------------------------------------------------------------
if (-not $ConfigPath) {
    $ConfigPath = Join-Path $PSScriptRoot 'Config\PurviewConfig.psd1'
}
if (-not (Test-Path -LiteralPath $ConfigPath)) {
    throw "Config file not found: $ConfigPath"
}

$connectScript = Join-Path $PSScriptRoot 'Modules\Connect-PurviewServices.ps1'
$setupScript   = Join-Path $PSScriptRoot 'Modules\Setup-TenantSettings.ps1'
foreach ($p in @($connectScript, $setupScript)) {
    if (-not (Test-Path -LiteralPath $p)) {
        throw "Required module not found: $p"
    }
}

# ---------------------------------------------------------------------------
# Banner
# ---------------------------------------------------------------------------
$bar = ('=' * 78)
Write-Host ""
Write-Host $bar -ForegroundColor Cyan
Write-Host "  Purview Best Practice — tenant baseline deployment" -ForegroundColor Cyan
Write-Host $bar -ForegroundColor Cyan
Write-Host ("  Tenant admin   : {0}" -f $TenantAdminUpn)
Write-Host ("  Config         : {0}" -f $ConfigPath)
Write-Host ("  Mode           : {0}" -f $(if ($WhatIfPreference) { 'DRY RUN (-WhatIf)' } else { 'APPLY' }))
Write-Host $bar -ForegroundColor Cyan
Write-Host ""

# ---------------------------------------------------------------------------
# Load config
# ---------------------------------------------------------------------------
$config = Import-PowerShellDataFile -LiteralPath $ConfigPath
if (-not $config.TenantSettings) {
    throw "Config $ConfigPath is missing the required 'TenantSettings' hashtable."
}

Write-Host "Settings to apply (from config):" -ForegroundColor Cyan
$config.TenantSettings.GetEnumerator() | Sort-Object Name | ForEach-Object {
    $on = if ($_.Value) { 'on ' } else { 'off' }
    Write-Host ("  [{0}] {1}" -f $on, $_.Name) -ForegroundColor DarkGray
}
Write-Host "  [on ] Container labels (Group.Unified EnableMIPLabels)" -ForegroundColor DarkGray
Write-Host ""

# ---------------------------------------------------------------------------
# Confirmation gate (skipped under -WhatIf or -NonInteractive)
# ---------------------------------------------------------------------------
if (-not $WhatIfPreference -and -not $NonInteractive) {
    $answer = Read-Host "Proceed with deployment? [y/N]"
    if ($answer -notmatch '^[yY]') {
        Write-Host "Aborted by user." -ForegroundColor Yellow
        exit 0
    }
}

# ---------------------------------------------------------------------------
# 1. Connect to all services
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "Connecting to Microsoft 365 services..." -ForegroundColor Cyan

# Container-label writes require Directory.ReadWrite.All. Request both the
# default read scope and the write scope up front so we don't need a second
# interactive consent later.
$graphScopes = @('Directory.ReadWrite.All', 'Organization.Read.All')

$connectParams = @{
    TenantAdminUpn  = $TenantAdminUpn
    NeedsSharePoint = $true
    ConnectGraph    = $true
    GraphScopes     = $graphScopes
}
if ($SharePointAdminUrl) { $connectParams.SharePointAdminUrl = $SharePointAdminUrl }
if ($AutoInstallModules) { $connectParams.AutoInstallModules = $true }
if ($NonInteractive)     { $connectParams.NonInteractive     = $true }

$connectResult = $null
try {
    $connectResult = & $connectScript @connectParams
} catch {
    Write-Host ""
    Write-Host "Sign-in failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Carry the SPO admin URL the connect script resolved (for diagnostics only).
if (-not $SharePointAdminUrl -and $connectResult -and $connectResult.SharePointAdminUrl) {
    $SharePointAdminUrl = $connectResult.SharePointAdminUrl
}

# ---------------------------------------------------------------------------
# 2. Apply tenant settings
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "Applying tenant settings..." -ForegroundColor Cyan

$setupParams = @{
    Config                = $config
    EnableContainerLabels = $true
}
if ($NonInteractive) { $setupParams.NonInteractive = $true }

$tenantSettingsStatus = 'OK'
try {
    # Propagate -WhatIf through to the module (SupportsShouldProcess).
    & $setupScript @setupParams -WhatIf:$WhatIfPreference
} catch {
    $tenantSettingsStatus = "FAILED — $($_.Exception.Message)"
    Write-Host ""
    Write-Host "Tenant-settings deploy failed: $($_.Exception.Message)" -ForegroundColor Red
}

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
$elapsed = New-TimeSpan -Start $startedAt -End (Get-Date)
$elapsedFmt = '{0:hh\:mm\:ss}' -f $elapsed

Write-Host ""
Write-Host $bar
Write-Host ("  Deployment summary  (elapsed: {0})" -f $elapsedFmt)
Write-Host $bar
Write-Host ("  Tenant settings        {0}" -f $tenantSettingsStatus)
Write-Host $bar
Write-Host ""

if ($tenantSettingsStatus -ne 'OK') { exit 1 }
