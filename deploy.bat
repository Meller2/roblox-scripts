@echo off
echo [DEPLOY] Pushing to GitHub...
git add .
git commit -m "Update %date% %time%"
git push origin master
echo [DEPLOY] Done!
pause
