import 'book_category_enum.dart';

class Book {
  final String id;
  final String titre;
  final String? auteur;
  final String? description;
  final String? niveau;
  final String? classe;
  final String? matiere;
  final String? etat;
  final String? image;
  final String status;
  final String? userId;
  final BookCategory category;
  final double? price; // For sell category
  final List<String>? desiredBooks; // For exchange category
  final String? needType; // 'buy', 'exchange', 'free' for need category
  final double? latitude;
  final double? longitude;
  final DateTime? createdAt;

  Book({
    required this.id,
    required this.titre,
    this.auteur,
    this.description,
    this.niveau,
    this.classe,
    this.matiere,
    this.etat,
    this.image,
    this.status = 'Disponible',
    this.userId,
    this.category = BookCategory.exchange,
    this.price,
    this.desiredBooks,
    this.needType,
    this.latitude,
    this.longitude,
    this.createdAt,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id']?.toString() ?? '',
      titre: json['titre'] ?? 'Unknown',
      auteur: json['auteur'],
      description: json['description'],
      niveau: json['niveau'],
      classe: json['classe'],
      matiere: json['matiere'],
      etat: json['etat'],
      image: json['image'],
      status: json['status'] ?? json['statut'] ?? 'Disponible',
      userId: json['userId'],
      category: BookCategory.fromString(json['category'] ?? 'exchange'),
      price: json['price'] != null
          ? double.tryParse(json['price'].toString())
          : null,
      desiredBooks: json['desiredBooks'] != null
          ? List<String>.from(json['desiredBooks'] as List)
          : null,
      needType: json['needType'],
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'auteur': auteur,
      'description': description,
      'niveau': niveau,
      'classe': classe,
      'matiere': matiere,
      'etat': etat,
      'image': image,
      'status': status,
      'userId': userId,
      'category': category.toJson(),
      if (price != null) 'price': price,
      if (desiredBooks != null) 'desiredBooks': desiredBooks,
      if (needType != null) 'needType': needType,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  Book copyWith({
    String? id,
    String? titre,
    String? auteur,
    String? description,
    String? niveau,
    String? classe,
    String? matiere,
    String? etat,
    String? image,
    String? status,
    String? userId,
    BookCategory? category,
    double? price,
    List<String>? desiredBooks,
    String? needType,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
  }) {
    return Book(
      id: id ?? this.id,
      titre: titre ?? this.titre,
      auteur: auteur ?? this.auteur,
      description: description ?? this.description,
      niveau: niveau ?? this.niveau,
      classe: classe ?? this.classe,
      matiere: matiere ?? this.matiere,
      etat: etat ?? this.etat,
      image: image ?? this.image,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      price: price ?? this.price,
      desiredBooks: desiredBooks ?? this.desiredBooks,
      needType: needType ?? this.needType,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
