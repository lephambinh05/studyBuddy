import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studybuddy/presentation/providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentAppThemeMode = ref.watch(settingsProvider.notifier).currentAppThemeMode;
    // currentAppThemeMode là AppThemeMode enum của chúng ta,
    // còn ref.watch(settingsProvider) sẽ trả về ThemeMode của Material.

    return Scaffold(
      appBar: AppBar(
        title: const Text("Cài Đặt"),
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0).copyWith(bottom: 8.0),
            child: Text(
              "Giao diện",
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.brightness_6_outlined),
            title: const Text("Chủ đề ứng dụng"),
            subtitle: Text(currentAppThemeMode.displayName),
            onTap: () async {
              final AppThemeMode? selectedTheme = await showDialog<AppThemeMode>(
                context: context,
                builder: (BuildContext context) {
                  return SimpleDialog(
                    title: const Text('Chọn chủ đề'),
                    children: AppThemeMode.values.map((theme) {
                      return SimpleDialogOption(
                        onPressed: () {
                          Navigator.pop(context, theme);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(theme.displayName),
                              if (theme == currentAppThemeMode)
                                Icon(Icons.check, color: Theme.of(context).colorScheme.primary),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              );

              if (selectedTheme != null) {
                await ref.read(settingsProvider.notifier).setThemeMode(selectedTheme);
              }
            },
          ),
          const Divider(),

          // Ví dụ: Thêm các cài đặt khác ở đây
          // ListTile(
          //   leading: const Icon(Icons.notifications_outlined),
          //   title: const Text("Thông báo"),
          //   onTap: () {
          //     // Điều hướng đến màn hình cài đặt thông báo (nếu có)
          //   },
          // ),
          // const Divider(),

          // ListTile(
          //   leading: const Icon(Icons.info_outline),
          //   title: const Text("Về ứng dụng"),
          //   onTap: () {
          //     showAboutDialog(
          //       context: context,
          //       applicationName: 'StudyBuddy',
          //       applicationVersion: '1.0.0', // Lấy từ package_info
          //       applicationLegalese: '©2023 Your Company Name',
          //       children: <Widget>[
          //         const Padding(
          //           padding: EdgeInsets.only(top: 15),
          //           child: Text('Ứng dụng giúp bạn quản lý công việc học tập hiệu quả.'),
          //         )
          //       ],
          //     );
          //   },
          // ),
        ],
      ),
    );
  }
}


