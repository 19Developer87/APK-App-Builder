# ---------------- LAYOUT CONSTANTS ----------------
$headerY = 0
$headerH = 78

$topCardsY = 95
$cardW = 455
$cardH = 455
$leftCardX = 20
$rightCardX = 495

$logCardY = 560
$logCardH = 100
$logBoxH = 16

$footerY = 668
$footerH = 58

# ---------------- HEADER ----------------
$headerPanel = New-Object System.Windows.Forms.Panel
$headerPanel.Location = New-Object System.Drawing.Point(0, $headerY)
$headerPanel.Size = New-Object System.Drawing.Size(980, $headerH)
$headerPanel.Anchor = 'Top,Left,Right'
$headerPanel.BackColor = $script:ColorHeader
$form.Controls.Add($headerPanel)

$lblTitle = New-Object System.Windows.Forms.Label
$lblTitle.Text = $script:AppTitle
$lblTitle.Location = New-Object System.Drawing.Point(22, 14)
$lblTitle.Size = New-Object System.Drawing.Size(320, 28)
Style-Label -Label $lblTitle -Size 16 -Bold $true
$headerPanel.Controls.Add($lblTitle)

$lblSubtitle = New-Object System.Windows.Forms.Label
$lblSubtitle.Text = $script:AppDescription
$lblSubtitle.Location = New-Object System.Drawing.Point(24, 44)
$lblSubtitle.Size = New-Object System.Drawing.Size(420, 20)
Style-Label -Label $lblSubtitle -Muted $true -Size 9
$headerPanel.Controls.Add($lblSubtitle)

$btnHelp = New-Object System.Windows.Forms.Button
$btnHelp.Text = '?'
$btnHelp.Location = New-Object System.Drawing.Point(792, 20)
$btnHelp.Size = New-Object System.Drawing.Size(40, 34)
$btnHelp.Anchor = 'Top,Right'
Style-Button -Button $btnHelp -BackColor $script:ColorButton -ForeColor $script:ColorText
$btnHelp.Font = New-Object System.Drawing.Font('Segoe UI', 11, [System.Drawing.FontStyle]::Bold)
$headerPanel.Controls.Add($btnHelp)

$btnSettings = New-Object System.Windows.Forms.Button
$btnSettings.Text = 'Settings'
$btnSettings.Location = New-Object System.Drawing.Point(840, 20)
$btnSettings.Size = New-Object System.Drawing.Size(110, 34)
$btnSettings.Anchor = 'Top,Right'
Style-Button -Button $btnSettings -BackColor $script:ColorButton -ForeColor $script:ColorText
$headerPanel.Controls.Add($btnSettings)

# ---------------- LEFT CARD ----------------
$leftCard = New-CardPanel -X $leftCardX -Y $topCardsY -W $cardW -H $cardH
$leftCard.Anchor = 'Top,Left'
$form.Controls.Add($leftCard)

$lblSetup = New-Object System.Windows.Forms.Label
$lblSetup.Text = 'Project Setup'
$lblSetup.Location = New-Object System.Drawing.Point(16, 14)
$lblSetup.Size = New-Object System.Drawing.Size(200, 25)
Style-Label -Label $lblSetup -Size 12 -Bold $true
$leftCard.Controls.Add($lblSetup)

$lblBaseFolder = New-Object System.Windows.Forms.Label
$lblBaseFolder.Text = 'Base Folder'
$lblBaseFolder.Location = New-Object System.Drawing.Point(16, 60)
$lblBaseFolder.AutoSize = $true
Style-Label -Label $lblBaseFolder -Muted $true
$leftCard.Controls.Add($lblBaseFolder)

$txtFolder = New-Object System.Windows.Forms.TextBox
$txtFolder.Location = New-Object System.Drawing.Point(16, 82)
$txtFolder.Size = New-Object System.Drawing.Size(315, 28)
Style-TextBox $txtFolder
$leftCard.Controls.Add($txtFolder)

