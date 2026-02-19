/// Transaction/Proposal status states
enum TransactionStatus {
  pending('En attente'),
  accepted('Acceptée'),
  rejected('Rejetée'),
  negotiating('En négociation'),
  completed('Complétée'),
  cancelled('Annulée');

  final String displayName;
  const TransactionStatus(this.displayName);

  static TransactionStatus fromString(String value) {
    return TransactionStatus.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => TransactionStatus.pending,
    );
  }

  String toJson() => name;
}
