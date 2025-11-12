import 'package:flutter/material.dart';
import '../../../../shared/database/database_helper.dart';
import '../../../../shared/models/borrow_card.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class UserBorrowsScreen extends StatefulWidget {
  final String filter; // 'active', 'overdue', 'returned'

  const UserBorrowsScreen({
    super.key,
    required this.filter,
  });

  @override
  State<UserBorrowsScreen> createState() => _UserBorrowsScreenState();
}

class _UserBorrowsScreenState extends State<UserBorrowsScreen> {
  List<BorrowCard> _borrows = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBorrows();
  }

  Future<void> _loadBorrows() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! Authenticated) {
        throw Exception('User not authenticated');
      }

      final user = authState.user;
      final dbHelper = DatabaseHelper();

      // Build query based on filter
      String whereClause = "LOWER(borrower_name) = LOWER('${user.fullName}')";
      
      if (widget.filter == 'active') {
        whereClause += " AND status = 'borrowed' AND expected_return_date >= CURRENT_DATE";
      } else if (widget.filter == 'overdue') {
        whereClause += " AND (status = 'overdue' OR (status = 'borrowed' AND expected_return_date < CURRENT_DATE))";
      } else if (widget.filter == 'returned') {
        whereClause += " AND status = 'returned'";
      }

      final result = await dbHelper.executeRemoteQuery(
        '''
        SELECT * FROM borrow_cards 
        WHERE $whereClause
        ORDER BY borrow_date DESC
        ''',
      );

      result.fold(
        (failure) {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _errorMessage = failure.message;
            });
          }
        },
        (rows) {
          if (mounted) {
            setState(() {
              _borrows = rows.map((row) => BorrowCard.fromJson(row)).toList();
              _isLoading = false;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  String _getTitle() {
    switch (widget.filter) {
      case 'active':
        return 'Sách đang mượn';
      case 'overdue':
        return 'Sách quá hạn';
      case 'returned':
        return 'Sách đã trả';
      default:
        return 'Danh sách sách';
    }
  }

  List<Color> _getGradientColors() {
    switch (widget.filter) {
      case 'active':
        return [const Color(0xFF1976D2), const Color(0xFF2196F3)];
      case 'overdue':
        return [const Color(0xFFC62828), const Color(0xFFE53935)];
      case 'returned':
        return [const Color(0xFF388E3C), const Color(0xFF4CAF50)];
      default:
        return [const Color(0xFF1976D2), const Color(0xFF2196F3)];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _getGradientColors(),
            ),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Lỗi: $_errorMessage',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadBorrows,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_borrows.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Không có sách nào',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBorrows,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _borrows.length,
        itemBuilder: (context, index) {
          final borrow = _borrows[index];
          return _buildBorrowCard(borrow);
        },
      ),
    );
  }

  Widget _buildBorrowCard(BorrowCard borrow) {
    final now = DateTime.now();
    final isOverdue = borrow.status == BorrowStatus.overdue ||
        (borrow.status == BorrowStatus.borrowed &&
            borrow.expectedReturnDate.isBefore(now));

    Color cardColor;
    IconData statusIcon;
    String statusText;

    if (borrow.status == BorrowStatus.returned) {
      cardColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = 'Đã trả';
    } else if (isOverdue) {
      cardColor = Colors.red;
      statusIcon = Icons.warning;
      statusText = 'Quá hạn';
    } else {
      cardColor = Colors.blue;
      statusIcon = Icons.book;
      statusText = 'Đang mượn';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              cardColor.withOpacity(0.1),
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: cardColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(statusIcon, color: cardColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          borrow.bookName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            statusText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              // Details
              _buildDetailRow(
                Icons.calendar_today,
                'Ngày mượn',
                DateFormat('dd/MM/yyyy').format(borrow.borrowDate),
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                Icons.event,
                'Ngày trả dự kiến',
                DateFormat('dd/MM/yyyy').format(borrow.expectedReturnDate),
              ),
              if (borrow.actualReturnDate != null) ...[
                const SizedBox(height: 8),
                _buildDetailRow(
                  Icons.check_circle,
                  'Ngày trả thực tế',
                  DateFormat('dd/MM/yyyy').format(borrow.actualReturnDate!),
                ),
              ],
              if (isOverdue && borrow.status != BorrowStatus.returned) ...[
                const SizedBox(height: 8),
                _buildDetailRow(
                  Icons.warning,
                  'Số ngày quá hạn',
                  '${now.difference(borrow.expectedReturnDate).inDays} ngày',
                  color: Colors.red,
                ),
              ],
              if (borrow.bookCode != null && borrow.bookCode!.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildDetailRow(
                  Icons.qr_code,
                  'Mã sách',
                  borrow.bookCode!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value,
      {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color ?? Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color ?? Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