$btnFolder = New-Object System.Windows.Forms.Button
$btnFolder.Text = 'Browse'
$btnFolder.Location = New-Object System.Drawing.Point(340, 80)
$btnFolder.Size = New-Object System.Drawing.Size(95, 32)
Style-Button -Button $btnFolder -BackColor $script:ColorButton -ForeColor $script:ColorText
$leftCard.Controls.Add($btnFolder)

$lblProject = New-Object System.Windows.Forms.Label
$lblProject.Text = 'Project Name'
$lblProject.Location = New-Object System.Drawing.Point(16, 126)
$lblProject.AutoSize = $true
Style-Label -Label $lblProject -Muted $true
$leftCard.Controls.Add($lblProject)

$txtProject = New-Object System.Windows.Forms.TextBox
$txtProject.Location = New-Object System.Drawing.Point(16, 148)
$txtProject.Size = New-Object System.Drawing.Size(190, 28)
Style-TextBox $txtProject
$leftCard.Controls.Add($txtProject)

$lblAppName = New-Object System.Windows.Forms.Label
$lblAppName.Text = 'App Name'
$lblAppName.Location = New-Object System.Drawing.Point(225, 126)
$lblAppName.AutoSize = $true
Style-Label -Label $lblAppName -Muted $true
$leftCard.Controls.Add($lblAppName)

$txtAppName = New-Object System.Windows.Forms.TextBox
$txtAppName.Location = New-Object System.Drawing.Point(225, 148)
$txtAppName.Size = New-Object System.Drawing.Size(210, 28)
Style-TextBox $txtAppName
$leftCard.Controls.Add($txtAppName)

$btnPickIndex = New-Object System.Windows.Forms.Button
$btnPickIndex.Text = 'Select index.html'
$btnPickIndex.Location = New-Object System.Drawing.Point(16, 198)
$btnPickIndex.Size = New-Object System.Drawing.Size(135, 32)
Style-Button -Button $btnPickIndex -BackColor $script:ColorButton -ForeColor $script:ColorText
$leftCard.Controls.Add($btnPickIndex)

$lblSelectedIndex = New-Object System.Windows.Forms.Label
$lblSelectedIndex.Text = 'Selected: none'
$lblSelectedIndex.Location = New-Object System.Drawing.Point(165, 204)
$lblSelectedIndex.Size = New-Object System.Drawing.Size(270, 20)
Style-Label -Label $lblSelectedIndex -Muted $true
$leftCard.Controls.Add($lblSelectedIndex)

# ---------------- LIVE VALIDATION PANEL ----------------
$validationCard = New-Object System.Windows.Forms.Panel
$validationCard.Location = New-Object System.Drawing.Point(16, 244)
$validationCard.Size = New-Object System.Drawing.Size(419, 180)
$validationCard.BackColor = $script:ColorLogBg
$validationCard.BorderStyle = 'FixedSingle'
$leftCard.Controls.Add($validationCard)

$lblValidationTitle = New-Object System.Windows.Forms.Label
$lblValidationTitle.Text = 'Live Validation'
$lblValidationTitle.Location = New-Object System.Drawing.Point(10, 8)
$lblValidationTitle.Size = New-Object System.Drawing.Size(160, 22)
Style-Label -Label $lblValidationTitle -Size 10.5 -Bold $true
$validationCard.Controls.Add($lblValidationTitle)

$lblValidationBaseFolder = New-Object System.Windows.Forms.Label
$lblValidationBaseFolder.Text = '- Base Folder'
$lblValidationBaseFolder.Location = New-Object System.Drawing.Point(10, 36)
$lblValidationBaseFolder.Size = New-Object System.Drawing.Size(190, 21)
Style-Label -Label $lblValidationBaseFolder -Muted $true -Size 9.2
$validationCard.Controls.Add($lblValidationBaseFolder)

