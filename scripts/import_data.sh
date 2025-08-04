#!/bin/bash

echo "========================================"
echo "   StudyBuddy Data Import Script"
echo "========================================"
echo

# Kiểm tra Python có được cài đặt không
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 chưa được cài đặt!"
    echo "Vui lòng cài đặt Python3 từ https://python.org"
    exit 1
fi

echo "✅ Python3 đã được cài đặt"
echo

# Kiểm tra và cài đặt dependencies
echo "📦 Đang kiểm tra dependencies..."
pip3 install -r requirements.txt > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "⚠️ Có lỗi khi cài đặt dependencies"
    echo "Đang thử cài đặt lại..."
    pip3 install firebase-admin google-cloud-firestore google-auth
fi

echo "✅ Dependencies đã sẵn sàng"
echo

# Chạy script import
echo "🚀 Bắt đầu import data..."
python3 import_data.py

echo
echo "========================================"
echo "   Import hoàn tất!"
echo "========================================" 