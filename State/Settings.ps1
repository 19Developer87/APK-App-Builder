function Get-SettingsFolderPath {
    try {
        $localAppData = [Environment]::GetFolderPath('LocalApplicationData')
        if ([string]::IsNullOrWhiteSpace($localAppData)) {
            $localAppData = $env:LOCALAPPDATA
        }

        if ([string]::IsNullOrWhiteSpace($localAppData)) {
            throw 'Local AppData path could not be determined.'
        }

        return (Join-Path $localAppData 'AndroidAppBuilder')
    }
    catch {
        throw
    }
}

function Ensure-SettingsFolder {
    try {
        $settingsFolder = Get-SettingsFolderPath
        if (-not (Test-Path $settingsFolder)) {
            New-Item -ItemType Directory -Path $settingsFolder -Force | Out-Null
        }
        return $settingsFolder
    }
    catch {
        throw
    }
}

function Get-SettingsFilePath {
    try {
        $settingsFolder = Ensure-SettingsFolder
        return (Join-Path $settingsFolder 'builder-settings.json')
    }
    catch {
        throw
    }
}

function Save-Settings {
    param(
        [string]$BaseFolder,
        [string]$ProjectName,
        [string]$AppName,
        [string]$AppId,
        [bool]$AskAssets,
        [string]$LastProjectPath,
        [bool]$UseLatestCapacitor,
        [bool]$BuildApkAfterSetup,
        [int]$WindowWidth,
        [int]$WindowHeight,
        [int]$WindowLeft,
        [int]$WindowTop,
        [string]$WindowState
    )

    try {
        $script:SettingsPath = Get-SettingsFilePath

        $settings = [ordered]@{
            BaseFolder          = $BaseFolder
            ProjectName         = $ProjectName
            AppName             = $AppName
            AppId               = $AppId
            AskAssets           = $AskAssets
            LastProjectPath     = $LastProjectPath
            DarkMode            = [bool]$script:IsDarkMode
            UseLatestCapacitor  = $UseLatestCapacitor
            BuildApkAfterSetup  = $BuildApkAfterSetup
            JavaHomePath        = $script:JavaHomePath
            AndroidSdkPath      = $script:AndroidSdkPath
            SelectedIndexFile   = $script:SelectedIndexFile
            SelectedPngFiles    = $script:SelectedPngFiles
            WindowWidth         = $WindowWidth
            WindowHeight        = $WindowHeight
            WindowLeft          = $WindowLeft
            WindowTop           = $WindowTop
            WindowState         = $WindowState
        }

        $json = $settings | ConvertTo-Json -Depth 6
        Set-Content -Path $script:SettingsPath -Value $json -Encoding UTF8 -Force
    }
    catch {
        try {
            if (Get-Command Write-Log -ErrorAction SilentlyContinue) {
                Write-Log ("Could not save settings: " + $_.Exception.Message) 'WARN'
            }
        }
        catch {
        }
    }
}

