// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analysis_result_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnalysisResultModel _$AnalysisResultModelFromJson(Map<String, dynamic> json) =>
    AnalysisResultModel(
      items: (json['items'] as List<dynamic>)
          .map((e) => AnalyzedItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      rawResponse: json['rawResponse'] as String?,
    );

Map<String, dynamic> _$AnalysisResultModelToJson(
  AnalysisResultModel instance,
) => <String, dynamic>{
  'items': instance.items.map((e) => e.toJson()).toList(),
  'rawResponse': instance.rawResponse,
};

AnalyzedItem _$AnalyzedItemFromJson(Map<String, dynamic> json) => AnalyzedItem(
  name: json['name'] as String? ?? '',
  description: json['description'] as String?,
  location: json['location'] as String?,
  confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
  boundingBox: json['boundingBox'] == null
      ? null
      : BoundingBox.fromJson(json['boundingBox'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AnalyzedItemToJson(AnalyzedItem instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'location': instance.location,
      'confidence': instance.confidence,
      'boundingBox': instance.boundingBox?.toJson(),
    };

BoundingBox _$BoundingBoxFromJson(Map<String, dynamic> json) => BoundingBox(
      x: (json['x'] as num?)?.toDouble() ?? 0.0,
      y: (json['y'] as num?)?.toDouble() ?? 0.0,
      width: (json['width'] as num?)?.toDouble() ?? 0.0,
      height: (json['height'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$BoundingBoxToJson(BoundingBox instance) =>
    <String, dynamic>{
      'x': instance.x,
      'y': instance.y,
      'width': instance.width,
      'height': instance.height,
    };
