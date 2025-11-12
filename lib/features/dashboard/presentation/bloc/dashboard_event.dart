import 'package:equatable/equatable.dart';
import '../../../auth/domain/entities/user.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboardDataEvent extends DashboardEvent {
  final User? user;
  
  const LoadDashboardDataEvent({this.user});
  
  @override
  List<Object?> get props => [user];
}

class RefreshDashboardDataEvent extends DashboardEvent {
  final User? user;
  
  const RefreshDashboardDataEvent({this.user});
  
  @override
  List<Object?> get props => [user];
}
