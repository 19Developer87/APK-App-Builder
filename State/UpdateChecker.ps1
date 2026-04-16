# ---------------- UPDATE CONFIG ----------------
# Set these to your real GitHub raw/version URL and release/download page when ready.
# Example manifest URL:
# https://raw.githubusercontent.com/<YOUR-USER>/<YOUR-REPO>/main/version.json
#
# Example version.json:
# {
#   "version": "1.1",
#   "downloadUrl": "https://github.com/<YOUR-USER>/<YOUR-REPO>/releases/latest",
#   "notes": "Bug fixes and installer improvements."
# }

if (-not $script:AppVersionNumber) {
    if ($script:AppVersion -and ($script:AppVersion -match '(\d+(\.\d+)+)')) {
        $script:AppVersionNumber = $matches[1]
    } else {
        $script:AppVersionNumber = '1.0'
    }
}

if ($null -eq $script:UpdateManifestUrl) {
    $script:UpdateManifestUrl = ''
}

if ($null -eq $script:FallbackUpdateDownloadUrl) {
    $script:FallbackUpdateDownloadUrl = ''
}

if ($null -eq $script:AutoCheckUpdatesOnStartup) {
    $script:AutoCheckUpdatesOnStartup = $true
}

if ($null -eq $script:HasShownUpdateCheckThisSession) {
    $script:HasShownUpdateCheckThisSession = $false
}

function Get-NormalizedVersionNumber {
    param([string]$Value)

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return '0.0.0'
    }

    $trimmed = $Value.Trim()

    if ($trimmed -match '(\d+(\.\d+)+)') {
        return $matches[1]
    }

    if ($trimmed -match '^\d+$') {
        return ($trimmed + '.0')
    }

    return '0.0.0'
}

function Test-IsNewerVersion {
    param(
        [string]$CurrentVersion,
        [string]$LatestVersion
    )

    try {
        $current = [Version](Get-NormalizedVersionNumber $CurrentVersion)
        $latest = [Version](Get-NormalizedVersionNumber $LatestVersion)
        return ($latest -gt $current)
    }
    catch {
        return $false
    }
}

function Get-LatestVersionInfo {
    $result = [ordered]@{
        IsConfigured = $false
        Success      = $false
        Version      = ''
        DownloadUrl  = ''
        Notes        = ''
        ErrorMessage = ''
    }

    try {
        $uri = [string]$script:UpdateManifestUrl
        if ([string]::IsNullOrWhiteSpace($uri)) {
            return [pscustomobject]$result
        }

        $result.IsConfigured = $true

        $response = Invoke-RestMethod -Uri $uri -Method Get -TimeoutSec 10 -Headers @{
            'Cache-Control' = 'no-cache'
            'Pragma'        = 'no-cache'
        }

        if ($response -is [string]) {
            $result.Version = (Get-NormalizedVersionNumber $response)
            $result.DownloadUrl = [string]$script:FallbackUpdateDownloadUrl
            $result.Success = -not [string]::IsNullOrWhiteSpace($result.Version)
            return [pscustomobject]$result
        }

        if ($response.PSObject.Properties.Name -contains 'version') {
            $result.Version = (Get-NormalizedVersionNumber ([string]$response.version))
        }

        if ($response.PSObject.Properties.Name -contains 'downloadUrl') {
            $result.DownloadUrl = [string]$response.downloadUrl
        }

        if ($response.PSObject.Properties.Name -contains 'notes') {
            $result.Notes = [string]$response.notes
        }

        if ([string]::IsNullOrWhiteSpace($result.DownloadUrl)) {
            $result.DownloadUrl = [string]$script:FallbackUpdateDownloadUrl
        }

        $result.Success = -not [string]::IsNullOrWhiteSpace($result.Version)
        return [pscustomobject]$result
    }
    catch {
        $result.ErrorMessage = $_.Exception.Message
        return [pscustomobject]$result
    }
}

