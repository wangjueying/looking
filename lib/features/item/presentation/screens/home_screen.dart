import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/item_provider.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _checkApiKey();
  }

  Future<void> _checkApiKey() async {
    final apiKey = ref.read(apiKeyProvider);
    if (apiKey == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showApiKeyDialog();
      });
    }
  }

  void _showApiKeyDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('配置 API Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
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
            ),
            const SizedBox(height: 8),
            const Text(
              '获取地址: https://dashscope.console.aliyun.com/',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await ref.read(apiKeyProvider.notifier).setApiKey(controller.text);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('API Key 配置成功')),
                  );
                }
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImageFromCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('需要相机权限')),
        );
      }
      return;
    }

    final XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
    if (image != null && mounted) {
      context.go('/identify', extra: image.path);
    }
  }

  Future<void> _pickImageFromGallery() async {
    final status = await Permission.photos.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('需要相册权限')),
        );
      }
      return;
    }

    final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      context.go('/identify', extra: image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(itemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('物品追踪器'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _pickImageFromCamera,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('拍照识别'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _pickImageFromGallery,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('相册选择'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Recent items
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '最近记录',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton.icon(
                  onPressed: () => context.go('/items'),
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: const Text('查看全部'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Expanded(
              child: itemsAsync.isLoading
                  ? const LoadingIndicator(message: '加载中...')
                  : itemsAsync.items.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                '还没有物品记录',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: itemsAsync.items.length > 5
                              ? 5
                              : itemsAsync.items.length,
                          itemBuilder: (context, index) {
                            final item = itemsAsync.items[index];
                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: Text(item.itemName[0]),
                                ),
                                title: Text(item.itemName),
                                subtitle: Text(item.location),
                                trailing: Text(
                                  '${item.confidence.toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    color: item.confidence > 0.8
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                ),
                                onTap: () => context.go('/item/${item.id}'),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 1:
              context.go('/search');
              break;
            case 2:
              context.go('/items');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: '搜索',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: '清单',
          ),
        ],
      ),
    );
  }
}
