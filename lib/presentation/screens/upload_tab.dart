import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../providers/analysis_provider.dart';
import '../providers/items_provider.dart';
import '../providers/settings_provider.dart';
import '../screens/settings_screen.dart';

class UploadTab extends ConsumerStatefulWidget {
  const UploadTab({super.key});

  @override
  ConsumerState<UploadTab> createState() => _UploadTabState();
}

class _UploadTabState extends ConsumerState<UploadTab> {
  final ImagePicker _picker = ImagePicker();
  int? _expandedResultIndex;

  bool _ensureApiKeyConfigured() {
    final settings = ref.read(settingsProvider);
    if (settings.apiKey == null || settings.apiKey!.isEmpty) {
      _showSnackBar('请先在设置中配置API Key', Colors.orange);
      return false;
    }

    return true;
  }

  Future<void> _analyzeSelectedFile(
    String filePath, {
    required String fileType,
    required String loadingMessage,
  }) async {
    setState(() {
      _expandedResultIndex = null;
    });

    _showSnackBar(loadingMessage, Colors.blue);

    final notifier = ref.read(analysisProvider.notifier);
    if (fileType == 'video') {
      await notifier.analyzeVideo(filePath);
    } else {
      await notifier.analyzeImage(filePath, fileType);
    }

    if (!mounted) {
      return;
    }

    final analysisState = ref.read(analysisProvider);
    if (!analysisState.hasError) {
      await ref.read(itemsProvider.notifier).loadAllItems();
      ref.invalidate(statsProvider);
    }
  }

  bool _isVideoPath(String path) {
    final lowerPath = path.toLowerCase();
    return lowerPath.endsWith('.mp4') ||
        lowerPath.endsWith('.mov') ||
        lowerPath.endsWith('.m4v') ||
        lowerPath.endsWith('.avi') ||
        lowerPath.endsWith('.mkv') ||
        lowerPath.endsWith('.webm');
  }

