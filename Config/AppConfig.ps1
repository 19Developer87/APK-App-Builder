Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ---------------- APP IDENTITY ----------------
$script:AppTitle = 'Android App Builder'

$versionFile = Join-Path $script:AppBasePath 'version.txt'
if (Test-Path $versionFile) {
    $script:AppVersionNumber = (Get-Content $versionFile -Raw).Trim()
} else {
    $script:AppVersionNumber = '1.0'
}

$script:AppVersion = "Version $($script:AppVersionNumber)"
$script:AppAuthor = 'Craig Doughty'
$script:AppYear = '2026'
$script:AppCopyright = 'Copyright 2026 Craig Doughty. All rights reserved.'
$script:AppDescription = 'Create and prepare Capacitor Android projects faster.'

# ---------------- PATHS / STATE ----------------
$script:RootPath = $script:AppBasePath
$script:SettingsPath = Join-Path $script:RootPath 'builder-settings.json'

$script:IsDarkMode = $false
$script:WindowStateLoaded = $false
$script:IsUpdatingAppIdProgrammatically = $false
$script:AppIdManuallyEdited = $false

$script:SelectedIndexFile = $null
$script:SelectedPngFiles = @{}
$script:LastProjectPath = $null
$script:LastBuiltApkPath = $null
$script:JavaHomePath = ''
$script:AndroidSdkPath = ''
$script:UseLatestCapacitor = $false
$script:BuildApkAfterSetup = $false

# ---------------- ENVIRONMENT SETUP ----------------
$script:RequiredAndroidPlatformPackage = 'platforms;android-35'
$script:RequiredAndroidBuildToolsPackage = 'build-tools;35.0.0'
$script:RequiredAndroidPlatformToolsPackage = 'platform-tools'

if ($null -eq $script:AutoCheckUpdatesOnStartup) {
    $script:AutoCheckUpdatesOnStartup = $true
}

if ($null -eq $script:LatestAvailableVersion) {
    $script:LatestAvailableVersion = ''
}

if ($null -eq $script:LatestAvailableVersionStatus) {
    $script:LatestAvailableVersionStatus = 'Not checked yet'
}

# ---------------- LIGHT THEME ----------------
$script:ColorBg = [System.Drawing.Color]::FromArgb(245, 246, 248)
$script:ColorPanel = [System.Drawing.Color]::White
$script:ColorHeader = [System.Drawing.Color]::FromArgb(240, 242, 245)
$script:ColorBorder = [System.Drawing.Color]::FromArgb(210, 214, 220)
$script:ColorText = [System.Drawing.Color]::FromArgb(36, 36, 36)
$script:ColorMutedText = [System.Drawing.Color]::FromArgb(110, 118, 128)
$script:ColorInputBg = [System.Drawing.Color]::White
$script:ColorButton = [System.Drawing.Color]::FromArgb(245, 247, 250)
$script:ColorAccent = [System.Drawing.Color]::FromArgb(66, 133, 244)

$script:ColorLogBg = [System.Drawing.Color]::FromArgb(250, 250, 250)
$script:ColorLogInfo = [System.Drawing.Color]::FromArgb(70, 70, 70)
$script:ColorLogSuccess = [System.Drawing.Color]::FromArgb(34, 139, 34)
$script:ColorLogWarning = [System.Drawing.Color]::FromArgb(184, 134, 11)
$script:ColorLogError = [System.Drawing.Color]::FromArgb(178, 34, 34)

# Extra environment status colours
$script:ColorSuccess = [System.Drawing.Color]::FromArgb(34, 139, 34)
$script:ColorError = [System.Drawing.Color]::FromArgb(178, 34, 34)

# ---------------- DARK THEME ----------------
$script:DarkColorBg = [System.Drawing.Color]::FromArgb(30, 32, 36)
$script:DarkColorPanel = [System.Drawing.Color]::FromArgb(39, 42, 47)
$script:DarkColorHeader = [System.Drawing.Color]::FromArgb(35, 38, 43)
$script:DarkColorBorder = [System.Drawing.Color]::FromArgb(70, 74, 80)
$script:DarkColorText = [System.Drawing.Color]::FromArgb(235, 235, 235)
$script:DarkColorMutedText = [System.Drawing.Color]::FromArgb(170, 175, 182)
$script:DarkColorInputBg = [System.Drawing.Color]::FromArgb(48, 52, 58)
$script:DarkColorButton = [System.Drawing.Color]::FromArgb(55, 60, 67)
$script:DarkColorAccent = [System.Drawing.Color]::FromArgb(66, 133, 244)

