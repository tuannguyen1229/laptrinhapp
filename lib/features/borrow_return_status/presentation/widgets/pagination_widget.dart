import 'package:flutter/material.dart';
import '../../domain/entities/borrow_status_filter.dart';
import '../services/borrow_status_calculator.dart';

class PaginationWidget extends StatelessWidget {
  final PaginationInfo paginationInfo;
  final int currentItemCount;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final ValueChanged<int>? onPageSelected;

  const PaginationWidget({
    Key? key,
    required this.paginationInfo,
    required this.currentItemCount,
    this.onPrevious,
    this.onNext,
    this.onPageSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (paginationInfo.totalItems == 0) {
      return const SizedBox();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Column(
        children: [
          // Info row
          Row(
            children: [
              Text(
                BorrowStatusCalculator.getDisplayRange(
                  currentPage: paginationInfo.currentPage,
                  itemsPerPage: paginationInfo.itemsPerPage,
                  totalItems: paginationInfo.totalItems,
                  currentItemCount: currentItemCount,
                ),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              Text(
                'Trang ${paginationInfo.currentPage} / ${paginationInfo.totalPages}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Navigation row
          Row(
            children: [
              // Previous button
              IconButton(
                onPressed: paginationInfo.hasPreviousPage ? onPrevious : null,
                icon: const Icon(Icons.chevron_left),
                tooltip: 'Trang trước',
              ),

              // Page numbers
              Expanded(
                child: _buildPageNumbers(context),
              ),

              // Next button
              IconButton(
                onPressed: paginationInfo.hasNextPage ? onNext : null,
                icon: const Icon(Icons.chevron_right),
                tooltip: 'Trang sau',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPageNumbers(BuildContext context) {
    if (paginationInfo.totalPages <= 1) {
      return const SizedBox();
    }

    final pageNumbers = _getVisiblePageNumbers();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: pageNumbers.map((pageNumber) {
          if (pageNumber == -1) {
            // Ellipsis
            return const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text('...'),
            );
          }

          final isCurrentPage = pageNumber == paginationInfo.currentPage;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: InkWell(
              onTap: isCurrentPage ? null : () => onPageSelected?.call(pageNumber),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isCurrentPage 
                      ? Theme.of(context).primaryColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: isCurrentPage 
                      ? null 
                      : Border.all(color: Colors.grey[300]!),
                ),
                child: Center(
                  child: Text(
                    pageNumber.toString(),
                    style: TextStyle(
                      color: isCurrentPage ? Colors.white : Colors.black87,
                      fontWeight: isCurrentPage ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  List<int> _getVisiblePageNumbers() {
    const maxVisible = 7;
    final totalPages = paginationInfo.totalPages;
    final currentPage = paginationInfo.currentPage;

    if (totalPages <= maxVisible) {
      return List.generate(totalPages, (index) => index + 1);
    }

    List<int> pages = [];

    // Always show first page
    pages.add(1);

    if (currentPage > 4) {
      pages.add(-1); // Ellipsis
    }

    // Show pages around current page
    final start = (currentPage - 2).clamp(2, totalPages - 1);
    final end = (currentPage + 2).clamp(2, totalPages - 1);

    for (int i = start; i <= end; i++) {
      if (!pages.contains(i)) {
        pages.add(i);
      }
    }

    if (currentPage < totalPages - 3) {
      pages.add(-1); // Ellipsis
    }

    // Always show last page
    if (!pages.contains(totalPages)) {
      pages.add(totalPages);
    }

    return pages;
  }
}