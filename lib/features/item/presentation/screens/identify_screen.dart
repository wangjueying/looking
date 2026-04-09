import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/item_provider.dart';
import '../../../../shared/widgets/loading_indicator.dart';

class IdentifyScreen extends ConsumerStatefulWidget {
  final String imagePath;

  const IdentifyScreen({
    super.key,
    required this.imagePath,
  });

  @override
  ConsumerState<IdentifyScreen> createState() => _IdentifyScreenState();
}

class _IdentifyScreenState extends ConsumerState<IdentifyScreen> {
  bool _isIdentifying = false;
  String? _error;

  Future<void> _identifyItem() async {
    setState(() {
      _isIdentifying = true;
      _error = null;
    });

    final result = await ref.read(identifyItemProvider)(
      filePath: widget.imagePath,
      fileType: 'image',
    );

    result.fold(
      (failure) {
        setState(() {
          _isIdentifying = false;
          _error = failure.toString();
        });
      },
      (item) {
        setState(() {
          _isIdentifying = false;
        });
        // Refresh items list
        ref.read(itemsProvider.notifier).loadItems();
        // Navigate to item detail
        context.go('/item/${item.id}');
      },
    );
  }

  @override
  void initState() {
    super.initState();
    // Auto-start identification
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _identifyItem();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('识别物品'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image preview
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(widget.imagePath),
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 24),

            // Status
            if (_isIdentifying)
              const Column(
                children: [
                  LoadingIndicator(message: 'AI 正在识别物品...'),
                  SizedBox(height: 16),
                  Text('请稍候，这可能需要几秒钟'),
                ],
              )
            else if (_error != null)
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '识别失败',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _identifyItem,
                        icon: const Icon(Icons.refresh),
                        label: const Text('重试'),
                      ),
                    ],
                  ),
                ),
              )
            else
              const SizedBox(),
          ],
        ),
      ),
    );
  }
}
