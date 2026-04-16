function Show-PngInfoDialog {
    [System.Windows.Forms.MessageBox]::Show(
        "Required PNG filenames if you want Android asset generation:`r`n`r`n- icon-only.png`r`n- icon-foreground.png`r`n- icon-background.png`r`n- splash.png`r`n- splash-dark.png`r`n`r`nYou can skip PNG assets completely if you do not want to generate icons and splash assets.",
        'PNG Asset File Names',
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Information
    ) | Out-Null
}

function Show-CleanInfoDialog {
    [System.Windows.Forms.MessageBox]::Show(
        "Clean generated files will only remove generated project folders and files inside the current project before rebuilding.`r`n`r`nThis is intended to remove items such as:`r`n- android`r`n- node_modules`r`n- assets`r`n- package-lock.json`r`n`r`nIt does not remove your original selected index.html or your original PNG files outside the project folder.",
        'Clean Generated Files',
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Information
    ) | Out-Null
}

function Show-SettingsDialog {
    $dialog = New-Object System.Windows.Forms.Form
    $dialog.Text = 'Settings'
    $dialog.StartPosition = 'CenterParent'
    $dialog.Size = New-Object System.Drawing.Size(430, 360)
    $dialog.FormBorderStyle = 'FixedDialog'
    $dialog.MaximizeBox = $false
    $dialog.MinimizeBox = $false
    $dialog.ShowInTaskbar = $false

    if ($script:IsDarkMode) {
        $dialog.BackColor = $script:DarkColorBg
        $dialog.ForeColor = $script:DarkColorText
    } else {
        $dialog.BackColor = $script:ColorBg
        $dialog.ForeColor = $script:ColorText
    }

    $lblTheme = New-Object System.Windows.Forms.Label
    $lblTheme.Text = 'Appearance'
    $lblTheme.Location = New-Object System.Drawing.Point(20, 18)
    $lblTheme.Size = New-Object System.Drawing.Size(150, 22)
    Style-Label -Label $lblTheme -Size 11 -Bold $true
    $dialog.Controls.Add($lblTheme)

    $btnToggleTheme = New-Object System.Windows.Forms.Button
    $btnToggleTheme.Text = if ($script:IsDarkMode) { 'Switch to Light Mode' } else { 'Switch to Dark Mode' }
    $btnToggleTheme.Location = New-Object System.Drawing.Point(20, 46)
    $btnToggleTheme.Size = New-Object System.Drawing.Size(170, 32)
    Style-Button -Button $btnToggleTheme -BackColor $(if ($script:IsDarkMode) { $script:DarkColorButton } else { $script:ColorButton }) -ForeColor $(if ($script:IsDarkMode) { $script:DarkColorText } else { $script:ColorText })
    $dialog.Controls.Add($btnToggleTheme)

    $aboutPanel = New-Object System.Windows.Forms.Panel
    $aboutPanel.Location = New-Object System.Drawing.Point(20, 96)
    $aboutPanel.Size = New-Object System.Drawing.Size(374, 175)
    $aboutPanel.BorderStyle = 'FixedSingle'
    $aboutPanel.BackColor = if ($script:IsDarkMode) { $script:DarkColorLogBg } else { $script:ColorLogBg }
    $dialog.Controls.Add($aboutPanel)

    $lblAboutTitle = New-Object System.Windows.Forms.Label
    $lblAboutTitle.Text = 'About'
    $lblAboutTitle.Location = New-Object System.Drawing.Point(12, 10)
    $lblAboutTitle.Size = New-Object System.Drawing.Size(120, 22)
    Style-Label -Label $lblAboutTitle -Size 11 -Bold $true
    $aboutPanel.Controls.Add($lblAboutTitle)

    $lblAboutName = New-Object System.Windows.Forms.Label
    $lblAboutName.Text = $script:AppTitle
    $lblAboutName.Location = New-Object System.Drawing.Point(12, 38)
    $lblAboutName.Size = New-Object System.Drawing.Size(250, 20)
    Style-Label -Label $lblAboutName -Size 9.5 -Bold $true
    $aboutPanel.Controls.Add($lblAboutName)

    $lblAboutVersion = New-Object System.Windows.Forms.Label
    $lblAboutVersion.Text = $script:AppVersion
    $lblAboutVersion.Location = New-Object System.Drawing.Point(12, 60)
    $lblAboutVersion.Size = New-Object System.Drawing.Size(250, 18)
    Style-Label -Label $lblAboutVersion -Muted $true -Size 9
    $aboutPanel.Controls.Add($lblAboutVersion)

    $lblAboutAuthor = New-Object System.Windows.Forms.Label
    $lblAboutAuthor.Text = "Created by $($script:AppAuthor)"
    $lblAboutAuthor.Location = New-Object System.Drawing.Point(12, 80)
    $lblAboutAuthor.Size = New-Object System.Drawing.Size(250, 18)
    Style-Label -Label $lblAboutAuthor -Muted $true -Size 9
    $aboutPanel.Controls.Add($lblAboutAuthor)

    $lblAboutYear = New-Object System.Windows.Forms.Label
    $lblAboutYear.Text = "Year: $($script:AppYear)"
    $lblAboutYear.Location = New-Object System.Drawing.Point(12, 98)
    $lblAboutYear.Size = New-Object System.Drawing.Size(250, 18)
    Style-Label -Label $lblAboutYear -Muted $true -Size 9
    $aboutPanel.Controls.Add($lblAboutYear)

    $lblAboutCopyright = New-Object System.Windows.Forms.Label
    $lblAboutCopyright.Text = $script:AppCopyright
    $lblAboutCopyright.Location = New-Object System.Drawing.Point(12, 118)
    $lblAboutCopyright.Size = New-Object System.Drawing.Size(345, 18)
    Style-Label -Label $lblAboutCopyright -Muted $true -Size 8.5
    $aboutPanel.Controls.Add($lblAboutCopyright)

    $btnCheckUpdates = New-Object System.Windows.Forms.Button
    $btnCheckUpdates.Text = 'Check for Updates'
    $btnCheckUpdates.Location = New-Object System.Drawing.Point(12, 140)
    $btnCheckUpdates.Size = New-Object System.Drawing.Size(135, 26)
    Style-Button -Button $btnCheckUpdates -BackColor $(if ($script:IsDarkMode) { $script:DarkColorButton } else { $script:ColorButton }) -ForeColor $(if ($script:IsDarkMode) { $script:DarkColorText } else { $script:ColorText })
    $aboutPanel.Controls.Add($btnCheckUpdates)

    $btnCloseSettings = New-Object System.Windows.Forms.Button
    $btnCloseSettings.Text = 'Close'
    $btnCloseSettings.Location = New-Object System.Drawing.Point(304, 286)
    $btnCloseSettings.Size = New-Object System.Drawing.Size(90, 30)
    Style-Button -Button $btnCloseSettings -BackColor $(if ($script:IsDarkMode) { $script:DarkColorButton } else { $script:ColorButton }) -ForeColor $(if ($script:IsDarkMode) { $script:DarkColorText } else { $script:ColorText })
    $dialog.Controls.Add($btnCloseSettings)

    $btnToggleTheme.Add_Click({
        Apply-Theme (-not $script:IsDarkMode)
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
        $dialog.Close()
    })

    $btnCheckUpdates.Add_Click({
        if (Get-Command Invoke-CheckForUpdates -ErrorAction SilentlyContinue) {
            Invoke-CheckForUpdates -Interactive:$true -OnlyNotifyIfUpdateAvailable:$false
        } else {
            [System.Windows.Forms.MessageBox]::Show(
                'Update checker is not available.',
                'Check for Updates',
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Information
            ) | Out-Null
        }
    })

    $btnCloseSettings.Add_Click({
        $dialog.Close()
    })

    [void]$dialog.ShowDialog($form)
}

