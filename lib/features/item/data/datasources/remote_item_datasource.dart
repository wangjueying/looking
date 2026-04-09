import 'dart:convert';
import 'dart:io';
import '../../../../core/network/api_client.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/item_model.dart';

class RemoteItemDataSource {
  final ApiClient apiClient;

  RemoteItemDataSource({required this.apiClient});

  Future<ItemModel> identifyItem({
    required String filePath,
    required String fileType,
  }) async {
    try {
      // Convert image to base64
      final fileBytes = await convertImageToBase64(filePath);
      if (fileBytes == null) {
        throw ServerException('Failed to read image file');
      }

      // Call API
      final response = await apiClient.identifyItem(fileBytes);

      // Parse response
      final itemInfo = parseApiResponse(response);

      return ItemModel(
        filePath: filePath,
        fileType: fileType,
        itemName: itemInfo['name'] ?? '未知物品',
        description: itemInfo['description'] ?? '',
        location: itemInfo['location'] ?? '',
        confidence: itemInfo['confidence'] ?? 0.0,
        createdAt: DateTime.now(),
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to identify item: ${e.toString()}');
    }
  }

  Future<String?> convertImageToBase64(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return null;
      }

      final bytes = await file.readAsBytes();
      final base64 = base64Encode(bytes);
      return base64;
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> parseApiResponse(Map<String, dynamic> response) {
    try {
      final output = response['output'] as Map<String, dynamic>?;
      if (output == null) {
        throw const FormatException('Missing output in response');
      }

      final choices = output['choices'] as List?;
      if (choices == null || choices.isEmpty) {
        throw const FormatException('No choices in response');
      }

      final firstChoice = choices[0] as Map<String, dynamic>;
      final message = firstChoice['message'] as Map<String, dynamic>?;
      if (message == null) {
        throw const FormatException('Missing message in choice');
      }

      final content = message['content'] as List?;
      if (content == null || content.isEmpty) {
        throw const FormatException('No content in message');
      }

      final textContent = content[0] as Map<String, dynamic>;
      final text = textContent['text'] as String?;

      if (text == null || text.isEmpty) {
        throw const FormatException('Empty text in content');
      }

      // Try to parse JSON from text
      final jsonMatch = RegExp(r'\{[^}]+\}').firstMatch(text);
      if (jsonMatch != null) {
        final jsonStr = jsonMatch.group(0);
        if (jsonStr != null) {
          try {
            final jsonData = jsonDecode(jsonStr) as Map<String, dynamic>;
            return {
              'name': jsonData['name'] as String?,
              'description': jsonData['description'] as String?,
              'location': jsonData['location'] as String?,
              'confidence': (jsonData['confidence'] as num?)?.toDouble() ?? 0.0,
            };
          } catch (e) {
            // If JSON parsing fails, return default values
          }
        }
      }

      // Return default values if parsing fails
      return {
        'name': '识别的物品',
        'description': text,
        'location': '',
        'confidence': 0.5,
      };
    } catch (e) {
      return {
        'name': '未知物品',
        'description': '识别失败',
        'location': '',
        'confidence': 0.0,
      };
    }
  }
}
