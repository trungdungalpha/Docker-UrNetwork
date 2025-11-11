@echo off
chcp 65001 >nul
echo ========================================
echo Git Push Script
echo ========================================
echo.

cd /d "%~dp0"
echo Current directory: %CD%
echo.

echo [1/4] Checking Git status...
git status
echo.

echo [2/4] Adding all files...
git add .
echo.

echo [3/4] Committing changes...
git commit -m "Add GUI close feature and GitHub Packages support"
echo.

echo [4/4] Pushing to GitHub...
git push origin main
echo.

echo ========================================
echo Done!
echo ========================================
pause


