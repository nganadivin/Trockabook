class Category {
  final String id;
  final String nom;
  final String icone; // Icon name or emoji
  final String couleur; // Hex color code

  Category({
    required this.id,
    required this.nom,
    required this.icone,
    required this.couleur,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String? ?? '',
      nom: json['nom'] as String? ?? '',
      icone: json['icone'] as String? ?? '📚',
      couleur: json['couleur'] as String? ?? '#2196F3',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'nom': nom, 'icone': icone, 'couleur': couleur};
  }
}