$lblValidationProjectName = New-Object System.Windows.Forms.Label
$lblValidationProjectName.Text = '- Project Name'
$lblValidationProjectName.Location = New-Object System.Drawing.Point(10, 58)
$lblValidationProjectName.Size = New-Object System.Drawing.Size(190, 21)
Style-Label -Label $lblValidationProjectName -Muted $true -Size 9.2
$validationCard.Controls.Add($lblValidationProjectName)

$lblValidationAppName = New-Object System.Windows.Forms.Label
$lblValidationAppName.Text = '- App Name'
$lblValidationAppName.Location = New-Object System.Drawing.Point(10, 80)
$lblValidationAppName.Size = New-Object System.Drawing.Size(190, 21)
Style-Label -Label $lblValidationAppName -Muted $true -Size 9.2
$validationCard.Controls.Add($lblValidationAppName)

$lblValidationAppId = New-Object System.Windows.Forms.Label
$lblValidationAppId.Text = '- App ID'
$lblValidationAppId.Location = New-Object System.Drawing.Point(10, 102)
$lblValidationAppId.Size = New-Object System.Drawing.Size(190, 21)
Style-Label -Label $lblValidationAppId -Muted $true -Size 9.2
$validationCard.Controls.Add($lblValidationAppId)

$lblValidationIndex = New-Object System.Windows.Forms.Label
$lblValidationIndex.Text = '- index.html'
$lblValidationIndex.Location = New-Object System.Drawing.Point(215, 36)
$lblValidationIndex.Size = New-Object System.Drawing.Size(190, 21)
Style-Label -Label $lblValidationIndex -Muted $true -Size 9.2
$validationCard.Controls.Add($lblValidationIndex)

$lblValidationApkMode = New-Object System.Windows.Forms.Label
$lblValidationApkMode.Text = '- APK Build'
$lblValidationApkMode.Location = New-Object System.Drawing.Point(215, 58)
$lblValidationApkMode.Size = New-Object System.Drawing.Size(190, 21)
Style-Label -Label $lblValidationApkMode -Muted $true -Size 9.2
$validationCard.Controls.Add($lblValidationApkMode)

$lblValidationJavaHome = New-Object System.Windows.Forms.Label
$lblValidationJavaHome.Text = '- Java Home'
$lblValidationJavaHome.Location = New-Object System.Drawing.Point(215, 80)
$lblValidationJavaHome.Size = New-Object System.Drawing.Size(190, 21)
Style-Label -Label $lblValidationJavaHome -Muted $true -Size 9.2
$validationCard.Controls.Add($lblValidationJavaHome)

$lblValidationAndroidSdk = New-Object System.Windows.Forms.Label
$lblValidationAndroidSdk.Text = '- Android SDK'
$lblValidationAndroidSdk.Location = New-Object System.Drawing.Point(215, 102)
$lblValidationAndroidSdk.Size = New-Object System.Drawing.Size(190, 21)
Style-Label -Label $lblValidationAndroidSdk -Muted $true -Size 9.2
$validationCard.Controls.Add($lblValidationAndroidSdk)

# ---------------- RIGHT CARD ----------------
$rightCard = New-CardPanel -X $rightCardX -Y $topCardsY -W $cardW -H $cardH
$rightCard.Anchor = 'Top,Left,Right'
$form.Controls.Add($rightCard)

$lblOptions = New-Object System.Windows.Forms.Label
$lblOptions.Text = 'Build Options'
$lblOptions.Location = New-Object System.Drawing.Point(16, 14)
$lblOptions.Size = New-Object System.Drawing.Size(200, 25)
Style-Label -Label $lblOptions -Size 12 -Bold $true
$rightCard.Controls.Add($lblOptions)

$lblAppId = New-Object System.Windows.Forms.Label
$lblAppId.Text = 'App ID'
$lblAppId.Location = New-Object System.Drawing.Point(16, 60)
$lblAppId.AutoSize = $true
Style-Label -Label $lblAppId -Muted $true
$rightCard.Controls.Add($lblAppId)

