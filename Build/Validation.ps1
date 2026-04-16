function Test-AppIdFormat {
    param(
        [string]$AppId
    )

    if ([string]::IsNullOrWhiteSpace($AppId)) {
        return $false
    }

    $appId = $AppId.Trim().ToLower()

    if (-not $appId.StartsWith('com.')) {
        return $false
    }

    $dotCount = ($appId.ToCharArray() | Where-Object { $_ -eq '.' }).Count
    if ($dotCount -ne 2) {
        return $false
    }

    $parts = $appId.Split('.')
    if ($parts.Count -ne 3) {
        return $false
    }

    if ($parts[0] -ne 'com') {
        return $false
    }

    if ($parts[1] -notmatch '^[a-z][a-z0-9]*$') {
        return $false
    }

    if ($parts[2] -notmatch '^[a-z][a-z0-9]*$') {
        return $false
    }

    return $true
}

function Get-ValidationColor {
    param([string]$Level)

    if ($script:IsDarkMode) {
        switch ($Level) {
            'GOOD' { return $script:DarkColorLogSuccess }
            'WARN' { return $script:DarkColorLogWarning }
            'BAD'  { return $script:DarkColorLogError }
            default { return $script:DarkColorMutedText }
        }
    } else {
        switch ($Level) {
            'GOOD' { return $script:ColorLogSuccess }
            'WARN' { return $script:ColorLogWarning }
            'BAD'  { return $script:ColorLogError }
            default { return $script:ColorMutedText }
        }
    }
}

function Set-ValidationLabelState {
    param(
        [object]$Label,
        [string]$Text,
        [string]$Level
    )

    if (-not $Label) { return }

    try {
        $Label.Text = $Text
        $Label.ForeColor = Get-ValidationColor $Level
        $Label.BackColor = [System.Drawing.Color]::Transparent
    }
    catch {
    }
}

function Test-JavaHomePath {
    param([string]$PathValue)

    if ([string]::IsNullOrWhiteSpace($PathValue)) { return $false }
    $javaExe = Join-Path $PathValue 'bin\java.exe'
    return (Test-Path $javaExe)
}

function Test-AndroidSdkPath {
    param([string]$PathValue)

    if ([string]::IsNullOrWhiteSpace($PathValue)) { return $false }
    return (Test-Path (Join-Path $PathValue 'platform-tools'))
}

function Test-BuildReady {
    $base = ''
    $proj = ''
    $appName = ''
    $appId = ''
    $apkEnabled = $false

    if ($txtFolder) { $base = $txtFolder.Text.Trim() }
    if ($txtProject) { $proj = $txtProject.Text.Trim() }
    if ($txtAppName) { $appName = $txtAppName.Text.Trim() }

    if (Get-Command Get-RealAppIdValue -ErrorAction SilentlyContinue) {
        $appId = Get-RealAppIdValue
    }

    if ($chkBuildApkAfterSetup) {
        $apkEnabled = $chkBuildApkAfterSetup.Checked
    }

    if ([string]::IsNullOrWhiteSpace($base) -or -not (Test-Path $base)) { return $false }
    if ([string]::IsNullOrWhiteSpace($proj)) { return $false }
    if ([string]::IsNullOrWhiteSpace($appName)) { return $false }
    if (-not (Test-AppIdFormat $appId)) { return $false }
    if (-not $script:SelectedIndexFile -or -not (Test-Path $script:SelectedIndexFile)) { return $false }

    if ($apkEnabled) {
        if (-not (Test-JavaHomePath $script:JavaHomePath)) { return $false }
        if (-not (Test-AndroidSdkPath $script:AndroidSdkPath)) { return $false }
    }

    return $true
}

