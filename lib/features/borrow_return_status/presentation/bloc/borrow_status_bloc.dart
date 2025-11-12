import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../shared/models/borrow_card.dart';
import '../../domain/entities/borrow_status_filter.dart';
import '../../domain/repositories/borrow_status_repository.dart';
import '../services/borrow_status_calculator.dart';
import 'borrow_status_event.dart';
import 'borrow_status_state.dart';

class BorrowStatusBloc extends Bloc<BorrowStatusEvent, BorrowStatusState> {
  final BorrowStatusRepository _repository;
  BorrowStatusFilter _currentFilter = const BorrowStatusFilter(tab: BorrowStatusTab.active);

  BorrowStatusBloc({
    required BorrowStatusRepository repository,
  })  : _repository = repository,
        super(const BorrowStatusInitial()) {
    
    on<LoadBorrowStatusEvent>(_onLoadBorrowStatus);
    on<SwitchTabEvent>(_onSwitchTab);
    on<SearchBorrowsEvent>(_onSearchBorrows);
    on<LoadNextPageEvent>(_onLoadNextPage);
    on<LoadPreviousPageEvent>(_onLoadPreviousPage);
    on<GoToPageEvent>(_onGoToPage);
    on<MarkAsReturnedEvent>(_onMarkAsReturned);
    on<RefreshDataEvent>(_onRefreshData);
    on<LoadStatusCountsEvent>(_onLoadStatusCounts);
  }

  Future<void> _onLoadBorrowStatus(
    LoadBorrowStatusEvent event,
    Emitter<BorrowStatusState> emit,
  ) async {
    emit(const BorrowStatusLoading());
    _currentFilter = event.filter;

    try {
      // Load status counts first
      final countsResult = await _repository.getStatusCounts();
      final statusCounts = countsResult.fold(
        (failure) => <BorrowStatus, int>{
          BorrowStatus.borrowed: 0,
          BorrowStatus.returned: 0,
          BorrowStatus.overdue: 0,
        },
        (counts) => counts,
      );

      // Load borrow cards based on tab
      final result = await _getBorrowCardsForTab(event.filter);

      result.fold(
        (failure) => emit(BorrowStatusError(
          message: failure.message,
          currentFilter: event.filter,
        )),
        (borrowCards) {
          if (borrowCards.isEmpty) {
            emit(BorrowStatusEmpty(
              currentFilter: event.filter,
              statusCounts: statusCounts,
            ));
          } else {
            final paginationInfo = BorrowStatusCalculator.calculatePagination(
              totalItems: _getTotalItemsForTab(event.filter.tab, statusCounts),
              currentPage: event.filter.page,
              itemsPerPage: event.filter.limit,
            );

            emit(BorrowStatusLoaded(
              borrowCards: borrowCards,
              currentFilter: event.filter,
              paginationInfo: paginationInfo,
              statusCounts: statusCounts,
            ));
          }
        },
      );
    } catch (e) {
      emit(BorrowStatusError(
        message: 'Unexpected error: $e',
        currentFilter: event.filter,
      ));
    }
  }

  Future<void> _onSwitchTab(
    SwitchTabEvent event,
    Emitter<BorrowStatusState> emit,
  ) async {
    final newFilter = _currentFilter.copyWith(
      tab: event.tab,
      page: 1, // Reset to first page when switching tabs
      searchQuery: null, // Clear search when switching tabs
    );

    add(LoadBorrowStatusEvent(newFilter));
  }

  Future<void> _onSearchBorrows(
    SearchBorrowsEvent event,
    Emitter<BorrowStatusState> emit,
  ) async {
    final newFilter = _currentFilter.copyWith(
      searchQuery: event.query.isEmpty ? null : event.query,
      page: 1, // Reset to first page when searching
    );

    add(LoadBorrowStatusEvent(newFilter));
  }

  Future<void> _onLoadNextPage(
    LoadNextPageEvent event,
    Emitter<BorrowStatusState> emit,
  ) async {
    if (state is BorrowStatusLoaded) {
      final currentState = state as BorrowStatusLoaded;
      if (currentState.paginationInfo.hasNextPage) {
        final newFilter = _currentFilter.copyWith(
          page: _currentFilter.page + 1,
        );
        add(LoadBorrowStatusEvent(newFilter));
      }
    }
  }

