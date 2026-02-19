class PanierSurprise {
  final String id;
  final String titre;
  final String description;
  final double prix;
  final int quantiteRestante;
  final String? image;
  final DateTime? dateCollecte;
  final String? localisation;

  PanierSurprise({
    required this.id,
    required this.titre,
    required this.description,
    required this.prix,
    required this.quantiteRestante,
    this.image,
    this.dateCollecte,
    this.localisation,
  });

  factory PanierSurprise.fromJson(Map<String, dynamic> json) {
    return PanierSurprise(
      id: json['id'] as String? ?? '',
      titre: json['titre'] as String? ?? '',
      description: json['description'] as String? ?? '',
      prix: (json['prix'] as num?)?.toDouble() ?? 0.0,
      quantiteRestante: json['quantiteRestante'] as int? ?? 0,
      image: json['image'] as String?,
      dateCollecte: json['dateCollecte'] != null
          ? DateTime.tryParse(json['dateCollecte'] as String)
          : null,
      localisation: json['localisation'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'description': description,
      'prix': prix,
      'quantiteRestante': quantiteRestante,
      'image': image,
      'dateCollecte': dateCollecte?.toIso8601String(),
      'localisation': localisation,
    };
  }
}
