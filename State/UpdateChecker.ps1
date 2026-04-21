# ---------------- UPDATE CONFIG ----------------
$script:UpdateManifestUrl = 'https://raw.githubusercontent.com/19Developer87/APK-App-Builder/main/version.json'
$script:FallbackUpdateDownloadUrl = 'https://github.com/19Developer87/APK-App-Builder/releases/latest'

if (-not $script:AppVersionNumber) {
    if ($script:AppVersion -and ($script:AppVersion -match '(\d+(\.\d+)+)')) {
        $script:AppVersionNumber = $matches[1]
    } else {
        $script:AppVersionNumber = '1.0'
    }
}

if ($null -eq $script:AutoCheckUpdatesOnStartup) {
    $script:AutoCheckUpdatesOnStartup = $true
}

if ($null -eq $script:HasShownUpdateCheckThisSession) {
    $script:HasShownUpdateCheckThisSession = $false
}

if ($null -eq $script:LatestAvailableVersion) {
    $script:LatestAvailableVersion = ''
}

if ($null -eq $script:LatestAvailableVersionStatus) {
    $script:LatestAvailableVersionStatus = 'Not checked yet'
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

        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

        $response = Invoke-RestMethod -Uri $uri -Method Get -TimeoutSec 15 -Headers @{
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

function Download-UpdateInstaller {
    param(
        [string]$DownloadUrl,
        [string]$LatestVersion
    )

    if ([string]::IsNullOrWhiteSpace($DownloadUrl)) {
        throw 'No download URL was provided.'
    }

    $tempFolder = Join-Path $env:TEMP 'AndroidAppBuilderUpdater'
    if (-not (Test-Path $tempFolder)) {
        New-Item -ItemType Directory -Path $tempFolder -Force | Out-Null
    }

    $safeVersion = ($LatestVersion -replace '[^0-9\.]', '_')
    $installerPath = Join-Path $tempFolder ("AndroidAppBuilderSetup-" + $safeVersion + ".exe")

    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

        Invoke-WebRequest `
            -Uri $DownloadUrl `
            -OutFile $installerPath `
            -UseBasicParsing `
            -Headers @{ "User-Agent" = "AndroidAppBuilderUpdater" } `
            -MaximumRedirection 10 `
            -TimeoutSec 120
    }
    catch {
        throw "Download failed: $($_.Exception.Message)"
    }

    if (-not (Test-Path $installerPath)) {
        throw 'Installer file was not downloaded.'
    }

    $fileInfo = Get-Item $installerPath
    if ($fileInfo.Length -lt 100000) {
        throw 'Downloaded file is too small (likely failed download).'
    }

    return $installerPath
}

function Start-SilentInstallerAfterExit {
    param(
        [string]$InstallerPath
    )

    if ([string]::IsNullOrWhiteSpace($InstallerPath) -or -not (Test-Path $InstallerPath)) {
        throw 'Installer file was not found.'
    }

    $escapedInstallerPath = $InstallerPath.Replace('"', '""')
    $cmdArgs = '/c ping 127.0.0.1 -n 3 > nul && start "" "' + $escapedInstallerPath + '" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART'

    Start-Process -FilePath 'cmd.exe' -ArgumentList $cmdArgs -WindowStyle Hidden
}

function Install-UpdateNow {
    param(
        [string]$DownloadUrl,
        [string]$LatestVersion
    )

    try {
        $installerPath = Download-UpdateInstaller -DownloadUrl $DownloadUrl -LatestVersion $LatestVersion

        $confirm = [System.Windows.Forms.MessageBox]::Show(
            "The update installer has been downloaded.`r`n`r`nThe app will now close and start the update automatically.`r`n`r`nContinue?",
            'Install Update',
            [System.Windows.Forms.MessageBoxButtons]::YesNo,
            [System.Windows.Forms.MessageBoxIcon]::Question
        )

        if ($confirm -ne [System.Windows.Forms.DialogResult]::Yes) {
            return
        }

        Start-SilentInstallerAfterExit -InstallerPath $installerPath

        if ($script:form) {
            [System.Windows.Forms.Application]::Exit()
        } else {
            exit
        }
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show(
            $_.Exception.Message,
            'Install Update Failed',
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null
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
            $script:LatestAvailableVersion = ''
            $script:LatestAvailableVersionStatus = 'Not configured'

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
            $script:LatestAvailableVersion = ''
            $script:LatestAvailableVersionStatus = 'Check failed'

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
        $script:LatestAvailableVersion = $latestVersion

        $isNewer = Test-IsNewerVersion -CurrentVersion $currentVersion -LatestVersion $latestVersion

        if ($isNewer) {
            $script:HasShownUpdateCheckThisSession = $true
            $script:LatestAvailableVersionStatus = $latestVersion

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

            $message += @(
                ""
                "Would you like to download and install it now?"
            )

            $result = [System.Windows.Forms.MessageBox]::Show(
                ($message -join "`r`n"),
                'Update Available',
                [System.Windows.Forms.MessageBoxButtons]::YesNo,
                [System.Windows.Forms.MessageBoxIcon]::Information
            )

            if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
                Install-UpdateNow -DownloadUrl $latestInfo.DownloadUrl -LatestVersion $latestVersion
            }

            return
        }

        $script:LatestAvailableVersionStatus = 'Up to date'

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
        $script:LatestAvailableVersionStatus = 'Check failed'

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