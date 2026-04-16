function Get-ExpectedApkPath {
    if ($script:LastBuiltApkPath -and (Test-Path $script:LastBuiltApkPath)) {
        return $script:LastBuiltApkPath
    }

    if ($script:LastProjectPath -and (Test-Path $script:LastProjectPath)) {
        $candidate = Join-Path $script:LastProjectPath 'android\app\build\outputs\apk\debug\app-debug.apk'
        if (Test-Path $candidate) {
            return $candidate
        }
    }

    return $null
}

function Update-ActionButtonsState {
    try {
        $projectExists = $false
        $androidExists = $false
        $apkPath = Get-ExpectedApkPath
        $apkExists = -not [string]::IsNullOrWhiteSpace($apkPath)

        if ($script:LastProjectPath -and (Test-Path $script:LastProjectPath)) {
            $projectExists = $true
        }

        if ($projectExists) {
            $androidPath = Join-Path $script:LastProjectPath 'android'
            $androidExists = (Test-Path $androidPath)
        }

        if ($apkExists) {
            $script:LastBuiltApkPath = $apkPath
        } else {
            $script:LastBuiltApkPath = $null
        }

        if ($btnOpenProject) { $btnOpenProject.Enabled = $projectExists }
        if ($btnOpenAndroid) { $btnOpenAndroid.Enabled = $androidExists }
        if ($btnOpenApkFolder) { $btnOpenApkFolder.Enabled = $apkExists }
        if ($btnInstallApk) { $btnInstallApk.Enabled = $apkExists }
    }
    catch {
    }
}

function Ensure-WindowInteropLoaded {
    if (-not ([System.Management.Automation.PSTypeName]'Win32.NativeMethods').Type) {
        Add-Type @"
using System;
using System.Runtime.InteropServices;

namespace Win32 {
    public static class NativeMethods {
        [DllImport("user32.dll")]
        public static extern bool SetForegroundWindow(IntPtr hWnd);

        [DllImport("user32.dll")]
        public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);

        [DllImport("user32.dll", SetLastError=true)]
        public static extern bool SetWindowPos(
            IntPtr hWnd,
            IntPtr hWndInsertAfter,
            int X,
            int Y,
            int cx,
            int cy,
            uint uFlags
        );

        public static readonly IntPtr HWND_BOTTOM = new IntPtr(1);
        public static readonly IntPtr HWND_NOTOPMOST = new IntPtr(-2);

        public const UInt32 SWP_NOSIZE = 0x0001;
        public const UInt32 SWP_NOMOVE = 0x0002;
        public const UInt32 SWP_NOACTIVATE = 0x0010;
    }
}
"@
    }
}

function Send-BuilderBehind {
    try {
        Ensure-WindowInteropLoaded

        if ($script:form -and $script:form.Handle -ne [IntPtr]::Zero) {
            $flags = [Win32.NativeMethods]::SWP_NOMOVE -bor `
                     [Win32.NativeMethods]::SWP_NOSIZE -bor `
                     [Win32.NativeMethods]::SWP_NOACTIVATE

            [Win32.NativeMethods]::SetWindowPos(
                $script:form.Handle,
                [Win32.NativeMethods]::HWND_NOTOPMOST,
                0, 0, 0, 0,
                $flags
            ) | Out-Null

            [Win32.NativeMethods]::SetWindowPos(
                $script:form.Handle,
                [Win32.NativeMethods]::HWND_BOTTOM,
                0, 0, 0, 0,
                $flags
            ) | Out-Null

            try { $script:form.SendToBack() } catch {}
        }
    }
    catch {
    }
}

function Bring-WindowToFront {
    param([IntPtr]$Handle)

    if ($Handle -eq [IntPtr]::Zero) { return }

    try {
        Ensure-WindowInteropLoaded
        [Win32.NativeMethods]::ShowWindowAsync($Handle, 9) | Out-Null
        Start-Sleep -Milliseconds 150
        [Win32.NativeMethods]::SetForegroundWindow($Handle) | Out-Null
    }
    catch {
    }
}

