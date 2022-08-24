class Meal {
  final String id;
  final String name;
  final String description;
  int favorite = 0;
  Meal({
    this.id = '',
    this.name = '',
    this.description = '',
    this.favorite = 0,
  });

  Meal copy() => Meal(
        id: this.id,
        name: this.name,
        description: this.description,
        favorite: this.favorite,
      );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'favorite': favorite,
    };
  }
}
