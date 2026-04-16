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
            Save-Settings $txtFolder.Text.Trim() $txtProject.Text.Trim() $txtAppName.Text.Trim() (Get-RealAppIdValue) $chkAssets.Checked $script:LastProjectPath
            return
        }
    }

    Set-Content -Path (Join-Path $wwwPath 'index.html') -Value '<!doctype html><html><head><meta charset="utf-8"><title>App</title></head><body><h1>Hello App</h1></body></html>'
    Write-Log 'No index.html provided. Created default index.html' 'WARN'
}