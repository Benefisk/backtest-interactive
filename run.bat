@echo off
cd /d "%~dp0"
title Бэктест стратегии SMA

REM Ищем Python: пробуем python, затем лаунчер py
where python >nul 2>nul
if errorlevel 1 goto :try_py
set "PY=python"
goto :python_ok
:try_py
where py >nul 2>nul
if errorlevel 1 goto :no_python
set "PY=py"
goto :python_ok

:no_python
echo.
echo  Python не найден на компьютере.
echo  Установите Python 3.10+ с https://www.python.org/downloads/
echo  Важно: при установке поставьте галочку "Add python.exe to PATH".
echo.
pause
exit /b 1

:python_ok
REM При первом запуске создаём виртуальное окружение
if exist ".venv\Scripts\python.exe" goto :venv_ok
echo Создаю виртуальное окружение, один раз...
"%PY%" -m venv .venv
if errorlevel 1 goto :venv_fail
:venv_ok

REM При первом запуске устанавливаем зависимости, проверяем по импорту
".venv\Scripts\python.exe" -c "import pandas, requests, webview" >nul 2>nul
if not errorlevel 1 goto :deps_ok
echo Устанавливаю зависимости: первый запуск, нужен интернет, пара минут...
".venv\Scripts\python.exe" -m pip install -r requirements.txt
if errorlevel 1 goto :deps_fail
:deps_ok

echo Запускаю приложение...
".venv\Scripts\python.exe" app.py
if errorlevel 1 pause
exit /b 0

:venv_fail
echo Не удалось создать виртуальное окружение.
pause
exit /b 1

:deps_fail
echo Не удалось установить зависимости. Проверьте интернет и повторите.
pause
exit /b 1
