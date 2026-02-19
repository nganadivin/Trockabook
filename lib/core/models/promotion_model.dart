class Promotion {
  final String id;
  final String titre;
  final String description;
  final String? image;
  final double? remise; // Pourcentage
  final DateTime? dateDebut;
  final DateTime? dateFin;
  final String? code;

  Promotion({
    required this.id,
    required this.titre,
    required this.description,
    this.image,
    this.remise,
    this.dateDebut,
    this.dateFin,
    this.code,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      id: json['id'] as String? ?? '',
      titre: json['titre'] as String? ?? '',
      description: json['description'] as String? ?? '',
      image: json['image'] as String?,
      remise: (json['remise'] as num?)?.toDouble(),
      dateDebut: json['dateDebut'] != null
          ? DateTime.tryParse(json['dateDebut'] as String)
          : null,
      dateFin: json['dateFin'] != null
          ? DateTime.tryParse(json['dateFin'] as String)
          : null,
      code: json['code'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'description': description,
      'image': image,
      'remise': remise,
      'dateDebut': dateDebut?.toIso8601String(),
      'dateFin': dateFin?.toIso8601String(),
      'code': code,
    };
  }
}
