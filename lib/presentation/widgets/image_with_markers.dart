import 'package:flutter/material.dart';
import 'dart:io';
import '../../data/models/analysis_result_model.dart';

class ImageWithMarkers extends StatelessWidget {
  final String imagePath;
  final List<AnalyzedItem> items;

  const ImageWithMarkers({
    super.key,
    required this.imagePath,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 图片和标记
        SizedBox(
          height: 300,
          child: Stack(
            children: [
              // 显示图片
              Center(
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.contain,
                ),
              ),
              // 绘制物品标记
              ..._buildItemMarkers(),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // 物品列表
        ...items.map((item) => _buildItemCard(item, context)),
      ],
    );
  }

  List<Widget> _buildItemMarkers() {
    // 这里暂时简化处理，只显示物品名称标签
    // 实际的边界框标记需要更复杂的实现
    return items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final position = _calculatePosition(index, items.length);

      return Positioned(
        left: position.dx,
        top: position.dy,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Text(
            item.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }).toList();
  }

  Offset _calculatePosition(int index, int total) {
    // 简单的位置计算，将标签分布在图片的不同位置
    const double margin = 20.0;
    const double availableWidth = 280.0;

    // 将标签分成多行显示
    const itemsPerRow = 3;
    final row = index ~/ itemsPerRow;
    final col = index % itemsPerRow;
    final maxRows = total <= 0 ? 1 : ((total - 1) ~/ itemsPerRow) + 1;

    return Offset(
      margin + (col * availableWidth / itemsPerRow),
      margin + 50.0 + (row % maxRows) * 30.0,
    );
  }

  Widget _buildItemCard(AnalyzedItem item, BuildContext context) {
    final itemName = item.name.trim().isEmpty ? '未命名物品' : item.name.trim();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Text(
            itemName[0].toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(itemName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('置信度: ${(item.confidence * 100).toStringAsFixed(0)}%'),
            if (item.description != null && item.description!.isNotEmpty)
              Text(item.description!),
          ],
        ),
        trailing: item.location != null
            ? const Icon(Icons.location_on, color: Colors.green)
            : null,
      ),
    );
  }
}
