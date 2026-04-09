class Item {
  final int? id;
  final String filePath;
  final String fileType;
  final String itemName;
  final String description;
  final String location;
  final double confidence;
  final DateTime createdAt;

  Item({
    this.id,
    required this.filePath,
    required this.fileType,
    required this.itemName,
    required this.description,
    required this.location,
    required this.confidence,
    required this.createdAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Item && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Item{id: $id, itemName: $itemName, location: $location}';
  }
}
