import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../data/services/dashboard_service.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

@injectable
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardService _dashboardService;

  DashboardBloc(this._dashboardService) : super(const DashboardInitial()) {
    on<LoadDashboardDataEvent>(_onLoadDashboardData);
    on<RefreshDashboardDataEvent>(_onRefreshDashboardData);
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardDataEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());
    try {
      final stats = await _dashboardService.getDashboardStats(user: event.user);
      final activities = await _dashboardService.getRecentActivities(user: event.user);

      emit(DashboardLoaded(
        stats: stats,
        recentActivities: activities,
      ));
    } catch (e) {
      emit(DashboardError('Không thể tải dữ liệu: $e'));
    }
  }

  Future<void> _onRefreshDashboardData(
    RefreshDashboardDataEvent event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      final stats = await _dashboardService.getDashboardStats(user: event.user);
      final activities = await _dashboardService.getRecentActivities(user: event.user);

      emit(DashboardLoaded(
        stats: stats,
        recentActivities: activities,
      ));
    } catch (e) {
      emit(DashboardError('Không thể làm mới dữ liệu: $e'));
    }
  }
}
