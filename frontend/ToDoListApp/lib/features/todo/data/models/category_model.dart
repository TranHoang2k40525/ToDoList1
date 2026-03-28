import '../../domain/entities/category_entity.dart';

class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    this.icon,
    this.colorHex,
  });

  final String id;
  final String name;
  final String? icon;
  final String? colorHex;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      icon: json['icon']?.toString(),
      colorHex: json['colorHex']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'colorHex': colorHex,
    };
  }

  CategoryEntity toEntity() {
    return CategoryEntity(id: id, name: name, icon: icon, colorHex: colorHex);
  }
}
