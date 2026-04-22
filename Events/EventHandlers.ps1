$btnFolder.Add_Click({
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description = 'Select the base folder where the project folder will be created'
    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $txtFolder.Text = $dialog.SelectedPath
        Save-Settings $txtFolder.Text.Trim() $txtProject.Text.Trim() $txtAppName.Text.Trim() (Get-RealAppIdValue) $false $script:LastProjectPath $script:UseLatestCapacitor $script:BuildApkAfterSetup $script:form.Width $script:form.Height $script:form.Left $script:form.Top $script:form.WindowState.ToString()
        Update-LiveValidationPanel
    }
})

$btnPickIndex.Add_Click({
    $picked = Pick-SingleFile 'Select your index.html file' 'HTML files (*.html)|*.html'
    if ($picked) {
        $script:SelectedIndexFile = $picked
        Update-SelectedFileLabels
        Save-Settings $txtFolder.Text.Trim() $txtProject.Text.Trim() $txtAppName.Text.Trim() (Get-RealAppIdValue) $false $script:LastProjectPath $script:UseLatestCapacitor $script:BuildApkAfterSetup $script:form.Width $script:form.Height $script:form.Left $script:form.Top $script:form.WindowState.ToString()
        Write-Log ("Selected index.html -> " + [System.IO.Path]::GetFileName($picked)) 'SUCCESS'
        Update-LiveValidationPanel
    }
})

$btnPickPng.Add_Click({
    Show-PngSelectorDialog
})

$btnPngInfo.Add_Click({
    Show-PngInfoDialog
})

$btnCleanInfo.Add_Click({
    Show-CleanInfoDialog
})

$btnHelp.Add_Click({
    Show-HelpDialog
})

$btnClearAll.Add_Click({
    Show-ClearAllConfirm
})

$btnSettings.Add_Click({
    Show-SettingsDialog
})

$btnAutoDetectPaths.Add_Click({
    Auto-DetectPaths
    Update-EnvironmentStatus
})

$btnBrowseJavaHome.Add_Click({
    $picked = Pick-Folder -Description 'Select your Java Home folder' -InitialPath $txtJavaHome.Text.Trim()
    if ($picked) {
        $txtJavaHome.Text = $picked
        $script:JavaHomePath = $picked
        Save-Settings $txtFolder.Text.Trim() $txtProject.Text.Trim() $txtAppName.Text.Trim() (Get-RealAppIdValue) $false $script:LastProjectPath $script:UseLatestCapacitor $script:BuildApkAfterSetup $script:form.Width $script:form.Height $script:form.Left $script:form.Top $script:form.WindowState.ToString()
        Update-LiveValidationPanel
        Update-EnvironmentStatus
    }
})

$btnBrowseAndroidSdk.Add_Click({
    $picked = Pick-Folder -Description 'Select your Android SDK folder' -InitialPath $txtAndroidSdk.Text.Trim()
    if ($picked) {
        $txtAndroidSdk.Text = $picked
        $script:AndroidSdkPath = $picked
        Save-Settings $txtFolder.Text.Trim() $txtProject.Text.Trim() $txtAppName.Text.Trim() (Get-RealAppIdValue) $false $script:LastProjectPath $script:UseLatestCapacitor $script:BuildApkAfterSetup $script:form.Width $script:form.Height $script:form.Left $script:form.Top $script:form.WindowState.ToString()
        Update-LiveValidationPanel
        Update-EnvironmentStatus
    }
})

$btnOpenProject.Add_Click({
    if ($script:LastProjectPath -and (Test-Path $script:LastProjectPath)) {
        Start-Process explorer.exe $script:LastProjectPath
    }
})

