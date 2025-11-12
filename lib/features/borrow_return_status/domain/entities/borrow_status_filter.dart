import 'package:equatable/equatable.dart';
import '../../../../shared/models/borrow_card.dart';

enum BorrowStatusTab {
  active,    // Đang mượn (borrowed + overdue)
  returned,  // Đã trả
}

class BorrowStatusFilter extends Equatable {
  final BorrowStatusTab tab;
  final String? searchQuery;
  final int page;
  final int limit;
  final DateTime? fromDate;
  final DateTime? toDate;

  const BorrowStatusFilter({
    required this.tab,
    this.searchQuery,
    this.page = 1,
    this.limit = 20,
    this.fromDate,
    this.toDate,
  });

  BorrowStatusFilter copyWith({
    BorrowStatusTab? tab,
    String? searchQuery,
    int? page,
    int? limit,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    return BorrowStatusFilter(
      tab: tab ?? this.tab,
      searchQuery: searchQuery ?? this.searchQuery,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
    );
  }

  @override
  List<Object?> get props => [
        tab,
        searchQuery,
        page,
        limit,
        fromDate,
        toDate,
      ];
}

class PaginationInfo extends Equatable {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;

  const PaginationInfo({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
  });

  bool get hasNextPage => currentPage < totalPages;
  bool get hasPreviousPage => currentPage > 1;

  @override
  List<Object?> get props => [
        currentPage,
        totalPages,
        totalItems,
        itemsPerPage,
      ];
}