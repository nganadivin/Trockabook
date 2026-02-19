import 'transaction_status_enum.dart';

class Transaction {
  final String id;
  final String bookId;
  final String? offeredBookId;
  final String proposedBy; // User ID initiating the proposal
  final String? receiverId; // User ID receiving the proposal
  final TransactionStatus status;
  final String? proposedPrice; // For selling
  final List<String>? proposedBooks; // For exchange
  final String? message;
  final String? counterMessage;
  final List<Map<String, dynamic>>? history; // Track negotiation history
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;

  Transaction({
    required this.id,
    required this.bookId,
    this.offeredBookId,
    required this.proposedBy,
    this.receiverId,
    this.status = TransactionStatus.pending,
    this.proposedPrice,
    this.proposedBooks,
    this.message,
    this.counterMessage,
    this.history,
    required this.createdAt,
    this.updatedAt,
    this.completedAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id']?.toString() ?? '',
      bookId: json['bookId']?.toString() ?? json['livreId']?.toString() ?? '',
      offeredBookId: json['offeredBookId']?.toString(),
      proposedBy:
          json['proposedBy']?.toString() ??
          json['fromUserId']?.toString() ??
          '',
      receiverId:
          json['receiverId']?.toString() ?? json['toUserId']?.toString(),
      status: TransactionStatus.fromString(json['status'] ?? 'pending'),
      proposedPrice: json['proposedPrice']?.toString(),
      proposedBooks: json['proposedBooks'] != null
          ? List<String>.from(json['proposedBooks'] as List)
          : null,
      message: json['message'],
      counterMessage: json['counterMessage'],
      history: json['history'] != null
          ? List<Map<String, dynamic>>.from(json['history'] as List)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'offeredBookId': offeredBookId,
      'proposedBy': proposedBy,
      'receiverId': receiverId,
      'status': status.toJson(),
      if (proposedPrice != null) 'proposedPrice': proposedPrice,
      if (proposedBooks != null) 'proposedBooks': proposedBooks,
      if (message != null) 'message': message,
      if (counterMessage != null) 'counterMessage': counterMessage,
      if (history != null) 'history': history,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  Transaction copyWith({
    String? id,
    String? bookId,
    String? offeredBookId,
    String? proposedBy,
    String? receiverId,
    TransactionStatus? status,
    String? proposedPrice,
    List<String>? proposedBooks,
    String? message,
    String? counterMessage,
    List<Map<String, dynamic>>? history,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      offeredBookId: offeredBookId ?? this.offeredBookId,
      proposedBy: proposedBy ?? this.proposedBy,
      receiverId: receiverId ?? this.receiverId,
      status: status ?? this.status,
      proposedPrice: proposedPrice ?? this.proposedPrice,
      proposedBooks: proposedBooks ?? this.proposedBooks,
      message: message ?? this.message,
      counterMessage: counterMessage ?? this.counterMessage,
      history: history ?? this.history,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
