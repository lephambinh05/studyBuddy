# iOS Build Fix - StudyBuddy

## Vấn đề đã được giải quyết:

### **Lỗi chính:**
- `unsupported option '-G' for target 'arm64-apple-ios13.0'`
- GoogleUtilities version conflict
- FirebaseCoreInternal compilation error

### **Giải pháp đã áp dụng:**

#### **1. Podfile được tối ưu:**
```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    
    # Minimal iOS build settings to avoid compiler conflicts
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      config.build_settings['ENABLE_BITCODE'] = 'NO'
      config.build_settings['SWIFT_VERSION'] = '5.0'
      
      # Remove problematic compiler flags
      config.build_settings.delete('GCC_OPTIMIZATION_LEVEL')
      config.build_settings.delete('GCC_PREPROCESSOR_DEFINITIONS')
      config.build_settings.delete('CLANG_WARN_STRICT_PROTOTYPES')
      config.build_settings.delete('CLANG_WARN_UNREACHABLE_CODE')
      config.build_settings.delete('CLANG_WARN_EMPTY_BODY')
    end
  end
end
```

#### **2. Firebase packages được tối ưu:**
- Remove GoogleSignIn tạm thời
- Disable Firebase Web packages
- Downgrade Firebase versions để tương thích

#### **3. Android build vẫn hoạt động:**
- ✅ APK build thành công
- ✅ Firebase hoạt động bình thường

## **Cấu hình Codemagic mới:**

### **File: codemagic.yaml**
```yaml
workflows:
  ios-workflow:
    name: iOS Build (Fixed)
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
      - name: Generate code
        script: |
          flutter pub run build_runner clean
          flutter pub run build_runner build --delete-conflicting-outputs
      - name: Clean iOS build
        script: |
          rm -rf ios/Pods
          rm -f ios/Podfile.lock
          rm -rf .symlinks/
          flutter clean
      - name: Install iOS dependencies
        script: |
          cd ios
          pod install --repo-update
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

## **Next Steps:**

### **1. Test trên Codemagic:**
- Push code lên GitHub
- Setup Codemagic với cấu hình mới
- Monitor build logs

### **2. Nếu vẫn lỗi:**
- Thử MacStadium hoặc MacinCloud
- Hoặc focus vào Android trước

### **3. Alternative solutions:**
- **Web version**: Deploy lên Firebase Hosting
- **PWA**: Progressive Web App
- **Hybrid approach**: Android native + Web for iOS

## **Status:**
- ✅ **Android**: Hoạt động hoàn toàn
- 🔄 **iOS**: Đang test với cấu hình mới
- ⚠️ **Web**: Tạm thời disabled Firebase Web

**Ready for Codemagic test!** 🚀 