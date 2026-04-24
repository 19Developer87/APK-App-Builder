function Apply-StandardButtonTheme {
    param([System.Windows.Forms.Button[]]$Buttons)

    foreach ($btn in $Buttons) {
        if (-not $btn) { continue }

        if ($script:IsDarkMode) {
            $btn.BackColor = $script:DarkColorButton
            $btn.ForeColor = $script:DarkColorText
            $btn.FlatAppearance.BorderSize = 1
            $btn.FlatAppearance.BorderColor = $script:DarkColorBorder
        } else {
            $btn.BackColor = $script:ColorButton
            $btn.ForeColor = $script:ColorText
            $btn.FlatAppearance.BorderSize = 1
            $btn.FlatAppearance.BorderColor = $script:ColorBorder
        }
    }
}

function Apply-AccentButtonTheme {
    param([System.Windows.Forms.Button[]]$Buttons)

    foreach ($btn in $Buttons) {
        if (-not $btn) { continue }

        $btn.FlatAppearance.BorderSize = 0

        if ($script:IsDarkMode) {
            $btn.BackColor = $script:DarkColorAccent
            $btn.ForeColor = [System.Drawing.Color]::White
        } else {
            $btn.BackColor = $script:ColorAccent
            $btn.ForeColor = [System.Drawing.Color]::White
        }
    }
}

function Apply-EnvironmentSetupTheme {
    if (-not $script:EnvGroup) { return }

    $envBack = if ($script:IsDarkMode) { $script:DarkColorLogBg } else { $script:ColorLogBg }
    $envText = if ($script:IsDarkMode) { $script:DarkColorText } else { $script:ColorText }
    $envMuted = if ($script:IsDarkMode) { $script:DarkColorMutedText } else { $script:ColorMutedText }

    $script:EnvGroup.BackColor = $envBack
    $script:EnvGroup.ForeColor = $envText

    foreach ($ctrl in $script:EnvGroup.Controls) {
        if ($ctrl -is [System.Windows.Forms.Label]) {
            $ctrl.BackColor = $envBack

            if ($ctrl.Name -eq 'lblEnvHelp') {
                $ctrl.ForeColor = $envMuted
            }
        }

        if ($ctrl -is [System.Windows.Forms.Button]) {
            if ($ctrl.Text -eq 'Install Required SDK Packages') {
                Apply-AccentButtonTheme @($ctrl)
            }
            else {
                Apply-StandardButtonTheme @($ctrl)
            }
        }
    }
}

