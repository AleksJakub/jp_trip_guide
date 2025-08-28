@echo off
echo Building web app with environment variables...

REM Read the .env file and extract GOOGLE_MAPS_API_KEY
for /f "tokens=1,2 delims==" %%a in (.env) do (
    if "%%a"=="GOOGLE_MAPS_API_KEY" (
        set API_KEY=%%b
        goto :found
    )
)

:found
if "%API_KEY%"=="" (
    echo ERROR: GOOGLE_MAPS_API_KEY not found in .env file
    exit /b 1
)

echo Found API key: %API_KEY%

REM Copy template and replace placeholder
copy web\index.html.template web\index.html >nul

REM Replace placeholder with actual API key (using PowerShell for better string replacement)
powershell -Command "(Get-Content web\index.html) -replace '{{GOOGLE_MAPS_API_KEY}}', '%API_KEY%' | Set-Content web\index.html"

echo Generated index.html with API key
echo Now run: flutter run -d chrome
