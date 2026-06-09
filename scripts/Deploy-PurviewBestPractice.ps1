# =============================================================================
# DISCLAIMER
# =============================================================================
# This sample script is not supported under any Microsoft standard support
# program or service. The sample script is provided AS IS without warranty of
# any kind. Microsoft further disclaims all implied warranties including,
# without limitation, any implied warranties of merchantability or of fitness
# for a particular purpose. The entire risk arising out of the use or
# performance of the sample scripts and documentation remains with you. In no
# event shall Microsoft, its authors, or anyone else involved in the creation,
# production, or delivery of the scripts be liable for any damages whatsoever
# (including, without limitation, damages for loss of business profits,
# business interruption, loss of business information, or other pecuniary
# loss) arising out of the use of or inability to use the sample scripts or
# documentation, even if Microsoft has been advised of the possibility of
# such damages.
# =============================================================================

<#
.SYNOPSIS
    Deploys foundational Microsoft Purview tenant settings.

.DESCRIPTION
    Reduced orchestrator that only runs:
      1. Connect-PurviewServices.ps1   - sign in to EXO + IPPS + (optional) SPO
      2. Setup-TenantSettings.ps1      - audit log, AIP/SPO, PDF labels, label co-auth

    Sensitivity labels, DLP, retention, and AI-governance modules have been
    removed from this build.

.PARAMETER TenantAdminUpn
    UPN of the tenant administrator used for sign-in.

.PARAMETER SharePointAdminUrl
    Optional override for the SharePoint admin centre URL. When omitted, the
    URL is auto-derived from the tenant admin UPN suffix or the EXO accepted
    domain after Exchange Online is connected.

.PARAMETER ConfigPath
    Path to PurviewConfig.psd1. Defaults to .\Config\PurviewConfig.psd1.

.PARAMETER NonInteractive
    Skip the preflight confirmation prompt.

.PARAMETER AutoInstallModules
    Auto-install missing PowerShell modules (CurrentUser scope) without prompting.

.NOTES
    Every feature runs unconditionally:
      * Unified Audit Log
      * SharePoint AIP integration
      * SharePoint PDF sensitivity labels
      * Office label co-authoring
      * Container labels (Group.Unified EnableMIPLabels) - requires E5 / Purview Suite
                                                          and Microsoft Graph (Beta) connection.

.EXAMPLE
    .\Deploy-PurviewBestPractice.ps1 -TenantAdminUpn admin@contoso.onmicrosoft.com

.EXAMPLE
    .\Deploy-PurviewBestPractice.ps1 -TenantAdminUpn admin@contoso.onmicrosoft.com -WhatIf
#>
[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'None')]
param(
    [Parameter(Mandatory)]
    [string] $TenantAdminUpn,

    [Parameter()]
    [string] $SharePointAdminUrl,

    [Parameter()]
    [string] $ConfigPath,

    [Parameter()]
    [switch] $NonInteractive,

    [Parameter()]
    [switch] $AutoInstallModules
)

$ErrorActionPreference = 'Stop'
$ConfirmPreference     = 'None'

$script:DeployVersion = '0.5.0-tenant-only'
$script:StartTime     = Get-Date

# ---------------------------------------------------------------------------
# PowerShell version gate
# ---------------------------------------------------------------------------
if ($PSVersionTable.PSVersion.Major -lt 7) {
    $edition = if ($PSVersionTable.PSEdition) { $PSVersionTable.PSEdition } else { 'Desktop' }
    throw @"
This toolkit requires PowerShell 7 or later (PowerShell Core / pwsh.exe).
You are running: PowerShell $($PSVersionTable.PSVersion) (Edition: $edition).

Install PowerShell 7:  winget install --id Microsoft.PowerShell --source winget
                  or:  https://aka.ms/PowerShell-Release
Then re-run this script from a `pwsh` prompt (not `powershell`).
"@
}

# ---------------------------------------------------------------------------
# Locate config & modules relative to this script
# ---------------------------------------------------------------------------
$scriptRoot = Split-Path -Parent $PSCommandPath
if (-not $ConfigPath) {
    $ConfigPath = Join-Path $scriptRoot 'Config\PurviewConfig.psd1'
}
if (-not (Test-Path $ConfigPath)) {
    throw "Config file not found: $ConfigPath"
}
$config = Import-PowerShellDataFile -Path $ConfigPath

