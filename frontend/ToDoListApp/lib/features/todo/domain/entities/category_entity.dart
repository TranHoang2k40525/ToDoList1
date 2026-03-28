class CategoryEntity {
  const CategoryEntity({
    required this.id,
    required this.name,
    this.icon,
    this.colorHex,
  });

  final String id;
  final String name;
  final String? icon;
  final String? colorHex;
}