function Update-BuildButtonState {
    try {
        $isReady = Test-BuildReady

        if ($btnRun) {
            $btnRun.Enabled = $isReady
        }

        if ($lblBuildReadyStatus) {
            if ($isReady) {
                $lblBuildReadyStatus.Text = 'Ready to build'
                $lblBuildReadyStatus.ForeColor = Get-ValidationColor 'GOOD'
            } else {
                $lblBuildReadyStatus.Text = 'Fix validation issues'
                $lblBuildReadyStatus.ForeColor = Get-ValidationColor 'BAD'
            }
            $lblBuildReadyStatus.BackColor = [System.Drawing.Color]::Transparent
        }
    }
    catch {
    }
}

function Auto-DetectPaths {
    $javaCandidates = @(
        (Join-Path $env:ProgramFiles 'Android\Android Studio\jbr'),
        (Join-Path $env:ProgramFiles 'Android\Android Studio\jre'),
        (Join-Path ${env:ProgramFiles(x86)} 'Android\Android Studio\jbr'),
        (Join-Path ${env:ProgramFiles(x86)} 'Android\Android Studio\jre'),
        (Join-Path $env:LOCALAPPDATA 'Programs\Android Studio\jbr'),
        'D:\Program Files\Android\Android Studio\jbr',
        'D:\Program Files\Android\Android Studio\jre',
        'D:\Android\Android Studio\jbr',
        'D:\Android\Android Studio\jre'
    )

    $sdkCandidates = @(
        (Join-Path $env:LOCALAPPDATA 'Android\Sdk'),
        (Join-Path $env:USERPROFILE 'AppData\Local\Android\Sdk'),
        'D:\Android\SDK',
        'D:\Android\Sdk',
        'C:\Android\SDK',
        'C:\Android\Sdk'
    )

    $detectedJava = $null
    $detectedSdk = $null

    foreach ($candidate in $javaCandidates) {
        if ([string]::IsNullOrWhiteSpace($candidate)) { continue }
        if (Test-JavaHomePath $candidate) {
            $detectedJava = $candidate
            break
        }
    }

    foreach ($candidate in $sdkCandidates) {
        if ([string]::IsNullOrWhiteSpace($candidate)) { continue }
        if (Test-AndroidSdkPath $candidate) {
            $detectedSdk = $candidate
            break
        }
    }

    if ($detectedJava) {
        $script:JavaHomePath = $detectedJava
        if ($txtJavaHome) { $txtJavaHome.Text = $detectedJava }
        Write-Log ("Auto-detected Java Home: " + $detectedJava) 'SUCCESS'
    } else {
        Write-Log 'Could not auto-detect Java Home' 'WARN'
    }

    if ($detectedSdk) {
        $script:AndroidSdkPath = $detectedSdk
        if ($txtAndroidSdk) { $txtAndroidSdk.Text = $detectedSdk }
        Write-Log ("Auto-detected Android SDK: " + $detectedSdk) 'SUCCESS'
    } else {
        Write-Log 'Could not auto-detect Android SDK' 'WARN'
    }

    if ($script:WindowStateLoaded) {
        Save-Settings `
            $txtFolder.Text.Trim() `
            $txtProject.Text.Trim() `
            $txtAppName.Text.Trim() `
            (Get-RealAppIdValue) `
            $false `
            $script:LastProjectPath `
            $script:UseLatestCapacitor `
            $script:BuildApkAfterSetup `
            $script:form.Width `
            $script:form.Height `
            $script:form.Left `
            $script:form.Top `
            $script:form.WindowState.ToString()
    }

    Update-LiveValidationPanel
}

function Update-LiveValidationPanel {
    try {
        if (-not $lblValidationBaseFolder) {
            Update-BuildButtonState
            return
        }

        $base = ''
        $proj = ''
        $appName = ''
        $appId = ''
        $apkEnabled = $false

        if ($txtFolder) { $base = $txtFolder.Text.Trim() }
        if ($txtProject) { $proj = $txtProject.Text.Trim() }
        if ($txtAppName) { $appName = $txtAppName.Text.Trim() }
        if (Get-Command Get-RealAppIdValue -ErrorAction SilentlyContinue) { $appId = Get-RealAppIdValue }
        if ($chkBuildApkAfterSetup) { $apkEnabled = $chkBuildApkAfterSetup.Checked }

        if (-not [string]::IsNullOrWhiteSpace($base) -and (Test-Path $base)) {
            Set-ValidationLabelState $lblValidationBaseFolder '- Base Folder ready' 'GOOD'
        } elseif (-not [string]::IsNullOrWhiteSpace($base)) {
            Set-ValidationLabelState $lblValidationBaseFolder '- Base Folder not found' 'BAD'
        } else {
            Set-ValidationLabelState $lblValidationBaseFolder '- Base Folder required' 'BAD'
        }

        if (-not [string]::IsNullOrWhiteSpace($proj)) {
            Set-ValidationLabelState $lblValidationProjectName '- Project Name entered' 'GOOD'
        } else {
            Set-ValidationLabelState $lblValidationProjectName '- Project Name required' 'BAD'
        }

        if (-not [string]::IsNullOrWhiteSpace($appName)) {
            Set-ValidationLabelState $lblValidationAppName '- App Name entered' 'GOOD'
        } else {
            Set-ValidationLabelState $lblValidationAppName '- App Name required' 'BAD'
        }

        if (Test-AppIdFormat $appId) {
            Set-ValidationLabelState $lblValidationAppId '- App ID valid' 'GOOD'
        } else {
            Set-ValidationLabelState $lblValidationAppId '- App ID invalid' 'BAD'
        }

        if ($script:SelectedIndexFile -and (Test-Path $script:SelectedIndexFile)) {
            Set-ValidationLabelState $lblValidationIndex '- index.html selected' 'GOOD'
        } else {
            Set-ValidationLabelState $lblValidationIndex '- index.html required' 'BAD'
        }

        if ($apkEnabled) {
            Set-ValidationLabelState $lblValidationApkMode '- APK build enabled' 'GOOD'

            if (Test-JavaHomePath $script:JavaHomePath) {
                Set-ValidationLabelState $lblValidationJavaHome '- Java Home valid' 'GOOD'
            } elseif ([string]::IsNullOrWhiteSpace($script:JavaHomePath)) {
                Set-ValidationLabelState $lblValidationJavaHome '- Java Home required' 'BAD'
            } else {
                Set-ValidationLabelState $lblValidationJavaHome '- Java Home invalid' 'BAD'
            }

            if (Test-AndroidSdkPath $script:AndroidSdkPath) {
                Set-ValidationLabelState $lblValidationAndroidSdk '- Android SDK valid' 'GOOD'
            } elseif ([string]::IsNullOrWhiteSpace($script:AndroidSdkPath)) {
                Set-ValidationLabelState $lblValidationAndroidSdk '- Android SDK required' 'BAD'
            } else {
                Set-ValidationLabelState $lblValidationAndroidSdk '- Android SDK invalid' 'BAD'
            }
        } else {
            Set-ValidationLabelState $lblValidationApkMode '- APK build disabled' 'WARN'
            Set-ValidationLabelState $lblValidationJavaHome '- Java Home not needed' 'WARN'
            Set-ValidationLabelState $lblValidationAndroidSdk '- Android SDK not needed' 'WARN'
        }
    }
    catch {
    }

    Update-BuildButtonState
}

function Update-AppIdValidationState {
    try {
        if (-not $txtAppId -or -not $lblAppIdStatus) {
            Update-LiveValidationPanel
            return
        }

        $realValue = Get-RealAppIdValue

        if ([string]::IsNullOrWhiteSpace($realValue)) {
            $lblAppIdStatus.Text = ''
            Update-LiveValidationPanel
            return
        }

        if (Test-AppIdFormat $realValue) {
            $lblAppIdStatus.Text = 'App ID format looks good.'
            if ($script:IsDarkMode) {
                $lblAppIdStatus.ForeColor = $script:DarkColorLogSuccess
            } else {
                $lblAppIdStatus.ForeColor = $script:ColorLogSuccess
            }
        } else {
            $lblAppIdStatus.Text = 'Must start with com. Example: com.company.appname'
            if ($script:IsDarkMode) {
                $lblAppIdStatus.ForeColor = $script:DarkColorLogError
            } else {
                $lblAppIdStatus.ForeColor = $script:ColorLogError
            }
        }
    }
    catch {
    }

    Update-LiveValidationPanel
}

function Update-ApkPathInputsState {
    $enabled = $false
    if ($chkBuildApkAfterSetup) {
        $enabled = $chkBuildApkAfterSetup.Checked
    }

    foreach ($control in @(
        $lblJavaHome, $txtJavaHome, $btnBrowseJavaHome, $lblJavaHomeHint,
        $lblAndroidSdk, $txtAndroidSdk, $btnBrowseAndroidSdk, $lblAndroidSdkHint
    )) {
        if ($control) {
            try { $control.Enabled = $enabled } catch {}
        }
    }

    Update-LiveValidationPanel
}

function Get-BuildValidationIssues {
    $issues = New-Object System.Collections.Generic.List[string]

    $base = $txtFolder.Text.Trim()
    $proj = $txtProject.Text.Trim()
    $appName = $txtAppName.Text.Trim()
    $appId = Get-RealAppIdValue

    if ([string]::IsNullOrWhiteSpace($base)) {
        [void]$issues.Add('Base Folder is required.')
    } elseif (-not (Test-Path $base)) {
        [void]$issues.Add('Base Folder does not exist.')
    }

    if ([string]::IsNullOrWhiteSpace($proj)) {
        [void]$issues.Add('Project Name is required.')
    }

    if ([string]::IsNullOrWhiteSpace($appName)) {
        [void]$issues.Add('App Name is required.')
    }

    if ([string]::IsNullOrWhiteSpace($appId)) {
        [void]$issues.Add('App ID is required.')
    } elseif (-not (Test-AppIdFormat $appId)) {
        [void]$issues.Add('App ID format is invalid. It must start with com. For example: com.company.appname')
    }

    if (-not $script:SelectedIndexFile -or -not (Test-Path $script:SelectedIndexFile)) {
        [void]$issues.Add('No index.html file has been selected.')
    }

    if ($script:BuildApkAfterSetup) {
        if ([string]::IsNullOrWhiteSpace($script:JavaHomePath)) {
            [void]$issues.Add('Java Home is required when Build debug APK after project setup is enabled.')
        } elseif (-not (Test-Path $script:JavaHomePath)) {
            [void]$issues.Add('Java Home path does not exist.')
        } elseif (-not (Test-JavaHomePath $script:JavaHomePath)) {
            [void]$issues.Add('Java Home does not contain bin\java.exe.')
        }

        if ([string]::IsNullOrWhiteSpace($script:AndroidSdkPath)) {
            [void]$issues.Add('Android SDK path is required when Build debug APK after project setup is enabled.')
        } elseif (-not (Test-Path $script:AndroidSdkPath)) {
            [void]$issues.Add('Android SDK path does not exist.')
        } elseif (-not (Test-AndroidSdkPath $script:AndroidSdkPath)) {
            [void]$issues.Add('Android SDK path does not appear valid. platform-tools folder was not found.')
        }
    }

    return $issues
}

function Show-BuildValidationIssues {
    param(
        [System.Collections.Generic.List[string]]$Issues
    )

    if (-not $Issues -or $Issues.Count -eq 0) {
        return
    }

    $message = "Please fix the following before building:`r`n`r`n"
    foreach ($issue in $Issues) {
        $message += "- $issue`r`n"
    }

    [System.Windows.Forms.MessageBox]::Show(
        $message,
        'Build Validation',
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Warning
    ) | Out-Null
}