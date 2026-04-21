param(
    [string]$RepoPath = "D:\Users\Craig\Visual Studio\Android-App-Builder",
    [string]$Branch = "main"
)

$ErrorActionPreference = "Stop"

try {
    if (!(Test-Path $RepoPath)) {
        Write-Host "Repo path not found: $RepoPath" -ForegroundColor Red
        exit 1
    }

    Set-Location $RepoPath

    try {
        git rev-parse --is-inside-work-tree *> $null
    } catch {
        Write-Host "This folder is not a Git repository:" -ForegroundColor Red
        Write-Host $RepoPath -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Run these commands once in this folder first:" -ForegroundColor Cyan
        Write-Host "git init"
        Write-Host "git remote add origin https://github.com/YOURNAME/YOURREPO.git"
        Write-Host "git branch -M main"
        Write-Host 'git add .'
        Write-Host 'git commit -m "Initial commit"'
        Write-Host "git push -u origin main"
        exit 1
    }

    $status = git status --porcelain

    if (-not $status) {
        Write-Host "No changes to sync." -ForegroundColor Yellow
        exit 0
    }

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $message = "Manual sync $timestamp"

    Write-Host "Adding changed files..." -ForegroundColor Cyan
    git add .

    Write-Host "Creating commit..." -ForegroundColor Cyan
    git commit -m $message

    Write-Host "Pushing to GitHub..." -ForegroundColor Cyan
    git push origin $Branch

    Write-Host ""
    Write-Host "Sync complete." -ForegroundColor Green
    Write-Host "Commit message: $message" -ForegroundColor Green
}
catch {
    Write-Host ""
    Write-Host "Sync failed:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}