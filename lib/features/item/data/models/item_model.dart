import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/item.dart';

part 'item_model.g.dart';

@JsonSerializable()
class ItemModel {
  final int? id;
  final String filePath;
  final String fileType;
  final String itemName;
  final String description;
  final String location;
  final double confidence;
  final DateTime createdAt;

  ItemModel({
    this.id,
    required this.filePath,
    required this.fileType,
    required this.itemName,
    required this.description,
    required this.location,
    required this.confidence,
    required this.createdAt,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) =>
      _$ItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$ItemModelToJson(this);

  // Convert from database map
  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(
      id: map['id'] as int?,
      filePath: map['file_path'] as String,
      fileType: map['file_type'] as String,
      itemName: map['item_name'] as String,
      description: map['description'] as String? ?? '',
      location: map['location'] as String? ?? '',
      confidence: (map['confidence'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  // Convert to database map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'file_path': filePath,
      'file_type': fileType,
      'item_name': itemName,
      'description': description,
      'location': location,
      'confidence': confidence,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Copy with method
  ItemModel copyWith({
    int? id,
    String? filePath,
    String? fileType,
    String? itemName,
    String? description,
    String? location,
    double? confidence,
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
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Convert to entity
  Item toEntity() {
    return Item(
      id: id,
      filePath: filePath,
      fileType: fileType,
      itemName: itemName,
      description: description,
      location: location,
      confidence: confidence,
      createdAt: createdAt,
    );
  }
}
