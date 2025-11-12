import 'package:equatable/equatable.dart';

abstract class OverdueEvent extends Equatable {
  const OverdueEvent();

  @override
  List<Object?> get props => [];
}

/// Event để load danh sách sách quá hạn
class LoadOverdueCardsEvent extends OverdueEvent {
  const LoadOverdueCardsEvent();
}

/// Event để load thống kê quá hạn
class LoadOverdueStatisticsEvent extends OverdueEvent {
  const LoadOverdueStatisticsEvent();
}

/// Event để refresh danh sách
class RefreshOverdueEvent extends OverdueEvent {
  const RefreshOverdueEvent();
}

/// Event để kiểm tra quá hạn tự động
class CheckOverdueAutomaticallyEvent extends OverdueEvent {
  const CheckOverdueAutomaticallyEvent();
}
