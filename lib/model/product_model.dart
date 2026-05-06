import 'package:delivery_app/model/category_model.dart';

/// ProductModel
class ProductModel {
  /// Constructor
  const ProductModel({
    this.id,
    this.name,
    this.description,
    this.price,
    this.rating,
    this.imageUrl,
    this.category,
    this.categoryId,
  });

  /// المصنع المسؤول عن تحويل البيانات من قاعدة البيانات (Map) إلى كائن Dart
  factory ProductModel.fromColumnMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      imageUrl: map['image'] as String? ?? '',
      price: num.tryParse(map['price'].toString())?.toDouble() ?? 0,
      rating: num.tryParse(map['rating'].toString())?.toDouble() ?? 0,
      category: map['category'] != null
          ? CategoryModel.fromColumnMap(map['category'] as Map<String, dynamic>)
          : null,
      categoryId: map['category_id'] as String? ?? '',
    );
  }

  ///id
  final String? id;

  ///name
  final String? name;

  ///description
  final String? description;

  ///price
  final double? price;

  ///rating
  final double? rating;

  ///imageUrl
  final String? imageUrl;

  /// category
  final CategoryModel? category;

  /// categoryId
  final String? categoryId;

  /// toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'rating': rating,
      'image': imageUrl,
      'category': category?.toJson(),
      'category_id': categoryId,
    };
  }
}