function Show-BuildSummaryDialog {
    param(
        [string]$BaseFolder,
        [string]$ProjectName,
        [string]$AppName,
        [string]$AppId
    )

    $projectPath = Join-Path $BaseFolder $ProjectName
    $assetSummary = if (Test-AnySelectedPngAssets) { 'Selected PNG assets will be included' } else { 'No PNG assets selected' }
    $apkSummary = if ($script:BuildApkAfterSetup) { 'Debug APK build enabled' } else { 'Debug APK build disabled' }
    $cleanSummary = if ($chkCleanGeneratedFiles -and $chkCleanGeneratedFiles.Checked) { 'Clean generated files before build: Enabled' } else { 'Clean generated files before build: Disabled' }
    $capSummary = if ($script:UseLatestCapacitor) { 'Use latest Capacitor packages: Enabled' } else { 'Use latest Capacitor packages: Disabled' }

    $message = @(
        "Please confirm this build:`r`n"
        "Project Path:`r`n$projectPath`r`n"
        "App Name: $AppName"
        "App ID: $AppId`r`n"
        "$capSummary"
        "$cleanSummary"
        "$assetSummary"
        "$apkSummary"
    ) -join "`r`n"

    $result = [System.Windows.Forms.MessageBox]::Show(
        $message,
        'Build Summary',
        [System.Windows.Forms.MessageBoxButtons]::OKCancel,
        [System.Windows.Forms.MessageBoxIcon]::Information
    )

    return ($result -eq [System.Windows.Forms.DialogResult]::OK)
}

function Show-BuildCompleteDialog {
    param(
        [string]$ProjectPath,
        [string]$AppName,
        [string]$AppId,
        [string]$LatestCapacitorStatus,
        [string]$AssetPromptStatus,
        [string]$AssetResultStatus,
        [string]$ApkBuildStatus,
        [string]$ApkPath
    )

    $message = @(
        "Build complete.`r`n"
        "Project Path:`r`n$ProjectPath`r`n"
        "App Name: $AppName"
        "App ID: $AppId`r`n"
        "Use latest Capacitor: $LatestCapacitorStatus"
        "Selected assets: $AssetResultStatus"
        "APK build: $ApkBuildStatus"
        "APK path: $ApkPath"
    ) -join "`r`n"

    [System.Windows.Forms.MessageBox]::Show(
        $message,
        'Build Complete',
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Information
    ) | Out-Null
}