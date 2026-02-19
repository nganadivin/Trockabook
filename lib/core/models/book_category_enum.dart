/// Book listing category
enum BookCategory {
  exchange('Échange'),
  sell('Vente'),
  donate('Don'),
  need('Besoin');

  final String displayName;
  const BookCategory(this.displayName);

  static BookCategory fromString(String value) {
    return BookCategory.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => BookCategory.exchange,
    );
  }

  String toJson() => name;
}
