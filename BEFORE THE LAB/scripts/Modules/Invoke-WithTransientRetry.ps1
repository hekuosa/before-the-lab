# Minimal shim for Setup-TenantSettings.ps1 standalone use.
# Real toolkit version does exponential-backoff retries on transient 429/503/timeouts.
# This shim runs the action once and surfaces any error.

function Invoke-WithTransientRetry {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string] $Description,
        [Parameter(Mandatory)] [scriptblock] $Action,
        [switch] $AlreadyExistsIsSuccess
    )
    try {
        & $Action
    } catch {
        if ($AlreadyExistsIsSuccess -and ($_.Exception.Message -match 'already exists|DSAlreadyExist')) {
            Write-Verbose "$Description : already exists, treating as success."
            return
        }
        throw
    }
}

function Test-TransientServerError {
    param($ErrorRecord)
    return $false
}

function Add-RunLogEntry {
    [CmdletBinding()]
    param(
        [string] $Module,
        [string] $Action,
        [string] $Target,
        [string] $Status,
        [string] $Detail
    )
    Write-Verbose ("[{0}] {1} -> {2} : {3} ({4})" -f $Module, $Action, $Target, $Status, $Detail)
}