$txtAppId = New-Object System.Windows.Forms.TextBox
$txtAppId.Location = New-Object System.Drawing.Point(16, 82)
$txtAppId.Size = New-Object System.Drawing.Size(420, 28)
Style-TextBox $txtAppId
$rightCard.Controls.Add($txtAppId)

$lblAppIdStatus = New-Object System.Windows.Forms.Label
$lblAppIdStatus.Text = ''
$lblAppIdStatus.Location = New-Object System.Drawing.Point(16, 112)
$lblAppIdStatus.Size = New-Object System.Drawing.Size(420, 16)
Style-Label -Label $lblAppIdStatus -Muted $true -Size 8
$rightCard.Controls.Add($lblAppIdStatus)

$chkAssets = New-Object System.Windows.Forms.CheckBox
$chkAssets.Text = 'Ask to add icons and splash files during build'
$chkAssets.Checked = $false
$chkAssets.Visible = $false
$chkAssets.Location = New-Object System.Drawing.Point(-1000, -1000)
$rightCard.Controls.Add($chkAssets)

$chkLatestCapacitor = New-Object System.Windows.Forms.CheckBox
$chkLatestCapacitor.Text = 'Use latest Capacitor packages during build'
$chkLatestCapacitor.Location = New-Object System.Drawing.Point(18, 138)
$chkLatestCapacitor.AutoSize = $true
$chkLatestCapacitor.Checked = $script:UseLatestCapacitor
$chkLatestCapacitor.BackColor = $script:ColorPanel
$chkLatestCapacitor.ForeColor = $script:ColorText
$chkLatestCapacitor.Font = New-Object System.Drawing.Font('Segoe UI', 9)
$rightCard.Controls.Add($chkLatestCapacitor)

$chkBuildApkAfterSetup = New-Object System.Windows.Forms.CheckBox
$chkBuildApkAfterSetup.Text = 'Build debug APK after project setup'
$chkBuildApkAfterSetup.Location = New-Object System.Drawing.Point(18, 160)
$chkBuildApkAfterSetup.AutoSize = $true
$chkBuildApkAfterSetup.Checked = $false
$chkBuildApkAfterSetup.BackColor = $script:ColorPanel
$chkBuildApkAfterSetup.ForeColor = $script:ColorText
$chkBuildApkAfterSetup.Font = New-Object System.Drawing.Font('Segoe UI', 9)
$rightCard.Controls.Add($chkBuildApkAfterSetup)

$chkCleanGeneratedFiles = New-Object System.Windows.Forms.CheckBox
$chkCleanGeneratedFiles.Text = 'Clean generated files before build'
$chkCleanGeneratedFiles.Location = New-Object System.Drawing.Point(18, 182)
$chkCleanGeneratedFiles.AutoSize = $true
$chkCleanGeneratedFiles.Checked = $false
$chkCleanGeneratedFiles.BackColor = $script:ColorPanel
$chkCleanGeneratedFiles.ForeColor = $script:ColorText
$chkCleanGeneratedFiles.Font = New-Object System.Drawing.Font('Segoe UI', 9)
$rightCard.Controls.Add($chkCleanGeneratedFiles)

$btnCleanInfo = New-Object System.Windows.Forms.Button
$btnCleanInfo.Text = 'i'
$btnCleanInfo.Location = New-Object System.Drawing.Point(280, 178)
$btnCleanInfo.Size = New-Object System.Drawing.Size(28, 24)
Style-Button -Button $btnCleanInfo -BackColor $script:ColorButton -ForeColor $script:ColorText
$btnCleanInfo.Font = New-Object System.Drawing.Font('Segoe UI', 9, [System.Drawing.FontStyle]::Bold)
$rightCard.Controls.Add($btnCleanInfo)

