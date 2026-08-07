class Category {
  int? id;
  final String name;
  String? color = "#FFFFFF";

  Category({
    this.id,
    required this.name,
    this.color
  });


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color
    };
  }


  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      color: map['color']
    );
  }
}