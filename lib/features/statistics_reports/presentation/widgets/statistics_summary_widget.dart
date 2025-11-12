import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/models/statistics_data.dart';
import '../../data/services/chart_data_service.dart';

class StatisticsSummaryWidget extends StatelessWidget {
  final StatisticsSummary summary;

  const StatisticsSummaryWidget({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Tổng quan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 12),
          // Summary cards in 3 columns
          _buildCompactSummaryCards(),
          const SizedBox(height: 12),
          // Highlights in compact form
          _buildCompactHighlights(),
        ],
      ),
    );
  }

  Widget _buildCompactSummaryCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildCompactCard(
                'Tổng mượn',
                summary.totalBorrows.toString(),
                Icons.library_books,
                const Color(0xFF3182CE),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildCompactCard(
                'Đang mượn',
                summary.activeBorrows.toString(),
                Icons.schedule,
                const Color(0xFF38A169),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildCompactCard(
                'Đã trả',
                summary.returnedBorrows.toString(),
                Icons.check_circle,
                const Color(0xFF38A169),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildCompactCard(
                'Quá hạn',
                summary.overdueBorrows.toString(),
                Icons.warning,
                const Color(0xFFE53E3E),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildCompactCard(
                'Người mượn',
                summary.uniqueBorrowers.toString(),
                Icons.people,
                const Color(0xFF805AD5),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildCompactCard(
                'Sách khác',
                summary.uniqueBooks.toString(),
                Icons.menu_book,
                const Color(0xFFD69E2E),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactHighlights() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6A11CB).withOpacity(0.1),
            const Color(0xFF2575FC).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Điểm nổi bật',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          _buildCompactHighlightItem(
            'Sách phổ biến',
            summary.mostPopularBook,
            Icons.star,
            const Color(0xFFD69E2E),
          ),
          const SizedBox(height: 6),
          _buildCompactHighlightItem(
            'Người tích cực',
            summary.mostActiveBorrower,
            Icons.person,
            const Color(0xFF805AD5),
          ),
          const SizedBox(height: 6),
          _buildCompactHighlightItem(
            'TB mượn',
            '${summary.averageBorrowDuration.toStringAsFixed(1)} ngày',
            Icons.access_time,
            const Color(0xFF3182CE),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactHighlightItem(String title, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }


}