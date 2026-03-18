class Listing {
  final String id;
  final String titre;
  final String description;
  final double? prix;
  final String? image;
  final String? localisation;
  final String? ownerId;
  final DateTime? date;

  Listing({
    required this.id,
    required this.titre,
    required this.description,
    this.prix,
    this.image,
    this.localisation,
    this.date,
    required this.ownerId,
  });

  factory Listing.fromJson(Map<String, dynamic> json) {
    return Listing(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      ownerId: json['parent_offreur_id']?.toString() ?? json['user_id']?.toString() ?? '',
      titre: json['titre'] as String? ?? json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      prix:
          (json['prix'] as num?)?.toDouble() ??
          (json['price'] as num?)?.toDouble(),
      image: json['image'] as String? ?? json['photo'] as String?,
      localisation: json['localisation'] as String?,
      date: json['date'] != null
          ? DateTime.tryParse(json['date'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'ownerId': ownerId,
    'titre': titre,
    'description': description,
    'prix': prix,
    'image': image,
    'localisation': localisation,
    'date': date?.toIso8601String(),
  };
}
