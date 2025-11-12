import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../shared/models/borrow_card.dart';
import '../bloc/borrow_bloc.dart';
import '../bloc/borrow_event.dart';
import '../bloc/borrow_state.dart';
import 'borrow_form_screen.dart';

class BorrowDetailScreen extends StatefulWidget {
  final BorrowCard borrowCard;

  const BorrowDetailScreen({
    Key? key,
    required this.borrowCard,
  }) : super(key: key);

  @override
  State<BorrowDetailScreen> createState() => _BorrowDetailScreenState();
}

class _BorrowDetailScreenState extends State<BorrowDetailScreen> {
  late BorrowCard _borrowCard;

  @override
  void initState() {
    super.initState();
    _borrowCard = widget.borrowCard;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4E9AF1), Color(0xFF7C3AED)],
            ),
          ),
        ),
        title: const Text('Chi tiết thẻ mượn'),
        actions: [
          IconButton(
            onPressed: _editBorrowCard,
            icon: const Icon(Icons.edit_rounded),
            tooltip: 'Chỉnh sửa',
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              if (_borrowCard.status == BorrowStatus.borrowed)
                const PopupMenuItem(
                  value: 'mark_returned',
                  child: ListTile(
                    leading: Icon(Icons.check_rounded),
                    title: Text('Đánh dấu đã trả'),
                  ),
                ),
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete_rounded, color: Colors.red),
                  title: Text('Xóa thẻ mượn', style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocListener<BorrowBloc, BorrowState>(
        listener: (context, state) {
          if (state is BorrowOperationSuccess) {
            _showSuccessMessage(state.message);
            if (state.updatedCard != null) {
              setState(() {
                _borrowCard = state.updatedCard!;
              });
            }
          } else if (state is BorrowCardLoaded) {
            // Cập nhật thông tin sau khi reload
            if (mounted) {
              setState(() {
                _borrowCard = state.borrowCard;
              });
            }
          } else if (state is BorrowCardUpdated) {
            // Cập nhật thông tin sau khi sửa
            _showSuccessMessage('Đã cập nhật thông tin thành công');
            if (mounted) {
              setState(() {
                _borrowCard = state.borrowCard;
              });
            }
          } else if (state is BorrowCardDeleted) {
            _showSuccessMessage('Đã xóa thẻ mượn thành công');
            Navigator.of(context).pop(true); // Pop với result = true để list reload
          } else if (state is BorrowError) {
            _showErrorMessage(state.message);
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusCard(theme),
              const SizedBox(height: 16),
              _buildBookInfoCard(theme),
              const SizedBox(height: 16),
              _buildBorrowerInfoCard(theme),
              const SizedBox(height: 16),
              _buildDateInfoCard(theme, dateFormat),
              const SizedBox(height: 24),
              _buildActionButtons(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(ThemeData theme) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (_borrowCard.status) {
      case BorrowStatus.borrowed:
        if (_borrowCard.isOverdue) {
          statusColor = theme.colorScheme.error;
          statusIcon = Icons.warning;
          statusText = 'Quá hạn ${_borrowCard.daysOverdue} ngày';
        } else {
          statusColor = theme.colorScheme.primary;
          statusIcon = Icons.book;
          statusText = 'Đang mượn';
        }
        break;
      case BorrowStatus.returned:
        statusColor = theme.colorScheme.surfaceVariant;
        statusIcon = Icons.check_circle;
        statusText = 'Đã trả';
        break;
      case BorrowStatus.overdue:
        statusColor = theme.colorScheme.error;
        statusIcon = Icons.warning;
        statusText = 'Quá hạn';
        break;
    }

    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              statusIcon,
              size: 48,
              color: statusColor,
            ),
            const SizedBox(height: 12),
            Text(
              statusText,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_borrowCard.isOverdue && _borrowCard.status != BorrowStatus.returned) ...[
              const SizedBox(height: 8),
              Text(
                'Cần xử lý ngay',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: statusColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBookInfoCard(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4E9AF1), Color(0xFF7C3AED)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.book_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Thông tin sách',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Tên sách', _borrowCard.bookName, theme),
            if (_borrowCard.bookCode != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow('Mã sách', _borrowCard.bookCode!, theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBorrowerInfoCard(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4E9AF1), Color(0xFF7C3AED)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.person_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Thông tin người mượn',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Họ tên', _borrowCard.borrowerName, theme),
            if (_borrowCard.borrowerClass != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow('Lớp', _borrowCard.borrowerClass!, theme),
            ],
            if (_borrowCard.borrowerStudentId != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow('MSSV', _borrowCard.borrowerStudentId!, theme),
            ],
            if (_borrowCard.borrowerPhone != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow('Số điện thoại', _borrowCard.borrowerPhone!, theme),
            ],
            if (_borrowCard.borrowerEmail != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow('Email', _borrowCard.borrowerEmail!, theme, icon: Icons.email_rounded),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDateInfoCard(ThemeData theme, DateFormat dateFormat) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4E9AF1), Color(0xFF7C3AED)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Thông tin ngày tháng',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Ngày mượn',
              dateFormat.format(_borrowCard.borrowDate),
              theme,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Ngày trả dự kiến',
              dateFormat.format(_borrowCard.expectedReturnDate),
              theme,
              isOverdue: _borrowCard.isOverdue && _borrowCard.status != BorrowStatus.returned,
            ),
            if (_borrowCard.actualReturnDate != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                'Ngày trả thực tế',
                dateFormat.format(_borrowCard.actualReturnDate!),
                theme,
                isSuccess: true,
              ),
            ],
            if (_borrowCard.createdAt != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                'Ngày tạo',
                DateFormat('dd/MM/yyyy HH:mm').format(_borrowCard.createdAt!),
                theme,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    ThemeData theme, {
    bool isOverdue = false,
    bool isSuccess = false,
    IconData? icon,
  }) {
    Color? valueColor;
    if (isOverdue) {
      valueColor = theme.colorScheme.error;
    } else if (isSuccess) {
      valueColor = theme.colorScheme.primary;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: theme.colorScheme.primary.withOpacity(0.7),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: valueColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_borrowCard.status == BorrowStatus.borrowed)
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4E9AF1), Color(0xFF7C3AED)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4E9AF1).withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: _markAsReturned,
              icon: const Icon(Icons.check_rounded, color: Colors.white),
              label: const Text('Đánh dấu đã trả', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _editBorrowCard,
          icon: const Icon(Icons.edit_rounded),
          label: const Text('Chỉnh sửa thông tin'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: const BorderSide(color: Color(0xFF4E9AF1), width: 2),
            foregroundColor: const Color(0xFF4E9AF1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _deleteBorrowCard,
          icon: const Icon(Icons.delete_rounded),
          label: const Text('Xóa thẻ mượn'),
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.colorScheme.error,
            side: BorderSide(color: theme.colorScheme.error, width: 2),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'mark_returned':
        _markAsReturned();
        break;
      case 'delete':
        _deleteBorrowCard();
        break;
    }
  }

  void _editBorrowCard() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => BorrowFormScreen(borrowId: _borrowCard.id),
      ),
    );

    if (result == true && mounted) {
      // Reload the borrow card data
      if (_borrowCard.id != null) {
        context.read<BorrowBloc>().add(GetBorrowByIdEvent(borrowId: _borrowCard.id!));
      }
    }
  }

  void _markAsReturned() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc chắn muốn đánh dấu sách này đã được trả?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<BorrowBloc>().add(
                MarkAsReturnedEvent(borrowId: _borrowCard.id!),
              );
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  void _deleteBorrowCard() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc chắn muốn xóa thẻ mượn "${_borrowCard.bookName}"?\n\n'
          'Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<BorrowBloc>().add(
                DeleteBorrowEvent(borrowId: _borrowCard.id!),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
