@echo off
chcp 65001 >nul
echo ========================================
echo Git Setup Script
echo ========================================
echo.

cd /d "%~dp0"
echo Current directory: %CD%
echo.

echo Checking if .git exists...
if exist .git (
    echo .git folder found!
    git status
) else (
    echo .git folder not found. Initializing...
    git init
    echo.
    echo Adding remote repository...
    git remote add origin https://github.com/trungdungalpha/Docker-UrNetwork.git
    echo.
    echo Remote added successfully!
    git remote -v
)
echo.
echo ========================================
echo Setup complete!
echo ========================================
pause