function Open-UpdateDownloadPage {
    param([string]$Url)

    if ([string]::IsNullOrWhiteSpace($Url)) {
        return
    }

    try {
        Start-Process $Url
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show(
            $_.Exception.Message,
            'Open Update Page Failed',
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null
    }
}

function Invoke-CheckForUpdates {
    param(
        [bool]$Interactive = $true,
        [bool]$OnlyNotifyIfUpdateAvailable = $false
    )

    try {
        if (-not $Interactive -and $script:HasShownUpdateCheckThisSession) {
            return
        }

        $currentVersion = Get-NormalizedVersionNumber $script:AppVersionNumber
        $latestInfo = Get-LatestVersionInfo

        if (-not $latestInfo.IsConfigured) {
            if ($Interactive) {
                [System.Windows.Forms.MessageBox]::Show(
                    "Update checking is not configured yet.`r`n`r`nSet `\$script:UpdateManifestUrl in State\UpdateChecker.ps1 to your GitHub-hosted version.json file.",
                    'Check for Updates',
                    [System.Windows.Forms.MessageBoxButtons]::OK,
                    [System.Windows.Forms.MessageBoxIcon]::Information
                ) | Out-Null
            }
            return
        }

        if (-not $latestInfo.Success) {
            if ($Interactive) {
                $message = "Could not check for updates."
                if (-not [string]::IsNullOrWhiteSpace($latestInfo.ErrorMessage)) {
                    $message += "`r`n`r`n" + $latestInfo.ErrorMessage
                }

                [System.Windows.Forms.MessageBox]::Show(
                    $message,
                    'Check for Updates',
                    [System.Windows.Forms.MessageBoxButtons]::OK,
                    [System.Windows.Forms.MessageBoxIcon]::Warning
                ) | Out-Null
            }
            return
        }

        $latestVersion = Get-NormalizedVersionNumber $latestInfo.Version
        $isNewer = Test-IsNewerVersion -CurrentVersion $currentVersion -LatestVersion $latestVersion

        if ($isNewer) {
            $script:HasShownUpdateCheckThisSession = $true

            $message = @(
                "A newer version is available."
                ""
                "Current version: $currentVersion"
                "Latest version: $latestVersion"
            )

            if (-not [string]::IsNullOrWhiteSpace($latestInfo.Notes)) {
                $message += @(
                    ""
                    "What's new:"
                    $latestInfo.Notes
                )
            }

            if (-not [string]::IsNullOrWhiteSpace($latestInfo.DownloadUrl)) {
                $message += @(
                    ""
                    "Open the download page now?"
                )

                $result = [System.Windows.Forms.MessageBox]::Show(
                    ($message -join "`r`n"),
                    'Update Available',
                    [System.Windows.Forms.MessageBoxButtons]::YesNo,
                    [System.Windows.Forms.MessageBoxIcon]::Information
                )

                if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
                    Open-UpdateDownloadPage -Url $latestInfo.DownloadUrl
                }
            }
            elseif ($Interactive -or -not $OnlyNotifyIfUpdateAvailable) {
                [System.Windows.Forms.MessageBox]::Show(
                    ($message -join "`r`n"),
                    'Update Available',
                    [System.Windows.Forms.MessageBoxButtons]::OK,
                    [System.Windows.Forms.MessageBoxIcon]::Information
                ) | Out-Null
            }

            return
        }

        if ($Interactive -and -not $OnlyNotifyIfUpdateAvailable) {
            [System.Windows.Forms.MessageBox]::Show(
                "You are up to date.`r`n`r`nCurrent version: $currentVersion",
                'Check for Updates',
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Information
            ) | Out-Null
        }
    }
    catch {
        if ($Interactive) {
            [System.Windows.Forms.MessageBox]::Show(
                $_.Exception.Message,
                'Check for Updates Failed',
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Error
            ) | Out-Null
        }
    }
}