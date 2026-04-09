import 'package:json_annotation/json_annotation.dart';

part 'analysis_request_model.g.dart';

@JsonSerializable()
class AnalysisRequestModel {
  final String model;
  final Input input;
  final Parameters parameters;

  AnalysisRequestModel({
    required this.model,
    required this.input,
    required this.parameters,
  });

  factory AnalysisRequestModel.fromJson(Map<String, dynamic> json) =>
      _$AnalysisRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$AnalysisRequestModelToJson(this);

  // 创建图片分析请求
  factory AnalysisRequestModel.forImageAnalysis(String base64Image) {
    return AnalysisRequestModel(
      model: 'qwen-vl-max',
      input: Input.withImage(base64Image),
      parameters: Parameters.defaultParams(),
    );
  }

  // 创建视频分析请求
  factory AnalysisRequestModel.forVideoAnalysis(
    List<String> videoFrames, {
    required double fps,
  }) {
    return AnalysisRequestModel(
      model: 'qwen-vl-max',
      input: Input.withVideo(videoFrames, fps: fps),
      parameters: Parameters.defaultParams(),
    );
  }
}

@JsonSerializable()
class Input {
  final List<Message> messages;

  Input({required this.messages});

  factory Input.fromJson(Map<String, dynamic> json) => _$InputFromJson(json);

  Map<String, dynamic> toJson() => _$InputToJson(this);

  // 创建图片输入
  factory Input.withImage(String base64Image) {
    return Input(
      messages: [
        Message(
          role: 'user',
          content: [
            ContentItem.image(base64Image),
            ContentItem.text(_getDetailedPrompt()),
          ],
        ),
      ],
    );
  }

  // 创建视频输入
  factory Input.withVideo(List<String> videoFrames, {required double fps}) {
    return Input(
      messages: [
        Message(
          role: 'user',
          content: [
            ContentItem.video(videoFrames, fps: fps),
            ContentItem.text(_getDetailedVideoPrompt()),
          ],
        ),
      ],
    );
  }

  static String _getDetailedPrompt() {
    return '''请极其仔细地扫描这张图片的每一个角落，识别出所有可见的物品。

请按以下JSON格式返回结果：
{
  "items": [
    {
      "name": "具体物品名称",
      "description": "颜色、品牌、型号、状态等详细特征",
      "location": "精确位置描述（如：左上角、中间、右侧、桌面等）",
      "confidence": 0.95
    }
  ]
}

要求：
1. 识别所有可见物品，包括小的和不显眼的
2. 提供详细的位置描述
3. 描述物品的颜色、形状、品牌、状态等特征
4. 置信度范围0-1，表示识别的确定程度
5. 只返回JSON格式，不要其他文字说明

请开始识别：''';
  }

  static String _getDetailedVideoPrompt() {
    return '''以下内容是从同一个视频中按时间顺序抽取的关键帧，请综合所有帧来识别视频里出现的物品。

请按以下JSON格式返回结果：
{
  "items": [
    {
      "name": "具体物品名称",
      "description": "颜色、品牌、型号、状态等详细特征",
      "location": "物品在画面中的位置或出现的场景描述",
      "confidence": 0.95
    }
  ]
}

要求：
1. 综合全部帧进行识别，不要只看单一帧
2. 同一个物品在多帧重复出现时只保留一条结果
3. 优先识别在视频中清晰、持续出现或明显可见的物品
4. location 描述应结合视频场景，如“桌面中央”“沙发旁边”“车辆后排”等
5. 置信度范围为0-1
6. 如果没有识别到清晰物品，返回 {"items":[]}
7. 只返回JSON，不要附加说明文字

请开始识别：''';
  }
}

@JsonSerializable()
class Message {
  final String role;
  final List<ContentItem> content;

  Message({required this.role, required this.content});

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);
}

@JsonSerializable()
class ContentItem {
  final String? image;
  final List<String>? video;
  final double? fps;
  final String? text;

  ContentItem({this.image, this.video, this.fps, this.text});

  factory ContentItem.fromJson(Map<String, dynamic> json) =>
      _$ContentItemFromJson(json);

  Map<String, dynamic> toJson() => _$ContentItemToJson(this);

  factory ContentItem.image(String base64) {
    return ContentItem(image: 'data:image/jpeg;base64,$base64');
  }

  factory ContentItem.video(List<String> frames, {required double fps}) {
    return ContentItem(video: frames, fps: fps);
  }

  factory ContentItem.text(String content) {
    return ContentItem(text: content);
  }
}

@JsonSerializable()
class Parameters {
  final double temperature;
  final int maxTokens;

  Parameters({required this.temperature, required this.maxTokens});

  factory Parameters.fromJson(Map<String, dynamic> json) =>
      _$ParametersFromJson(json);

  Map<String, dynamic> toJson() => _$ParametersToJson(this);

  factory Parameters.defaultParams() {
    return Parameters(temperature: 0.3, maxTokens: 4000);
  }
}
