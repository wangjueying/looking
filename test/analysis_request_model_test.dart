import 'package:flutter_test/flutter_test.dart';

import '../lib/data/models/analysis_request_model.dart';

void main() {
  group('AnalysisRequestModel', () {
    test('forImageAnalysis serializes image payload', () {
      final request = AnalysisRequestModel.forImageAnalysis('abc123');
      final json = request.toJson();

      expect(json['model'], 'qwen-vl-max');

      final input = json['input'] as Map<String, dynamic>;
      final messages = input['messages'] as List<dynamic>;
      final content =
          (messages.first as Map<String, dynamic>)['content'] as List<dynamic>;

      final imageContent = content.first as Map<String, dynamic>;
      final promptContent = content[1] as Map<String, dynamic>;

      expect(imageContent['image'], 'data:image/jpeg;base64,abc123');
      expect(promptContent['text'], contains('请极其仔细地扫描这张图片'));
    });

    test('forVideoAnalysis serializes frames and fps', () {
      final request = AnalysisRequestModel.forVideoAnalysis(const [
        'data:image/jpeg;base64,frame1',
        'data:image/jpeg;base64,frame2',
        'data:image/jpeg;base64,frame3',
        'data:image/jpeg;base64,frame4',
      ], fps: 1.5);
      final json = request.toJson();

      expect(json['model'], 'qwen-vl-max');

      final input = json['input'] as Map<String, dynamic>;
      final messages = input['messages'] as List<dynamic>;
      final content =
          (messages.first as Map<String, dynamic>)['content'] as List<dynamic>;

      final videoContent = content.first as Map<String, dynamic>;
      final promptContent = content[1] as Map<String, dynamic>;

      expect(videoContent['video'], hasLength(4));
      expect(videoContent['fps'], 1.5);
      expect(promptContent['text'], contains('关键帧'));
      expect(promptContent['text'], contains('同一个物品在多帧重复出现时只保留一条结果'));
    });
  });
}
