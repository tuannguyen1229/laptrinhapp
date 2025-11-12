import '../../domain/entities/borrow_status_filter.dart';

class BorrowStatusCalculator {
  /// Tính toán pagination info
  static PaginationInfo calculatePagination({
    required int totalItems,
    required int currentPage,
    required int itemsPerPage,
  }) {
    final totalPages = totalItems == 0 ? 1 : (totalItems / itemsPerPage).ceil();
    
    return PaginationInfo(
      currentPage: currentPage,
      totalPages: totalPages,
      totalItems: totalItems,
      itemsPerPage: itemsPerPage,
    );
  }

  /// Tính toán range hiển thị (e.g., "1-20 of 100")
  static String getDisplayRange({
    required int currentPage,
    required int itemsPerPage,
    required int totalItems,
    required int currentItemCount,
  }) {
    if (totalItems == 0) return '0 of 0';
    
    final start = (currentPage - 1) * itemsPerPage + 1;
    final end = start + currentItemCount - 1;
    
    return '$start-$end of $totalItems';
  }

  /// Tính toán progress percentage
  static double getProgressPercentage({
    required int currentPage,
    required int totalPages,
  }) {
    if (totalPages <= 1) return 1.0;
    return currentPage / totalPages;
  }
}