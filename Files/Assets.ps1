function Update-SelectedFileLabels {
    if ($script:SelectedIndexFile -and (Test-Path $script:SelectedIndexFile)) {
        $lblSelectedIndex.Text = [System.IO.Path]::GetFileName($script:SelectedIndexFile)
        if ($script:IsDarkMode) {
            $lblSelectedIndex.ForeColor = $script:DarkColorLogSuccess
        } else {
            $lblSelectedIndex.ForeColor = $script:ColorLogSuccess
        }
    } else {
        $lblSelectedIndex.Text = 'Selected: none'
        if ($script:IsDarkMode) {
            $lblSelectedIndex.ForeColor = $script:DarkColorLogError
        } else {
            $lblSelectedIndex.ForeColor = $script:ColorLogError
        }
    }

    $trackedNames = @(
        'icon-only.png',
        'icon-foreground.png',
        'icon-background.png',
        'splash.png',
        'splash-dark.png'
    )

    $selectedTrackedCount = 0
    foreach ($name in $trackedNames) {
        if ($script:SelectedPngFiles.ContainsKey($name) -and (Test-Path $script:SelectedPngFiles[$name])) {
            $selectedTrackedCount++
        }
    }

    $lblSelectedPng.Text = "PNG files: $selectedTrackedCount/5 selected"

    if ($selectedTrackedCount -gt 0) {
        if ($script:IsDarkMode) {
            $lblSelectedPng.ForeColor = $script:DarkColorLogSuccess
        } else {
            $lblSelectedPng.ForeColor = $script:ColorLogSuccess
        }
    } else {
        if ($script:IsDarkMode) {
            $lblSelectedPng.ForeColor = $script:DarkColorLogError
        } else {
            $lblSelectedPng.ForeColor = $script:ColorLogError
        }
    }
}

function Test-AnySelectedPngAssets {
    $files = @(
        'icon-only.png',
        'icon-foreground.png',
        'icon-background.png',
        'splash.png',
        'splash-dark.png'
    )

    foreach ($file in $files) {
        if ($script:SelectedPngFiles.ContainsKey($file) -and (Test-Path $script:SelectedPngFiles[$file])) {
            return $true
        }
    }

    return $false
}

function Import-PngFiles {
    param([string[]]$Files)

    $validNames = @(
        'icon-only.png',
        'icon-foreground.png',
        'icon-background.png',
        'splash.png',
        'splash-dark.png'
    )

    $importedCount = 0

    foreach ($file in $Files) {
        if (-not (Test-Path $file)) { continue }

        $name = [System.IO.Path]::GetFileName($file).ToLower()

        if ($validNames -contains $name) {
            $script:SelectedPngFiles[$name] = $file
            Write-Log ("Imported $name") 'SUCCESS'
            $importedCount++
        } else {
            Write-Log ("Ignored " + [System.IO.Path]::GetFileName($file) + " - filename does not match tracked asset names") 'WARN'
        }
    }

    Update-SelectedFileLabels
    Save-Settings $txtFolder.Text.Trim() $txtProject.Text.Trim() $txtAppName.Text.Trim() (Get-RealAppIdValue) $false $script:LastProjectPath $script:UseLatestCapacitor $script:BuildApkAfterSetup $script:form.Width $script:form.Height $script:form.Left $script:form.Top $script:form.WindowState.ToString()

    if ($importedCount -eq 0) {
        Write-Log 'No matching PNG asset filenames were imported' 'WARN'
    }
}

function Clear-AllInputs {
    $txtFolder.Text = ''
    $txtProject.Text = ''
    $txtAppName.Text = ''
    $txtAppId.Text = ''
    $txtJavaHome.Text = ''
    $txtAndroidSdk.Text = ''

    $script:SelectedIndexFile = $null
    $script:SelectedPngFiles = @{}
    $script:LastProjectPath = $null
    $script:JavaHomePath = ''
    $script:AndroidSdkPath = ''
    $script:LastBuiltApkPath = $null

    if ($chkLatestCapacitor) { $chkLatestCapacitor.Checked = $false }
    if ($chkBuildApkAfterSetup) { $chkBuildApkAfterSetup.Checked = $false }
    if ($chkCleanGeneratedFiles) { $chkCleanGeneratedFiles.Checked = $false }
    if ($chkAssets) { $chkAssets.Checked = $false }

    $btnOpenProject.Enabled = $false
    $btnOpenAndroid.Enabled = $false
    if ($btnOpenApkFolder) { $btnOpenApkFolder.Enabled = $false }

    Update-SelectedFileLabels
    Set-AppIdPlaceholder

    if (Get-Command Update-ApkPathInputsState -ErrorAction SilentlyContinue) {
        Update-ApkPathInputsState
    }

    Save-Settings '' '' '' '' $false $null $script:UseLatestCapacitor $script:BuildApkAfterSetup $script:form.Width $script:form.Height $script:form.Left $script:form.Top $script:form.WindowState.ToString()
    Write-Log 'Cleared all input information and selected files' 'WARN'
}