  Future<void> _pickImageFromGallery() async {
    if (!_ensureApiKeyConfigured()) {
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        await _analyzeSelectedFile(
          image.path,
          fileType: 'image',
          loadingMessage: '图片已选择，开始AI识别...',
        );
      } else {
        _showSnackBar('未选择图片', Colors.grey);
      }
    } catch (e) {
      _showSnackBar('选择图片失败: $e', Colors.red);
    }
  }

  Future<void> _pickImageFromCamera() async {
    if (!_ensureApiKeyConfigured()) {
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        await _analyzeSelectedFile(
          image.path,
          fileType: 'image',
          loadingMessage: '照片已拍摄，开始AI识别...',
        );
      } else {
        _showSnackBar('未拍摄照片', Colors.grey);
      }
    } catch (e) {
      _showSnackBar('拍照失败: $e', Colors.red);
    }
  }

  Future<void> _pickVideoFromGallery() async {
    if (!_ensureApiKeyConfigured()) {
      return;
    }

    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);

      if (video != null) {
        await _analyzeSelectedFile(
          video.path,
          fileType: 'video',
          loadingMessage: '视频已选择，开始AI识别...',
        );
      } else {
        _showSnackBar('未选择视频', Colors.grey);
      }
    } catch (e) {
      _showSnackBar('选择视频失败: $e', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final analysisState = ref.watch(analysisProvider);
    final settingsState = ref.watch(settingsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // API Key 提示卡片
          if (settingsState.apiKey == null || settingsState.apiKey!.isEmpty)
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      Icons.warning,
                      color: Colors.orange.shade700,
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '需要配置API Key',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('请点击右上角设置图标，输入通义千问API Key'),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.settings),
                      label: const Text('去设置'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),

          // 主上传卡片
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.cloud_upload,
                    size: 72,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'AI 物品识别',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '选择图片或视频，AI自动识别所有物品',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // 相机按钮
                  ElevatedButton.icon(
                    onPressed:
                        (settingsState.apiKey != null &&
                            settingsState.apiKey!.isNotEmpty &&
                            !analysisState.isLoading)
                        ? _pickImageFromCamera
                        : null,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('拍照识别'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      minimumSize: const Size(200, 50),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 相册图片按钮
                  ElevatedButton.icon(
                    onPressed:
                        (settingsState.apiKey != null &&
                            settingsState.apiKey!.isNotEmpty &&
                            !analysisState.isLoading)
                        ? _pickImageFromGallery
                        : null,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('相册图片'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      minimumSize: const Size(200, 50),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 相册视频按钮
                  ElevatedButton.icon(
                    onPressed:
                        (settingsState.apiKey != null &&
                            settingsState.apiKey!.isNotEmpty &&
                            !analysisState.isLoading)
                        ? _pickVideoFromGallery
                        : null,
                    icon: const Icon(Icons.video_library),
                    label: const Text('相册视频'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      minimumSize: const Size(200, 50),
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 分析状态卡片
          if (analysisState.isLoading)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    const Text('AI正在识别物品...', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      '这可能需要10-30秒',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (analysisState.hasError)
            Card(
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    const Text(
                      '识别失败',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      analysisState.errorMessage ?? '未知错误',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(analysisProvider.notifier).reset();
                      },
                      child: const Text('重试'),
                    ),
                  ],
                ),
              ),
            )
          else if (analysisState.result != null)
            _buildResultsCard(analysisState),
        ],
      ),
    );
  }

  Widget _buildResultsCard(AnalysisState analysisState) {
    final result = analysisState.result!;
    final analyzedPath = analysisState.analyzedFilePath ?? '';
    final fileName = analyzedPath.isEmpty
        ? '未知文件'
        : analyzedPath.split('/').last;
    final fileType = _isVideoPath(analyzedPath) ? '视频' : '图片';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Success indicator
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  '识别成功！',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Split layout: Original file (left) + File info + Recognition results (right)
            LayoutBuilder(
              builder: (context, constraints) {
                // Use split layout on larger screens, stacked on mobile
                if (constraints.maxWidth > 600) {
                  // Split layout for tablets/desktop
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left side: Original file preview
                      Expanded(
                        flex: 1,
                        child: _buildOriginalFileSection(
                          analyzedPath,
                          fileType,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Right side: File info + Recognition results
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFileInfoSection(fileName, fileType),
                            const SizedBox(height: 16),
                            _buildRecognitionResultsSection(result),
                          ],
                        ),
                      ),
                    ],
                  );
                } else {
                  // Stacked layout for mobile
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOriginalFileSection(analyzedPath, fileType),
                      const SizedBox(height: 16),
                      _buildFileInfoSection(fileName, fileType),
                      const SizedBox(height: 16),
                      _buildRecognitionResultsSection(result),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOriginalFileSection(String analyzedPath, String fileType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '原始文件',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: fileType == '视频'
                ? _buildVideoPreview(analyzedPath)
                : _buildImagePreview(analyzedPath),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview(String imagePath) {
    if (imagePath.isEmpty) {
      return const SizedBox(height: 200, child: Center(child: Text('无法加载图片')));
    }

    try {
      if (imagePath.startsWith('http')) {
        return Image.network(
          imagePath,
          height: 200,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const SizedBox(
              height: 200,
              child: Center(child: Text('图片加载失败')),
            );
          },
        );
      } else {
        final file = File(imagePath);
        if (file.existsSync()) {
          return Image.file(
            file,
            height: 200,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const SizedBox(
                height: 200,
                child: Center(child: Text('图片加载失败')),
              );
            },
          );
        } else {
          return const SizedBox(
            height: 200,
            child: Center(child: Text('文件不存在')),
          );
        }
      }
    } catch (e) {
      return const SizedBox(height: 200, child: Center(child: Text('图片加载错误')));
    }
  }

  Widget _buildVideoPreview(String videoPath) {
    if (videoPath.isEmpty) {
      return const SizedBox(height: 200, child: Center(child: Text('无法加载视频')));
    }

    final file = File(videoPath);
    if (!file.existsSync()) {
      return const SizedBox(height: 200, child: Center(child: Text('视频文件不存在')));
    }

    return FutureBuilder<Uint8List?>(
      future: VideoThumbnail.thumbnailData(
        video: videoPath,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 512,
        quality: 75,
      ),
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        if (bytes == null || bytes.isEmpty) {
          return Container(
            height: 200,
            color: Colors.grey.shade200,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_circle_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('视频预览生成中', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          );
        }

        return Stack(
          alignment: Alignment.center,
          children: [
            Image.memory(
              bytes,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 32,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFileInfoSection(String fileName, String fileType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '文件信息',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('文件名', fileName),
              const SizedBox(height: 8),
              _buildInfoRow('文件类型', fileType),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(color: Colors.black87)),
        ),
      ],
    );
  }

  Widget _buildRecognitionResultsSection(dynamic result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '识别结果',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (result.items.isEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '未识别到物品，请尝试更清晰的图片或视频',
              style: TextStyle(color: Colors.orange),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ExpansionPanelList(
              elevation: 0,
              expandedHeaderPadding: EdgeInsets.zero,
              expansionCallback: (panelIndex, isExpanded) {
                setState(() {
                  _expandedResultIndex = isExpanded ? null : panelIndex;
                });
              },
              children: List<ExpansionPanel>.generate(result.items.length, (
                index,
              ) {
                final item = result.items[index];
                return ExpansionPanel(
                  headerBuilder: (BuildContext context, bool isExpanded) {
                    return ListTile(
                      title: Text(
                        item.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                      trailing: Text(
                        '${(item.confidence * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: item.confidence > 0.8
                              ? Colors.green
                              : item.confidence > 0.6
                              ? Colors.orange
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                  body: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item.description != null &&
                            item.description!.isNotEmpty)
                          Text(
                            item.description!,
                            style: const TextStyle(color: Colors.black87),
                          ),
                        if (item.boundingBox != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            '位置: ${item.boundingBox!.toString()}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  isExpanded: _expandedResultIndex == index,
                );
              }),
            ),
          ),
      ],
    );
  }
}
