import 'item_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'analysis_result_model.g.dart';

@JsonSerializable()
class AnalysisResultModel {
  final List<AnalyzedItem> items;
  final String? rawResponse;

  AnalysisResultModel({
    required this.items,
    this.rawResponse,
  });

  factory AnalysisResultModel.fromJson(Map<String, dynamic> json) =>
      _$AnalysisResultModelFromJson(json);

  Map<String, dynamic> toJson() => _$AnalysisResultModelToJson(this);

  // 转换为ItemModel列表（用于保存到数据库）
  List<ItemModel> toItemModels(String filePath, String fileType) {
    return items.map((item) {
      return ItemModel(
        filePath: filePath,
        fileType: fileType,
        itemName: item.name,
        description: item.description,
        location: item.location,
        confidence: item.confidence,
      );
    }).toList();
  }
}

@JsonSerializable()
class AnalyzedItem {
  final String name;
  final String? description;
  final String? location;
  final double confidence;
  // 添加物品在图片中的位置信息（可选）
  final BoundingBox? boundingBox;

  AnalyzedItem({
    required this.name,
    this.description,
    this.location,
    required this.confidence,
    this.boundingBox,
  });

  factory AnalyzedItem.fromJson(Map<String, dynamic> json) =>
      _$AnalyzedItemFromJson(json);

  Map<String, dynamic> toJson() => _$AnalyzedItemToJson(this);
}

// 边界框模型
@JsonSerializable()
class BoundingBox {
  final double x;
  final double y;
  final double width;
  final double height;

  BoundingBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  factory BoundingBox.fromJson(Map<String, dynamic> json) =>
      _$BoundingBoxFromJson(json);

  Map<String, dynamic> toJson() => _$BoundingBoxToJson(this);
}
