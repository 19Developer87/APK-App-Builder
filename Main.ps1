Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = 'Stop'

function Get-AppBasePath {
    try {
        if ($PSScriptRoot -and (Test-Path $PSScriptRoot)) {
            return $PSScriptRoot
        }
    }
    catch {
    }

    try {
        $exePath = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName
        if ($exePath) {
            $exeFolder = Split-Path -Parent $exePath
            if ($exeFolder -and (Test-Path $exeFolder)) {
                return $exeFolder
            }
        }
    }
    catch {
    }

    try {
        $baseDir = [System.AppDomain]::CurrentDomain.BaseDirectory
        if ($baseDir -and (Test-Path $baseDir)) {
            return $baseDir.TrimEnd('\')
        }
    }
    catch {
    }

    throw 'Could not determine the application base folder.'
}

try {
    $script:AppBasePath = Get-AppBasePath

    . (Join-Path $script:AppBasePath 'Config\AppConfig.ps1')
    . (Join-Path $script:AppBasePath 'Logging\Logger.ps1')
    . (Join-Path $script:AppBasePath 'State\AppId.ps1')
    . (Join-Path $script:AppBasePath 'State\Settings.ps1')
    . (Join-Path $script:AppBasePath 'State\UpdateChecker.ps1')
    . (Join-Path $script:AppBasePath 'Files\FileSelectors.ps1')
    . (Join-Path $script:AppBasePath 'Files\Assets.ps1')
    . (Join-Path $script:AppBasePath 'Build\Validation.ps1')
    . (Join-Path $script:AppBasePath 'Build\BuildRunner.ps1')
    . (Join-Path $script:AppBasePath 'Build\ProjectBuild.ps1')
    . (Join-Path $script:AppBasePath 'UI\Controls.ps1')
    . (Join-Path $script:AppBasePath 'UI\Dialogs.ps1')
    . (Join-Path $script:AppBasePath 'UI\HelpDialog.ps1')
    . (Join-Path $script:AppBasePath 'Themes\ThemeManager.ps1')
    . (Join-Path $script:AppBasePath 'Events\EventHandlers.ps1')

    $requiredFunctions = @(
        'Save-Settings',
        'Load-Settings',
        'Write-Log',
        'Set-ProgressStep',
        'Ensure-IndexFile',
        'Ensure-Assets',
        'Start-ProjectBuild',
        'Show-BuildSummaryDialog',
        'Show-BuildCompleteDialog',
        'Update-AppIdValidationState',
        'Update-BuildButtonState',
        'Update-ActionButtonsState',
        'Show-HelpDialog',
        'Invoke-CheckForUpdates'
    )

    foreach ($fn in $requiredFunctions) {
        if (-not (Get-Command $fn -ErrorAction SilentlyContinue)) {
            throw "Required function was not loaded: $fn"
        }
    }

    if (-not $script:form) {
        throw 'The main form was not created correctly.'
    }

    Load-Settings

    if (Get-Command Update-ActionButtonsState -ErrorAction SilentlyContinue) {
        Update-ActionButtonsState
    }

    if (Get-Command Update-ExportLogButtonState -ErrorAction SilentlyContinue) {
        Update-ExportLogButtonState
    }

    $script:form.Add_Shown({
        try {
            if ($script:AutoCheckUpdatesOnStartup -and (Get-Command Invoke-CheckForUpdates -ErrorAction SilentlyContinue)) {
                Invoke-CheckForUpdates -Interactive:$false -OnlyNotifyIfUpdateAvailable:$true
            }
        }
        catch {
        }
    })

    [void]$script:form.ShowDialog()
}
catch {
    $msg = @(
        "Message:"
        $_.Exception.Message
        ""
        "Script:"
        $_.InvocationInfo.ScriptName
        ""
        "Line:"
        $_.InvocationInfo.ScriptLineNumber
        ""
        "Code:"
        $_.InvocationInfo.Line
        ""
        "Position:"
        $_.InvocationInfo.PositionMessage
    ) -join [Environment]::NewLine

    [System.Windows.Forms.MessageBox]::Show(
        $msg,
        'Startup failed',
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    ) | Out-Null
}