function Load-Settings {
    try {
        $script:SettingsPath = Get-SettingsFilePath

        if (-not (Test-Path $script:SettingsPath)) {
            $script:WindowStateLoaded = $true

            if (Get-Command Set-AppIdPlaceholder -ErrorAction SilentlyContinue) {
                Set-AppIdPlaceholder
            }

            if (Get-Command Update-SelectedFileLabels -ErrorAction SilentlyContinue) {
                Update-SelectedFileLabels
            }

            if (Get-Command Update-ApkPathInputsState -ErrorAction SilentlyContinue) {
                Update-ApkPathInputsState
            }

            if (Get-Command Apply-Theme -ErrorAction SilentlyContinue) {
                Apply-Theme $script:IsDarkMode
            }

            return
        }

        $settings = Get-Content -Path $script:SettingsPath -Raw | ConvertFrom-Json

        if ($null -ne $settings.BaseFolder -and $txtFolder) {
            $txtFolder.Text = [string]$settings.BaseFolder
        }

        if ($null -ne $settings.ProjectName -and $txtProject) {
            $txtProject.Text = [string]$settings.ProjectName
        }

        if ($null -ne $settings.AppName -and $txtAppName) {
            $txtAppName.Text = [string]$settings.AppName
        }

        if ($null -ne $settings.LastProjectPath) {
            $script:LastProjectPath = [string]$settings.LastProjectPath
        }

        if ($null -ne $settings.UseLatestCapacitor) {
            $script:UseLatestCapacitor = [bool]$settings.UseLatestCapacitor
            if ($chkLatestCapacitor) {
                $chkLatestCapacitor.Checked = $script:UseLatestCapacitor
            }
        }

        if ($null -ne $settings.BuildApkAfterSetup) {
            $script:BuildApkAfterSetup = [bool]$settings.BuildApkAfterSetup
            if ($chkBuildApkAfterSetup) {
                $chkBuildApkAfterSetup.Checked = $script:BuildApkAfterSetup
            }
        }

        if ($null -ne $settings.JavaHomePath) {
            $script:JavaHomePath = [string]$settings.JavaHomePath
            if ($txtJavaHome) {
                $txtJavaHome.Text = $script:JavaHomePath
            }
        }

        if ($null -ne $settings.AndroidSdkPath) {
            $script:AndroidSdkPath = [string]$settings.AndroidSdkPath
            if ($txtAndroidSdk) {
                $txtAndroidSdk.Text = $script:AndroidSdkPath
            }
        }

        if ($null -ne $settings.SelectedIndexFile) {
            $script:SelectedIndexFile = [string]$settings.SelectedIndexFile
        }

        if ($null -ne $settings.SelectedPngFiles) {
            $restoredPngFiles = @{}
            foreach ($item in $settings.SelectedPngFiles.PSObject.Properties) {
                $restoredPngFiles[$item.Name] = [string]$item.Value
            }
            $script:SelectedPngFiles = $restoredPngFiles
        } elseif (-not $script:SelectedPngFiles) {
            $script:SelectedPngFiles = @{}
        }

        $appIdValue = $null
        if ($null -ne $settings.AppId) {
            $appIdValue = [string]$settings.AppId
        }

        if ($txtAppId) {
            if (-not [string]::IsNullOrWhiteSpace($appIdValue)) {
                $script:IsUpdatingAppIdProgrammatically = $true
                $txtAppId.Text = $appIdValue
                $txtAppId.Tag = $null
                $script:IsUpdatingAppIdProgrammatically = $false
                $script:AppIdManuallyEdited = $true
            } elseif (Get-Command Set-AppIdPlaceholder -ErrorAction SilentlyContinue) {
                Set-AppIdPlaceholder
                $script:AppIdManuallyEdited = $false
            }
        }

        if ($null -ne $settings.DarkMode) {
            $script:IsDarkMode = [bool]$settings.DarkMode
        }

        if ($form) {
            try {
                if ($settings.WindowWidth -and $settings.WindowHeight) {
                    $width = [int]$settings.WindowWidth
                    $height = [int]$settings.WindowHeight

                    if ($width -ge $form.MinimumSize.Width) {
                        $form.Width = $width
                    }

                    if ($height -ge $form.MinimumSize.Height) {
                        $form.Height = $height
                    }
                }

                if ($null -ne $settings.WindowLeft -and $null -ne $settings.WindowTop) {
                    $form.StartPosition = 'Manual'
                    $form.Left = [int]$settings.WindowLeft
                    $form.Top = [int]$settings.WindowTop
                }
            }
            catch {
            }
        }

        $script:WindowStateLoaded = $true

        if (Get-Command Update-SelectedFileLabels -ErrorAction SilentlyContinue) {
            Update-SelectedFileLabels
        }

        if (Get-Command Update-ApkPathInputsState -ErrorAction SilentlyContinue) {
            Update-ApkPathInputsState
        }

        if (Get-Command Apply-Theme -ErrorAction SilentlyContinue) {
            Apply-Theme $script:IsDarkMode
        }

        if ($form -and $settings.WindowState) {
            try {
                $savedState = [string]$settings.WindowState
                if ($savedState -eq 'Maximized') {
                    $form.WindowState = [System.Windows.Forms.FormWindowState]::Maximized
                }
            }
            catch {
            }
        }
    }
    catch {
        $script:WindowStateLoaded = $true

        try {
            if (Get-Command Set-AppIdPlaceholder -ErrorAction SilentlyContinue) {
                Set-AppIdPlaceholder
            }
        }
        catch {
        }

        try {
            if (Get-Command Apply-Theme -ErrorAction SilentlyContinue) {
                Apply-Theme $script:IsDarkMode
            }
        }
        catch {
        }

        try {
            if (Get-Command Write-Log -ErrorAction SilentlyContinue) {
                Write-Log ("Could not load settings: " + $_.Exception.Message) 'WARN'
            }
        }
        catch {
        }
    }
}