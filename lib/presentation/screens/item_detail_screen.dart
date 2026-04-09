import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../data/models/item_model.dart';
import '../providers/items_provider.dart';

class ItemDetailScreen extends ConsumerStatefulWidget {
  final ItemModel item;

  const ItemDetailScreen({super.key, required this.item});

  @override
  ConsumerState<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends ConsumerState<ItemDetailScreen> {
  VideoPlayerController? _videoController;
  Future<void>? _videoInitialization;

  bool get _isVideo => widget.item.fileType.toLowerCase() == 'video';

  bool get _isNetworkFile =>
      widget.item.filePath.startsWith('http://') ||
      widget.item.filePath.startsWith('https://');

  @override
  void initState() {
    super.initState();
    if (_isVideo) {
      _initializeVideo();
    }
  }

  void _initializeVideo() {
    final controller = _isNetworkFile
        ? VideoPlayerController.networkUrl(Uri.parse(widget.item.filePath))
        : VideoPlayerController.file(File(widget.item.filePath));

    _videoController = controller;
    _videoInitialization = controller.initialize().then((_) {
      controller.setLooping(true);
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _restoreToList() async {
    final itemId = widget.item.id;
    if (itemId == null) {
      return;
    }

    await ref.read(itemsProvider.notifier).restoreItem(itemId);
    ref.invalidate(statsProvider);

    if (!mounted) {
      return;
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final itemName = widget.item.itemName.trim().isEmpty
        ? '未命名物品'
        : widget.item.itemName.trim();

    return Scaffold(
      appBar: AppBar(
        title: Text(itemName),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (widget.item.isHidden) ...[
            _buildHiddenNoticeCard(),
            const SizedBox(height: 16),
          ],
          _buildPreviewCard(context),
          const SizedBox(height: 16),
          _buildLocationCard(),
          const SizedBox(height: 16),
          _buildInfoCard(),
        ],
      ),
    );
  }

  Widget _buildHiddenNoticeCard() {
    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.inventory_2_outlined, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                Text(
                  '这条记录已从物品清单移出',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('恢复后，它会重新显示在“物品清单”里。'),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _restoreToList,
              icon: const Icon(Icons.undo),
              label: const Text('恢复到清单'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isVideo ? Icons.video_library : Icons.image_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  _isVideo ? '原始视频' : '原始图片',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _isVideo ? _buildVideoPreview() : _buildImagePreview(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (widget.item.filePath.isEmpty) {
      return _buildPreviewFallback(
        icon: Icons.image_not_supported_outlined,
        message: '没有可展示的原始图片',
      );
    }

    if (_isNetworkFile) {
      return Image.network(
        widget.item.filePath,
        height: 320,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPreviewFallback(
            icon: Icons.broken_image_outlined,
            message: '图片加载失败',
          );
        },
      );
    }

    final file = File(widget.item.filePath);
    if (!file.existsSync()) {
      return _buildPreviewFallback(
        icon: Icons.folder_off_outlined,
        message: '原始图片文件不存在',
      );
    }

    return InteractiveViewer(
      minScale: 0.8,
      maxScale: 4,
      child: Image.file(
        file,
        height: 320,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPreviewFallback(
            icon: Icons.broken_image_outlined,
            message: '图片加载失败',
          );
        },
      ),
    );
  }

  Widget _buildVideoPreview() {
    final initialization = _videoInitialization;
    if (_videoController == null || initialization == null) {
      return _buildPreviewFallback(
        icon: Icons.video_file_outlined,
        message: '没有可展示的原始视频',
      );
    }

    return FutureBuilder<void>(
      future: initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Container(
            height: 240,
            color: Colors.black12,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError || !_videoController!.value.isInitialized) {
          return _buildPreviewFallback(
            icon: Icons.video_file_outlined,
            message: '视频加载失败',
          );
        }

        final controller = _videoController!;
        final aspectRatio = controller.value.aspectRatio == 0
            ? 16 / 9
            : controller.value.aspectRatio;

        return Container(
          color: Colors.black,
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: aspectRatio,
                child: VideoPlayer(controller),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          if (controller.value.isPlaying) {
                            controller.pause();
                          } else {
                            controller.play();
                          }
                        });
                      },
                      icon: Icon(
                        controller.value.isPlaying
                            ? Icons.pause_circle_outline
                            : Icons.play_circle_outline,
                        color: Colors.white,
                      ),
                    ),
                    Expanded(
                      child: VideoProgressIndicator(
                        controller,
                        allowScrubbing: true,
                        colors: VideoProgressColors(
                          playedColor: Theme.of(context).colorScheme.primary,
                          bufferedColor: Colors.white30,
                          backgroundColor: Colors.white12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLocationCard() {
    final location = widget.item.location?.trim() ?? '';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.location_on_outlined, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  '存放位置',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              location.isEmpty ? '这条记录没有保存位置描述' : location,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: location.isEmpty ? Colors.grey : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    final description = widget.item.description?.trim() ?? '';
    final confidence = widget.item.confidence == null
        ? '未提供'
        : '${((widget.item.confidence ?? 0).clamp(0.0, 1.0) * 100).toStringAsFixed(0)}%';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '识别信息',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              '物品名称',
              widget.item.itemName.trim().isEmpty
                  ? '未命名物品'
                  : widget.item.itemName.trim(),
            ),
            _buildInfoRow('文件类型', _isVideo ? '视频' : '图片'),
            _buildInfoRow(
              '识别时间',
              widget.item.createdAt.toString().split('.').first,
            ),
            _buildInfoRow('置信度', confidence),
            _buildInfoRow('原始文件', widget.item.filePath.split('/').last),
            if (description.isNotEmpty) _buildInfoRow('补充描述', description),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 84,
            child: Text(
              '$label：',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(height: 1.4))),
        ],
      ),
    );
  }

  Widget _buildPreviewFallback({
    required IconData icon,
    required String message,
  }) {
    return Container(
      height: 240,
      width: double.infinity,
      color: Colors.grey.shade100,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
