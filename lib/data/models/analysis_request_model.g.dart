// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analysis_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnalysisRequestModel _$AnalysisRequestModelFromJson(
  Map<String, dynamic> json,
) => AnalysisRequestModel(
  model: json['model'] as String,
  input: Input.fromJson(json['input'] as Map<String, dynamic>),
  parameters: Parameters.fromJson(json['parameters'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AnalysisRequestModelToJson(
  AnalysisRequestModel instance,
) => <String, dynamic>{
  'model': instance.model,
  'input': instance.input.toJson(),
  'parameters': instance.parameters.toJson(),
};

Input _$InputFromJson(Map<String, dynamic> json) => Input(
  messages: (json['messages'] as List<dynamic>)
      .map((e) => Message.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$InputToJson(Input instance) => <String, dynamic>{
  'messages': instance.messages.map((e) => e.toJson()).toList(),
};

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
  role: json['role'] as String,
  content: (json['content'] as List<dynamic>)
      .map((e) => ContentItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
  'role': instance.role,
  'content': instance.content.map((e) => e.toJson()).toList(),
};

ContentItem _$ContentItemFromJson(Map<String, dynamic> json) => ContentItem(
  image: json['image'] as String?,
  video: (json['video'] as List<dynamic>?)?.map((e) => e as String).toList(),
  fps: (json['fps'] as num?)?.toDouble(),
  text: json['text'] as String?,
);

Map<String, dynamic> _$ContentItemToJson(ContentItem instance) =>
    <String, dynamic>{
      'image': instance.image,
      'video': instance.video,
      'fps': instance.fps,
      'text': instance.text,
    };

Parameters _$ParametersFromJson(Map<String, dynamic> json) => Parameters(
  temperature: (json['temperature'] as num).toDouble(),
  maxTokens: (json['maxTokens'] as num).toInt(),
);

Map<String, dynamic> _$ParametersToJson(Parameters instance) =>
    <String, dynamic>{
      'temperature': instance.temperature,
      'maxTokens': instance.maxTokens,
    };