function Get-ExplorerWindowHandles {
    try {
        $shell = New-Object -ComObject Shell.Application
        $handles = @()

        foreach ($window in $shell.Windows()) {
            try {
                if ($window -and $window.HWND) {
                    $hwnd = [IntPtr]([int]$window.HWND)
                    if ($hwnd -ne [IntPtr]::Zero) {
                        $handles += $hwnd
                    }
                }
            }
            catch {
            }
        }

        return $handles
    }
    catch {
        return @()
    }
}

function Open-ApkFolder {
    param([string]$ApkPath)

    if ([string]::IsNullOrWhiteSpace($ApkPath)) { return }
    if (-not (Test-Path $ApkPath)) { return }

    $handlesBefore = Get-ExplorerWindowHandles

    Send-BuilderBehind
    Start-Sleep -Milliseconds 150

    try {
        Start-Process explorer.exe -ArgumentList "/select,`"$ApkPath`"" | Out-Null
    }
    catch {
        try {
            $apkFolder = Split-Path -Parent $ApkPath
            if (Test-Path $apkFolder) {
                Start-Process explorer.exe -ArgumentList "`"$apkFolder`"" | Out-Null
            } else {
                return
            }
        }
        catch {
            return
        }
    }

    $newHandle = [IntPtr]::Zero

    for ($i = 0; $i -lt 20; $i++) {
        Start-Sleep -Milliseconds 250
        $handlesAfter = Get-ExplorerWindowHandles
        $diff = $handlesAfter | Where-Object { $_ -notin $handlesBefore }

        if ($diff -and $diff.Count -gt 0) {
            $newHandle = $diff[-1]
            break
        }
    }

    if ($newHandle -ne [IntPtr]::Zero) {
        Bring-WindowToFront -Handle $newHandle
        return
    }

    try {
        Add-Type -AssemblyName Microsoft.VisualBasic -ErrorAction SilentlyContinue
        [Microsoft.VisualBasic.Interaction]::AppActivate('File Explorer') | Out-Null
    }
    catch {
    }
}

function Remove-GeneratedProjectFiles {
    param([string]$ProjectPath)

    $targets = @(
        (Join-Path $ProjectPath 'android'),
        (Join-Path $ProjectPath 'node_modules'),
        (Join-Path $ProjectPath 'assets'),
        (Join-Path $ProjectPath 'package-lock.json')
    )

    foreach ($target in $targets) {
        if (Test-Path $target) {
            try {
                Remove-Item -Path $target -Recurse -Force
                Write-Log ("Removed generated item: " + $target) 'WARN'
            }
            catch {
                Write-Log ("Could not remove generated item: " + $target) 'WARN'
            }
        }
    }
}

function Export-BuildLog {
    try {
        $projectPath = $script:LastProjectPath
        $defaultFolder = if ($projectPath -and (Test-Path $projectPath)) { $projectPath } else { $env:USERPROFILE }
        $timestamp = Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'

        $dialog = New-Object System.Windows.Forms.SaveFileDialog
        $dialog.Title = 'Export Build Log'
        $dialog.Filter = 'Text files (*.txt)|*.txt'
        $dialog.FileName = "build-log-$timestamp.txt"
        $dialog.InitialDirectory = $defaultFolder

        if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            [System.IO.File]::WriteAllText($dialog.FileName, $logBox.Text)
            Write-Log ("Exported build log: " + $dialog.FileName) 'SUCCESS'
        }
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show(
            $_.Exception.Message,
            'Export Build Log Failed',
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null
    }
}

function Get-AdbExecutablePath {
    $candidates = @()

    if (-not [string]::IsNullOrWhiteSpace($script:AndroidSdkPath)) {
        $candidates += (Join-Path $script:AndroidSdkPath 'platform-tools\adb.exe')
    }

    $candidates += 'adb.exe'

    foreach ($candidate in $candidates) {
        try {
            if ($candidate -eq 'adb.exe') {
                $cmd = Get-Command adb.exe -ErrorAction SilentlyContinue
                if ($cmd -and $cmd.Source) {
                    return $cmd.Source
                }
            } elseif (Test-Path $candidate) {
                return $candidate
            }
        }
        catch {
        }
    }

    return $null
}

