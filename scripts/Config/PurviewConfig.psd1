@{
    # =========================================================================
    # Purview Toolkit — minimal config (tenant-settings only)
    #
    # Trimmed to the four foundational tenant-wide flags consumed by
    # Setup-TenantSettings.ps1. Sensitivity-label, DLP, retention, and
    # AI-governance config blocks were removed because no module in this
    # reduced toolkit reads them.
    # =========================================================================

    TenantSettings = @{
        EnableUnifiedAuditLog        = $true
        EnableSensitivityLabelForPDF = $true
        EnableAIPIntegrationInSPO    = $true
        EnableLabelCoAuth            = $true
    }
}
