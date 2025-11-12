import 'package:equatable/equatable.dart';
import '../../../../shared/models/borrow_card.dart';
import '../../domain/entities/borrow_form_data.dart';

abstract class BorrowState extends Equatable {
  const BorrowState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class BorrowInitial extends BorrowState {
  const BorrowInitial();
}

/// Loading state
class BorrowLoading extends BorrowState {
  const BorrowLoading();
}

/// Success state for loading borrow cards
class BorrowsLoaded extends BorrowState {
  final List<BorrowCard> borrowCards;
  final int totalCount;
  final int currentPage;
  final bool hasReachedMax;

  const BorrowsLoaded({
    required this.borrowCards,
    this.totalCount = 0,
    this.currentPage = 1,
    this.hasReachedMax = false,
  });

  BorrowsLoaded copyWith({
    List<BorrowCard>? borrowCards,
    int? totalCount,
    int? currentPage,
    bool? hasReachedMax,
  }) {
    return BorrowsLoaded(
      borrowCards: borrowCards ?? this.borrowCards,
      totalCount: totalCount ?? this.totalCount,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [borrowCards, totalCount, currentPage, hasReachedMax];
}

/// Success state for single borrow card
class BorrowCardLoaded extends BorrowState {
  final BorrowCard borrowCard;

  const BorrowCardLoaded({required this.borrowCard});

  @override
  List<Object?> get props => [borrowCard];
}

/// Success state for borrow card creation
class BorrowCardCreated extends BorrowState {
  final BorrowCard borrowCard;

  const BorrowCardCreated({required this.borrowCard});

  @override
  List<Object?> get props => [borrowCard];
}

/// Success state for borrow card update
class BorrowCardUpdated extends BorrowState {
  final BorrowCard borrowCard;

  const BorrowCardUpdated({required this.borrowCard});

  @override
  List<Object?> get props => [borrowCard];
}

/// Success state for borrow card deletion
class BorrowCardDeleted extends BorrowState {
  final int deletedId;

  const BorrowCardDeleted({required this.deletedId});

  @override
  List<Object?> get props => [deletedId];
}

/// Success state for search results
class BorrowSearchResults extends BorrowState {
  final List<BorrowCard> searchResults;
  final String query;
  final int totalCount;
  final int currentPage;
  final bool hasReachedMax;

  const BorrowSearchResults({
    required this.searchResults,
    required this.query,
    this.totalCount = 0,
    this.currentPage = 1,
    this.hasReachedMax = false,
  });

  BorrowSearchResults copyWith({
    List<BorrowCard>? searchResults,
    String? query,
    int? totalCount,
    int? currentPage,
    bool? hasReachedMax,
  }) {
    return BorrowSearchResults(
      searchResults: searchResults ?? this.searchResults,
      query: query ?? this.query,
      totalCount: totalCount ?? this.totalCount,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [searchResults, query, totalCount, currentPage, hasReachedMax];
}

/// Success state for statistics
class BorrowStatisticsLoaded extends BorrowState {
  final Map<String, dynamic> statistics;
  final DateTime startDate;
  final DateTime endDate;

  const BorrowStatisticsLoaded({
    required this.statistics,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [statistics, startDate, endDate];
}

/// Success state for borrowing history
class BorrowingHistoryLoaded extends BorrowState {
  final List<BorrowCard> history;
  final String borrowerName;

  const BorrowingHistoryLoaded({
    required this.history,
    required this.borrowerName,
  });

  @override
  List<Object?> get props => [history, borrowerName];
}

/// State for form validation
class BorrowFormValidated extends BorrowState {
  final BorrowFormData formData;
  final Map<String, String> validationErrors;
  final bool isValid;

  const BorrowFormValidated({
    required this.formData,
    required this.validationErrors,
    required this.isValid,
  });

  @override
  List<Object?> get props => [formData, validationErrors, isValid];
}

/// State for form data loaded for editing
class BorrowFormDataLoaded extends BorrowState {
  final BorrowFormData formData;
  final bool isEditing;

  const BorrowFormDataLoaded({
    required this.formData,
    this.isEditing = false,
  });

  @override
  List<Object?> get props => [formData, isEditing];
}

/// State for scanner input processed
class ScannerInputProcessed extends BorrowState {
  final String scannedData;
  final Map<String, String> extractedData;
  final bool isValid;

  const ScannerInputProcessed({
    required this.scannedData,
    required this.extractedData,
    required this.isValid,
  });

  @override
  List<Object?> get props => [scannedData, extractedData, isValid];
}

/// Error state
class BorrowError extends BorrowState {
  final String message;
  final String? errorCode;

  const BorrowError({
    required this.message,
    this.errorCode,
  });

  @override
  List<Object?> get props => [message, errorCode];
}

/// Validation error state
class BorrowValidationError extends BorrowState {
  final Map<String, String> errors;

  const BorrowValidationError({required this.errors});

  @override
  List<Object?> get props => [errors];
}

/// Network error state
class BorrowNetworkError extends BorrowState {
  final String message;

  const BorrowNetworkError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Database error state
class BorrowDatabaseError extends BorrowState {
  final String message;

  const BorrowDatabaseError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Loading more data state (for pagination)
class BorrowLoadingMore extends BorrowState {
  final List<BorrowCard> currentBorrowCards;

  const BorrowLoadingMore({required this.currentBorrowCards});

  @override
  List<Object?> get props => [currentBorrowCards];
}

/// Refreshing state
class BorrowRefreshing extends BorrowState {
  final List<BorrowCard> currentBorrowCards;

  const BorrowRefreshing({required this.currentBorrowCards});

  @override
  List<Object?> get props => [currentBorrowCards];
}

/// Operation success state (for actions like mark as returned)
class BorrowOperationSuccess extends BorrowState {
  final String message;
  final BorrowCard? updatedCard;

  const BorrowOperationSuccess({
    required this.message,
    this.updatedCard,
  });

  @override
  List<Object?> get props => [message, updatedCard];
}

/// Empty state (no data found)
class BorrowEmpty extends BorrowState {
  final String message;

  const BorrowEmpty({this.message = 'Không tìm thấy thẻ mượn nào'});

  @override
  List<Object?> get props => [message];
}