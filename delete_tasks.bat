@echo off
echo 🚀 Script xóa toàn bộ tasks trong Firebase
echo ================================================

echo.
echo Chọn script để chạy:
echo 1. Python script (delete_all_tasks.py)
echo 2. Node.js script (delete_all_tasks.js)
echo.

set /p choice="Nhập lựa chọn (1 hoặc 2): "

if "%choice%"=="1" (
    echo.
    echo 🐍 Chạy Python script...
    python delete_all_tasks.py
) else if "%choice%"=="2" (
    echo.
    echo 📦 Chạy Node.js script...
    node delete_all_tasks.js
) else (
    echo ❌ Lựa chọn không hợp lệ!
    pause
    exit /b 1
)

echo.
echo ✅ Hoàn thành!
pause 