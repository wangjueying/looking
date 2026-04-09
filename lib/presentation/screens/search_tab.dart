import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/item_model.dart';
import '../providers/items_provider.dart';
import '../providers/shared_providers.dart';
import 'item_detail_screen.dart';

class SearchTab extends ConsumerStatefulWidget {
  const SearchTab({super.key});

  @override
  ConsumerState<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends ConsumerState<SearchTab> {
  final TextEditingController _searchController = TextEditingController();
  List<ItemModel> _searchResults = const [];
  bool _isSearchLoading = false;
  String? _searchError;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onSearchChanged(String value) async {
    final normalizedValue = value.trim();

    setState(() {
      _searchError = null;
      if (normalizedValue.isEmpty) {
        _searchResults = const [];
        _isSearchLoading = false;
      } else {
        _isSearchLoading = true;
      }
    });

    if (normalizedValue.isEmpty) {
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!mounted || _searchController.text.trim() != normalizedValue) {
      return;
    }

    try {
      final results = await ref
          .read(databaseProvider)
          .searchItems(normalizedValue);
      if (!mounted || _searchController.text.trim() != normalizedValue) {
        return;
      }

      setState(() {
        _searchResults = results;
        _isSearchLoading = false;
      });
    } catch (e) {
      if (!mounted || _searchController.text.trim() != normalizedValue) {
        return;
      }

      setState(() {
        _searchResults = const [];
        _searchError = e.toString();
        _isSearchLoading = false;
      });
    }
  }

  Future<void> _refreshCurrentSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      return;
    }

    await _onSearchChanged(query);
  }

  Future<void> _restoreItemToList(ItemModel item) async {
    if (item.id == null) {
      return;
    }

    await ref.read(itemsProvider.notifier).restoreItem(item.id!);
    ref.invalidate(statsProvider);
    await _refreshCurrentSearch();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('已将"${item.itemName}"恢复到物品清单')));
  }

  Future<void> _openItemDetail(ItemModel item) async {
    final restored = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => ItemDetailScreen(item: item)),
    );

    if (restored == true) {
      await _refreshCurrentSearch();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('已将"${item.itemName}"恢复到物品清单')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSearching = _searchController.text.trim().isNotEmpty;
    final displayedItems = _searchResults;
    final isLoading = _isSearchLoading;

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
                        _onSearchChanged('');
                        setState(() {});
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            onChanged: _onSearchChanged,
          ),
        ),
        Expanded(
          child: !isSearching
              ? _buildPromptState()
              : isLoading
              ? const Center(child: CircularProgressIndicator())
              : _searchError != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      _searchError!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                )
              : displayedItems.isEmpty
              ? _buildEmptyState(isSearching)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: displayedItems.length,
                  itemBuilder: (context, index) {
                    final item = displayedItems[index];
                    return _buildItemCard(item);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPromptState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            '输入物品后开始搜索',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text('搜索结果支持点击查看原图或视频', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isSearching) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('没有找到相关物品', style: TextStyle(fontSize: 18, color: Colors.grey)),
          SizedBox(height: 8),
          Text('试试其他关键词', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildItemCard(ItemModel item) {
    final itemName = item.itemName.trim().isEmpty
        ? '未命名物品'
        : item.itemName.trim();
    final confidence = (item.confidence ?? 0).clamp(0.0, 1.0);
    final fileTypeLabel = item.fileType.toLowerCase() == 'video' ? '视频' : '图片';
    final location = item.location?.trim() ?? '';
    final description = item.description?.trim() ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: () => _openItemDetail(item),
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Text(
            itemName[0].toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          itemName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: item.fileType.toLowerCase() == 'video'
                          ? Colors.purple.shade50
                          : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      fileTypeLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: item.fileType.toLowerCase() == 'video'
                            ? Colors.purple
                            : Colors.blue,
                      ),
                    ),
                  ),
                  if (item.confidence != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      '置信度 ${(confidence * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  if (item.isHidden) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Text(
                        '已移出清单',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            if (location.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, size: 12, color: Colors.blue),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                item.createdAt.toString().split('.')[0],
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ),
            if (item.isHidden)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: TextButton.icon(
                    onPressed: () => _restoreItemToList(item),
                    icon: const Icon(Icons.undo, size: 18),
                    label: const Text('恢复到清单'),
                  ),
                ),
              ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }
}
