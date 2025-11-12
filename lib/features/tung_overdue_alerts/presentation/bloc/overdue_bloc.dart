import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../data/repositories/overdue_repository.dart';
import 'overdue_event.dart';
import 'overdue_state.dart';

class OverdueBloc extends Bloc<OverdueEvent, OverdueState> {
  final OverdueRepository repository;

  OverdueBloc({required this.repository}) : super(const OverdueInitial()) {
    on<LoadOverdueCardsEvent>(_onLoadOverdueCards);
    on<LoadOverdueStatisticsEvent>(_onLoadStatistics);
    on<RefreshOverdueEvent>(_onRefresh);
    on<CheckOverdueAutomaticallyEvent>(_onCheckAutomatically);
  }

  Future<void> _onLoadOverdueCards(
    LoadOverdueCardsEvent event,
    Emitter<OverdueState> emit,
  ) async {
    emit(const OverdueLoading());

    final result = await repository.getOverdueCards();

    result.fold(
      (failure) => emit(OverdueError(message: _mapFailureToMessage(failure))),
      (cards) {
        if (cards.isEmpty) {
          emit(const OverdueEmpty());
        } else {
          emit(OverdueCardsLoaded(
            overdueCards: cards,
            totalCount: cards.length,
          ));
        }
      },
    );
  }

  Future<void> _onLoadStatistics(
    LoadOverdueStatisticsEvent event,
    Emitter<OverdueState> emit,
  ) async {
    emit(const OverdueLoading());

    final result = await repository.getStatistics();

    result.fold(
      (failure) {
        print('❌ Overdue Error: ${failure.message}');
        emit(OverdueError(message: _mapFailureToMessage(failure)));
      },
      (statistics) {
        print('📊 Overdue Statistics:');
        print('   Total: ${statistics.totalOverdue}');
        print('   Critical: ${statistics.criticalOverdue}');
        print('   Moderate: ${statistics.moderateOverdue}');
        print('   Recent: ${statistics.recentOverdue}');
        print('   Cards count: ${statistics.overdueCards.length}');
        
        if (statistics.totalOverdue == 0) {
          emit(const OverdueEmpty(message: 'Không có sách quá hạn'));
        } else {
          emit(OverdueStatisticsLoaded(statistics: statistics));
        }
      },
    );
  }

  Future<void> _onRefresh(
    RefreshOverdueEvent event,
    Emitter<OverdueState> emit,
  ) async {
    // Keep current state while refreshing
    if (state is OverdueStatisticsLoaded) {
      emit(OverdueRefreshing(
        currentCards: (state as OverdueStatisticsLoaded).statistics.overdueCards,
      ));
    } else if (state is OverdueCardsLoaded) {
      emit(OverdueRefreshing(
        currentCards: (state as OverdueCardsLoaded).overdueCards,
      ));
    }

    // Refresh statistics (same as LoadOverdueStatisticsEvent)
    final result = await repository.getStatistics();

    result.fold(
      (failure) {
        print('❌ Refresh Overdue Error: ${failure.message}');
        emit(OverdueError(message: _mapFailureToMessage(failure)));
      },
      (statistics) {
        print('🔄 Refreshed Overdue Statistics:');
        print('   Total: ${statistics.totalOverdue}');
        print('   Cards count: ${statistics.overdueCards.length}');
        
        if (statistics.totalOverdue == 0) {
          emit(const OverdueEmpty(message: 'Không có sách quá hạn'));
        } else {
          emit(OverdueStatisticsLoaded(statistics: statistics));
        }
      },
    );
  }

  Future<void> _onCheckAutomatically(
    CheckOverdueAutomaticallyEvent event,
    Emitter<OverdueState> emit,
  ) async {
    // Kiểm tra tự động mà không thay đổi UI state hiện tại
    final result = await repository.getOverdueCount();
    
    result.fold(
      (failure) {
        // Log error nhưng không emit error state
        print('Error checking overdue: ${failure.message}');
      },
      (count) {
        print('Auto check: Found $count overdue cards');
        // Có thể trigger notification ở đây
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case DatabaseFailure:
        return 'Lỗi cơ sở dữ liệu: ${failure.message}';
      case NetworkFailure:
        return 'Lỗi kết nối mạng: ${failure.message}';
      default:
        return 'Đã xảy ra lỗi: ${failure.message}';
    }
  }
}