function Show-ClearAllConfirm {
    $result = [System.Windows.Forms.MessageBox]::Show(
        'Clear all entered information, selected index.html, imported PNG files, Java Home, Android SDK, and last project path?',
        'Clear All',
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Question
    )

    if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
        Clear-AllInputs
    }
}

function Show-PngSelectorDialog {
    $files = Pick-MultiplePngFiles
    if ($files -and $files.Count -gt 0) {
        Import-PngFiles $files
    }
}

function Ensure-IndexFile {
    param([string]$wwwPath)

    if ($script:SelectedIndexFile -and (Test-Path $script:SelectedIndexFile)) {
        Copy-Item $script:SelectedIndexFile (Join-Path $wwwPath 'index.html') -Force
        Write-Log 'Copied selected index.html into www folder' 'SUCCESS'
        return
    }

    $useOwnIndex = [System.Windows.Forms.MessageBox]::Show(
        'No index.html was selected yet.' + [Environment]::NewLine + [Environment]::NewLine + 'Do you want to choose one now?',
        'Add index.html',
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Question
    )

    if ($useOwnIndex -eq [System.Windows.Forms.DialogResult]::Yes) {
        $indexFile = Pick-SingleFile 'Select your index.html file' 'HTML files (*.html)|*.html'
        if ($indexFile) {
            $script:SelectedIndexFile = $indexFile
            Copy-Item $indexFile (Join-Path $wwwPath 'index.html') -Force
            Write-Log 'Copied user-selected index.html into www folder' 'SUCCESS'
            Update-SelectedFileLabels
            Save-Settings $txtFolder.Text.Trim() $txtProject.Text.Trim() $txtAppName.Text.Trim() (Get-RealAppIdValue) $false $script:LastProjectPath $script:UseLatestCapacitor $script:BuildApkAfterSetup $script:form.Width $script:form.Height $script:form.Left $script:form.Top $script:form.WindowState.ToString()
            return
        }
    }

    Set-Content -Path (Join-Path $wwwPath 'index.html') -Value '<!doctype html><html><head><meta charset="utf-8"><title>App</title></head><body><h1>Hello App</h1></body></html>'
    Write-Log 'No index.html provided. Created default index.html' 'WARN'
}

function Ensure-Assets {
    param([string]$projectPath)

    if (-not (Test-AnySelectedPngAssets)) {
        Write-Log 'No PNG assets selected. Skipping asset generation.' 'WARN'
        return $false
    }

    $assetsPath = Join-Path $projectPath 'assets'
    New-Item -ItemType Directory -Path $assetsPath -Force | Out-Null
    Write-Log 'Created assets folder' 'SUCCESS'

    $files = @(
        'icon-only.png',
        'icon-foreground.png',
        'icon-background.png',
        'splash.png',
        'splash-dark.png'
    )

    foreach ($file in $files) {
        if ($script:SelectedPngFiles.ContainsKey($file) -and (Test-Path $script:SelectedPngFiles[$file])) {
            Copy-Item $script:SelectedPngFiles[$file] (Join-Path $assetsPath $file) -Force
            Write-Log "Added $file from selected file" 'SUCCESS'
        }
    }

    Update-SelectedFileLabels
    Save-Settings $txtFolder.Text.Trim() $txtProject.Text.Trim() $txtAppName.Text.Trim() (Get-RealAppIdValue) $false $script:LastProjectPath $script:UseLatestCapacitor $script:BuildApkAfterSetup $script:form.Width $script:form.Height $script:form.Left $script:form.Top $script:form.WindowState.ToString()
    return $true
}