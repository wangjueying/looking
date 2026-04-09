import 'package:json_annotation/json_annotation.dart';

part 'item_model.g.dart';

@JsonSerializable()
class ItemModel {
  final int? id;
  final String filePath;
  final String fileType; // 'image' or 'video'
  final String itemName;
  final String? description;
  final String? location;
  final double? confidence;
  final bool isHidden;
  final DateTime createdAt;

  ItemModel({
    this.id,
    required this.filePath,
    required this.fileType,
    required this.itemName,
    this.description,
    this.location,
    this.confidence,
    this.isHidden = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ItemModel.fromJson(Map<String, dynamic> json) =>
      _$ItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$ItemModelToJson(this);

  // 从数据库Map创建
  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(
      id: map['id'] as int?,
      filePath: map['file_path'] as String,
      fileType: map['file_type'] as String,
      itemName: map['item_name'] as String,
      description: map['description'] as String?,
      location: map['location'] as String?,
      confidence: (map['confidence'] as num?)?.toDouble(),
      isHidden: (map['is_hidden'] as num?)?.toInt() == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  // 转换为数据库Map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'file_path': filePath,
      'file_type': fileType,
      'item_name': itemName,
      'description': description,
      'location': location,
      'confidence': confidence,
      'is_hidden': isHidden ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // 复制并修改部分字段
  ItemModel copyWith({
    int? id,
    String? filePath,
    String? fileType,
    String? itemName,
    String? description,
    String? location,
    double? confidence,
    bool? isHidden,
    DateTime? createdAt,
  }) {
    return ItemModel(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      fileType: fileType ?? this.fileType,
      itemName: itemName ?? this.itemName,
      description: description ?? this.description,
      location: location ?? this.location,
      confidence: confidence ?? this.confidence,
      isHidden: isHidden ?? this.isHidden,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
