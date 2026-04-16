function Pick-SingleFile {
    param(
        [string]$Title,
        [string]$Filter
    )

    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.Title = $Title
    $dialog.Filter = $Filter
    $dialog.Multiselect = $false

    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        return $dialog.FileName
    }

    return $null
}

function Pick-MultiplePngFiles {
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.Title = 'Select PNG asset files'
    $dialog.Filter = 'PNG files (*.png)|*.png'
    $dialog.Multiselect = $true

    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        return $dialog.FileNames
    }

    return @()
}

function Pick-Folder {
    param(
        [string]$Description,
        [string]$InitialPath = ''
    )

    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description = $Description

    if (-not [string]::IsNullOrWhiteSpace($InitialPath) -and (Test-Path $InitialPath)) {
        $dialog.SelectedPath = $InitialPath
    }

    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        return $dialog.SelectedPath
    }

    return $null
}