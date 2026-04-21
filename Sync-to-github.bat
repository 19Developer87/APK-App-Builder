@echo off
title Android App Builder - Sync to GitHub

cd /d "D:\Users\Craig\Visual Studio\Android-App-Builder"

echo Pulling latest changes first...
git pull origin main

echo.
echo Adding changes...
git add .

echo.
echo Committing...
git commit -m "Manual sync %date% %time%"

echo.
echo Pushing to GitHub...
git push origin main

echo.
echo Done!
pause