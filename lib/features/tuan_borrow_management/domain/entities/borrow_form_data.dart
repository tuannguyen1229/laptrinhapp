import 'package:equatable/equatable.dart';
import '../../../../shared/models/borrow_card.dart';

class BorrowFormData extends Equatable {
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

  const BorrowFormData({
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
  });

  BorrowCard toBorrowCard({int? id}) {
    return BorrowCard(
      id: id,
      borrowerName: borrowerName,
      borrowerClass: borrowerClass,
      borrowerStudentId: borrowerStudentId,
      borrowerPhone: borrowerPhone,
      borrowerEmail: borrowerEmail,
      bookName: bookName,
      bookCode: bookCode,
      borrowDate: borrowDate,
      expectedReturnDate: expectedReturnDate,
      actualReturnDate: actualReturnDate,
      status: status,
    );
  }

  factory BorrowFormData.fromBorrowCard(BorrowCard borrowCard) {
    return BorrowFormData(
      borrowerName: borrowCard.borrowerName,
      borrowerClass: borrowCard.borrowerClass,
      borrowerStudentId: borrowCard.borrowerStudentId,
      borrowerPhone: borrowCard.borrowerPhone,
      borrowerEmail: borrowCard.borrowerEmail,
      bookName: borrowCard.bookName,
      bookCode: borrowCard.bookCode,
      borrowDate: borrowCard.borrowDate,
      expectedReturnDate: borrowCard.expectedReturnDate,
      actualReturnDate: borrowCard.actualReturnDate,
      status: borrowCard.status,
    );
  }

  BorrowFormData copyWith({
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
  }) {
    return BorrowFormData(
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
    );
  }

  @override
  List<Object?> get props => [
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
      ];
}