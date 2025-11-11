# Git Push Script for Docker-UrNetwork
$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Git Push Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Get script directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptPath

Write-Host "Current directory: $PWD" -ForegroundColor Yellow
Write-Host ""

# Check if .git exists
if (-not (Test-Path .git)) {
    Write-Host "Error: .git folder not found!" -ForegroundColor Red
    Write-Host "Please run git-setup.bat first or initialize git repository." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

try {
    Write-Host "[1/4] Checking Git status..." -ForegroundColor Green
    git status
    Write-Host ""

    Write-Host "[2/4] Adding all files..." -ForegroundColor Green
    git add .
    Write-Host ""

    Write-Host "[3/4] Committing changes..." -ForegroundColor Green
    git commit -m "Add GUI close feature and GitHub Packages support"
    Write-Host ""

    Write-Host "[4/4] Pushing to GitHub..." -ForegroundColor Green
    git push origin main
    Write-Host ""

    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Done! Successfully pushed to GitHub!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Check your GitHub Actions:" -ForegroundColor Yellow
    Write-Host "https://github.com/trungdungalpha/Docker-UrNetwork/actions" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Check your GitHub Packages:" -ForegroundColor Yellow
    Write-Host "https://github.com/trungdungalpha/Docker-UrNetwork/pkgs/container/docker-urnetwork" -ForegroundColor Cyan
} catch {
    Write-Host ""
    Write-Host "Error occurred: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please check:" -ForegroundColor Yellow
    Write-Host "1. Are you logged in to GitHub?" -ForegroundColor Yellow
    Write-Host "2. Do you have permission to push to this repository?" -ForegroundColor Yellow
    Write-Host "3. Is the remote URL correct?" -ForegroundColor Yellow
}

Write-Host ""
Read-Host "Press Enter to exit"


