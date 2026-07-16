@echo off
title Vun Ven Spring Boot Backend
echo =========================================================
echo       KHOI DONG BACKEND VUN VEN (SPRING BOOT)            
echo =========================================================
echo Dang thiet lap Java Home tai C:\Program Files\Java\jdk-17...
set "JAVA_HOME=C:\Program Files\Java\jdk-17"
set "PATH=%JAVA_HOME%\bin;%PATH%"

cd vunven-backend
echo Dang chay backend tren cong 8080...
call mvnw spring-boot:run
if %ERRORLEVEL% neq 0 (
    echo.
    echo [LOI] Khong the chay ung dung. Vui long kiem tra SQL Server co dang hoat dong khong.
)
pause