$lblJavaHome = New-Object System.Windows.Forms.Label
$lblJavaHome.Text = 'Java Home'
$lblJavaHome.Location = New-Object System.Drawing.Point(16, 212)
$lblJavaHome.AutoSize = $true
Style-Label -Label $lblJavaHome -Muted $true
$rightCard.Controls.Add($lblJavaHome)

$txtJavaHome = New-Object System.Windows.Forms.TextBox
$txtJavaHome.Location = New-Object System.Drawing.Point(16, 234)
$txtJavaHome.Size = New-Object System.Drawing.Size(320, 28)
Style-TextBox $txtJavaHome
$rightCard.Controls.Add($txtJavaHome)

$btnBrowseJavaHome = New-Object System.Windows.Forms.Button
$btnBrowseJavaHome.Text = 'Browse'
$btnBrowseJavaHome.Location = New-Object System.Drawing.Point(342, 232)
$btnBrowseJavaHome.Size = New-Object System.Drawing.Size(94, 32)
Style-Button -Button $btnBrowseJavaHome -BackColor $script:ColorButton -ForeColor $script:ColorText
$rightCard.Controls.Add($btnBrowseJavaHome)

$lblJavaHomeHint = New-Object System.Windows.Forms.Label
$lblJavaHomeHint.Text = 'e.g. Program Files\Android\Android Studio\jbr'
$lblJavaHomeHint.Location = New-Object System.Drawing.Point(16, 266)
$lblJavaHomeHint.Size = New-Object System.Drawing.Size(420, 18)
Style-Label -Label $lblJavaHomeHint -Muted $true -Size 8
$rightCard.Controls.Add($lblJavaHomeHint)

$lblAndroidSdk = New-Object System.Windows.Forms.Label
$lblAndroidSdk.Text = 'Android SDK'
$lblAndroidSdk.Location = New-Object System.Drawing.Point(16, 290)
$lblAndroidSdk.AutoSize = $true
Style-Label -Label $lblAndroidSdk -Muted $true
$rightCard.Controls.Add($lblAndroidSdk)

$txtAndroidSdk = New-Object System.Windows.Forms.TextBox
$txtAndroidSdk.Location = New-Object System.Drawing.Point(16, 312)
$txtAndroidSdk.Size = New-Object System.Drawing.Size(320, 28)
Style-TextBox $txtAndroidSdk
$rightCard.Controls.Add($txtAndroidSdk)

$btnBrowseAndroidSdk = New-Object System.Windows.Forms.Button
$btnBrowseAndroidSdk.Text = 'Browse'
$btnBrowseAndroidSdk.Location = New-Object System.Drawing.Point(342, 310)
$btnBrowseAndroidSdk.Size = New-Object System.Drawing.Size(94, 32)
Style-Button -Button $btnBrowseAndroidSdk -BackColor $script:ColorButton -ForeColor $script:ColorText
$rightCard.Controls.Add($btnBrowseAndroidSdk)

$lblAndroidSdkHint = New-Object System.Windows.Forms.Label
$lblAndroidSdkHint.Text = 'e.g. Android\Sdk'
$lblAndroidSdkHint.Location = New-Object System.Drawing.Point(16, 344)
$lblAndroidSdkHint.Size = New-Object System.Drawing.Size(420, 18)
Style-Label -Label $lblAndroidSdkHint -Muted $true -Size 8
$rightCard.Controls.Add($lblAndroidSdkHint)

$btnAutoDetectPaths = New-Object System.Windows.Forms.Button
$btnAutoDetectPaths.Text = 'Auto Detect Paths'
$btnAutoDetectPaths.Location = New-Object System.Drawing.Point(16, 370)
$btnAutoDetectPaths.Size = New-Object System.Drawing.Size(135, 32)
Style-Button -Button $btnAutoDetectPaths -BackColor $script:ColorButton -ForeColor $script:ColorText
$rightCard.Controls.Add($btnAutoDetectPaths)

