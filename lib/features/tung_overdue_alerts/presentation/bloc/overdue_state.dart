import 'package:equatable/equatable.dart';
import '../../../../shared/models/borrow_card.dart';
import '../../data/services/overdue_service.dart';

abstract class OverdueState extends Equatable {
  const OverdueState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class OverdueInitial extends OverdueState {
  const OverdueInitial();
}

/// Loading state
class OverdueLoading extends OverdueState {
  const OverdueLoading();
}

/// Loaded overdue cards
class OverdueCardsLoaded extends OverdueState {
  final List<BorrowCard> overdueCards;
  final int totalCount;

  const OverdueCardsLoaded({
    required this.overdueCards,
    required this.totalCount,
  });

  @override
  List<Object?> get props => [overdueCards, totalCount];
}

/// Loaded statistics
class OverdueStatisticsLoaded extends OverdueState {
  final OverdueStatistics statistics;

  const OverdueStatisticsLoaded({required this.statistics});

  @override
  List<Object?> get props => [statistics];
}

/// Empty state
class OverdueEmpty extends OverdueState {
  final String message;

  const OverdueEmpty({this.message = 'Không có sách quá hạn'});

  @override
  List<Object?> get props => [message];
}

/// Error state
class OverdueError extends OverdueState {
  final String message;

  const OverdueError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Refreshing state
class OverdueRefreshing extends OverdueState {
  final List<BorrowCard> currentCards;

  const OverdueRefreshing({required this.currentCards});

  @override
  List<Object?> get props => [currentCards];
}
