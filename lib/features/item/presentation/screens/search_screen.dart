import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/item_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      ref.read(itemsProvider.notifier).loadItems();
    } else {
      ref.read(itemsProvider.notifier).searchItems(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemsState = ref.watch(itemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '搜索物品名称、描述或位置...',
            border: InputBorder.none,
          ),
          style: Theme.of(context).textTheme.titleMedium,
          onChanged: (value) {
            setState(() {
              _isSearching = value.isNotEmpty;
            });
            _performSearch(value);
          },
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _isSearching = false;
                });
                _performSearch('');
              },
            ),
        ],
      ),
      body: itemsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : itemsState.items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isSearching ? Icons.search_off : Icons.inventory_2_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _isSearching ? '没有找到匹配的物品' : '还没有物品记录',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: itemsState.items.length,
                  itemBuilder: (context, index) {
                    final item = itemsState.items[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(item.itemName[0]),
                        ),
                        title: Text(item.itemName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.description),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 14),
                                const SizedBox(width: 4),
                                Text(item.location),
                                const SizedBox(width: 16),
                                Icon(
                                  item.confidence > 0.8
                                      ? Icons.check_circle
                                      : Icons.info,
                                  size: 14,
                                  color: item.confidence > 0.8
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                                const SizedBox(width: 4),
                                Text('${item.confidence.toStringAsFixed(0)}%'),
                              ],
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('确认删除'),
                                content: const Text('确定要删除这个物品记录吗？'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('取消'),
                                  ),
                                  FilledButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('删除'),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await ref.read(itemsProvider.notifier).deleteItem(item.id!);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('已删除')),
                                );
                              }
                            }
                          },
                        ),
                        onTap: () => context.go('/item/${item.id}'),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/');
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
