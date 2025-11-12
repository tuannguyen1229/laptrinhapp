import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../config/injection/injection.dart';
import '../../../../shared/models/borrow_card.dart';
import '../../../tuan_borrow_management/presentation/screens/borrow_detail_screen.dart';
import '../../../tuan_borrow_management/presentation/bloc/borrow_bloc.dart';

class SearchResultCardWidget extends StatelessWidget {
  final BorrowCard card;
  final String query;

  const SearchResultCardWidget({
    Key? key,
    required this.card,
    required this.query,
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
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (context) => getIt<BorrowBloc>(),
                child: BorrowDetailScreen(borrowCard: card),
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book name
              Row(
                children: [
                  const Icon(
                    Icons.book_rounded,
                    color: Color(0xFF06B6D4),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildHighlightedText(
                      card.bookName,
                      query,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Borrower info
              Row(
                children: [
                  const Icon(
                    Icons.person_rounded,
                    color: Colors.grey,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildHighlightedText(
                      '${card.borrowerName}${card.borrowerClass != null ? ' - ${card.borrowerClass}' : ''}',
                      query,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Dates
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    color: Colors.grey,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Mượn: ${dateFormat.format(card.borrowDate)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.event_rounded,
                    color: Colors.grey,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Trả: ${dateFormat.format(card.expectedReturnDate)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Status badge
              _buildStatusBadge(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightedText(
    String text,
    String query, {
    TextStyle? style,
  }) {
    if (query.isEmpty) {
      return Text(text, style: style);
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase().trim();
    final index = lowerText.indexOf(lowerQuery);

    if (index == -1) {
      return Text(text, style: style);
    }

    final defaultStyle = style ?? const TextStyle();

    return RichText(
      text: TextSpan(
        style: defaultStyle,
        children: [
          TextSpan(text: text.substring(0, index)),
          TextSpan(
            text: text.substring(index, index + query.length),
            style: defaultStyle.copyWith(
              backgroundColor: Colors.yellow[200],
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(text: text.substring(index + query.length)),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    String text;
    IconData icon;

    if (card.status == BorrowStatus.returned) {
      color = Colors.green;
      text = 'Đã trả';
      icon = Icons.check_circle_rounded;
    } else if (card.isOverdue) {
      color = Colors.red;
      text = 'Quá hạn ${card.daysOverdue} ngày';
      icon = Icons.warning_rounded;
    } else {
      color = Colors.blue;
      text = 'Đang mượn';
      icon = Icons.schedule_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
