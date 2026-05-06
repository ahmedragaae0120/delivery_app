/// CategoryModel
class CategoryModel {
  /// Constructor
  CategoryModel({
    required this.id,
    required this.name,
  });

  ///fromColumnMap
  factory CategoryModel.fromColumnMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
    );
  }

  ///toJson
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
      };

  ///id
  final String id;

  ///name
  final String name;
}
