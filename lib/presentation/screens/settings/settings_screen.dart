import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studybuddy/presentation/providers/settings_provider.dart';
import 'package:studybuddy/presentation/providers/subject_provider.dart';
import 'package:studybuddy/presentation/providers/task_provider.dart';
import 'package:studybuddy/presentation/providers/event_provider.dart';
import 'package:studybuddy/presentation/providers/study_target_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsNotifier = ref.watch(settingsProvider.notifier);
    final currentAppThemeMode = settingsNotifier.currentAppThemeMode;
    // currentAppThemeMode là AppThemeMode enum của chúng ta,
    // còn ref.watch(settingsProvider) sẽ trả về ThemeMode của Material.

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0).copyWith(bottom: 8.0),
            child: Text(
              "Interface",
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.brightness_6_outlined),
            title: const Text("App Theme"),
            subtitle: Text(currentAppThemeMode.displayName),
            onTap: () async {
              final AppThemeMode? selectedTheme = await showDialog<AppThemeMode>(
                context: context,
                builder: (BuildContext context) {
                  return SimpleDialog(
                    title: const Text('Choose Theme'),
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

          // Cài đặt đồng bộ dữ liệu
          Padding(
            padding: const EdgeInsets.all(16.0).copyWith(bottom: 8.0),
            child: Text(
              "Sync data",
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.sync),
            title: const Text("Sync subjects"),
            subtitle: const Text("Sync subject data from device to cloud"),
            onTap: () async {
              try {
                await ref.read(subjectProvider.notifier).syncLocalToFirebase();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sync subjects successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error syncing: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.task),
            title: const Text("Sync tasks"),
            subtitle: const Text("Sync task data from device to cloud"),
            onTap: () async {
              try {
                await ref.read(taskProvider.notifier).syncLocalToFirebase();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sync tasks successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error syncing: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.event),
            title: const Text("Sync events"),
            subtitle: const Text("Sync event data from device to cloud"),
            onTap: () async {
              try {
                await ref.read(eventProvider.notifier).syncLocalToFirebase();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sync events successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error syncing: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.track_changes),
            title: const Text("Sync study targets"),
            subtitle: const Text("Sync study target data from device to cloud"),
            onTap: () async {
              try {
                await ref.read(studyTargetProvider.notifier).syncLocalToFirebase();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Sync study targets successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error syncing: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
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


