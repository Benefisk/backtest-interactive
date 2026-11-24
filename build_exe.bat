@echo off
rem Пересборка настольного приложения BacktestChart (PyInstaller, onedir).
chcp 65001 >nul
cd /d "%~dp0"

echo Активация виртуального окружения...
call .venv\Scripts\activate.bat

echo Очистка старой сборки...
if exist build rmdir /s /q build
if exist dist\BacktestChart rmdir /s /q dist\BacktestChart

echo Сборка PyInstaller...
pyinstaller app.py --name BacktestChart --noconsole --noconfirm ^
    --add-data "web;web" --add-data "data;data"

if errorlevel 1 (
    echo.
    echo СБОРКА ЗАВЕРШИЛАСЬ С ОШИБКОЙ
    pause
    exit /b 1
)

echo.
echo Готово: dist\BacktestChart\BacktestChart.exe
pause
