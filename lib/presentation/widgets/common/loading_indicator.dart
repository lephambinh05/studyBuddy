import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final double? strokeWidth;
  final Color? color;
  final double? value; // For determinate progress
  final String? message; // Optional message to display

  const LoadingIndicator({
    super.key,
    this.strokeWidth,
    this.color,
    this.value,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: strokeWidth ?? 4.0,
            valueColor: color != null ? AlwaysStoppedAnimation<Color>(color!) : null,
            value: value,
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                color: color ?? Theme.of(context).primaryColor,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}