import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/injection/injection.dart';
import '../../../../shared/models/borrow_card.dart';
import '../../../../shared/services/email_service.dart';
import '../../../tuan_borrow_management/presentation/screens/borrow_detail_screen.dart';
import '../../../tuan_borrow_management/presentation/bloc/borrow_bloc.dart';
import '../../data/services/overdue_service.dart';
import '../bloc/overdue_bloc.dart';
import '../bloc/overdue_event.dart';
import '../bloc/overdue_state.dart';
import '../widgets/overdue_card_widget.dart';
import '../widgets/overdue_dashboard_widget.dart';

class OverdueListScreen extends StatelessWidget {
  const OverdueListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<OverdueBloc>()
        ..add(const LoadOverdueStatisticsEvent()),
      child: const _OverdueListScreenContent(),
    );
  }
}

class _OverdueListScreenContent extends StatelessWidget {
  const _OverdueListScreenContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
            ),
          ),
        ),
        title: const Text('Cảnh báo quá hạn'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<OverdueBloc>().add(const RefreshOverdueEvent());
            },
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: BlocBuilder<OverdueBloc, OverdueState>(
        builder: (context, state) {
          if (state is OverdueLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is OverdueError) {
            return _buildErrorState(context, state.message);
          }

          if (state is OverdueEmpty) {
            return _buildEmptyState(context);
          }

          if (state is OverdueStatisticsLoaded) {
            return _buildContent(context, state);
          }

          if (state is OverdueRefreshing) {
            return _buildContent(
              context,
              OverdueStatisticsLoaded(
                statistics: OverdueStatistics(
                  totalOverdue: state.currentCards.length,
                  criticalOverdue: 0,
                  moderateOverdue: 0,
                  recentOverdue: 0,
                  overdueCards: state.currentCards,
                ),
              ),
              isRefreshing: true,
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    OverdueStatisticsLoaded state, {
    bool isRefreshing = false,
  }) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<OverdueBloc>().add(const RefreshOverdueEvent());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dashboard widget
            OverdueDashboardWidget(statistics: state.statistics),
            const SizedBox(height: 24),
            
            // Title
            Text(
              'Danh sách sách quá hạn',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // List of overdue cards
            ...state.statistics.overdueCards.map((card) {
              return OverdueCardWidget(
                borrowCard: card,
                onTap: () => _navigateToDetail(context, card),
              );
            }).toList(),
            
            if (isRefreshing)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF10B981).withOpacity(0.1),
                  const Color(0xFF34D399).withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              size: 80,
              color: Color(0xFF10B981),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Tuyệt vời!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF10B981),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Không có sách quá hạn',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<OverdueBloc>().add(const LoadOverdueStatisticsEvent());
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(BuildContext context, BorrowCard card) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => getIt<BorrowBloc>(),
          child: BorrowDetailScreen(borrowCard: card),
        ),
      ),
    );
  }


}
