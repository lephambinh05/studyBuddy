# Setup Codemagic cho iOS Build

## Bước 1: Đăng ký Codemagic
1. Vào https://codemagic.io/
2. Đăng ký tài khoản miễn phí
3. Connect GitHub repository

## Bước 2: Tạo Workflow
1. Tạo file `codemagic.yaml` trong root project:

```yaml
workflows:
  ios-workflow:
    name: iOS Build
    environment:
      xcode: latest
      cocoapods: default
      vars:
        XCODE_WORKSPACE: "ios/Runner.xcworkspace"
        XCODE_SCHEME: "Runner"
    scripts:
      - name: Set up code signing settings
        script: |
          keychain initialize
          app-store-connect fetch-signing-files "com.studybuddy.app" --type IOS_APP_STORE --create
          keychain add-certificates
          xcode-project use-profiles
      - name: Get Flutter packages
        script: flutter pub get
      - name: Build iOS
        script: |
          flutter build ios --release --no-codesign
          xcode-project build-ipa --workspace ios/Runner.xcworkspace --scheme Runner
    artifacts:
      - build/ios/ipa/*.ipa
      - /tmp/xcodebuild_logs/*.log
      - flutter_drive.log
    publishing:
      app_store_connect:
        api_key: $APP_STORE_CONNECT_PRIVATE_KEY
        key_id: $APP_STORE_CONNECT_KEY_IDENTIFIER
        issuer_id: $APP_STORE_CONNECT_ISSUER_ID
        submit_to_testflight: true
```

## Bước 3: Setup App Store Connect
1. Vào https://appstoreconnect.apple.com/
2. Tạo app với Bundle ID: `com.studybuddy.app`
3. Tạo API Key cho Codemagic

## Bước 4: Chạy Build
1. Push code lên GitHub
2. Codemagic sẽ tự động build
3. Download IPA file từ Codemagic

## Lợi ích:
- ✅ Build trên macOS thật
- ✅ Tự động code signing
- ✅ Upload lên TestFlight
- ✅ Free tier có sẵn
- ✅ Không cần macOS local

## Chi phí:
- Free: 500 build minutes/tháng
- Paid: $99/tháng cho unlimited 