import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/item_model.dart';
import '../providers/items_provider.dart';
import 'item_detail_screen.dart';

class ItemsTab extends ConsumerWidget {
  const ItemsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsState = ref.watch(itemsProvider);
    final stats = ref.watch(statsProvider);

    return Column(
      children: [
        // 统计信息卡片
        stats.when(
          data: (data) {
            final itemCount = data['itemCount'] ?? 0;
            final typeCount = data['typeCount'] ?? 0;

            return Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('总记录', itemCount, Icons.list_alt),
                    _buildStatItem('物品种类', typeCount, Icons.category),
                  ],
                ),
              ),
            );
          },
          loading: () => const SizedBox(),
          error: (error, stackTrace) => const SizedBox(),
        ),

        // 物品列表
        Expanded(
          child: itemsState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : itemsState.items.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(itemsProvider.notifier).loadAllItems();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: itemsState.items.length,
                    itemBuilder: (context, index) {
                      final item = itemsState.items[index];
                      return _buildItemCard(context, ref, item);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, int value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.blue),
        const SizedBox(height: 8),
        Text(
          '$value',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            '还没有识别任何物品',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text('去"上传分析"页面开始识别物品吧！', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Future<void> _openItemDetail(BuildContext context, ItemModel item) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ItemDetailScreen(item: item)),
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            '移出清单',
            style: TextStyle(
              color: Colors.red.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.delete_outline, color: Colors.red.shade700),
        ],
      ),
    );
  }

  Future<bool> _confirmRemoveFromList(
    BuildContext context,
    WidgetRef ref,
    ItemModel item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('从清单移出'),
        content: Text(
          '确定要将"${item.itemName}"从物品清单移出吗？\n\n移出后不会删除识别记录，之后仍可在“搜索物品”中找到它。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('移出', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true || item.id == null) {
      return false;
    }

    await ref.read(itemsProvider.notifier).deleteItem(item.id!);
    ref.invalidate(statsProvider);

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('已从物品清单移出，可在搜索物品中继续查找')));
    }

    return true;
  }

  Widget _buildItemCard(BuildContext context, WidgetRef ref, ItemModel item) {
    final location = item.location?.trim() ?? '';

    return Dismissible(
      key: ValueKey('item-${item.id ?? item.createdAt.toIso8601String()}'),
      direction: DismissDirection.endToStart,
      background: _buildDismissBackground(),
      confirmDismiss: (_) => _confirmRemoveFromList(context, ref, item),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          onTap: () => _openItemDetail(context, item),
          leading: CircleAvatar(
            backgroundColor: _getAvatarColor(item.itemName),
            child: Text(
              _getAvatarLabel(item.itemName),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          title: Text(
            item.itemName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.description != null && item.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    item.description!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              if (location.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.place_outlined,
                        size: 14,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '大概位置：$location',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  item.createdAt.toString().split('.')[0],
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ),
            ],
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        ),
      ),
    );
  }

  String _getAvatarLabel(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return '?';
    }
    return trimmed[0].toUpperCase();
  }

  Color _getAvatarColor(String name) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.red,
    ];
    if (name.isEmpty) return Colors.grey;
    final index = name.codeUnitAt(0) % colors.length;
    return colors[index];
  }
}