$btnPickPng = New-Object System.Windows.Forms.Button
$btnPickPng.Text = 'Select PNG Assets'
$btnPickPng.Location = New-Object System.Drawing.Point(16, 406)
$btnPickPng.Size = New-Object System.Drawing.Size(135, 32)
Style-Button -Button $btnPickPng -BackColor $script:ColorButton -ForeColor $script:ColorText
$rightCard.Controls.Add($btnPickPng)

$btnPngInfo = New-Object System.Windows.Forms.Button
$btnPngInfo.Text = 'i'
$btnPngInfo.Location = New-Object System.Drawing.Point(156, 406)
$btnPngInfo.Size = New-Object System.Drawing.Size(28, 32)
Style-Button -Button $btnPngInfo -BackColor $script:ColorButton -ForeColor $script:ColorText
$btnPngInfo.Font = New-Object System.Drawing.Font('Segoe UI', 9, [System.Drawing.FontStyle]::Bold)
$rightCard.Controls.Add($btnPngInfo)

$lblSelectedPng = New-Object System.Windows.Forms.Label
$lblSelectedPng.Text = 'PNG files: 0/5 selected'
$lblSelectedPng.Location = New-Object System.Drawing.Point(195, 412)
$lblSelectedPng.Size = New-Object System.Drawing.Size(150, 20)
Style-Label -Label $lblSelectedPng -Muted $true
$rightCard.Controls.Add($lblSelectedPng)

$btnClearAll = New-Object System.Windows.Forms.Button
$btnClearAll.Text = 'Clear All'
$btnClearAll.Location = New-Object System.Drawing.Point(356, 408)
$btnClearAll.Size = New-Object System.Drawing.Size(80, 28)
Style-Button -Button $btnClearAll -BackColor $script:ColorButton -ForeColor $script:ColorText
$rightCard.Controls.Add($btnClearAll)

# ---------------- LOG CARD ----------------
$logCard = New-CardPanel -X 20 -Y $logCardY -W 930 -H $logCardH
$logCard.Anchor = 'Top,Bottom,Left,Right'
$form.Controls.Add($logCard)

$lblBuildProgress = New-Object System.Windows.Forms.Label
$lblBuildProgress.Text = 'Build Progress'
$lblBuildProgress.Location = New-Object System.Drawing.Point(16, 10)
$lblBuildProgress.Size = New-Object System.Drawing.Size(200, 22)
Style-Label -Label $lblBuildProgress -Size 12 -Bold $true
$logCard.Controls.Add($lblBuildProgress)

$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(16, 34)
$progressBar.Size = New-Object System.Drawing.Size(895, 18)
$progressBar.Minimum = 0
$progressBar.Maximum = 100
$progressBar.Value = 0
$progressBar.Anchor = 'Top,Left,Right'
$logCard.Controls.Add($progressBar)

$lblProgress = New-Object System.Windows.Forms.Label
$lblProgress.Text = 'Ready'
$lblProgress.Location = New-Object System.Drawing.Point(16, 56)
$lblProgress.Size = New-Object System.Drawing.Size(895, 18)
$lblProgress.Anchor = 'Top,Left,Right'
Style-Label -Label $lblProgress -Muted $true
$logCard.Controls.Add($lblProgress)

$logBox = New-Object System.Windows.Forms.RichTextBox
$logBox.Multiline = $true
$logBox.ScrollBars = 'Vertical'
$logBox.Location = New-Object System.Drawing.Point(16, 76)
$logBox.Size = New-Object System.Drawing.Size(895, $logBoxH)
$logBox.ReadOnly = $true
$logBox.Anchor = 'Top,Bottom,Left,Right'
$logBox.BackColor = $script:ColorLogBg
$logBox.ForeColor = $script:ColorText
$logBox.BorderStyle = 'FixedSingle'
$logBox.Font = New-Object System.Drawing.Font('Consolas', 9)
$logCard.Controls.Add($logBox)

