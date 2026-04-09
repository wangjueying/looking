import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/items_provider.dart';
import '../providers/settings_provider.dart';
import 'upload_tab.dart';
import 'search_tab.dart';
import 'items_tab.dart';
import 'settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;
  bool _hasShownApiDialog = false;

  final List<Widget> _tabs = const [
    UploadTab(),
    SearchTab(),
    ItemsTab(),
  ];

  @override
  void initState() {
    super.initState();
    // 加载物品列表
    Future.microtask(() {
      ref.read(itemsProvider.notifier).loadAllItems();
    });

    // 检查API Key配置 - 等待更长时间确保设置provider完全加载
    _checkApiKeyConfiguration();
  }

  void _checkApiKeyConfiguration() {
    // 延迟执行，确保UI和设置provider已经完全加载
    Future.delayed(const Duration(milliseconds: 1500), () async {
      if (mounted) {
        // 等待设置provider完成加载
        await ref.read(settingsProvider.notifier).loadApiKeyIfNeeded();

        final settingsState = ref.read(settingsProvider);
        if (settingsState.apiKey == null || settingsState.apiKey!.isEmpty) {
          if (!_hasShownApiDialog) {
            _showApiKeyConfigDialog();
          }
        }
      }
    });
  }

  void _showApiKeyConfigDialog() {
    if (_hasShownApiDialog) return;
    _hasShownApiDialog = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.key, color: Colors.orange),
            SizedBox(width: 8),
            Text('配置API Key'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('欢迎使用物品追踪器！'),
            SizedBox(height: 8),
            Text('为了使用AI识别功能，需要先配置通义千问API Key。'),
            SizedBox(height: 12),
            Text(
              '获取步骤：',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text('1. 访问 https://dashscope.console.aliyun.com/apiKey'),
            Text('2. 创建API Key'),
            Text('3. 复制并粘贴到下方'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
            child: const Text('去配置'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔍 物品追踪器'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // 重置对话框标记，这样如果用户删除了API key，下次返回时会再次提示
              _hasShownApiDialog = false;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              ).then((_) {
                // 从设置页面返回时，重新检查API Key配置
                _checkApiKeyConfiguration();
              });
            },
          ),
        ],
      ),
      body: _tabs[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.upload),
            label: '上传分析',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: '搜索物品',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: '物品清单',
          ),
        ],
      ),
    );
  }
}
