import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studybuddy/data/models/user.dart';
import 'package:studybuddy/presentation/providers/auth_provider.dart';
// import 'package:image_picker/image_picker.dart'; // Nếu cho phép chọn ảnh đại diện
// import 'package:firebase_storage/firebase_storage.dart'; // Nếu upload ảnh lên Storage
// import 'dart:io'; // Cho File

enum ProfileEditStatus { view, editing, saving, error }

class ProfileState {
  final ProfileEditStatus status;
  final String? errorMessage;
  // Bạn có thể giữ một bản sao của UserModel đang được chỉnh sửa ở đây
  final UserModel? editableUser;

  ProfileState({
    this.status = ProfileEditStatus.view,
    this.errorMessage,
    this.editableUser,
  });

  ProfileState copyWith({
    ProfileEditStatus? status,
    String? errorMessage,
    UserModel? editableUser,
    bool clearEditableUser = false,
  }) {
    return ProfileState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      editableUser: clearEditableUser ? null : editableUser ?? this.editableUser,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final AuthNotifier _authNotifier; // Để cập nhật user thông qua AuthNotifier
  // final FirebaseStorage? _storage; // Nếu có upload ảnh
  // final ImagePicker _picker = ImagePicker();

  ProfileNotifier(this._authNotifier /*, this._storage */) : super(ProfileState());

  // Bắt đầu chỉnh sửa profile
  void startEditing(UserModel currentUser) {
    state = state.copyWith(
      status: ProfileEditStatus.editing,
      editableUser: currentUser.copyWith(), // Tạo bản sao để chỉnh sửa
      errorMessage: null,
    );
  }

  // Hủy chỉnh sửa
  void cancelEditing() {
    state = state.copyWith(status: ProfileEditStatus.view, clearEditableUser: true, errorMessage: null);
  }

  // Cập nhật một trường trong editableUser
  void updateEditableUserField({String? displayName, String? email /* các trường khác */}) {
    if (state.status != ProfileEditStatus.editing || state.editableUser == null) return;
    state = state.copyWith(
      editableUser: state.editableUser!.copyWith(
        displayName: displayName ?? state.editableUser!.displayName,
        email: email ?? state.editableUser!.email,
        // Cập nhật các trường khác tương tự
      ),
    );
  }

  // Lưu thay đổi
  Future<void> saveChanges() async {
    if (state.status != ProfileEditStatus.editing || state.editableUser == null) return;

    state = state.copyWith(status: ProfileEditStatus.saving, errorMessage: null);
    try {
      await _authNotifier.updateAppUser(state.editableUser!);
      state = state.copyWith(status: ProfileEditStatus.view, clearEditableUser: true);
    } catch (e) {
      state = state.copyWith(status: ProfileEditStatus.error, errorMessage: e.toString());
      // Không clear editableUser để người dùng có thể thử lại
    }
  }

// Ví dụ: Thay đổi ảnh đại diện
// Future<void> changeProfilePicture() async {
//   if (state.status != ProfileEditStatus.editing || state.editableUser == null || _storage == null) return;

//   final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
//   if (image == null) return;

//   state = state.copyWith(status: ProfileEditStatus.saving); // Hoặc một trạng thái "uploading" riêng

//   try {
//     File imageFile = File(image.path);
//     String userId = state.editableUser!.id;
//     String fileName = 'profile_pictures/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
//     Reference ref = _storage!.ref().child(fileName);
//     UploadTask uploadTask = ref.putFile(imageFile);
//     TaskSnapshot snapshot = await uploadTask;
//     String downloadUrl = await snapshot.ref.getDownloadURL();

//     // Cập nhật editableUser với photoUrl mới
//     updateEditableUserField(photoUrl: downloadUrl); // Cần thêm photoUrl vào UserModel và copyWith
//     // Sau đó gọi saveChanges() để lưu vào Firestore
//     await saveChanges(); // Hoặc tách riêng logic upload và save user model
//   } catch (e) {
//     state = state.copyWith(status: ProfileEditStatus.error, errorMessage: "Failed to upload image: $e");
//   }
// }
}

final profileNotifierProvider = StateNotifierProvider.autoDispose<ProfileNotifier, ProfileState>((ref) {
  final authNotifier = ref.read(authNotifierProvider.notifier);
  // final storage = ref.watch(firebaseStorageProvider); // Nếu dùng
  return ProfileNotifier(authNotifier /*, storage */);
});

// Provider tiện ích để lấy UserModel đang được chỉnh sửa
final editableUserProvider = Provider.autoDispose<UserModel?>((ref) {
  return ref.watch(profileNotifierProvider).editableUser;
});

