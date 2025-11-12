import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/injection/injection.dart';
import '../../../../shared/models/borrow_card.dart';
import '../../../tuan_borrow_management/presentation/screens/borrow_detail_screen.dart';
import '../../../tuan_borrow_management/presentation/bloc/borrow_bloc.dart';
import '../../domain/entities/borrow_status_filter.dart';
import '../bloc/borrow_status_bloc.dart';
import '../bloc/borrow_status_event.dart';
import '../bloc/borrow_status_state.dart';
import '../widgets/borrow_status_card_widget.dart';
import '../widgets/pagination_widget.dart';
import '../widgets/status_summary_widget.dart';

class BorrowStatusScreen extends StatefulWidget {
  const BorrowStatusScreen({Key? key}) : super(key: key);

  @override
  State<BorrowStatusScreen> createState() => _BorrowStatusScreenState();
}

class _BorrowStatusScreenState extends State<BorrowStatusScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    
    // Load initial data
    context.read<BorrowStatusBloc>().add(
      const LoadBorrowStatusEvent(
        BorrowStatusFilter(tab: BorrowStatusTab.active),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      final tab = _tabController.index == 0 
          ? BorrowStatusTab.active 
          : BorrowStatusTab.returned;
      
      _searchController.clear();
      context.read<BorrowStatusBloc>().add(SwitchTabEvent(tab));
    }
  }

  void _onSearchChanged(String query) {
    context.read<BorrowStatusBloc>().add(SearchBorrowsEvent(query));
  }

  void _onClearSearch() {
    _searchController.clear();
    context.read<BorrowStatusBloc>().add(const SearchBorrowsEvent(''));
  }

  void _onRefresh() {
    context.read<BorrowStatusBloc>().add(const RefreshDataEvent());
  }

  void _onMarkAsReturned(BorrowCard card) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận trả sách'),
        content: Text(
          'Xác nhận đánh dấu sách "${card.bookName}" của ${card.borrowerName} là đã trả?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<BorrowStatusBloc>().add(
                MarkAsReturnedEvent(
                  borrowCardId: card.id!,
                  returnDate: DateTime.now(),
                ),
              );
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  void _onCardTap(BorrowCard card) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => getIt<BorrowBloc>(),
          child: BorrowDetailScreen(borrowCard: card),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
            ),
          ),
        ),
        title: const Text('Danh sách mượn/trả'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Đang mượn'),
            Tab(text: 'Đã trả'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _onRefresh,
            icon: const Icon(Icons.refresh),
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: Column(
        children: [
          // Status summary
          BlocBuilder<BorrowStatusBloc, BorrowStatusState>(
            builder: (context, state) {
              if (state is BorrowStatusLoaded || state is BorrowStatusEmpty) {
                final statusCounts = state is BorrowStatusLoaded
                    ? state.statusCounts
                    : (state as BorrowStatusEmpty).statusCounts;
                
                return StatusSummaryWidget(
                  statusCounts: statusCounts,
                  onStatusTap: (status) {
                    // Switch to appropriate tab based on status
                    if (status == BorrowStatus.returned) {
                      _tabController.animateTo(1);
                    } else {
                      _tabController.animateTo(0);
                    }
                  },
                );
              }
              return const SizedBox();
            },
          ),

          // Search bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo tên người mượn hoặc sách...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _onClearSearch,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),

          // Content
          Expanded(
            child: BlocBuilder<BorrowStatusBloc, BorrowStatusState>(
              builder: (context, state) {
                if (state is BorrowStatusInitial || state is BorrowStatusLoading) {
                  return _buildLoadingState();
                } else if (state is BorrowStatusLoaded) {
                  return _buildLoadedState(state);
                } else if (state is BorrowStatusEmpty) {
                  return _buildEmptyState(state);
                } else if (state is BorrowStatusError) {
                  return _buildErrorState(state);
                } else if (state is BorrowStatusUpdating) {
                  return _buildUpdatingState(state);
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildLoadedState(BorrowStatusLoaded state) {
    return Column(
      children: [
        // Results list
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => _onRefresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.borrowCards.length,
              itemBuilder: (context, index) {
                final card = state.borrowCards[index];
                return BorrowStatusCardWidget(
                  card: card,
                  onTap: () => _onCardTap(card),
                  onMarkAsReturned: card.status != BorrowStatus.returned
                      ? () => _onMarkAsReturned(card)
                      : null,
                );
              },
            ),
          ),
        ),

        // Pagination
        if (state.paginationInfo.totalPages > 1)
          PaginationWidget(
            paginationInfo: state.paginationInfo,
            currentItemCount: state.borrowCards.length,
            onPrevious: state.paginationInfo.hasPreviousPage
                ? () => context.read<BorrowStatusBloc>().add(const LoadPreviousPageEvent())
                : null,
            onNext: state.paginationInfo.hasNextPage
                ? () => context.read<BorrowStatusBloc>().add(const LoadNextPageEvent())
                : null,
            onPageSelected: (page) => context.read<BorrowStatusBloc>().add(GoToPageEvent(page)),
          ),
      ],
    );
  }

  Widget _buildEmptyState(BorrowStatusEmpty state) {
    final isActiveTab = state.currentFilter.tab == BorrowStatusTab.active;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActiveTab ? Icons.book_outlined : Icons.check_circle_outline,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              isActiveTab ? 'Không có sách đang mượn' : 'Không có sách đã trả',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.currentFilter.searchQuery != null
                  ? 'Không tìm thấy kết quả cho "${state.currentFilter.searchQuery}"'
                  : isActiveTab
                      ? 'Tất cả sách đã được trả'
                      : 'Chưa có sách nào được trả',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BorrowStatusError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 80,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Có lỗi xảy ra',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdatingState(BorrowStatusUpdating state) {
    return Column(
      children: [
        // Show updating indicator
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.blue[50],
          child: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              const Text('Đang cập nhật trạng thái...'),
            ],
          ),
        ),

        // Show current list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.borrowCards.length,
            itemBuilder: (context, index) {
              final card = state.borrowCards[index];
              final isUpdating = card.id == state.updatingCardId;
              
              return BorrowStatusCardWidget(
                card: card,
                onTap: () => _onCardTap(card),
                onMarkAsReturned: card.status != BorrowStatus.returned && !isUpdating
                    ? () => _onMarkAsReturned(card)
                    : null,
                isUpdating: isUpdating,
              );
            },
          ),
        ),

        // Pagination
        if (state.paginationInfo.totalPages > 1)
          PaginationWidget(
            paginationInfo: state.paginationInfo,
            currentItemCount: state.borrowCards.length,
            onPrevious: state.paginationInfo.hasPreviousPage
                ? () => context.read<BorrowStatusBloc>().add(const LoadPreviousPageEvent())
                : null,
            onNext: state.paginationInfo.hasNextPage
                ? () => context.read<BorrowStatusBloc>().add(const LoadNextPageEvent())
                : null,
            onPageSelected: (page) => context.read<BorrowStatusBloc>().add(GoToPageEvent(page)),
          ),
      ],
    );
  }
}