# ---------------- FOOTER ----------------
$footerPanel = New-Object System.Windows.Forms.Panel
$footerPanel.Location = New-Object System.Drawing.Point(0, $footerY)
$footerPanel.Size = New-Object System.Drawing.Size(980, $footerH)
$footerPanel.Anchor = 'Left,Right,Bottom'
$footerPanel.BackColor = $script:ColorHeader
$form.Controls.Add($footerPanel)

$btnRun = New-Object System.Windows.Forms.Button
$btnRun.Text = 'Build Project'
$btnRun.Location = New-Object System.Drawing.Point(20, 10)
$btnRun.Size = New-Object System.Drawing.Size(132, 32)
$btnRun.Anchor = 'Bottom,Left'
Style-AccentButton $btnRun
$footerPanel.Controls.Add($btnRun)

$lblBuildReadyStatus = New-Object System.Windows.Forms.Label
$lblBuildReadyStatus.Text = 'Ready to build'
$lblBuildReadyStatus.Location = New-Object System.Drawing.Point(158, 16)
$lblBuildReadyStatus.Size = New-Object System.Drawing.Size(112, 20)
$lblBuildReadyStatus.Anchor = 'Bottom,Left'
Style-Label -Label $lblBuildReadyStatus -Muted $true -Size 9 -Bold $true
$footerPanel.Controls.Add($lblBuildReadyStatus)

$btnOpenProject = New-Object System.Windows.Forms.Button
$btnOpenProject.Text = 'Open Project Folder'
$btnOpenProject.Location = New-Object System.Drawing.Point(274, 10)
$btnOpenProject.Size = New-Object System.Drawing.Size(134, 32)
$btnOpenProject.Enabled = $false
Style-Button -Button $btnOpenProject -BackColor $script:ColorButton -ForeColor $script:ColorText
$footerPanel.Controls.Add($btnOpenProject)

$btnOpenAndroid = New-Object System.Windows.Forms.Button
$btnOpenAndroid.Text = 'Open Android Studio'
$btnOpenAndroid.Location = New-Object System.Drawing.Point(416, 10)
$btnOpenAndroid.Size = New-Object System.Drawing.Size(134, 32)
$btnOpenAndroid.Enabled = $false
Style-Button -Button $btnOpenAndroid -BackColor $script:ColorButton -ForeColor $script:ColorText
$footerPanel.Controls.Add($btnOpenAndroid)

$btnOpenApkFolder = New-Object System.Windows.Forms.Button
$btnOpenApkFolder.Text = 'Open APK Folder'
$btnOpenApkFolder.Location = New-Object System.Drawing.Point(558, 10)
$btnOpenApkFolder.Size = New-Object System.Drawing.Size(122, 32)
$btnOpenApkFolder.Enabled = $false
Style-Button -Button $btnOpenApkFolder -BackColor $script:ColorButton -ForeColor $script:ColorText
$footerPanel.Controls.Add($btnOpenApkFolder)

$btnExportLog = New-Object System.Windows.Forms.Button
$btnExportLog.Text = 'Export Build Log'
$btnExportLog.Location = New-Object System.Drawing.Point(688, 10)
$btnExportLog.Size = New-Object System.Drawing.Size(122, 32)
$btnExportLog.Enabled = $false
Style-Button -Button $btnExportLog -BackColor $script:ColorButton -ForeColor $script:ColorText
$footerPanel.Controls.Add($btnExportLog)

$btnInstallApk = New-Object System.Windows.Forms.Button
$btnInstallApk.Text = 'Install APK to Device'
$btnInstallApk.Location = New-Object System.Drawing.Point(818, 10)
$btnInstallApk.Size = New-Object System.Drawing.Size(140, 32)
$btnInstallApk.Enabled = $false
Style-Button -Button $btnInstallApk -BackColor $script:ColorButton -ForeColor $script:ColorText
$footerPanel.Controls.Add($btnInstallApk)