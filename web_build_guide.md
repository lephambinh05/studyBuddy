# Build Web Version cho iOS

## Vấn đề hiện tại:
- iOS build gặp lỗi FirebaseCoreInternal
- Web build cũng có lỗi Firebase Web versions

## Giải pháp tạm thời:

### 1. Build Web không có Firebase
```bash
# Tạm thời comment out Firebase trong pubspec.yaml
# firebase_core: ^2.24.0
# firebase_auth: ^4.15.0
# cloud_firestore: ^4.13.0

flutter pub get
flutter build web
```

### 2. Deploy lên Firebase Hosting
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Initialize
firebase init hosting

# Deploy
firebase deploy
```

### 3. Sử dụng như PWA
- Web app có thể cài đặt như app
- Hoạt động offline
- Push notifications (nếu setup)

## Lợi ích:
- ✅ Không cần iOS build
- ✅ Chạy trên mọi thiết bị
- ✅ Dễ deploy và update
- ✅ Free hosting với Firebase

## Nhược điểm:
- ❌ Không có native features
- ❌ Performance kém hơn native
- ❌ Không có Firebase (tạm thời) 