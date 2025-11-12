import 'package:equatable/equatable.dart';
import '../../../../shared/models/borrow_card.dart';

enum SearchType {
  borrowerName,
  bookName,
  advanced,
}

class SearchQuery extends Equatable {
  final String? borrowerName;
  final String? bookName;
  final String? borrowerClass;
  final BorrowStatus? status;
  final DateTime? borrowDateFrom;
  final DateTime? borrowDateTo;
  final DateTime? returnDateFrom;
  final DateTime? returnDateTo;
  final SearchType type;

  const SearchQuery({
    this.borrowerName,
    this.bookName,
    this.borrowerClass,
    this.status,
    this.borrowDateFrom,
    this.borrowDateTo,
    this.returnDateFrom,
    this.returnDateTo,
    this.type = SearchType.borrowerName,
  });

  bool get isEmpty {
    return borrowerName == null &&
        bookName == null &&
        borrowerClass == null &&
        status == null &&
        borrowDateFrom == null &&
        borrowDateTo == null &&
        returnDateFrom == null &&
        returnDateTo == null;
  }

  SearchQuery copyWith({
    String? borrowerName,
    String? bookName,
    String? borrowerClass,
    BorrowStatus? status,
    DateTime? borrowDateFrom,
    DateTime? borrowDateTo,
    DateTime? returnDateFrom,
    DateTime? returnDateTo,
    SearchType? type,
  }) {
    return SearchQuery(
      borrowerName: borrowerName ?? this.borrowerName,
      bookName: bookName ?? this.bookName,
      borrowerClass: borrowerClass ?? this.borrowerClass,
      status: status ?? this.status,
      borrowDateFrom: borrowDateFrom ?? this.borrowDateFrom,
      borrowDateTo: borrowDateTo ?? this.borrowDateTo,
      returnDateFrom: returnDateFrom ?? this.returnDateFrom,
      returnDateTo: returnDateTo ?? this.returnDateTo,
      type: type ?? this.type,
    );
  }

  @override
  List<Object?> get props => [
        borrowerName,
        bookName,
        borrowerClass,
        status,
        borrowDateFrom,
        borrowDateTo,
        returnDateFrom,
        returnDateTo,
        type,
      ];
}
