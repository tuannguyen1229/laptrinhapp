import 'package:equatable/equatable.dart';
import '../../domain/entities/borrow_status_filter.dart';

abstract class BorrowStatusEvent extends Equatable {
  const BorrowStatusEvent();

  @override
  List<Object?> get props => [];
}

class LoadBorrowStatusEvent extends BorrowStatusEvent {
  final BorrowStatusFilter filter;

  const LoadBorrowStatusEvent(this.filter);

  @override
  List<Object?> get props => [filter];
}

class SwitchTabEvent extends BorrowStatusEvent {
  final BorrowStatusTab tab;

  const SwitchTabEvent(this.tab);

  @override
  List<Object?> get props => [tab];
}

class SearchBorrowsEvent extends BorrowStatusEvent {
  final String query;

  const SearchBorrowsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class LoadNextPageEvent extends BorrowStatusEvent {
  const LoadNextPageEvent();
}

class LoadPreviousPageEvent extends BorrowStatusEvent {
  const LoadPreviousPageEvent();
}

class GoToPageEvent extends BorrowStatusEvent {
  final int page;

  const GoToPageEvent(this.page);

  @override
  List<Object?> get props => [page];
}

class MarkAsReturnedEvent extends BorrowStatusEvent {
  final int borrowCardId;
  final DateTime returnDate;

  const MarkAsReturnedEvent({
    required this.borrowCardId,
    required this.returnDate,
  });

  @override
  List<Object?> get props => [borrowCardId, returnDate];
}

class RefreshDataEvent extends BorrowStatusEvent {
  const RefreshDataEvent();
}

class LoadStatusCountsEvent extends BorrowStatusEvent {
  const LoadStatusCountsEvent();
}