import '../../domain/entities/borrow_status_filter.dart';

class PaginationService {
  /// Tính toán pagination info
  static PaginationInfo calculatePagination({
    required int totalItems,
    required int currentPage,
    required int itemsPerPage,
  }) {
    final totalPages = (totalItems / itemsPerPage).ceil();
    
    return PaginationInfo(
      currentPage: currentPage,
      totalPages: totalPages,
      totalItems: totalItems,
      itemsPerPage: itemsPerPage,
    );
  }

  /// Lấy offset cho database query
  static int getOffset(int page, int limit) {
    return (page - 1) * limit;
  }

  /// Validate page number
  static int validatePage(int page, int totalPages) {
    if (page < 1) return 1;
    if (page > totalPages && totalPages > 0) return totalPages;
    return page;
  }

  /// Tạo list các page numbers để hiển thị
  static List<int> getPageNumbers({
    required int currentPage,
    required int totalPages,
    int maxVisible = 5,
  }) {
    if (totalPages <= maxVisible) {
      return List.generate(totalPages, (index) => index + 1);
    }

    final half = maxVisible ~/ 2;
    int start = currentPage - half;
    int end = currentPage + half;

    if (start < 1) {
      start = 1;
      end = maxVisible;
    }

    if (end > totalPages) {
      end = totalPages;
      start = totalPages - maxVisible + 1;
    }

    return List.generate(end - start + 1, (index) => start + index);
  }
}