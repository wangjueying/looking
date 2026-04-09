import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 应用状态
class AppState {
  final String? apiKey;
  final List<Map<String, dynamic>> items;

  AppState({this.apiKey, this.items = const []});

  AppState copyWith({String? apiKey, List<Map<String, dynamic>>? items}) {
    return AppState(
      apiKey: apiKey ?? this.apiKey,
      items: items ?? this.items,
    );
  }
}

// 状态管理
class AppNotifier extends StateNotifier<AppState> {
  AppNotifier() : super(AppState());

  void setApiKey(String key) {
    state = state.copyWith(apiKey: key);
  }

  void addItem(Map<String, dynamic> item) {
    final newItems = List<Map<String, dynamic>>.from(state.items);
    newItems.add(item);
    state = state.copyWith(items: newItems);
  }

  List<Map<String, dynamic>> searchItems(String query) {
    if (query.isEmpty) return state.items;
    return state.items
        .where((item) =>
            item['name'].toString().toLowerCase().contains(query.toLowerCase()) ||
            (item['description']?.toString().toLowerCase().contains(query.toLowerCase()) ?? false) ||
            (item['location']?.toString().toLowerCase().contains(query.toLowerCase()) ?? false))
        .toList();
  }
}

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '物品追踪器',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🔍 物品追踪器'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _showSettingsDialog();
            },
          ),
        ],
      ),
      body: _selectedIndex == 0 ? _buildUploadPage(appState) : _selectedIndex == 1 ? _buildSearchPage(appState) : _buildItemsPage(appState),
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

  Widget _buildUploadPage(dynamic appState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (appState.apiKey == null || appState.apiKey!.isEmpty)
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.warning, color: Colors.orange, size: 48),
                    const SizedBox(height: 8),
                    const Text(
                      '需要配置API Key',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => _showSettingsDialog(),
                      child: const Text('去设置'),
                    ),
                  ],
                ),
              ),
            ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(Icons.cloud_upload, size: 64, color: Colors.blue),
                  const SizedBox(height: 16),
                  const Text(
                    'AI 物品识别',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('选择图片，AI自动识别所有物品'),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: appState.apiKey != null && appState.apiKey!.isNotEmpty
                        ? () => _simulateAnalysis()
                        : null,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('选择图片识别'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchPage(dynamic appState) {
    final results = _searchController.text.isEmpty
        ? appState.items
        : ref.read(appProvider.notifier).searchItems(_searchController.text);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '搜索物品名称、描述或位置...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        (context as Element).markNeedsBuild();
                      },
                    )
                  : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (value) {
              (context as Element).markNeedsBuild();
            },
          ),
        ),
        Expanded(
          child: results.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('没有找到相关物品', style: TextStyle(fontSize: 18, color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final item = results[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: Text(item['name'][0].toUpperCase()),
                        ),
                        title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (item['description'] != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(item['description'], maxLines: 2, overflow: TextOverflow.ellipsis),
                              ),
                            if (item['location'] != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Row(
                                  children: [
                                    const Icon(Icons.location_on, size: 12, color: Colors.blue),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(item['location'], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.blue)),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        trailing: item['confidence'] != null
                            ? Text('${(item['confidence'] * 100).toStringAsFixed(0)}%')
                            : null,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildItemsPage(dynamic appState) {
    final itemCount = appState.items.length;
    final typeCount = appState.items.map((item) => item['name']).toSet().length;

    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text('$itemCount', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const Text('总记录'),
                  ],
                ),
                Column(
                  children: [
                    Text('$typeCount', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const Text('物品种类'),
                  ],
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: appState.items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2, size: 80, color: Colors.grey.shade300),
                      SizedBox(height: 16),
                      Text('还没有识别任何物品', style: TextStyle(fontSize: 20, color: Colors.grey)),
                      SizedBox(height: 8),
                      Text('先去"上传分析"页面识别物品吧！', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: appState.items.length,
                  itemBuilder: (context, index) {
                    final item = appState.items[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green.shade100,
                          child: Text(item['name'][0].toUpperCase()),
                        ),
                        title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(item['created_at'] ?? ''),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final appState = ref.watch(appProvider);
        return AlertDialog(
          title: const Text('⚙️ 设置'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '通义千问 API Key',
                  hintText: 'sk-xxxxxxxxxxxxxxxxxxxxxxxx',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: appState.apiKey ?? ''),
              ),
              const SizedBox(height: 16),
              const Text('获取API Key: https://dashscope.console.aliyun.com/apiKey', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                // 这里应该保存API Key
                Navigator.pop(context);
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
  }

  void _simulateAnalysis() {
    // 模拟AI识别过程
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('AI正在识别物品...'),
            SizedBox(height: 8),
            Text('这可能需要10-30秒', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );

    // 模拟识别完成
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pop(context); // 关闭加载对话框

        // 模拟识别结果
        ref.read(appProvider.notifier).addItem({
          'name': '示例物品',
          'description': '这是一个模拟的识别结果',
          'location': '左上角',
          'confidence': 0.95,
          'created_at': DateTime.now().toString().split('.')[0],
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('识别完成！找到1个物品（演示模式）'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }
}

// Provider
final appProvider = StateNotifierProvider<AppNotifier, AppState>((ref) {
  return AppNotifier();
});