$script:DarkColorLogBg = [System.Drawing.Color]::FromArgb(34, 36, 40)
$script:DarkColorLogInfo = [System.Drawing.Color]::FromArgb(210, 210, 210)
$script:DarkColorLogSuccess = [System.Drawing.Color]::FromArgb(88, 214, 141)
$script:DarkColorLogWarning = [System.Drawing.Color]::FromArgb(244, 208, 63)
$script:DarkColorLogError = [System.Drawing.Color]::FromArgb(236, 112, 99)

# Extra environment status colours
$script:DarkColorSuccess = [System.Drawing.Color]::FromArgb(88, 214, 141)
$script:DarkColorError = [System.Drawing.Color]::FromArgb(236, 112, 99)

# ---------------- MAIN FORM ----------------
$form = New-Object System.Windows.Forms.Form
$form.Text = $script:AppTitle
$iconPath = Join-Path $script:AppBasePath 'appicon.ico'
if (Test-Path $iconPath) {
    $form.Icon = New-Object System.Drawing.Icon($iconPath)
}
$form.StartPosition = 'CenterScreen'
$form.Size = New-Object System.Drawing.Size(980, 900)
$form.MinimumSize = New-Object System.Drawing.Size(1030, 760)
$form.BackColor = $script:ColorBg
$form.ForeColor = $script:ColorText
$form.Font = New-Object System.Drawing.Font('Segoe UI', 9)

function New-CardPanel {
    param(
        [int]$X,
        [int]$Y,
        [int]$W,
        [int]$H
    )

    $panel = New-Object System.Windows.Forms.Panel
    $panel.Location = New-Object System.Drawing.Point($X, $Y)
    $panel.Size = New-Object System.Drawing.Size($W, $H)
    $panel.BackColor = $script:ColorPanel
    $panel.BorderStyle = 'FixedSingle'
    return $panel
}

function Style-Label {
    param(
        [System.Windows.Forms.Label]$Label,
        [double]$Size = 9,
        [bool]$Bold = $false,
        [bool]$Muted = $false
    )

    $style = if ($Bold) { [System.Drawing.FontStyle]::Bold } else { [System.Drawing.FontStyle]::Regular }
    $Label.Font = New-Object System.Drawing.Font('Segoe UI', $Size, $style)
    $Label.ForeColor = if ($Muted) { $script:ColorMutedText } else { $script:ColorText }
    $Label.BackColor = [System.Drawing.Color]::Transparent
}

function Style-TextBox {
    param([System.Windows.Forms.TextBox]$TextBox)

    $TextBox.BackColor = $script:ColorInputBg
    $TextBox.ForeColor = $script:ColorText
    $TextBox.BorderStyle = 'FixedSingle'
    $TextBox.Font = New-Object System.Drawing.Font('Segoe UI', 10)
}

function Style-Button {
    param(
        [System.Windows.Forms.Button]$Button,
        [System.Drawing.Color]$BackColor,
        [System.Drawing.Color]$ForeColor
    )

    $Button.BackColor = $BackColor
    $Button.ForeColor = $ForeColor
    $Button.FlatStyle = 'Flat'
    $Button.FlatAppearance.BorderSize = 1
    $Button.FlatAppearance.BorderColor = $script:ColorBorder
    $Button.Font = New-Object System.Drawing.Font('Segoe UI', 9)
}

function Style-AccentButton {
    param([System.Windows.Forms.Button]$Button)

    $Button.BackColor = $script:ColorAccent
    $Button.ForeColor = [System.Drawing.Color]::White
    $Button.FlatStyle = 'Flat'
    $Button.FlatAppearance.BorderSize = 0
    $Button.Font = New-Object System.Drawing.Font('Segoe UI', 9, [System.Drawing.FontStyle]::Bold)
}