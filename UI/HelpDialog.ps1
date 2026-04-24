function Get-HelpSections {
    $overview = @"
Android App Builder Helps You Create And Prepare An Android App Project From Your Web App Files.

What This App Can Do:
- Create A Capacitor Project.
- Copy Your Selected Index.html Into The Project.
- Optionally Add Selected PNG Assets.
- Optionally Build A Debug APK.
- Open The Project Folder.
- Open The Android Folder.
- Open The Built APK Folder.
- Install The APK To A Connected Android Phone.

This Tool Is Designed To Make The Common Setup Steps Easier, Especially For Beginners.
"@

    $requirements = @"
Required For Normal Project Setup:
- Node.js.
- Internet Connection For Npm Package Downloads.
- Index.html File.

Required For APK Builds:
- Java JDK.
- Android SDK.
- Android Platform Tools.
- Android Build Tools.

Optional:
- Android Studio.
- Android SDK Command-Line Tools.

Important:
Command-Line Tools Are Optional For Normal Builds.
They Are Only Needed If You Want This App To Automatically Install SDK Packages Using Sdkmanager.
"@

    $environment = @"
Environment Setup

The Environment Setup section checks whether your PC has the tools needed to build Android apps and APK files.

Java JDK:
- Required For Building APK Files.
- The selected Java Home folder must contain:
  bin\java.exe
- Android Studio often includes Java here:
  Program Files\Android\Android Studio\jbr
- You can also use another valid JDK such as OpenJDK or Oracle JDK.

Android SDK:
- Required For Building APK Files.
- This is the main Android tools folder.
- Android Studio often installs it here:
  AppData\Local\Android\Sdk
- The SDK should contain platform-tools and build-tools.

Platform Tools:
- Required For APK install/device features.
- Contains adb.exe.
- ADB is used to detect connected Android phones and install APK files.

Build Tools:
- Required For APK builds.
- Used by Android/Gradle to compile and package the app.

Command-Line Tools:
- Optional For normal builds.
- Not required if your app is already building successfully.
- Only needed for the Install Required SDK Packages button.
- Contains sdkmanager, which can install Android SDK packages automatically.

Scan Environment:
- Re-checks Java JDK, Android SDK, Platform Tools, Build Tools, and Command-Line Tools.
- Use this after changing Java Home or Android SDK paths.

Open SDK Folder:
- Opens your selected Android SDK folder in File Explorer.
- Useful for checking whether platform-tools, build-tools, or cmdline-tools exist.

Download JDK:
- Opens the JDK download page.
- Use this if Java JDK is missing.

Download Android Studio:
- Opens the official Android Studio download page.
- Android Studio is the easiest way for beginners to install the SDK, platform tools, build tools, and Java.

Install Required SDK Packages:
- Attempts to install Android SDK packages automatically.
- Requires Command-Line Tools / sdkmanager.
- If Command-Line Tools are missing, normal builds may still work.
- This button is only for automatic SDK package installation.

What Is Required For Building:
- Java JDK.
- Android SDK.
- Platform Tools.
- Build Tools.

What Is Only Needed For Automatic SDK Installation:
- Command-Line Tools.
- sdkmanager.

Backup Links:
JDK:
https://adoptium.net/en-GB/temurin/releases/

Android Studio:
https://developer.android.com/studio

Android SDK Command-Line Tools:
https://developer.android.com/studio#command-tools
"@

    $setup = @"
First-Time Setup

1. Install Node.js.
- This gives you Node and Npm.

2. Install Android Studio.
- This is the easiest beginner-friendly way to get:
  - Java.
  - Android SDK.
  - Platform Tools.
  - Build Tools.

3. Open Android Studio SDK Manager.
- Make sure the Android SDK is installed.
- Make sure Platform Tools are installed.
- Make sure Build Tools are installed.

4. Optional: Install Command-Line Tools.
- Only needed if you want this app to auto-install SDK packages.

5. In This App:
- Set Java Home.
- Set Android SDK Path.
- Click Scan Environment.

6. Optional Phone Install Setup:
- Enable Developer Options on your phone.
- Enable USB Debugging.
- Connect the phone by USB.
- Accept the debugging/trust prompt.
"@

    $usingBuilder = @"
How To Use This Builder

1. Choose Base Folder.
- This is where the project folder will be created.

2. Enter Project Name.
- This becomes the generated project folder name.

3. Enter App Name.
- This is the display name used during setup.

4. Enter App ID.
- Example:
  com.company.appname

5. Select index.html.
- Required.
- This is copied into the project's www folder.

6. Optional: Select PNG Assets.
- Supported tracked filenames:
  - icon-only.png
  - icon-foreground.png
  - icon-background.png
  - splash.png
  - splash-dark.png

7. Optional: Build Debug APK After Project Setup.
- Requires Java JDK and Android SDK paths.

8. Click Build Project.
- Watch the Build Progress log for errors and progress.
"@

    $buildApk = @"
Building An APK

To Build A Debug APK:
- Enable Build Debug APK After Project Setup.
- Java JDK must be found.
- Android SDK must be found.
- Platform Tools must be found.
- Build Tools must be found.

Command-Line Tools:
- Not required for normal APK builds if your SDK already has the required tools.
- Only needed for automatic SDK package installation.

Typical APK Output:
android\app\build\outputs\apk\debug\app-debug.apk

After A Successful Build:
- Open APK Folder becomes available.
- Install APK To Device becomes available.
"@

    $installDevice = @"
Installing To Phone

Required:
- Built APK.
- USB cable.
- USB Debugging enabled on phone.
- Platform Tools installed.
- adb.exe available inside platform-tools.

If No Device Is Found:
- Unlock the phone.
- Reconnect USB.
- Accept the USB debugging prompt.
- Make sure USB Debugging is enabled.
"@

    $troubleshooting = @"
Troubleshooting

Build Button Disabled:
- Check Base Folder.
- Check Project Name.
- Check App Name.
- Check App ID.
- Select index.html.
- If APK build is enabled, check Java and Android SDK.

Java JDK Not Found:
- Java Home must contain:
  bin\java.exe

Android SDK Not Found:
- SDK path should usually contain:
  platform-tools
  build-tools

Command-Line Tools Missing:
- This is usually OK.
- Builds can still work without them.
- They are only needed for Install Required SDK Packages.

Install Required SDK Packages Does Not Work:
- Install Android SDK Command-Line Tools.
- Make sure sdkmanager is available.

APK Missing:
- Check the build log.
- Gradle may have failed.

Cannot Delete Project Folder:
- Close Android Studio.
- Close terminals open inside the folder.
- Close App Builder.
- Restart PC if needed.
"@

    return [ordered]@{
        'Overview'            = $overview.Trim()
        'What You Need'       = $requirements.Trim()
        'Environment Setup'   = $environment.Trim()
        'First-Time Setup'    = $setup.Trim()
        'How To Use This App' = $usingBuilder.Trim()
        'Building An APK'     = $buildApk.Trim()
        'Installing To Phone' = $installDevice.Trim()
        'Troubleshooting'     = $troubleshooting.Trim()
    }
}

