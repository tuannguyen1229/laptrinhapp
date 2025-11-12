import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/statistics_data.dart';
import '../../data/services/report_generator_service.dart';
import '../../domain/repositories/statistics_repository.dart';
import '../../../../shared/models/borrow_card.dart';

// Events
abstract class StatisticsEvent extends Equatable {
  const StatisticsEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserStatisticsEvent extends StatisticsEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadUserStatisticsEvent({this.startDate, this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

class LoadMonthlyStatisticsEvent extends StatisticsEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadMonthlyStatisticsEvent({this.startDate, this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

class LoadStatisticsSummaryEvent extends StatisticsEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadStatisticsSummaryEvent({this.startDate, this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

class LoadAllStatisticsEvent extends StatisticsEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadAllStatisticsEvent({this.startDate, this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

class ApplyDateFilterEvent extends StatisticsEvent {
  final DateTime startDate;
  final DateTime endDate;

  const ApplyDateFilterEvent({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

class ClearDateFilterEvent extends StatisticsEvent {
  const ClearDateFilterEvent();
}

class GenerateReportEvent extends StatisticsEvent {
  final ReportFormat format;
  final String fileName;

  const GenerateReportEvent({
    required this.format,
    required this.fileName,
  });

  @override
  List<Object?> get props => [format, fileName];
}

class RefreshStatisticsEvent extends StatisticsEvent {
  const RefreshStatisticsEvent();
}

// States
abstract class StatisticsState extends Equatable {
  const StatisticsState();

  @override
  List<Object?> get props => [];
}

class StatisticsInitial extends StatisticsState {
  const StatisticsInitial();
}

class StatisticsLoading extends StatisticsState {
  const StatisticsLoading();
}

class StatisticsLoaded extends StatisticsState {
  final List<UserStatistics> userStatistics;
  final List<MonthlyStatistics> monthlyStatistics;
  final StatisticsSummary summary;
  final DateTime? startDate;
  final DateTime? endDate;

  const StatisticsLoaded({
    required this.userStatistics,
    required this.monthlyStatistics,
    required this.summary,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [
        userStatistics,
        monthlyStatistics,
        summary,
        startDate,
        endDate,
      ];

  StatisticsLoaded copyWith({
    List<UserStatistics>? userStatistics,
    List<MonthlyStatistics>? monthlyStatistics,
    StatisticsSummary? summary,
    DateTime? startDate,
    DateTime? endDate,
    bool clearDates = false,
  }) {
    return StatisticsLoaded(
      userStatistics: userStatistics ?? this.userStatistics,
      monthlyStatistics: monthlyStatistics ?? this.monthlyStatistics,
      summary: summary ?? this.summary,
      startDate: clearDates ? null : (startDate ?? this.startDate),
      endDate: clearDates ? null : (endDate ?? this.endDate),
    );
  }
}

class UserStatisticsLoaded extends StatisticsState {
  final List<UserStatistics> userStatistics;
  final DateTime? startDate;
  final DateTime? endDate;

  const UserStatisticsLoaded({
    required this.userStatistics,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [userStatistics, startDate, endDate];
}

class MonthlyStatisticsLoaded extends StatisticsState {
  final List<MonthlyStatistics> monthlyStatistics;
  final DateTime? startDate;
  final DateTime? endDate;

  const MonthlyStatisticsLoaded({
    required this.monthlyStatistics,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [monthlyStatistics, startDate, endDate];
}

class StatisticsSummaryLoaded extends StatisticsState {
  final StatisticsSummary summary;
  final DateTime? startDate;
  final DateTime? endDate;

  const StatisticsSummaryLoaded({
    required this.summary,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [summary, startDate, endDate];
}

class ReportGenerating extends StatisticsState {
  const ReportGenerating();
}

class ReportGenerated extends StatisticsState {
  final String filePath;
  final ReportFormat format;

  const ReportGenerated({
    required this.filePath,
    required this.format,
  });

  @override
  List<Object?> get props => [filePath, format];
}

class StatisticsError extends StatisticsState {
  final String message;

  const StatisticsError({required this.message});

  @override
  List<Object?> get props => [message];
}

// BLoC
class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  final StatisticsRepository statisticsRepository;
  final ReportGeneratorService reportGeneratorService;

  StatisticsBloc({
    required this.statisticsRepository,
    required this.reportGeneratorService,
  }) : super(const StatisticsInitial()) {
    on<LoadUserStatisticsEvent>(_onLoadUserStatistics);
    on<LoadMonthlyStatisticsEvent>(_onLoadMonthlyStatistics);
    on<LoadStatisticsSummaryEvent>(_onLoadStatisticsSummary);
    on<LoadAllStatisticsEvent>(_onLoadAllStatistics);
    on<ApplyDateFilterEvent>(_onApplyDateFilter);
    on<ClearDateFilterEvent>(_onClearDateFilter);
    on<GenerateReportEvent>(_onGenerateReport);
    on<RefreshStatisticsEvent>(_onRefreshStatistics);
  }

  Future<void> _onLoadUserStatistics(
    LoadUserStatisticsEvent event,
    Emitter<StatisticsState> emit,
  ) async {
    emit(const StatisticsLoading());

    final result = await statisticsRepository.getUserStatistics(
      startDate: event.startDate,
      endDate: event.endDate,
    );

    result.fold(
      (failure) => emit(StatisticsError(message: _mapFailureToMessage(failure))),
      (userStats) => emit(UserStatisticsLoaded(
        userStatistics: userStats,
        startDate: event.startDate,
        endDate: event.endDate,
      )),
    );
  }

  Future<void> _onLoadMonthlyStatistics(
    LoadMonthlyStatisticsEvent event,
    Emitter<StatisticsState> emit,
  ) async {
    emit(const StatisticsLoading());

    final result = await statisticsRepository.getMonthlyStatistics(
      startDate: event.startDate,
      endDate: event.endDate,
    );

    result.fold(
      (failure) => emit(StatisticsError(message: _mapFailureToMessage(failure))),
      (monthlyStats) => emit(MonthlyStatisticsLoaded(
        monthlyStatistics: monthlyStats,
        startDate: event.startDate,
        endDate: event.endDate,
      )),
    );
  }

  Future<void> _onLoadStatisticsSummary(
    LoadStatisticsSummaryEvent event,
    Emitter<StatisticsState> emit,
  ) async {
    emit(const StatisticsLoading());

    final result = await statisticsRepository.getStatisticsSummary(
      startDate: event.startDate,
      endDate: event.endDate,
    );

    result.fold(
      (failure) => emit(StatisticsError(message: _mapFailureToMessage(failure))),
      (summary) => emit(StatisticsSummaryLoaded(
        summary: summary,
        startDate: event.startDate,
        endDate: event.endDate,
      )),
    );
  }

  Future<void> _onLoadAllStatistics(
    LoadAllStatisticsEvent event,
    Emitter<StatisticsState> emit,
  ) async {
    emit(const StatisticsLoading());

    try {
      // Load all statistics concurrently
      final results = await Future.wait([
        statisticsRepository.getUserStatistics(
          startDate: event.startDate,
          endDate: event.endDate,
        ),
        statisticsRepository.getMonthlyStatistics(
          startDate: event.startDate,
          endDate: event.endDate,
        ),
        statisticsRepository.getStatisticsSummary(
          startDate: event.startDate,
          endDate: event.endDate,
        ),
      ]);

      final userStatsResult = results[0] as Either<Failure, List<UserStatistics>>;
      final monthlyStatsResult = results[1] as Either<Failure, List<MonthlyStatistics>>;
      final summaryResult = results[2] as Either<Failure, StatisticsSummary>;

      // Check if any failed
      final failures = <Failure>[];
      
      List<UserStatistics> userStats = [];
      List<MonthlyStatistics> monthlyStats = [];
      StatisticsSummary? summary;

      userStatsResult.fold(
        (failure) => failures.add(failure),
        (stats) => userStats = stats,
      );

      monthlyStatsResult.fold(
        (failure) => failures.add(failure),
        (stats) => monthlyStats = stats,
      );

      summaryResult.fold(
        (failure) => failures.add(failure),
        (s) => summary = s,
      );

      if (failures.isNotEmpty) {
        emit(StatisticsError(message: _mapFailureToMessage(failures.first)));
        return;
      }

      emit(StatisticsLoaded(
        userStatistics: userStats,
        monthlyStatistics: monthlyStats,
        summary: summary!,
        startDate: event.startDate,
        endDate: event.endDate,
      ));
    } catch (e) {
      emit(StatisticsError(message: 'Lỗi không xác định: $e'));
    }
  }

  Future<void> _onApplyDateFilter(
    ApplyDateFilterEvent event,
    Emitter<StatisticsState> emit,
  ) async {
    // Reload statistics with new date range
    add(LoadAllStatisticsEvent(
      startDate: event.startDate,
      endDate: event.endDate,
    ));
  }

  Future<void> _onClearDateFilter(
    ClearDateFilterEvent event,
    Emitter<StatisticsState> emit,
  ) async {
    // Reload statistics without date filter
    add(const LoadAllStatisticsEvent());
  }

  Future<void> _onGenerateReport(
    GenerateReportEvent event,
    Emitter<StatisticsState> emit,
  ) async {
    if (state is! StatisticsLoaded) {
      emit(const StatisticsError(message: 'Không có dữ liệu để tạo báo cáo'));
      return;
    }

    final currentState = state as StatisticsLoaded;
    emit(const ReportGenerating());

    try {
      // Get raw borrow cards data for detailed report
      final borrowCardsResult = currentState.startDate != null && currentState.endDate != null
          ? await statisticsRepository.getBorrowCardsInDateRange(
              currentState.startDate!,
              currentState.endDate!,
            )
          : await statisticsRepository.getBorrowCardsInDateRange(
              DateTime(2020), // Default start date
              DateTime.now(),
            );

      await borrowCardsResult.fold(
        (failure) async {
          emit(StatisticsError(message: _mapFailureToMessage(failure)));
        },
        (borrowCards) async {
          try {
            late final reportData;
            
            if (event.format == ReportFormat.pdf) {
              reportData = await reportGeneratorService.generatePdfReport(
                summary: currentState.summary,
                userStats: currentState.userStatistics,
                monthlyStats: currentState.monthlyStatistics,
                startDate: currentState.startDate,
                endDate: currentState.endDate,
              );
            } else {
              reportData = await reportGeneratorService.generateExcelReport(
                summary: currentState.summary,
                userStats: currentState.userStatistics,
                monthlyStats: currentState.monthlyStatistics,
                borrowCards: borrowCards,
                startDate: currentState.startDate,
                endDate: currentState.endDate,
              );
            }

            final filePath = await reportGeneratorService.saveReportToFile(
              reportData,
              event.fileName,
              event.format,
            );

            emit(ReportGenerated(
              filePath: filePath,
              format: event.format,
            ));
          } catch (e) {
            emit(StatisticsError(message: 'Lỗi tạo báo cáo: $e'));
          }
        },
      );
    } catch (e) {
      emit(StatisticsError(message: 'Lỗi không xác định khi tạo báo cáo: $e'));
    }
  }

  Future<void> _onRefreshStatistics(
    RefreshStatisticsEvent event,
    Emitter<StatisticsState> emit,
  ) async {
    if (state is StatisticsLoaded) {
      final currentState = state as StatisticsLoaded;
      add(LoadAllStatisticsEvent(
        startDate: currentState.startDate,
        endDate: currentState.endDate,
      ));
    } else {
      add(const LoadAllStatisticsEvent());
    }
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case DatabaseFailure:
        return 'Lỗi cơ sở dữ liệu: ${failure.message}';
      case NetworkFailure:
        return 'Lỗi kết nối: ${failure.message}';
      default:
        return 'Lỗi không xác định: ${failure.message}';
    }
  }
}