function Apply-Theme {
    param([bool]$DarkMode)

    $script:IsDarkMode = $DarkMode

    if ($DarkMode) {
        if ($form) { $form.BackColor = $script:DarkColorBg; $form.ForeColor = $script:DarkColorText }
        if ($headerPanel) { $headerPanel.BackColor = $script:DarkColorHeader }
        if ($leftCard) { $leftCard.BackColor = $script:DarkColorPanel }
        if ($rightCard) { $rightCard.BackColor = $script:DarkColorPanel }
        if ($logCard) { $logCard.BackColor = $script:DarkColorPanel }
        if ($footerPanel) { $footerPanel.BackColor = $script:DarkColorHeader }
        if ($validationCard) { $validationCard.BackColor = $script:DarkColorLogBg }
        if ($logBox) { $logBox.BackColor = $script:DarkColorLogBg; $logBox.ForeColor = $script:DarkColorText }

        foreach ($tb in @($txtFolder, $txtProject, $txtAppName, $txtAppId, $txtJavaHome, $txtAndroidSdk)) {
            if (-not $tb) { continue }
            $tb.BackColor = $script:DarkColorInputBg
            if ($tb -ne $txtAppId -or $txtAppId.Tag -ne 'PLACEHOLDER') {
                $tb.ForeColor = $script:DarkColorText
            }
            $tb.BorderStyle = 'FixedSingle'
        }

        foreach ($chk in @($chkAssets, $chkLatestCapacitor, $chkBuildApkAfterSetup, $chkCleanGeneratedFiles)) {
            if (-not $chk) { continue }
            $chk.ForeColor = $script:DarkColorText
            $chk.BackColor = $script:DarkColorPanel
        }

        foreach ($lbl in @($lblTitle, $lblSetup, $lblOptions, $lblBuildProgress, $lblValidationTitle)) {
            if (-not $lbl) { continue }
            $lbl.ForeColor = [System.Drawing.Color]::White
            $lbl.BackColor = [System.Drawing.Color]::Transparent
        }

        foreach ($lbl in @(
            $lblSubtitle, $lblBaseFolder, $lblProject, $lblAppName, $lblAppId,
            $lblProgress, $lblJavaHome, $lblAndroidSdk, $lblJavaHomeHint, $lblAndroidSdkHint
        )) {
            if (-not $lbl) { continue }
            $lbl.ForeColor = $script:DarkColorMutedText
            $lbl.BackColor = [System.Drawing.Color]::Transparent
        }

        if ($lblAppIdStatus) { $lblAppIdStatus.BackColor = [System.Drawing.Color]::Transparent }
        if ($lblBuildReadyStatus) { $lblBuildReadyStatus.BackColor = [System.Drawing.Color]::Transparent }

        Apply-StandardButtonTheme @(
            $btnHelp, $btnSettings, $btnFolder, $btnPickIndex, $btnPickPng, $btnPngInfo, $btnCleanInfo,
            $btnBrowseJavaHome, $btnBrowseAndroidSdk, $btnAutoDetectPaths, $btnClearAll,
            $btnOpenProject, $btnOpenAndroid, $btnOpenApkFolder, $btnExportLog, $btnInstallApk
        )

        Apply-AccentButtonTheme @($btnRun)
    }
    else {
        if ($form) { $form.BackColor = $script:ColorBg; $form.ForeColor = $script:ColorText }
        if ($headerPanel) { $headerPanel.BackColor = $script:ColorHeader }
        if ($leftCard) { $leftCard.BackColor = $script:ColorPanel }
        if ($rightCard) { $rightCard.BackColor = $script:ColorPanel }
        if ($logCard) { $logCard.BackColor = $script:ColorPanel }
        if ($footerPanel) { $footerPanel.BackColor = $script:ColorHeader }
        if ($validationCard) { $validationCard.BackColor = $script:ColorLogBg }
        if ($logBox) { $logBox.BackColor = $script:ColorLogBg; $logBox.ForeColor = $script:ColorText }

        foreach ($tb in @($txtFolder, $txtProject, $txtAppName, $txtAppId, $txtJavaHome, $txtAndroidSdk)) {
            if (-not $tb) { continue }
            $tb.BackColor = $script:ColorInputBg
            if ($tb -ne $txtAppId -or $txtAppId.Tag -ne 'PLACEHOLDER') {
                $tb.ForeColor = $script:ColorText
            }
            $tb.BorderStyle = 'FixedSingle'
        }

        foreach ($chk in @($chkAssets, $chkLatestCapacitor, $chkBuildApkAfterSetup, $chkCleanGeneratedFiles)) {
            if (-not $chk) { continue }
            $chk.ForeColor = $script:ColorText
            $chk.BackColor = $script:ColorPanel
        }

        foreach ($lbl in @($lblTitle, $lblSetup, $lblOptions, $lblBuildProgress, $lblValidationTitle)) {
            if (-not $lbl) { continue }
            $lbl.ForeColor = $script:ColorText
            $lbl.BackColor = [System.Drawing.Color]::Transparent
        }

        foreach ($lbl in @(
            $lblSubtitle, $lblBaseFolder, $lblProject, $lblAppName, $lblAppId,
            $lblProgress, $lblJavaHome, $lblAndroidSdk, $lblJavaHomeHint, $lblAndroidSdkHint
        )) {
            if (-not $lbl) { continue }
            $lbl.ForeColor = $script:ColorMutedText
            $lbl.BackColor = [System.Drawing.Color]::Transparent
        }

        if ($lblAppIdStatus) { $lblAppIdStatus.BackColor = [System.Drawing.Color]::Transparent }
        if ($lblBuildReadyStatus) { $lblBuildReadyStatus.BackColor = [System.Drawing.Color]::Transparent }

        Apply-StandardButtonTheme @(
            $btnHelp, $btnSettings, $btnFolder, $btnPickIndex, $btnPickPng, $btnPngInfo, $btnCleanInfo,
            $btnBrowseJavaHome, $btnBrowseAndroidSdk, $btnAutoDetectPaths, $btnClearAll,
            $btnOpenProject, $btnOpenAndroid, $btnOpenApkFolder, $btnExportLog, $btnInstallApk
        )

        Apply-AccentButtonTheme @($btnRun)
    }

    Apply-EnvironmentSetupTheme

    if ($txtAppId -and $txtAppId.Tag -eq 'PLACEHOLDER') {
        $txtAppId.ForeColor = Get-AppIdPlaceholderColor
    }

    if (Get-Command Update-AppIdValidationState -ErrorAction SilentlyContinue) { Update-AppIdValidationState }
    if (Get-Command Update-SelectedFileLabels -ErrorAction SilentlyContinue) { Update-SelectedFileLabels }
    if (Get-Command Update-ApkPathInputsState -ErrorAction SilentlyContinue) { Update-ApkPathInputsState }
    if (Get-Command Update-LiveValidationPanel -ErrorAction SilentlyContinue) { Update-LiveValidationPanel }
    if (Get-Command Update-BuildButtonState -ErrorAction SilentlyContinue) { Update-BuildButtonState }
    if (Get-Command Update-ExportLogButtonState -ErrorAction SilentlyContinue) { Update-ExportLogButtonState }
}