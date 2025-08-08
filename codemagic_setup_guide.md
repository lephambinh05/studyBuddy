# 🚀 HƯỚNG DẪN DEPLOY TESTFLIGHT VỚI CODEMAGIC

## 📋 **Bước 1: Tạo App trên App Store Connect**

### 1.1 Truy cập App Store Connect
- Vào: https://appstoreconnect.apple.com
- Đăng nhập với Apple Developer Account

### 1.2 Tạo App mới
1. Click **"My Apps"**
2. Click **"+"** > **"New App"**
3. Điền thông tin:
   - **Platforms**: iOS
   - **Name**: StudyBuddy
   - **Primary Language**: English
   - **Bundle ID**: `com.studybuddy.app`
   - **SKU**: `studybuddy2024`
   - **User Access**: Full Access

### 1.3 Cấu hình App
1. Vào **App Information**
2. Điền **App Description**
3. Upload **App Icon** (1024x1024px)
4. Chọn **Category**: Education

## 🔑 **Bước 2: Tạo API Key**

### 2.1 Tạo Key trong App Store Connect
1. Vào **Users and Access** > **Keys**
2. Click **"+"** > **"Generate API Key"**
3. Điền thông tin:
   - **Name**: Codemagic CI/CD
   - **Role**: App Manager
   - **Key Type**: App Store Connect API

### 2.2 Lưu thông tin quan trọng
- **Key ID**: (ví dụ: `ABC123DEF4`)
- **Issuer ID**: (ví dụ: `57246b42-0d6e-4b3c-9c8d-1234567890ab`)
- **Private Key**: Tải file `.p8` về và lưu an toàn

## ⚙️ **Bước 3: Setup Codemagic**

### 3.1 Đăng ký Codemagic
1. Vào: https://codemagic.io
2. Đăng ký với GitHub account
3. Connect repository: `your-username/studybuddy`

### 3.2 Thêm Environment Variables
Trong Codemagic project settings, thêm:

```
APP_STORE_CONNECT_PRIVATE_KEY = [nội dung file .p8]
APP_STORE_CONNECT_KEY_IDENTIFIER = [Key ID]
APP_STORE_CONNECT_ISSUER_ID = [Issuer ID]
```

### 3.3 Cấu hình Bundle ID
Đảm bảo Bundle ID trong `codemagic.yaml` khớp với App Store Connect:
```yaml
app-store-connect fetch-signing-files "com.studybuddy.app" --type IOS_APP_STORE --create
```

## 🚀 **Bước 4: Deploy**

### 4.1 Trigger Build
1. Push code lên GitHub:
```bash
git add .
git commit -m "Ready for TestFlight deployment"
git push origin main
```

### 4.2 Monitor Build
1. Vào Codemagic dashboard
2. Theo dõi build progress
3. Kiểm tra logs nếu có lỗi

### 4.3 Kiểm tra TestFlight
1. Vào App Store Connect > **TestFlight**
2. App sẽ xuất hiện sau khi build thành công
3. Thêm testers và gửi build

## 📱 **Bước 5: Testing**

### 5.1 Internal Testing
1. Thêm team members làm internal testers
2. Gửi build cho internal testing
3. Test trên thiết bị thật

### 5.2 External Testing
1. Tạo external testing group
2. Thêm email testers
3. Gửi build cho external testing

## 🔧 **Troubleshooting**

### Lỗi thường gặp:
1. **Code signing issues**: Kiểm tra certificates
2. **Bundle ID mismatch**: Đảm bảo khớp với App Store Connect
3. **API Key permissions**: Kiểm tra role App Manager
4. **Build timeout**: Tăng timeout trong Codemagic settings

### Debug commands:
```bash
# Kiểm tra Bundle ID
grep -r "PRODUCT_BUNDLE_IDENTIFIER" ios/

# Kiểm tra certificates
security find-identity -v -p codesigning

# Clean build
flutter clean
flutter pub get
```

## ✅ **Checklist hoàn thành:**

- [ ] Tạo app trên App Store Connect
- [ ] Tạo API Key với role App Manager
- [ ] Setup Codemagic với environment variables
- [ ] Push code trigger build
- [ ] Build thành công trên Codemagic
- [ ] App xuất hiện trên TestFlight
- [ ] Thêm testers và gửi build
- [ ] Test trên thiết bị thật 