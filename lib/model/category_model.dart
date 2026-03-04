/// CategoryModel
class CategoryModel {
  /// Constructor
  CategoryModel({
    required this.id,
    required this.name,
  });

  ///fromJson
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
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
