@echo off
title Mugt Gelsin Backend Watchdog
:restart
echo [%date% %time%] Starting Flask Backend...
python flask_backend.py
echo [%date% %time%] Backend CRASHED or CLOSED. Restarting in 5 seconds...
timeout /t 5
goto restart
