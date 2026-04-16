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
Before Using This App, Make Sure The Following Are Available On Your Computer.

Required:
- Node.js.
- Android Development Tools.
- Internet Connection For Npm Package Downloads.

Recommended:
- Android Studio.

Node.js:
- Required For Npm And Project Package Installation.
- This App Uses Npm Commands During The Build Process.

Capacitor:
- Used By This Builder During Project Creation.
- You Do Not Need To Install Capacitor Globally If The Build Process Installs The Project Packages Correctly.

Java:
- Required When Building A Debug APK.
- You Are Not Limited To Android Studio's Built-In Java.
- A Valid Java Location Can Be:
  - Android Studio Jbr Folder.
  - OpenJDK.
  - Oracle JDK.
  - Another Valid Java Installation.
- Example:
  Program Files\Android\Android Studio\jbr

Android SDK:
- Required When Building A Debug APK.
- You Are Not Limited To Only One SDK Source.
- A Valid SDK Location Can Be:
  - Android Studio SDK.
  - Standalone Android SDK Installation.
  - Custom SDK Location.
- Example:
  Android\Sdk

USB Phone Connection:
- Needed If You Want To Install The APK Directly To A Real Android Phone.
- USB Debugging Must Be Enabled On The Phone.
"@

    $setup = @"
First-Time Setup

1. Install Node.js.
- This Gives You Node And Npm.

2. Install Android Studio.
- This Is The Easiest Way To Get:
  - Android SDK.
  - Platform-Tools.
  - Build Tools.
  - Cmdline-Tools.
  - A Usable Java Runtime.

3. In Android Studio, Make Sure The SDK Components Are Installed.
You Should Have:
- Android SDK.
- Platform-Tools.
- Build-Tools.
- Cmdline-Tools.

4. If You Want To Install APKs To Your Phone:
- Enable Developer Options On Your Phone.
- Enable USB Debugging.
- Connect The Phone By USB.
- Accept The Trust Or Debugging Prompt On The Device.

5. In This App, Enter:
- Java Home.
- Android SDK Path.

Tip:
Android Studio Often Installs Java Here:
Program Files\Android\Android Studio\jbr

Android Studio Often Installs SDK Here:
AppData\Local\Android\Sdk
"@

    $usingBuilder = @"
How To Use This Builder

1. Choose Base Folder.
- This Is Where The Project Folder Will Be Created.

2. Enter Project Name.
- This Becomes The Folder Name For The Generated Project.

3. Enter App Name.
- This Is The App Display Name Used During Setup.

4. Enter App ID.
- Example:
  com.company.appname
- It Must Start With com.
- It Must Use A Valid Package-Style Format.

5. Select Index.html.
- This Is Required.
- It Will Be Copied Into The Project's Www Folder.

6. Optional: Select PNG Assets.
- Use This Only If You Want To Generate Android Icon And Splash Assets.
- The Tracked Names Are:
  - icon-only.png
  - icon-foreground.png
  - icon-background.png
  - splash.png
  - splash-dark.png

7. Optional: Enable APK Build.
- If Enabled, The App Will Try To Build A Debug APK After Project Setup.

8. Press Build Project.
- The Log Panel Will Show Progress And Errors.
"@

    $buildApk = @"
Building An APK

To Build A Debug APK:
- Enable Build Debug APK After Project Setup.
- Provide A Valid Java Home Path.
- Provide A Valid Android SDK Path.

What Happens:
- The App Creates The Project.
- Installs Required Packages.
- Adds Android Platform Files.
- Syncs Capacitor.
- Builds A Debug APK Using Gradle.

Typical Output Path:
android\app\build\outputs\apk\debug\app-debug.apk

If A Build Finishes Successfully:
- Open APK Folder Will Become Available.
- Install APK To Device Will Become Available.
"@

    $installDevice = @"
Installing To Phone

This Feature Installs The Built Debug APK Onto A Connected Android Phone.

What You Need:
- A Built APK.
- USB Cable.
- USB Debugging Enabled On The Phone.
- ADB Available Through The Android SDK Platform-Tools.

How It Works:
- The App Checks For Adb.exe.
- The App Checks For A Connected Device.
- The App Runs An APK Install Command.

If No Device Is Found:
- Connect The Phone By USB.
- Unlock The Phone.
- Accept The USB Debugging Trust Prompt.
- Try Again.

This Feature Normally Uses USB.
Wireless Setup Is Possible In Android Development, But This Builder Is Intended For The Simpler USB Workflow.
"@

    $troubleshooting = @"
Troubleshooting

Build Button Stays Disabled.
- Check Base Folder.
- Check Project Name.
- Check App Name.
- Check App ID.
- Make Sure Index.html Is Selected.
- If APK Build Is Enabled, Make Sure Java Home And Android SDK Are Valid.

Java Home Invalid.
- Make Sure The Folder Contains:
  bin\java.exe

Android SDK Invalid.
- Make Sure The Folder Contains:
  platform-tools

No Device Detected.
- Connect Phone By USB.
- Enable USB Debugging.
- Accept The Trust Or Debug Prompt.
- Make Sure ADB Is Available.

APK Not Found.
- The Build May Have Failed.
- Check The Build Progress Log.
- Confirm Gradle Completed Successfully.

PNG Assets Not Applied.
- Make Sure The Filenames Match The Expected Tracked Names Exactly.

App ID Invalid.
- Use A Format Like:
  com.company.appname

Export Build Log Disabled.
- This Button Only Becomes Active When The Log Has Content.

Cannot Delete Project Folder.
- This usually means the folder is still being used by another process.

Common Causes.
- Android Studio Is Still Open.
- A PowerShell Or Terminal Window Is Open In The Project Folder.
- The App Builder Is Still Running A Process.
- A File Inside The Folder Is Still In Use.

Quick Fix.
- Close Android Studio.
- Close All PowerShell Or Terminal Windows.
- Close The App Builder.
- Wait A Few Seconds.
- Try Deleting The Folder Again.

If It Still Does Not Work.
- Restart Your PC And Delete The Folder Immediately After Logging In.

Advanced Fix.
- Open PowerShell As Administrator.
- Run:
  Remove-Item "C:\path\to\your\folder" -Recurse -Force

Tip.
- This can happen after building an app because background processes such as Node or Gradle may still be running.
"@

    return [ordered]@{
        'Overview'            = $overview.Trim()
        'What You Need'       = $requirements.Trim()
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

    if ($script:IsDarkMode) {
        $dialog.BackColor = $script:DarkColorBg
        $dialog.ForeColor = $script:DarkColorText
    } else {
        $dialog.BackColor = $script:ColorBg
        $dialog.ForeColor = $script:ColorText
    }

    $header = New-Object System.Windows.Forms.Label
    $header.Text = 'Android App Builder Help'
    $header.Location = New-Object System.Drawing.Point(18, 14)
    $header.Size = New-Object System.Drawing.Size(320, 26)
    Style-Label -Label $header -Size 13 -Bold $true
    $dialog.Controls.Add($header)

    $subHeader = New-Object System.Windows.Forms.Label
    $subHeader.Text = 'Everything A New User Needs To Get Started.'
    $subHeader.Location = New-Object System.Drawing.Point(20, 40)
    $subHeader.Size = New-Object System.Drawing.Size(340, 20)
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
    $contentBox.DetectUrls = $false
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
            if ($script:IsDarkMode) {
                $btn.BackColor = $script:DarkColorButton
                $btn.ForeColor = $script:DarkColorText
            } else {
                $btn.BackColor = $script:ColorButton
                $btn.ForeColor = $script:ColorText
            }
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