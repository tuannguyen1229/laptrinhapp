import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../shared/models/borrow_card.dart';

class BorrowStatusCardWidget extends StatelessWidget {
  final BorrowCard card;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsReturned;
  final bool isUpdating;

  const BorrowStatusCardWidget({
    Key? key,
    required this.card,
    this.onTap,
    this.onMarkAsReturned,
    this.isUpdating = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: _getStatusGradient(),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Book name
                          Text(
                            card.bookName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          // Borrower info
                          Text(
                            '${card.borrowerName}${card.borrowerClass != null ? ' - ${card.borrowerClass}' : ''}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Status badge
                    _buildStatusBadge(),
                  ],
                ),
                const SizedBox(height: 12),

                // Dates row
                Row(
                  children: [
                    Expanded(
                      child: _buildDateInfo(
                        'Ngày mượn',
                        dateFormat.format(card.borrowDate),
                        Icons.calendar_today_rounded,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDateInfo(
                        card.status == BorrowStatus.returned ? 'Ngày trả' : 'Hạn trả',
                        card.status == BorrowStatus.returned && card.actualReturnDate != null
                            ? dateFormat.format(card.actualReturnDate!)
                            : dateFormat.format(card.expectedReturnDate),
                        card.status == BorrowStatus.returned 
                            ? Icons.check_circle_rounded
                            : Icons.event_rounded,
                      ),
                    ),
                  ],
                ),

                // Action button for active borrows
                if (card.status != BorrowStatus.returned && onMarkAsReturned != null) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isUpdating ? null : onMarkAsReturned,
                      icon: isUpdating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.assignment_return_rounded),
                      label: Text(isUpdating ? 'Đang xử lý...' : 'Đánh dấu đã trả'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateInfo(String label, String date, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white70,
          size: 16,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white60,
                ),
              ),
              Text(
                date,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    String text;
    IconData icon;
    Color backgroundColor;

    if (card.status == BorrowStatus.returned) {
      text = 'Đã trả';
      icon = Icons.check_circle_rounded;
      backgroundColor = Colors.white.withOpacity(0.2);
    } else if (card.isOverdue) {
      text = 'Quá hạn ${card.daysOverdue} ngày';
      icon = Icons.warning_rounded;
      backgroundColor = Colors.white.withOpacity(0.3);
    } else {
      text = 'Đang mượn';
      icon = Icons.schedule_rounded;
      backgroundColor = Colors.white.withOpacity(0.2);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient _getStatusGradient() {
    if (card.status == BorrowStatus.returned) {
      return const LinearGradient(
        colors: [Color(0xFF10B981), Color(0xFF34D399)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (card.isOverdue) {
      return const LinearGradient(
        colors: [Color(0xFFEF4444), Color(0xFFF87171)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else {
      return const LinearGradient(
        colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
  }
}