import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Thêm dependency intl vào pubspec.yaml

class Helpers {
  // Định dạng ngày tháng
  static String formatDate(DateTime? date, {String format = 'dd/MM/yyyy'}) {
    if (date == null) return '';
    return DateFormat(format).format(date);
  }

  static String formatDateTime(DateTime? dateTime, {String format = 'dd/MM/yyyy HH:mm'}) {
    if (dateTime == null) return '';
    return DateFormat(format).format(dateTime);
  }

  // Hiển thị SnackBar
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.secondary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Hiển thị Dialog cơ bản
  static Future<void> showAlertDialog({
    required BuildContext context,
    required String title,
    required String content,
    String confirmButtonText = 'OK',
    VoidCallback? onConfirm,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(content),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(confirmButtonText),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss dialog
                onConfirm?.call();
              },
            ),
          ],
        );
      },
    );
  }

  // Xác thực email
  static bool isValidEmail(String email) {
    return RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  // Ẩn bàn phím
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

// TODO: Thêm các hàm tiện ích khác nếu cần
}
