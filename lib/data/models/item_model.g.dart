// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItemModel _$ItemModelFromJson(Map<String, dynamic> json) => ItemModel(
  id: (json['id'] as num?)?.toInt(),
  filePath: json['filePath'] as String,
  fileType: json['fileType'] as String,
  itemName: json['itemName'] as String,
  description: json['description'] as String?,
  location: json['location'] as String?,
  confidence: (json['confidence'] as num?)?.toDouble(),
  isHidden: json['isHidden'] as bool? ?? false,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$ItemModelToJson(ItemModel instance) => <String, dynamic>{
  'id': instance.id,
  'filePath': instance.filePath,
  'fileType': instance.fileType,
  'itemName': instance.itemName,
  'description': instance.description,
  'location': instance.location,
  'confidence': instance.confidence,
  'isHidden': instance.isHidden,
  'createdAt': instance.createdAt.toIso8601String(),
};
