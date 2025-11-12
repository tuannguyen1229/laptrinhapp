import 'package:equatable/equatable.dart';

enum BorrowStatus {
  borrowed,
  returned,
  overdue;

  String toJson() => name;
  
  static BorrowStatus fromJson(String value) {
    return BorrowStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => BorrowStatus.borrowed,
    );
  }
}

class BorrowCard extends Equatable {
  final int? id;
  final String borrowerName;
  final String? borrowerClass;
  final String? borrowerStudentId;
  final String? borrowerPhone;
  final String? borrowerEmail;
  final String bookName;
  final String? bookCode;
  final DateTime borrowDate;
  final DateTime expectedReturnDate;
  final DateTime? actualReturnDate;
  final BorrowStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BorrowCard({
    this.id,
    required this.borrowerName,
    this.borrowerClass,
    this.borrowerStudentId,
    this.borrowerPhone,
    this.borrowerEmail,
    required this.bookName,
    this.bookCode,
    required this.borrowDate,
    required this.expectedReturnDate,
    this.actualReturnDate,
    this.status = BorrowStatus.borrowed,
    this.createdAt,
    this.updatedAt,
  });

  factory BorrowCard.fromJson(Map<String, dynamic> json) {
    return BorrowCard(
      id: json['id'] as int?,
      borrowerName: json['borrower_name'] as String,
      borrowerClass: json['borrower_class'] as String?,
      borrowerStudentId: json['borrower_student_id'] as String?,
      borrowerPhone: json['borrower_phone'] as String?,
      borrowerEmail: json['borrower_email'] as String?,
      bookName: json['book_name'] as String,
      bookCode: json['book_code'] as String?,
      borrowDate: json['borrow_date'] is String
          ? DateTime.parse(json['borrow_date'] as String)
          : DateTime.fromMillisecondsSinceEpoch(json['borrow_date'] as int),
      expectedReturnDate: json['expected_return_date'] is String
          ? DateTime.parse(json['expected_return_date'] as String)
          : DateTime.fromMillisecondsSinceEpoch(json['expected_return_date'] as int),
      actualReturnDate: json['actual_return_date'] == null
          ? null
          : (json['actual_return_date'] is String
              ? DateTime.parse(json['actual_return_date'] as String)
              : DateTime.fromMillisecondsSinceEpoch(json['actual_return_date'] as int)),
      status: json['status'] is String
          ? BorrowStatus.fromJson(json['status'] as String)
          : BorrowStatus.borrowed,
      createdAt: json['created_at'] == null
          ? null
          : (json['created_at'] is String
              ? DateTime.parse(json['created_at'] as String)
              : DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int)),
      updatedAt: json['updated_at'] == null
          ? null
          : (json['updated_at'] is String
              ? DateTime.parse(json['updated_at'] as String)
              : DateTime.fromMillisecondsSinceEpoch(json['updated_at'] as int)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'borrower_name': borrowerName,
      'borrower_class': borrowerClass,
      'borrower_student_id': borrowerStudentId,
      'borrower_phone': borrowerPhone,
      'borrower_email': borrowerEmail,
      'book_name': bookName,
      'book_code': bookCode,
      'borrow_date': borrowDate.toIso8601String(),
      'expected_return_date': expectedReturnDate.toIso8601String(),
      'actual_return_date': actualReturnDate?.toIso8601String(),
      'status': status.toJson(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  BorrowCard copyWith({
    int? id,
    String? borrowerName,
    String? borrowerClass,
    String? borrowerStudentId,
    String? borrowerPhone,
    String? borrowerEmail,
    String? bookName,
    String? bookCode,
    DateTime? borrowDate,
    DateTime? expectedReturnDate,
    DateTime? actualReturnDate,
    BorrowStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BorrowCard(
      id: id ?? this.id,
      borrowerName: borrowerName ?? this.borrowerName,
      borrowerClass: borrowerClass ?? this.borrowerClass,
      borrowerStudentId: borrowerStudentId ?? this.borrowerStudentId,
      borrowerPhone: borrowerPhone ?? this.borrowerPhone,
      borrowerEmail: borrowerEmail ?? this.borrowerEmail,
      bookName: bookName ?? this.bookName,
      bookCode: bookCode ?? this.bookCode,
      borrowDate: borrowDate ?? this.borrowDate,
      expectedReturnDate: expectedReturnDate ?? this.expectedReturnDate,
      actualReturnDate: actualReturnDate ?? this.actualReturnDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isOverdue {
    if (status == BorrowStatus.returned) return false;
    return DateTime.now().isAfter(expectedReturnDate);
  }

  int get daysOverdue {
    if (!isOverdue) return 0;
    return DateTime.now().difference(expectedReturnDate).inDays;
  }

  @override
  List<Object?> get props => [
        id,
        borrowerName,
        borrowerClass,
        borrowerStudentId,
        borrowerPhone,
        borrowerEmail,
        bookName,
        bookCode,
        borrowDate,
        expectedReturnDate,
        actualReturnDate,
        status,
        createdAt,
        updatedAt,
      ];
}