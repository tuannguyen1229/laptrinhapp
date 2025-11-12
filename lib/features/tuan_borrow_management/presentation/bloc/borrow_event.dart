import 'package:equatable/equatable.dart';
import '../../../../shared/models/borrow_card.dart';
import '../../../../shared/repositories/borrow_card_repository.dart';
import '../../domain/entities/borrow_form_data.dart';

abstract class BorrowEvent extends Equatable {
  const BorrowEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all borrow cards
class LoadBorrowsEvent extends BorrowEvent {
  const LoadBorrowsEvent();
}

/// Event to load borrow cards with pagination
class LoadBorrowsWithPaginationEvent extends BorrowEvent {
  final int page;
  final int limit;

  const LoadBorrowsWithPaginationEvent({
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [page, limit];
}

/// Event to load borrow cards with filters
class LoadBorrowsWithFiltersEvent extends BorrowEvent {
  final BorrowCardFilters filters;
  final int page;
  final int limit;

  const LoadBorrowsWithFiltersEvent({
    required this.filters,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [filters, page, limit];
}

/// Event to create a new borrow card
class CreateBorrowEvent extends BorrowEvent {
  final BorrowFormData formData;

  const CreateBorrowEvent({required this.formData});

  @override
  List<Object?> get props => [formData];
}

/// Event to update an existing borrow card
class UpdateBorrowEvent extends BorrowEvent {
  final int borrowId;
  final BorrowFormData formData;

  const UpdateBorrowEvent({
    required this.borrowId,
    required this.formData,
  });

  @override
  List<Object?> get props => [borrowId, formData];
}

/// Event to delete a borrow card
class DeleteBorrowEvent extends BorrowEvent {
  final int borrowId;

  const DeleteBorrowEvent({required this.borrowId});

  @override
  List<Object?> get props => [borrowId];
}

/// Event to get a specific borrow card by ID
class GetBorrowByIdEvent extends BorrowEvent {
  final int borrowId;

  const GetBorrowByIdEvent({required this.borrowId});

  @override
  List<Object?> get props => [borrowId];
}

/// Event to search borrow cards
class SearchBorrowsEvent extends BorrowEvent {
  final String query;
  final int page;
  final int limit;

  const SearchBorrowsEvent({
    required this.query,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [query, page, limit];
}

/// Event to mark a borrow card as returned
class MarkAsReturnedEvent extends BorrowEvent {
  final int borrowId;

  const MarkAsReturnedEvent({required this.borrowId});

  @override
  List<Object?> get props => [borrowId];
}

/// Event to update borrow card status
class UpdateBorrowStatusEvent extends BorrowEvent {
  final int borrowId;
  final BorrowStatus status;

  const UpdateBorrowStatusEvent({
    required this.borrowId,
    required this.status,
  });

  @override
  List<Object?> get props => [borrowId, status];
}

/// Event to load borrow cards by status
class LoadBorrowsByStatusEvent extends BorrowEvent {
  final BorrowStatus status;

  const LoadBorrowsByStatusEvent({required this.status});

  @override
  List<Object?> get props => [status];
}

/// Event to load overdue borrow cards
class LoadOverdueBorrowsEvent extends BorrowEvent {
  const LoadOverdueBorrowsEvent();
}

/// Event to get borrowing statistics
class GetBorrowStatisticsEvent extends BorrowEvent {
  final DateTime startDate;
  final DateTime endDate;

  const GetBorrowStatisticsEvent({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

/// Event to get borrowing history for a specific borrower
class GetBorrowingHistoryEvent extends BorrowEvent {
  final String borrowerName;

  const GetBorrowingHistoryEvent({required this.borrowerName});

  @override
  List<Object?> get props => [borrowerName];
}

/// Event to refresh/reload current data
class RefreshBorrowsEvent extends BorrowEvent {
  const RefreshBorrowsEvent();
}

/// Event to clear current state
class ClearBorrowStateEvent extends BorrowEvent {
  const ClearBorrowStateEvent();
}

/// Event to handle scanner input (from QR/Barcode scanner)
class HandleScannerInputEvent extends BorrowEvent {
  final String scannedData;
  final ScannerInputType inputType;

  const HandleScannerInputEvent({
    required this.scannedData,
    required this.inputType,
  });

  @override
  List<Object?> get props => [scannedData, inputType];
}

enum ScannerInputType {
  bookCode,
  studentId,
  readerCard,
}

/// Event to validate form data
class ValidateFormDataEvent extends BorrowEvent {
  final BorrowFormData formData;

  const ValidateFormDataEvent({required this.formData});

  @override
  List<Object?> get props => [formData];
}

/// Event to reset form
class ResetFormEvent extends BorrowEvent {
  const ResetFormEvent();
}

/// Event to load form data for editing
class LoadFormDataEvent extends BorrowEvent {
  final int? borrowId;

  const LoadFormDataEvent({this.borrowId});

  @override
  List<Object?> get props => [borrowId];
}