function Invoke-ExternalProcess {
    param(
        [string]$FilePath,
        [string[]]$Arguments
    )

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $FilePath
    $psi.Arguments = ($Arguments -join ' ')
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.CreateNoWindow = $true

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $psi

    [void]$process.Start()
    $stdout = $process.StandardOutput.ReadToEnd()
    $stderr = $process.StandardError.ReadToEnd()
    $process.WaitForExit()

    return [pscustomobject]@{
        ExitCode = $process.ExitCode
        StdOut   = $stdout
        StdErr   = $stderr
    }
}

function Install-BuiltApkToDevice {
    try {
        $resolvedApkPath = Get-ExpectedApkPath
        if (-not $resolvedApkPath -or -not (Test-Path $resolvedApkPath)) {
            [System.Windows.Forms.MessageBox]::Show(
                'No built APK was found. Build the APK first.',
                'Install APK',
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Warning
            ) | Out-Null
            return
        }

        $script:LastBuiltApkPath = $resolvedApkPath

        $adbPath = Get-AdbExecutablePath
        if (-not $adbPath) {
            [System.Windows.Forms.MessageBox]::Show(
                'ADB was not found. Make sure Android SDK platform-tools are installed, or that adb.exe is available.',
                'Install APK',
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Error
            ) | Out-Null
            return
        }

        Write-Log ('Using ADB: ' + $adbPath) 'INFO'
        Write-Log 'Checking for connected Android devices...' 'INFO'

        $devicesResult = Invoke-ExternalProcess -FilePath $adbPath -Arguments @('devices')
        $deviceLines = @()

        if (-not [string]::IsNullOrWhiteSpace($devicesResult.StdOut)) {
            $deviceLines = $devicesResult.StdOut -split "`r?`n" | Where-Object {
                $_ -match '\tdevice$'
            }
        }

        if ($deviceLines.Count -eq 0) {
            Write-Log 'No Android device detected. Connect your phone by USB and allow USB debugging.' 'WARN'
            [System.Windows.Forms.MessageBox]::Show(
                'No Android device was detected.' + [Environment]::NewLine + [Environment]::NewLine +
                'Connect your phone by USB, enable USB debugging, and accept the trust prompt on the phone.',
                'Install APK',
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Warning
            ) | Out-Null
            return
        }

        Write-Log ('Detected device count: ' + $deviceLines.Count) 'SUCCESS'
        Write-Log ('Installing APK: ' + $resolvedApkPath) 'INFO'

        $installResult = Invoke-ExternalProcess -FilePath $adbPath -Arguments @('install', '-r', ('"' + $resolvedApkPath + '"'))

        if ($installResult.ExitCode -eq 0 -and ($installResult.StdOut -match 'Success')) {
            Write-Log 'APK installed successfully on connected device.' 'SUCCESS'
            [System.Windows.Forms.MessageBox]::Show(
                'APK installed successfully on the connected Android device.',
                'Install APK',
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Information
            ) | Out-Null
        } else {
            $errorText = ($installResult.StdErr + [Environment]::NewLine + $installResult.StdOut).Trim()
            if ([string]::IsNullOrWhiteSpace($errorText)) {
                $errorText = 'ADB install failed.'
            }

            Write-Log ('APK install failed: ' + $errorText) 'ERROR'
            [System.Windows.Forms.MessageBox]::Show(
                $errorText,
                'Install APK Failed',
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Error
            ) | Out-Null
        }
    }
    catch {
        Write-Log ('Install APK failed: ' + $_.Exception.Message) 'ERROR'
        [System.Windows.Forms.MessageBox]::Show(
            $_.Exception.Message,
            'Install APK Failed',
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null
    }
    finally {
        Update-ActionButtonsState
    }
}

function Start-ProjectBuild {
    try {
        $script:LastBuiltApkPath = $null
        Update-ActionButtonsState

        if ($btnRun) { $btnRun.Enabled = $false }

        $progressBar.Value = 0
        $logBox.Clear()
        if (Get-Command Update-ExportLogButtonState -ErrorAction SilentlyContinue) {
            Update-ExportLogButtonState
        }

        Set-ProgressStep 2 'Validating input...'

        $validationIssues = Get-BuildValidationIssues
        if ($validationIssues.Count -gt 0) {
            foreach ($issue in $validationIssues) {
                Write-Log $issue 'WARN'
            }

            Show-BuildValidationIssues $validationIssues
            Set-ProgressStep 0 'Validation failed'
            Update-BuildButtonState
            Update-ActionButtonsState
            return
        }

        $base = $txtFolder.Text.Trim()
        $proj = $txtProject.Text.Trim()
        $appName = $txtAppName.Text.Trim()
        $appId = Get-RealAppIdValue

        $shouldBuild = Show-BuildSummaryDialog -BaseFolder $base -ProjectName $proj -AppName $appName -AppId $appId
        if (-not $shouldBuild) {
            Write-Log 'Build cancelled from summary dialog.' 'WARN'
            Set-ProgressStep 0 'Build cancelled'
            Update-BuildButtonState
            Update-ActionButtonsState
            return
        }

        $projectPath = Join-Path $base $proj
        $script:LastProjectPath = $projectPath

        if ($script:UseLatestCapacitor) {
            Write-Log 'Using latest Capacitor packages' 'WARN'
        } else {
            Write-Log 'Using default Capacitor versions' 'INFO'
        }

        if ($chkCleanGeneratedFiles -and $chkCleanGeneratedFiles.Checked -and (Test-Path $projectPath)) {
            Set-ProgressStep 5 'Cleaning generated files...'
            Remove-GeneratedProjectFiles $projectPath
        }

        $assetResultStatus = 'No PNG assets selected'
        $apkResultStatus = 'Debug APK build disabled'
        $apkPath = Join-Path $projectPath 'android\app\build\outputs\apk\debug\app-debug.apk'

        New-Item -ItemType Directory -Path $projectPath -Force | Out-Null
        Write-Log ('Project folder: ' + $projectPath) 'INFO'

        Save-Settings $base $proj $appName $appId $false $projectPath $script:UseLatestCapacitor $script:BuildApkAfterSetup $script:form.Width $script:form.Height $script:form.Left $script:form.Top $script:form.WindowState.ToString()

        Set-ProgressStep 10 'Running npm init...'
        Run-Cmd 'npm init -y' $projectPath

        Set-ProgressStep 20 'Installing Capacitor core and CLI...'
        if ($script:UseLatestCapacitor) {
            Run-Cmd 'npm install @capacitor/core@latest @capacitor/cli@latest' $projectPath
        } else {
            Run-Cmd 'npm install @capacitor/core @capacitor/cli' $projectPath
        }

        Set-ProgressStep 30 'Initializing Capacitor...'
        Run-Cmd ('npx cap init "' + $appName + '" "' + $appId + '"') $projectPath

        Set-ProgressStep 40 'Creating www folder...'
        $wwwPath = Join-Path $projectPath 'www'
        New-Item -ItemType Directory -Path $wwwPath -Force | Out-Null
        Write-Log 'Created www folder' 'SUCCESS'

        Ensure-IndexFile $wwwPath

        Set-ProgressStep 52 'Installing Android platform package...'
        if ($script:UseLatestCapacitor) {
            Run-Cmd 'npm install @capacitor/android@latest' $projectPath
        } else {
            Run-Cmd 'npm install @capacitor/android' $projectPath
        }

        Set-ProgressStep 70 'Adding Android platform...'
        Run-Cmd 'npx cap add android' $projectPath

        Set-ProgressStep 80 'Running final sync...'
        Run-Cmd 'npx cap sync' $projectPath

        if (Test-AnySelectedPngAssets) {
            Set-ProgressStep 88 'Preparing selected PNG assets...'
            $assetsWereCopied = Ensure-Assets $projectPath

            if ($assetsWereCopied) {
                Set-ProgressStep 93 'Installing asset generator...'
                Run-Cmd 'npm install @capacitor/assets --save-dev' $projectPath

                Set-ProgressStep 97 'Generating Android assets...'
                Run-Cmd 'npx @capacitor/assets generate --android' $projectPath
                $assetResultStatus = 'Selected PNG assets generated'
            }
        } else {
            Write-Log 'No PNG assets selected. Skipping asset generation.' 'WARN'
        }

        if ($script:BuildApkAfterSetup) {
            $androidPath = Join-Path $projectPath 'android'
            $localPropertiesPath = Join-Path $androidPath 'local.properties'
            $escapedSdkPath = $script:AndroidSdkPath -replace '\\', '\\'
            Set-Content -Path $localPropertiesPath -Value ("sdk.dir=" + $escapedSdkPath) -Encoding ASCII
            Write-Log 'Created android\local.properties using selected Android SDK path' 'SUCCESS'

            $javaBin = Join-Path $script:JavaHomePath 'bin'
            $sdkPlatformTools = Join-Path $script:AndroidSdkPath 'platform-tools'
            $sdkEmulator = Join-Path $script:AndroidSdkPath 'emulator'
            $sdkCmdline = Join-Path $script:AndroidSdkPath 'cmdline-tools\latest\bin'

            $customPathParts = @($javaBin, $sdkPlatformTools, $sdkEmulator)
            if (Test-Path $sdkCmdline) {
                $customPathParts += $sdkCmdline
            }
            $customPathParts += $env:Path
            $customPath = ($customPathParts -join ';')

            $envOverrides = @{
                JAVA_HOME        = $script:JavaHomePath
                ANDROID_HOME     = $script:AndroidSdkPath
                ANDROID_SDK_ROOT = $script:AndroidSdkPath
                PATH             = $customPath
            }

            Set-ProgressStep 99 'Building debug APK...'
            Run-Cmd 'gradlew.bat assembleDebug' $androidPath -EnvironmentOverrides $envOverrides

            if (Test-Path $apkPath) {
                $apkResultStatus = 'Debug APK built successfully'
                $script:LastBuiltApkPath = $apkPath
                Write-Log ('APK created: ' + $apkPath) 'SUCCESS'
            } else {
                $apkResultStatus = 'Build finished, but APK was not found at expected path'
                Write-Log 'APK build finished, but the expected APK file was not found.' 'WARN'
            }
        }

        Save-Settings $base $proj $appName $appId $false $projectPath $script:UseLatestCapacitor $script:BuildApkAfterSetup $script:form.Width $script:form.Height $script:form.Left $script:form.Top $script:form.WindowState.ToString()

        Set-ProgressStep 100 'Build complete'
        Write-Log 'Build complete.' 'SUCCESS'

        Update-ActionButtonsState

        if ($script:LastBuiltApkPath -and (Test-Path $script:LastBuiltApkPath)) {
            Write-Log 'APK is ready. Opening APK folder now.' 'SUCCESS'
            Write-Log 'Use the footer buttons to reopen the APK folder or install the APK to your device.' 'INFO'
            Open-ApkFolder -ApkPath $script:LastBuiltApkPath
        } else {
            $latestCapStatus = if ($script:UseLatestCapacitor) { 'Enabled' } else { 'Disabled' }

            Show-BuildCompleteDialog `
                -ProjectPath $projectPath `
                -AppName $appName `
                -AppId $appId `
                -LatestCapacitorStatus $latestCapStatus `
                -AssetPromptStatus 'Removed' `
                -AssetResultStatus $assetResultStatus `
                -ApkBuildStatus $apkResultStatus `
                -ApkPath $apkPath
        }
    }
    catch {
        Write-Log ('ERROR: ' + $_.Exception.Message) 'ERROR'
        [System.Windows.Forms.MessageBox]::Show(
            $_.Exception.Message,
            'Build failed',
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null
    }
    finally {
        Update-BuildButtonState
        Update-ActionButtonsState
    }
}