function Show-HelpDialog {
    $sections = Get-HelpSections

    $dialog = New-Object System.Windows.Forms.Form
    $dialog.Text = 'Help'
    $dialog.StartPosition = 'CenterParent'
    $dialog.Size = New-Object System.Drawing.Size(820, 620)
    $dialog.MinimumSize = New-Object System.Drawing.Size(820, 620)
    $dialog.FormBorderStyle = 'Sizable'
    $dialog.MaximizeBox = $true
    $dialog.MinimizeBox = $false
    $dialog.ShowInTaskbar = $false

    $dialog.BackColor = if ($script:IsDarkMode) { $script:DarkColorBg } else { $script:ColorBg }
    $dialog.ForeColor = if ($script:IsDarkMode) { $script:DarkColorText } else { $script:ColorText }

    $header = New-Object System.Windows.Forms.Label
    $header.Text = 'Android App Builder Help'
    $header.Location = New-Object System.Drawing.Point(18, 14)
    $header.Size = New-Object System.Drawing.Size(320, 26)
    Style-Label -Label $header -Size 13 -Bold $true
    $dialog.Controls.Add($header)

    $subHeader = New-Object System.Windows.Forms.Label
    $subHeader.Text = 'Everything A New User Needs To Get Started.'
    $subHeader.Location = New-Object System.Drawing.Point(20, 40)
    $subHeader.Size = New-Object System.Drawing.Size(420, 20)
    Style-Label -Label $subHeader -Muted $true -Size 9
    $dialog.Controls.Add($subHeader)

    $navPanel = New-Object System.Windows.Forms.Panel
    $navPanel.Location = New-Object System.Drawing.Point(20, 72)
    $navPanel.Size = New-Object System.Drawing.Size(210, 470)
    $navPanel.BorderStyle = 'FixedSingle'
    $navPanel.BackColor = if ($script:IsDarkMode) { $script:DarkColorPanel } else { $script:ColorPanel }
    $dialog.Controls.Add($navPanel)

    $contentPanel = New-Object System.Windows.Forms.Panel
    $contentPanel.Location = New-Object System.Drawing.Point(242, 72)
    $contentPanel.Size = New-Object System.Drawing.Size(540, 470)
    $contentPanel.BorderStyle = 'FixedSingle'
    $contentPanel.BackColor = if ($script:IsDarkMode) { $script:DarkColorPanel } else { $script:ColorPanel }
    $dialog.Controls.Add($contentPanel)

    $contentTitle = New-Object System.Windows.Forms.Label
    $contentTitle.Location = New-Object System.Drawing.Point(14, 12)
    $contentTitle.Size = New-Object System.Drawing.Size(500, 24)
    Style-Label -Label $contentTitle -Size 12 -Bold $true
    $contentPanel.Controls.Add($contentTitle)

    $contentBox = New-Object System.Windows.Forms.RichTextBox
    $contentBox.Location = New-Object System.Drawing.Point(14, 42)
    $contentBox.Size = New-Object System.Drawing.Size(510, 410)
    $contentBox.ReadOnly = $true
    $contentBox.BorderStyle = 'None'
    $contentBox.ScrollBars = 'Vertical'
    $contentBox.Multiline = $true
    $contentBox.DetectUrls = $true
    $contentBox.Font = New-Object System.Drawing.Font('Segoe UI', 10)
    $contentBox.BackColor = if ($script:IsDarkMode) { $script:DarkColorPanel } else { $script:ColorPanel }
    $contentBox.ForeColor = if ($script:IsDarkMode) { $script:DarkColorText } else { $script:ColorText }
    $contentPanel.Controls.Add($contentBox)

    $btnClose = New-Object System.Windows.Forms.Button
    $btnClose.Text = 'Close'
    $btnClose.Location = New-Object System.Drawing.Point(692, 550)
    $btnClose.Size = New-Object System.Drawing.Size(90, 30)
    Style-Button -Button $btnClose -BackColor $(if ($script:IsDarkMode) { $script:DarkColorButton } else { $script:ColorButton }) -ForeColor $(if ($script:IsDarkMode) { $script:DarkColorText } else { $script:ColorText })
    $dialog.Controls.Add($btnClose)

    $sectionButtons = New-Object System.Collections.Generic.List[System.Windows.Forms.Button]
    $buttonY = 12

    function Set-HelpContent {
        param(
            [string]$Title,
            [string]$Body,
            [System.Windows.Forms.Button]$ActiveButton,
            [System.Collections.Generic.List[System.Windows.Forms.Button]]$AllButtons
        )

        $contentTitle.Text = $Title
        $contentBox.Clear()
        $contentBox.Text = $Body
        $contentBox.SelectionStart = 0
        $contentBox.SelectionLength = 0

        foreach ($btn in $AllButtons) {
            Style-Button -Button $btn -BackColor $(if ($script:IsDarkMode) { $script:DarkColorButton } else { $script:ColorButton }) -ForeColor $(if ($script:IsDarkMode) { $script:DarkColorText } else { $script:ColorText })
        }

        if ($ActiveButton) {
            $ActiveButton.BackColor = $script:ColorAccent
            $ActiveButton.ForeColor = [System.Drawing.Color]::White
        }
    }

    foreach ($title in $sections.Keys) {
        $btnSection = New-Object System.Windows.Forms.Button
        $btnSection.Text = $title
        $btnSection.Tag = $title
        $btnSection.Location = New-Object System.Drawing.Point(10, $buttonY)
        $btnSection.Size = New-Object System.Drawing.Size(186, 36)
        Style-Button -Button $btnSection -BackColor $(if ($script:IsDarkMode) { $script:DarkColorButton } else { $script:ColorButton }) -ForeColor $(if ($script:IsDarkMode) { $script:DarkColorText } else { $script:ColorText })
        $navPanel.Controls.Add($btnSection)

        [void]$sectionButtons.Add($btnSection)

        $btnSection.Add_Click({
            param($sender, $eventArgs)

            $selectedTitle = [string]$sender.Tag
            $selectedBody = [string]$sections[$selectedTitle]
            Set-HelpContent -Title $selectedTitle -Body $selectedBody -ActiveButton $sender -AllButtons $sectionButtons
        })

        $buttonY += 42
    }

    $contentBox.Add_LinkClicked({
        param($sender, $eventArgs)
        try {
            Start-Process $eventArgs.LinkText
        }
        catch {
        }
    })

    $btnClose.Add_Click({
        $dialog.Close()
    })

    if ($sectionButtons.Count -gt 0) {
        $firstTitle = [string]$sectionButtons[0].Tag
        $firstBody = [string]$sections[$firstTitle]
        Set-HelpContent -Title $firstTitle -Body $firstBody -ActiveButton $sectionButtons[0] -AllButtons $sectionButtons
    }

    [void]$dialog.ShowDialog($form)
}