  Future<void> _onLoadPreviousPage(
    LoadPreviousPageEvent event,
    Emitter<BorrowStatusState> emit,
  ) async {
    if (state is BorrowStatusLoaded) {
      final currentState = state as BorrowStatusLoaded;
      if (currentState.paginationInfo.hasPreviousPage) {
        final newFilter = _currentFilter.copyWith(
          page: _currentFilter.page - 1,
        );
        add(LoadBorrowStatusEvent(newFilter));
      }
    }
  }

  Future<void> _onGoToPage(
    GoToPageEvent event,
    Emitter<BorrowStatusState> emit,
  ) async {
    if (event.page != _currentFilter.page) {
      final newFilter = _currentFilter.copyWith(page: event.page);
      add(LoadBorrowStatusEvent(newFilter));
    }
  }

  Future<void> _onMarkAsReturned(
    MarkAsReturnedEvent event,
    Emitter<BorrowStatusState> emit,
  ) async {
    if (state is BorrowStatusLoaded) {
      final currentState = state as BorrowStatusLoaded;
      
      emit(BorrowStatusUpdating(
        borrowCards: currentState.borrowCards,
        currentFilter: currentState.currentFilter,
        paginationInfo: currentState.paginationInfo,
        statusCounts: currentState.statusCounts,
        updatingCardId: event.borrowCardId,
      ));

      final result = await _repository.markAsReturned(
        event.borrowCardId,
        event.returnDate,
      );

      result.fold(
        (failure) => emit(BorrowStatusError(
          message: 'Failed to mark as returned: ${failure.message}',
          currentFilter: currentState.currentFilter,
        )),
        (updatedCard) {
          // Reload current data to reflect changes
          add(LoadBorrowStatusEvent(currentState.currentFilter));
        },
      );
    }
  }

  Future<void> _onRefreshData(
    RefreshDataEvent event,
    Emitter<BorrowStatusState> emit,
  ) async {
    if (state is BorrowStatusLoaded) {
      final currentState = state as BorrowStatusLoaded;
      
      emit(currentState.copyWith(isRefreshing: true));

      await _repository.refreshData();
      
      // Reload current data
      add(LoadBorrowStatusEvent(currentState.currentFilter));
    } else {
      // If not loaded yet, just load with current filter
      add(LoadBorrowStatusEvent(_currentFilter));
    }
  }

  Future<void> _onLoadStatusCounts(
    LoadStatusCountsEvent event,
    Emitter<BorrowStatusState> emit,
  ) async {
    if (state is BorrowStatusLoaded) {
      final currentState = state as BorrowStatusLoaded;
      
      final countsResult = await _repository.getStatusCounts();
      
      countsResult.fold(
        (failure) {
          // Keep current state if counts loading fails
        },
        (statusCounts) {
          emit(currentState.copyWith(statusCounts: statusCounts));
        },
      );
    }
  }

  Future<Either<Failure, List<BorrowCard>>> _getBorrowCardsForTab(
    BorrowStatusFilter filter,
  ) async {
    switch (filter.tab) {
      case BorrowStatusTab.active:
        return await _repository.getActiveBorrows(
          page: filter.page,
          limit: filter.limit,
          searchQuery: filter.searchQuery,
        );
      case BorrowStatusTab.returned:
        return await _repository.getReturnedBorrows(
          page: filter.page,
          limit: filter.limit,
          searchQuery: filter.searchQuery,
        );
    }
  }

  int _getTotalItemsForTab(BorrowStatusTab tab, Map<BorrowStatus, int> counts) {
    switch (tab) {
      case BorrowStatusTab.active:
        return (counts[BorrowStatus.borrowed] ?? 0) + 
               (counts[BorrowStatus.overdue] ?? 0);
      case BorrowStatusTab.returned:
        return counts[BorrowStatus.returned] ?? 0;
    }
  }
}