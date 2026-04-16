function Run-Cmd {
    param(
        [string]$Command,
        [string]$WorkingDirectory,
        [switch]$AllowFailure,
        [hashtable]$EnvironmentOverrides
    )

    Write-Log '' 'INFO'
    Write-Log ('> ' + $Command) 'COMMAND'

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = 'cmd.exe'
    $psi.Arguments = '/c ' + $Command
    $psi.WorkingDirectory = $WorkingDirectory
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true

    if ($EnvironmentOverrides) {
        foreach ($key in $EnvironmentOverrides.Keys) {
            $psi.EnvironmentVariables[$key] = [string]$EnvironmentOverrides[$key]
        }
    }

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $psi
    $null = $process.Start()

    $stdout = $process.StandardOutput.ReadToEnd()
    $stderr = $process.StandardError.ReadToEnd()
    $process.WaitForExit()

    if ($stdout) {
        foreach ($line in ($stdout -split "`r?`n")) {
            if ([string]::IsNullOrWhiteSpace($line)) { continue }

            if ($line -match 'added|created|generated|success|complete|synced|installed|BUILD SUCCESSFUL') {
                Write-Log $line 'SUCCESS'
            } else {
                Write-Log $line 'INFO'
            }
        }
    }

    if ($stderr) {
        foreach ($line in ($stderr -split "`r?`n")) {
            if ([string]::IsNullOrWhiteSpace($line)) { continue }

            if ($line -match '^\s*npm warn deprecated') { continue }
            if ($line -match '^\s*npm warn ') { continue }

            if ($line -match '^\s*Note:') {
                Write-Log $line 'WARN'
            }
            elseif ($line -match 'unchecked or unsafe operations') {
                Write-Log $line 'WARN'
            }
            elseif ($line -match 'Recompile with -Xlint:unchecked for details') {
                Write-Log $line 'WARN'
            }
            elseif ($line -match 'BUILD SUCCESSFUL') {
                Write-Log $line 'SUCCESS'
            }
            else {
                Write-Log $line 'ERROR'
            }
        }
    }

    if ($process.ExitCode -ne 0 -and -not $AllowFailure) {
        throw 'Command failed: ' + $Command
    }
}