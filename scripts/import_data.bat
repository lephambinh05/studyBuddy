@echo off
echo ========================================
echo    StudyBuddy Data Import Script
echo ========================================
echo.

REM Kiểm tra Python có được cài đặt không
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Python chưa được cài đặt!
    echo Vui lòng cài đặt Python từ https://python.org
    pause
    exit /b 1
)

echo ✅ Python đã được cài đặt
echo.

REM Kiểm tra và cài đặt dependencies
echo 📦 Đang kiểm tra dependencies...
pip install -r requirements.txt >nul 2>&1
if errorlevel 1 (
    echo ⚠️ Có lỗi khi cài đặt dependencies
    echo Đang thử cài đặt lại...
    pip install firebase-admin google-cloud-firestore google-auth
)

echo ✅ Dependencies đã sẵn sàng
echo.

REM Chạy script import
echo 🚀 Bắt đầu import data...
python import_data.py

echo.
echo ========================================
echo    Import hoàn tất!
echo ========================================
pause 