import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../shared/models/borrow_card.dart';

class BorrowCardWidget extends StatelessWidget {
  final BorrowCard borrowCard;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onMarkAsReturned;
  final bool showActions;

  const BorrowCardWidget({
    Key? key,
    required this.borrowCard,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onMarkAsReturned,
    this.showActions = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _getGradientColors(context),
        ),
        boxShadow: [
          BoxShadow(
            color: _getGradientColors(context)[0].withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with status
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.book_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        borrowCard.bookName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusChip(context),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Borrower info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.person_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              borrowCard.borrowerName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (borrowCard.borrowerClass != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.school_rounded,
                              size: 16,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              borrowCard.borrowerClass!,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Dates info
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: 14,
                                  color: Colors.white70,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Ngày mượn',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dateFormat.format(borrowCard.borrowDate),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.event_rounded,
                                  size: 14,
                                  color: borrowCard.isOverdue ? Colors.red[200] : Colors.white70,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Hạn trả',
                                  style: TextStyle(
                                    color: borrowCard.isOverdue ? Colors.red[200] : Colors.white70,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dateFormat.format(borrowCard.expectedReturnDate),
                              style: TextStyle(
                                color: borrowCard.isOverdue ? Colors.red[100] : Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                if (borrowCard.actualReturnDate != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Đã trả: ${dateFormat.format(borrowCard.actualReturnDate!)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                if (borrowCard.isOverdue && borrowCard.status != BorrowStatus.returned) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Quá hạn ${borrowCard.daysOverdue} ngày',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                // Actions
                if (showActions) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (borrowCard.status == BorrowStatus.borrowed && onMarkAsReturned != null)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextButton.icon(
                            onPressed: onMarkAsReturned,
                            icon: const Icon(Icons.check_rounded, size: 16, color: Colors.white),
                            label: const Text('Đã trả', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      
                      if (onEdit != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            onPressed: onEdit,
                            icon: const Icon(Icons.edit_rounded, size: 18, color: Colors.white),
                            tooltip: 'Sửa',
                          ),
                        ),
                      ],
                      
                      if (onDelete != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            onPressed: onDelete,
                            icon: const Icon(Icons.delete_rounded, size: 18, color: Colors.white),
                            tooltip: 'Xóa',
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Color> _getGradientColors(BuildContext context) {
    switch (borrowCard.status) {
      case BorrowStatus.borrowed:
        if (borrowCard.isOverdue) {
          return const [Color(0xFFFF6B6B), Color(0xFFFF8E53)]; // Coral-Orange gradient
        } else {
          return const [Color(0xFF4E9AF1), Color(0xFF7C3AED)]; // Blue-Purple gradient
        }
      case BorrowStatus.returned:
        return const [Color(0xFF10B981), Color(0xFF34D399)]; // Green gradient
      case BorrowStatus.overdue:
        return const [Color(0xFFFF6B6B), Color(0xFFFF8E53)]; // Coral-Orange gradient
    }
  }

  Widget _buildStatusChip(BuildContext context) {
    String label;
    IconData icon;

    switch (borrowCard.status) {
      case BorrowStatus.borrowed:
        if (borrowCard.isOverdue) {
          label = 'Quá hạn';
          icon = Icons.warning_rounded;
        } else {
          label = 'Đang mượn';
          icon = Icons.book_rounded;
        }
        break;
      case BorrowStatus.returned:
        label = 'Đã trả';
        icon = Icons.check_circle_rounded;
        break;
      case BorrowStatus.overdue:
        label = 'Quá hạn';
        icon = Icons.warning_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class BorrowCardListTile extends StatelessWidget {
  final BorrowCard borrowCard;
  final VoidCallback? onTap;
  final Widget? trailing;

  const BorrowCardListTile({
    Key? key,
    required this.borrowCard,
    this.onTap,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: _getStatusColor(context),
        child: Icon(
          _getStatusIcon(),
          color: Colors.white,
          size: 20,
        ),
      ),
      title: Text(
        borrowCard.bookName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(borrowCard.borrowerName),
          Text(
            'Mượn: ${dateFormat.format(borrowCard.borrowDate)} - '
            'Trả: ${dateFormat.format(borrowCard.expectedReturnDate)}',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
      trailing: trailing,
      isThreeLine: true,
    );
  }

  Color _getStatusColor(BuildContext context) {
    final theme = Theme.of(context);
    
    switch (borrowCard.status) {
      case BorrowStatus.borrowed:
        return borrowCard.isOverdue 
            ? theme.colorScheme.error 
            : theme.colorScheme.primary;
      case BorrowStatus.returned:
        return theme.colorScheme.surfaceVariant;
      case BorrowStatus.overdue:
        return theme.colorScheme.error;
    }
  }

  IconData _getStatusIcon() {
    switch (borrowCard.status) {
      case BorrowStatus.borrowed:
        return borrowCard.isOverdue ? Icons.warning : Icons.book;
      case BorrowStatus.returned:
        return Icons.check;
      case BorrowStatus.overdue:
        return Icons.warning;
    }
  }
}