$moduleRoot     = Join-Path $scriptRoot 'Modules'
$connectScript  = Join-Path $moduleRoot 'Connect-PurviewServices.ps1'
$tenantScript   = Join-Path $moduleRoot 'Setup-TenantSettings.ps1'

foreach ($s in @($connectScript, $tenantScript)) {
    if (-not (Test-Path $s)) { throw "Required module script not found: $s" }
}

# ---------------------------------------------------------------------------
# Preflight summary
# ---------------------------------------------------------------------------
$bannerSpoUrl  = if ($SharePointAdminUrl) { $SharePointAdminUrl } else { '(auto-derive from tenant)' }
$bannerMode    = if ($WhatIfPreference) { 'WHAT-IF (preview only - no changes)' } else { 'APPLY (changes will be made)' }

$banner = @"

==============================================================================
  Microsoft Purview - Tenant Settings Deployment
==============================================================================
  Tenant admin UPN     : $TenantAdminUpn
  SharePoint admin URL : $bannerSpoUrl
  Config file          : $ConfigPath

  Features applied (all unconditional):
    [X] Unified Audit Log
    [X] SharePoint AIP integration
    [X] SharePoint PDF sensitivity labels
    [X] Office label co-authoring
    [X] Container labels (Group.Unified EnableMIPLabels)  - requires E5 / Purview Suite

  Mode: $bannerMode
==============================================================================

"@

Write-Host $banner -ForegroundColor Cyan

if (-not $WhatIfPreference -and -not $NonInteractive) {
    $confirmation = Read-Host "Proceed with deployment? [y/N]"
    if ($confirmation -notmatch '^[yY]') {
        Write-Host "Deployment cancelled." -ForegroundColor Yellow
        return
    }
}

# ---------------------------------------------------------------------------
# Connect
# ---------------------------------------------------------------------------
Write-Host "`n--- Connecting to services ---" -ForegroundColor White
$connectArgs = @{
    TenantAdminUpn  = $TenantAdminUpn
    NeedsSharePoint = $true
    ConnectGraph    = $true
    GraphScopes     = @('Organization.Read.All','Directory.ReadWrite.All')
}
if ($SharePointAdminUrl)   { $connectArgs['SharePointAdminUrl']   = $SharePointAdminUrl }
if ($AutoInstallModules)   { $connectArgs['AutoInstallModules']   = $true }
if ($NonInteractive)       { $connectArgs['NonInteractive']       = $true }
$connectionInfo = & $connectScript @connectArgs
if ($connectionInfo -and $connectionInfo.SharePointAdminUrl) {
    $SharePointAdminUrl = $connectionInfo.SharePointAdminUrl
}

# ---------------------------------------------------------------------------
# Run task: Tenant settings
# ---------------------------------------------------------------------------
$summary = [ordered]@{}
try {
    Write-Host "`n--- Tenant settings ---" -ForegroundColor White
    $taskArgs = @{
        Config                = $config
        EnableContainerLabels = $true
    }
    if ($NonInteractive)        { $taskArgs['NonInteractive']        = $true }
    try {
        & $tenantScript @taskArgs
        $summary['Tenant settings'] = 'OK'
    } catch {
        $summary['Tenant settings'] = "FAILED: $($_.Exception.Message)"
        Write-Error $_
    }
} finally {
    # ---------------------------------------------------------------------------
    # Summary (always runs - even if a task threw a terminating error above).
    # ---------------------------------------------------------------------------
    $endTime = Get-Date
    $elapsed = ($endTime - $script:StartTime).ToString('hh\:mm\:ss')
    Write-Host "`n==============================================================================" -ForegroundColor Cyan
    Write-Host "  Deployment summary  (elapsed: $elapsed)" -ForegroundColor Cyan
    Write-Host "==============================================================================" -ForegroundColor Cyan
    if ($summary.Count -eq 0) {
        Write-Host "  (No tasks recorded - run aborted before any step started.)" -ForegroundColor DarkYellow
    } else {
        $summary.GetEnumerator() | ForEach-Object {
            $color = switch -Wildcard ($_.Value) {
                'OK'        { 'Green' }
                'Skipped*'  { 'DarkGray' }
                'FAILED:*'  { 'Red' }
                default     { 'White' }
            }
            Write-Host ("  {0,-22} {1}" -f $_.Key, $_.Value) -ForegroundColor $color
        }
    }
    Write-Host "==============================================================================" -ForegroundColor Cyan
    Write-Host "`nReminder: tenant-setting changes can take a few minutes to propagate." -ForegroundColor DarkYellow
}
