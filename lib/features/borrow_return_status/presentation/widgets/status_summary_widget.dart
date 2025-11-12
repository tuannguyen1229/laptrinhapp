import 'package:flutter/material.dart';
import '../../../../shared/models/borrow_card.dart';

class StatusSummaryWidget extends StatelessWidget {
  final Map<BorrowStatus, int> statusCounts;
  final ValueChanged<BorrowStatus>? onStatusTap;

  const StatusSummaryWidget({
    Key? key,
    required this.statusCounts,
    this.onStatusTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: _buildStatusCard(
              'Đang mượn',
              statusCounts[BorrowStatus.borrowed] ?? 0,
              Icons.book_rounded,
              const Color(0xFF3B82F6),
              () => onStatusTap?.call(BorrowStatus.borrowed),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatusCard(
              'Đã trả',
              statusCounts[BorrowStatus.returned] ?? 0,
              Icons.check_circle_rounded,
              const Color(0xFF10B981),
              () => onStatusTap?.call(BorrowStatus.returned),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatusCard(
              'Quá hạn',
              statusCounts[BorrowStatus.overdue] ?? 0,
              Icons.warning_rounded,
              const Color(0xFFEF4444),
              () => onStatusTap?.call(BorrowStatus.overdue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(
    String title,
    int count,
    IconData icon,
    Color color,
    VoidCallback? onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}