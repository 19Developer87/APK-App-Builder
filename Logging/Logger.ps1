function Get-LogColor {
    param([string]$Level)

    if ($script:IsDarkMode) {
        switch ($Level) {
            'SUCCESS' { return $script:DarkColorLogSuccess }
            'WARN'    { return $script:DarkColorLogWarning }
            'ERROR'   { return $script:DarkColorLogError }
            default   { return $script:DarkColorLogInfo }
        }
    } else {
        switch ($Level) {
            'SUCCESS' { return $script:ColorLogSuccess }
            'WARN'    { return $script:ColorLogWarning }
            'ERROR'   { return $script:ColorLogError }
            default   { return $script:ColorLogInfo }
        }
    }
}

function Update-ExportLogButtonState {
    try {
        if (-not $btnExportLog) { return }

        $hasLogContent = $false
        if ($logBox) {
            $hasLogContent = -not [string]::IsNullOrWhiteSpace($logBox.Text)
        }

        $btnExportLog.Enabled = $hasLogContent
    }
    catch {
    }
}

function Write-Log {
    param(
        [string]$Message,
        [string]$Level = 'INFO'
    )

    if (-not $logBox) { return }

    $timestamp = Get-Date -Format 'HH:mm:ss'
    $line = "[$timestamp] $Message"

    $logBox.SelectionStart = $logBox.TextLength
    $logBox.SelectionLength = 0
    $logBox.SelectionColor = Get-LogColor $Level
    $logBox.AppendText($line + [Environment]::NewLine)
    $logBox.SelectionColor = $logBox.ForeColor
    $logBox.ScrollToCaret()

    Update-ExportLogButtonState
}

function Set-ProgressStep {
    param(
        [int]$Percent,
        [string]$Message
    )

    if ($progressBar) {
        $safeValue = [Math]::Max($progressBar.Minimum, [Math]::Min($Percent, $progressBar.Maximum))
        $progressBar.Value = $safeValue
    }

    if ($lblProgress) {
        $lblProgress.Text = $Message
    }
}