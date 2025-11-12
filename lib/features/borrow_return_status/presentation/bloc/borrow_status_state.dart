import 'package:equatable/equatable.dart';
import '../../../../shared/models/borrow_card.dart';
import '../../domain/entities/borrow_status_filter.dart';

abstract class BorrowStatusState extends Equatable {
  const BorrowStatusState();

  @override
  List<Object?> get props => [];
}

class BorrowStatusInitial extends BorrowStatusState {
  const BorrowStatusInitial();
}

class BorrowStatusLoading extends BorrowStatusState {
  const BorrowStatusLoading();
}

class BorrowStatusLoaded extends BorrowStatusState {
  final List<BorrowCard> borrowCards;
  final BorrowStatusFilter currentFilter;
  final PaginationInfo paginationInfo;
  final Map<BorrowStatus, int> statusCounts;
  final bool isRefreshing;

  const BorrowStatusLoaded({
    required this.borrowCards,
    required this.currentFilter,
    required this.paginationInfo,
    required this.statusCounts,
    this.isRefreshing = false,
  });

  BorrowStatusLoaded copyWith({
    List<BorrowCard>? borrowCards,
    BorrowStatusFilter? currentFilter,
    PaginationInfo? paginationInfo,
    Map<BorrowStatus, int>? statusCounts,
    bool? isRefreshing,
  }) {
    return BorrowStatusLoaded(
      borrowCards: borrowCards ?? this.borrowCards,
      currentFilter: currentFilter ?? this.currentFilter,
      paginationInfo: paginationInfo ?? this.paginationInfo,
      statusCounts: statusCounts ?? this.statusCounts,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [
        borrowCards,
        currentFilter,
        paginationInfo,
        statusCounts,
        isRefreshing,
      ];
}

class BorrowStatusEmpty extends BorrowStatusState {
  final BorrowStatusFilter currentFilter;
  final Map<BorrowStatus, int> statusCounts;

  const BorrowStatusEmpty({
    required this.currentFilter,
    required this.statusCounts,
  });

  @override
  List<Object?> get props => [currentFilter, statusCounts];
}

class BorrowStatusError extends BorrowStatusState {
  final String message;
  final BorrowStatusFilter? currentFilter;

  const BorrowStatusError({
    required this.message,
    this.currentFilter,
  });

  @override
  List<Object?> get props => [message, currentFilter];
}

class BorrowStatusUpdating extends BorrowStatusState {
  final List<BorrowCard> borrowCards;
  final BorrowStatusFilter currentFilter;
  final PaginationInfo paginationInfo;
  final Map<BorrowStatus, int> statusCounts;
  final int updatingCardId;

  const BorrowStatusUpdating({
    required this.borrowCards,
    required this.currentFilter,
    required this.paginationInfo,
    required this.statusCounts,
    required this.updatingCardId,
  });

  @override
  List<Object?> get props => [
        borrowCards,
        currentFilter,
        paginationInfo,
        statusCounts,
        updatingCardId,
      ];
}