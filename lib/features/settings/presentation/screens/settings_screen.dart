import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../item/presentation/providers/item_provider.dart'
    show apiKeyProvider;

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apiKey = ref.watch(apiKeyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          // API Key Section
          ListTile(
            title: const Text('API Key'),
            subtitle: Text(
              apiKey ?? '未配置',
              style: TextStyle(
                color: apiKey != null ? Colors.green : Colors.grey,
              ),
            ),
            leading: const Icon(Icons.key),
            trailing: apiKey != null
                ? IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('清除 API Key'),
                          content: const Text(
                              '确定要清除已保存的 API Key 吗？'),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(context, false),
                              child: const Text('取消'),
                            ),
                            FilledButton(
                              onPressed: () =>
                                  Navigator.pop(context, true),
                              child: const Text('清除'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await ref
                            .read(apiKeyProvider.notifier)
                            .clearApiKey();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('API Key 已清除')),
                          );
                        }
                      }
                    },
                  )
                : const Icon(Icons.arrow_forward),
            onTap: () async {
              final controller = TextEditingController(
                text: apiKey ?? '',
              );

              final result = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('配置 API Key'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('请输入通义千问 API Key'),
                      const SizedBox(height: 16),
                      TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          hintText: 'sk-xxxxxxxxxxxxxxxx',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        autofocus: true,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '获取地址: https://dashscope.console.aliyun.com/',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('取消'),
                    ),
                    FilledButton(
                      onPressed: () {
                        if (controller.text.isNotEmpty) {
                          Navigator.pop(context, true);
                        }
                      },
                      child: const Text('保存'),
                    ),
                  ],
                ),
              );

              if (result == true && controller.text.isNotEmpty) {
                await ref
                    .read(apiKeyProvider.notifier)
                    .setApiKey(controller.text);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('API Key 已保存')),
                  );
                }
              }
            },
          ),

          const Divider(),

          // About Section
          ListTile(
            title: const Text('关于应用'),
            leading: const Icon(Icons.info),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: '物品追踪器',
                applicationVersion: '1.0.0',
                applicationIcon: const FlutterLogo(),
                children: [
                  const Text('AI驱动的物品位置追踪应用'),
                  const SizedBox(height: 16),
                  const Text('功能特性：'),
                  const Text('• AI物品识别'),
                  const Text('• 相机拍照 + 相册选择'),
                  const Text('• 物品搜索和清单'),
                  const Text('• 本地SQLite存储'),
                ],
              );
            },
          ),

          ListTile(
            title: const Text('开源许可'),
            leading: const Icon(Icons.code),
            onTap: () {
              showLicensePage(
                context: context,
                applicationName: '物品追踪器',
                applicationVersion: '1.0.0',
              );
            },
          ),
        ],
      ),
    );
  }
}