$btnOpenAndroid.Add_Click({
    if ($script:LastProjectPath) {
        $androidPath = Join-Path $script:LastProjectPath 'android'
        if (Test-Path $androidPath) {
            try {
                Start-Process cmd.exe -ArgumentList "/c cd /d `"$script:LastProjectPath`" && npx cap open android"
            }
            catch {
                Start-Process explorer.exe $androidPath
                [System.Windows.Forms.MessageBox]::Show('Could not launch Android Studio automatically. Open the android folder manually.')
            }
        } else {
            [System.Windows.Forms.MessageBox]::Show('Android folder not found yet.')
        }
    }
})

$btnOpenApkFolder.Add_Click({
    if ($script:LastBuiltApkPath -and (Test-Path $script:LastBuiltApkPath)) {
        $apkFolder = Split-Path -Parent $script:LastBuiltApkPath
        if (Test-Path $apkFolder) {
            Start-Process explorer.exe $apkFolder
        }
    }
})

$btnInstallApk.Add_Click({
    Install-BuiltApkToDevice
})

$btnExportLog.Add_Click({
    Export-BuildLog
})

$btnRun.Add_Click({
    Start-ProjectBuild
})

$btnScanEnvironment.Add_Click({
    Update-EnvironmentStatus
})

$btnOpenSdkFolder.Add_Click({
    Open-CurrentSdkFolder
})

$btnDownloadJdk.Add_Click({
    Open-JdkDownloadPage
})

$btnDownloadAndroidTools.Add_Click({
    Open-AndroidToolsDownloadPage
})

$btnInstallSdkPackages.Add_Click({
    try {
        $sdkStatus = Test-AndroidSdkEnvironment $script:AndroidSdkPath

        if (-not $sdkStatus.SdkFound) {
            [System.Windows.Forms.MessageBox]::Show(
                'Select a valid Android SDK path first.',
                'Install Required SDK Packages',
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Warning
            ) | Out-Null
            return
        }

        if (-not $sdkStatus.CmdlineToolsFound -or [string]::IsNullOrWhiteSpace($sdkStatus.SdkManagerPath)) {
            [System.Windows.Forms.MessageBox]::Show(
                'Automatic SDK package installation is not available right now.' + [Environment]::NewLine + [Environment]::NewLine +
                'Your current Android SDK already appears usable for builds.' + [Environment]::NewLine +
                'This button only works when Android command-line tools (sdkmanager) are available in the selected SDK path.',
                'Install Required SDK Packages',
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Information
            ) | Out-Null
            return
        }

        Install-RequiredSdkPackages
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show(
            $_.Exception.Message,
            'Install Required SDK Packages Failed',
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null
    }
})

$txtFolder.Add_TextChanged({
    if ($script:WindowStateLoaded) {
        Save-Settings $txtFolder.Text.Trim() $txtProject.Text.Trim() $txtAppName.Text.Trim() (Get-RealAppIdValue) $false $script:LastProjectPath $script:UseLatestCapacitor $script:BuildApkAfterSetup $script:form.Width $script:form.Height $script:form.Left $script:form.Top $script:form.WindowState.ToString()
        Update-LiveValidationPanel
    }
})

$txtProject.Add_TextChanged({
    if ($script:WindowStateLoaded) {
        Save-Settings $txtFolder.Text.Trim() $txtProject.Text.Trim() $txtAppName.Text.Trim() (Get-RealAppIdValue) $false $script:LastProjectPath $script:UseLatestCapacitor $script:BuildApkAfterSetup $script:form.Width $script:form.Height $script:form.Left $script:form.Top $script:form.WindowState.ToString()
        Update-LiveValidationPanel
    }
})

$txtAppName.Add_TextChanged({
    if (-not $script:AppIdManuallyEdited) {
        if (-not [string]::IsNullOrWhiteSpace($txtAppName.Text.Trim())) {
            Update-AppIdFromAppName
        }
    }

    if ($script:WindowStateLoaded) {
        Save-Settings $txtFolder.Text.Trim() $txtProject.Text.Trim() $txtAppName.Text.Trim() (Get-RealAppIdValue) $false $script:LastProjectPath $script:UseLatestCapacitor $script:BuildApkAfterSetup $script:form.Width $script:form.Height $script:form.Left $script:form.Top $script:form.WindowState.ToString()
        Update-LiveValidationPanel
    }
})

$txtAppId.Add_Enter({
    Clear-AppIdPlaceholder
    Update-AppIdValidationState
})

$txtAppId.Add_Leave({
    if ([string]::IsNullOrWhiteSpace($txtAppId.Text)) {
        Set-AppIdPlaceholder
        $script:AppIdManuallyEdited = $false
    }
    Update-AppIdValidationState
})

$txtAppId.Add_TextChanged({
    if (-not $script:IsUpdatingAppIdProgrammatically) {
        if ([string]::IsNullOrWhiteSpace($txtAppId.Text)) {
            $txtAppId.Tag = $null
        } elseif ($txtAppId.Tag -ne 'PLACEHOLDER') {
            $script:AppIdManuallyEdited = $true
            $txtAppId.Tag = $null
        }
    }

    Update-AppIdValidationState

    if ($script:WindowStateLoaded -and $txtAppId.Tag -ne 'PLACEHOLDER') {
        Save-Settings $txtFolder.Text.Trim() $txtProject.Text.Trim() $txtAppName.Text.Trim() (Get-RealAppIdValue) $false $script:LastProjectPath $script:UseLatestCapacitor $script:BuildApkAfterSetup $script:form.Width $script:form.Height $script:form.Left $script:form.Top $script:form.WindowState.ToString()
    }
})

$txtJavaHome.Add_TextChanged({
    $script:JavaHomePath = $txtJavaHome.Text.Trim()
    if ($script:WindowStateLoaded) {
        Save-Settings $txtFolder.Text.Trim() $txtProject.Text.Trim() $txtAppName.Text.Trim() (Get-RealAppIdValue) $false $script:LastProjectPath $script:UseLatestCapacitor $script:BuildApkAfterSetup $script:form.Width $script:form.Height $script:form.Left $script:form.Top $script:form.WindowState.ToString()
        Update-LiveValidationPanel
        Update-EnvironmentStatus
    }
})

$txtAndroidSdk.Add_TextChanged({
    $script:AndroidSdkPath = $txtAndroidSdk.Text.Trim()
    if ($script:WindowStateLoaded) {
        Save-Settings $txtFolder.Text.Trim() $txtProject.Text.Trim() $txtAppName.Text.Trim() (Get-RealAppIdValue) $false $script:LastProjectPath $script:UseLatestCapacitor $script:BuildApkAfterSetup $script:form.Width $script:form.Height $script:form.Left $script:form.Top $script:form.WindowState.ToString()
        Update-LiveValidationPanel
        Update-EnvironmentStatus
    }
})

$chkLatestCapacitor.Add_CheckedChanged({
    $script:UseLatestCapacitor = $chkLatestCapacitor.Checked
    if ($script:WindowStateLoaded) {
        Save-Settings $txtFolder.Text.Trim() $txtProject.Text.Trim() $txtAppName.Text.Trim() (Get-RealAppIdValue) $false $script:LastProjectPath $script:UseLatestCapacitor $script:BuildApkAfterSetup $script:form.Width $script:form.Height $script:form.Left $script:form.Top $script:form.WindowState.ToString()
        Update-LiveValidationPanel
    }
})

$chkBuildApkAfterSetup.Add_CheckedChanged({
    $script:BuildApkAfterSetup = $chkBuildApkAfterSetup.Checked
    Update-ApkPathInputsState
    if ($script:WindowStateLoaded) {
        Save-Settings $txtFolder.Text.Trim() $txtProject.Text.Trim() $txtAppName.Text.Trim() (Get-RealAppIdValue) $false $script:LastProjectPath $script:UseLatestCapacitor $script:BuildApkAfterSetup $script:form.Width $script:form.Height $script:form.Left $script:form.Top $script:form.WindowState.ToString()
    }
})

$chkCleanGeneratedFiles.Add_CheckedChanged({
    if ($script:WindowStateLoaded) {
        Update-LiveValidationPanel
    }
})

$form.Add_FormClosing({
    $windowBounds = if ($script:form.WindowState -eq [System.Windows.Forms.FormWindowState]::Normal) {
        $script:form.Bounds
    } else {
        $script:form.RestoreBounds
    }

    Save-Settings `
        $txtFolder.Text.Trim() `
        $txtProject.Text.Trim() `
        $txtAppName.Text.Trim() `
        (Get-RealAppIdValue) `
        $false `
        $script:LastProjectPath `
        $script:UseLatestCapacitor `
        $script:BuildApkAfterSetup `
        $windowBounds.Width `
        $windowBounds.Height `
        $windowBounds.X `
        $windowBounds.Y `
        $script:form.WindowState.ToString()
})