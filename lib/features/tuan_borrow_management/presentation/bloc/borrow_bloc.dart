import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../../../shared/models/borrow_card.dart';
import '../../../../shared/repositories/borrow_card_repository.dart';
import '../../data/validators/borrow_card_validator.dart';
import '../../domain/entities/borrow_form_data.dart';
import 'borrow_event.dart';
import 'borrow_state.dart';

class BorrowBloc extends Bloc<BorrowEvent, BorrowState> {
  final BorrowCardRepository repository;

  BorrowBloc({required this.repository}) : super(const BorrowInitial()) {
    on<LoadBorrowsEvent>(_onLoadBorrows);
    on<LoadBorrowsWithPaginationEvent>(_onLoadBorrowsWithPagination);
    on<LoadBorrowsWithFiltersEvent>(_onLoadBorrowsWithFilters);
    on<CreateBorrowEvent>(_onCreateBorrow);
    on<UpdateBorrowEvent>(_onUpdateBorrow);
    on<DeleteBorrowEvent>(_onDeleteBorrow);
    on<GetBorrowByIdEvent>(_onGetBorrowById);
    on<SearchBorrowsEvent>(_onSearchBorrows);
    on<MarkAsReturnedEvent>(_onMarkAsReturned);
    on<UpdateBorrowStatusEvent>(_onUpdateBorrowStatus);
    on<LoadBorrowsByStatusEvent>(_onLoadBorrowsByStatus);
    on<LoadOverdueBorrowsEvent>(_onLoadOverdueBorrows);
    on<GetBorrowStatisticsEvent>(_onGetBorrowStatistics);
    on<GetBorrowingHistoryEvent>(_onGetBorrowingHistory);
    on<RefreshBorrowsEvent>(_onRefreshBorrows);
    on<ClearBorrowStateEvent>(_onClearBorrowState);
    on<HandleScannerInputEvent>(_onHandleScannerInput);
    on<ValidateFormDataEvent>(_onValidateFormData);
    on<ResetFormEvent>(_onResetForm);
    on<LoadFormDataEvent>(_onLoadFormData);
  }

  Future<void> _onLoadBorrows(
    LoadBorrowsEvent event,
    Emitter<BorrowState> emit,
  ) async {
    emit(const BorrowLoading());

    final result = await repository.getAll();

    result.fold(
      (failure) => emit(BorrowError(message: _mapFailureToMessage(failure))),
      (borrowCards) {
        if (borrowCards.isEmpty) {
          emit(const BorrowEmpty());
        } else {
          emit(BorrowsLoaded(
            borrowCards: borrowCards,
            totalCount: borrowCards.length,
          ));
        }
      },
    );
  }

  Future<void> _onLoadBorrowsWithPagination(
    LoadBorrowsWithPaginationEvent event,
    Emitter<BorrowState> emit,
  ) async {
    print('🔄 BLoC: Loading borrows with pagination (page ${event.page})...');
    
    if (event.page == 1) {
      emit(const BorrowLoading());
    } else if (state is BorrowsLoaded) {
      emit(BorrowLoadingMore(
        currentBorrowCards: (state as BorrowsLoaded).borrowCards,
      ));
    }

    final result = await repository.getAllWithPagination(
      page: event.page,
      limit: event.limit,
    );

    final totalCountResult = await repository.getTotalCount();

    result.fold(
      (failure) => emit(BorrowError(message: _mapFailureToMessage(failure))),
      (borrowCards) {
        totalCountResult.fold(
          (failure) => emit(BorrowError(message: _mapFailureToMessage(failure))),
          (totalCount) {
            if (event.page == 1) {
              if (borrowCards.isEmpty) {
                emit(const BorrowEmpty());
              } else {
                emit(BorrowsLoaded(
                  borrowCards: borrowCards,
                  totalCount: totalCount,
                  currentPage: event.page,
                  hasReachedMax: borrowCards.length < event.limit,
                ));
              }
            } else {
              // Get current cards from either BorrowsLoaded or BorrowLoadingMore
              final List<BorrowCard> currentCards;
              if (state is BorrowsLoaded) {
                currentCards = (state as BorrowsLoaded).borrowCards;
              } else if (state is BorrowLoadingMore) {
                currentCards = (state as BorrowLoadingMore).currentBorrowCards;
              } else {
                currentCards = [];
              }
              
              final allBorrowCards = [...currentCards, ...borrowCards];
              
              emit(BorrowsLoaded(
                borrowCards: allBorrowCards,
                totalCount: totalCount,
                currentPage: event.page,
                hasReachedMax: borrowCards.length < event.limit,
              ));
            }
          },
        );
      },
    );
  }

  Future<void> _onLoadBorrowsWithFilters(
    LoadBorrowsWithFiltersEvent event,
    Emitter<BorrowState> emit,
  ) async {
    emit(const BorrowLoading());

    final result = await repository.getWithFiltersAndPagination(
      event.filters,
      page: event.page,
      limit: event.limit,
    );

    final countResult = await repository.getCountWithFilters(event.filters);

    result.fold(
      (failure) => emit(BorrowError(message: _mapFailureToMessage(failure))),
      (borrowCards) {
        countResult.fold(
          (failure) => emit(BorrowError(message: _mapFailureToMessage(failure))),
          (totalCount) {
            if (borrowCards.isEmpty) {
              emit(const BorrowEmpty(message: 'Không tìm thấy thẻ mượn nào phù hợp với bộ lọc'));
            } else {
              emit(BorrowsLoaded(
                borrowCards: borrowCards,
                totalCount: totalCount,
                currentPage: event.page,
                hasReachedMax: borrowCards.length < event.limit,
              ));
            }
          },
        );
      },
    );
  }

  Future<void> _onCreateBorrow(
    CreateBorrowEvent event,
    Emitter<BorrowState> emit,
  ) async {
    print('🔄 BLoC: Creating borrow card...');
    emit(const BorrowLoading());

    // Validate form data first
    final validation = BorrowCardValidator.validateFormData(
      borrowerName: event.formData.borrowerName,
      borrowerClass: event.formData.borrowerClass,
      borrowerStudentId: event.formData.borrowerStudentId,
      borrowerPhone: event.formData.borrowerPhone,
      bookName: event.formData.bookName,
      bookCode: event.formData.bookCode,
      borrowDate: event.formData.borrowDate,
      expectedReturnDate: event.formData.expectedReturnDate,
      actualReturnDate: event.formData.actualReturnDate,
    );

    await validation.fold(
      (failure) {
        print('❌ Validation failed: ${failure.message}');
        emit(BorrowError(message: failure.message));
      },
      (_) async {
        print('✅ Validation passed');
        final borrowCard = event.formData.toBorrowCard();
        final result = await repository.create(borrowCard);

        result.fold(
          (failure) {
            print('❌ Create failed: ${failure.message}');
            emit(BorrowError(message: _mapFailureToMessage(failure)));
          },
          (createdCard) {
            print('✅ Created successfully: ID ${createdCard.id}');
            emit(BorrowCardCreated(borrowCard: createdCard));
          },
        );
      },
    );
  }

  Future<void> _onUpdateBorrow(
    UpdateBorrowEvent event,
    Emitter<BorrowState> emit,
  ) async {
    emit(const BorrowLoading());

    // Validate form data first
    final validation = BorrowCardValidator.validateFormData(
      borrowerName: event.formData.borrowerName,
      borrowerClass: event.formData.borrowerClass,
      borrowerStudentId: event.formData.borrowerStudentId,
      borrowerPhone: event.formData.borrowerPhone,
      bookName: event.formData.bookName,
      bookCode: event.formData.bookCode,
      borrowDate: event.formData.borrowDate,
      expectedReturnDate: event.formData.expectedReturnDate,
      actualReturnDate: event.formData.actualReturnDate,
    );

    await validation.fold(
      (failure) {
        emit(BorrowError(message: failure.message));
      },
      (_) async {
        final borrowCard = event.formData.toBorrowCard(id: event.borrowId);
        final result = await repository.update(borrowCard);

        result.fold(
          (failure) => emit(BorrowError(message: _mapFailureToMessage(failure))),
          (updatedCard) => emit(BorrowCardUpdated(borrowCard: updatedCard)),
        );
      },
    );
  }

  Future<void> _onDeleteBorrow(
    DeleteBorrowEvent event,
    Emitter<BorrowState> emit,
  ) async {
    // Lưu state hiện tại trước khi xóa
    final currentState = state;
    List<BorrowCard>? currentCards;
    int? currentPage;
    bool? hasReachedMax;
    int? totalCount;

    if (currentState is BorrowsLoaded) {
      currentCards = currentState.borrowCards;
      currentPage = currentState.currentPage;
      hasReachedMax = currentState.hasReachedMax;
      totalCount = currentState.totalCount;
    } else if (currentState is BorrowSearchResults) {
      currentCards = currentState.searchResults;
      currentPage = currentState.currentPage;
      hasReachedMax = currentState.hasReachedMax;
      totalCount = currentState.totalCount;
    }

    final result = await repository.delete(event.borrowId);

    result.fold(
      (failure) => emit(BorrowError(message: _mapFailureToMessage(failure))),
      (success) {
        if (success) {
          // Xóa item khỏi danh sách hiện tại thay vì reload
          if (currentCards != null) {
            final updatedCards = currentCards.where((card) => card.id != event.borrowId).toList();
            
            if (updatedCards.isEmpty) {
              emit(const BorrowEmpty());
            } else if (currentState is BorrowSearchResults) {
              emit(BorrowSearchResults(
                searchResults: updatedCards,
                query: currentState.query,
                totalCount: (totalCount ?? 0) - 1,
                currentPage: currentPage ?? 1,
                hasReachedMax: hasReachedMax ?? false,
              ));
            } else {
              emit(BorrowsLoaded(
                borrowCards: updatedCards,
                totalCount: (totalCount ?? 0) - 1,
                currentPage: currentPage ?? 1,
                hasReachedMax: hasReachedMax ?? false,
              ));
            }
          } else {
            emit(BorrowCardDeleted(deletedId: event.borrowId));
          }
        } else {
          emit(const BorrowError(message: 'Không thể xóa thẻ mượn'));
        }
      },
    );
  }

  Future<void> _onGetBorrowById(
    GetBorrowByIdEvent event,
    Emitter<BorrowState> emit,
  ) async {
    emit(const BorrowLoading());

    final result = await repository.getById(event.borrowId);

    result.fold(
      (failure) => emit(BorrowError(message: _mapFailureToMessage(failure))),
      (borrowCard) {
        if (borrowCard != null) {
          emit(BorrowCardLoaded(borrowCard: borrowCard));
        } else {
          emit(const BorrowError(message: 'Không tìm thấy thẻ mượn'));
        }
      },
    );
  }

  Future<void> _onSearchBorrows(
    SearchBorrowsEvent event,
    Emitter<BorrowState> emit,
  ) async {
    if (event.page == 1) {
      emit(const BorrowLoading());
    }

    final result = await repository.searchWithPagination(
      event.query,
      page: event.page,
      limit: event.limit,
    );

    final countResult = await repository.getSearchCount(event.query);

    result.fold(
      (failure) => emit(BorrowError(message: _mapFailureToMessage(failure))),
      (searchResults) {
        countResult.fold(
          (failure) => emit(BorrowError(message: _mapFailureToMessage(failure))),
          (totalCount) {
            if (searchResults.isEmpty) {
              emit(const BorrowEmpty(message: 'Không tìm thấy kết quả nào'));
            } else {
              emit(BorrowSearchResults(
                searchResults: searchResults,
                query: event.query,
                totalCount: totalCount,
                currentPage: event.page,
                hasReachedMax: searchResults.length < event.limit,
              ));
            }
          },
        );
      },
    );
  }

  Future<void> _onMarkAsReturned(
    MarkAsReturnedEvent event,
    Emitter<BorrowState> emit,
  ) async {
    emit(const BorrowLoading());

    final result = await repository.markAsReturned(event.borrowId);

    result.fold(
      (failure) => emit(BorrowError(message: _mapFailureToMessage(failure))),
      (updatedCard) => emit(BorrowOperationSuccess(
        message: 'Đã đánh dấu sách đã trả thành công',
        updatedCard: updatedCard,
      )),
    );
  }

  Future<void> _onUpdateBorrowStatus(
    UpdateBorrowStatusEvent event,
    Emitter<BorrowState> emit,
  ) async {
    emit(const BorrowLoading());

    final result = await repository.updateStatus(event.borrowId, event.status);

    result.fold(
      (failure) => emit(BorrowError(message: _mapFailureToMessage(failure))),
      (updatedCard) => emit(BorrowOperationSuccess(
        message: 'Đã cập nhật trạng thái thành công',
        updatedCard: updatedCard,
      )),
    );
  }

  Future<void> _onLoadBorrowsByStatus(
    LoadBorrowsByStatusEvent event,
    Emitter<BorrowState> emit,
  ) async {
    emit(const BorrowLoading());

    final result = await repository.getByStatus(event.status);

    result.fold(
      (failure) => emit(BorrowError(message: _mapFailureToMessage(failure))),
      (borrowCards) {
        if (borrowCards.isEmpty) {
          emit(const BorrowEmpty(message: 'Không có thẻ mượn nào với trạng thái này'));
        } else {
          emit(BorrowsLoaded(
            borrowCards: borrowCards,
            totalCount: borrowCards.length,
          ));
        }
      },
    );
  }

  Future<void> _onLoadOverdueBorrows(
    LoadOverdueBorrowsEvent event,
    Emitter<BorrowState> emit,
  ) async {
    emit(const BorrowLoading());

    final result = await repository.getOverdueCards();

    result.fold(
      (failure) => emit(BorrowError(message: _mapFailureToMessage(failure))),
      (borrowCards) {
        if (borrowCards.isEmpty) {
          emit(const BorrowEmpty(message: 'Không có sách quá hạn'));
        } else {
          emit(BorrowsLoaded(
            borrowCards: borrowCards,
            totalCount: borrowCards.length,
          ));
        }
      },
    );
  }

  Future<void> _onGetBorrowStatistics(
    GetBorrowStatisticsEvent event,
    Emitter<BorrowState> emit,
  ) async {
    emit(const BorrowLoading());

    final result = await repository.getStatistics(event.startDate, event.endDate);

    result.fold(
      (failure) => emit(BorrowError(message: _mapFailureToMessage(failure))),
      (statistics) => emit(BorrowStatisticsLoaded(
        statistics: statistics,
        startDate: event.startDate,
        endDate: event.endDate,
      )),
    );
  }

  Future<void> _onGetBorrowingHistory(
    GetBorrowingHistoryEvent event,
    Emitter<BorrowState> emit,
  ) async {
    emit(const BorrowLoading());

    final result = await repository.getBorrowingHistory(event.borrowerName);

    result.fold(
      (failure) => emit(BorrowError(message: _mapFailureToMessage(failure))),
      (history) {
        if (history.isEmpty) {
          emit(const BorrowEmpty(message: 'Không có lịch sử mượn sách'));
        } else {
          emit(BorrowingHistoryLoaded(
            history: history,
            borrowerName: event.borrowerName,
          ));
        }
      },
    );
  }

  Future<void> _onRefreshBorrows(
    RefreshBorrowsEvent event,
    Emitter<BorrowState> emit,
  ) async {
    if (state is BorrowsLoaded) {
      emit(BorrowRefreshing(
        currentBorrowCards: (state as BorrowsLoaded).borrowCards,
      ));
    } else {
      emit(const BorrowLoading());
    }

    final result = await repository.getAll();

    result.fold(
      (failure) => emit(BorrowError(message: _mapFailureToMessage(failure))),
      (borrowCards) {
        if (borrowCards.isEmpty) {
          emit(const BorrowEmpty());
        } else {
          emit(BorrowsLoaded(
            borrowCards: borrowCards,
            totalCount: borrowCards.length,
          ));
        }
      },
    );
  }

  Future<void> _onClearBorrowState(
    ClearBorrowStateEvent event,
    Emitter<BorrowState> emit,
  ) async {
    emit(const BorrowInitial());
  }

  Future<void> _onHandleScannerInput(
    HandleScannerInputEvent event,
    Emitter<BorrowState> emit,
  ) async {
    try {
      final extractedData = <String, String>{};
      bool isValid = false;

      switch (event.inputType) {
        case ScannerInputType.bookCode:
          // Process book code from barcode/QR
          extractedData['bookCode'] = event.scannedData;
          // You might want to look up book details from the code
          isValid = event.scannedData.isNotEmpty;
          break;
        
        case ScannerInputType.studentId:
          // Process student ID from QR code
          extractedData['studentId'] = event.scannedData;
          isValid = event.scannedData.isNotEmpty;
          break;
        
        case ScannerInputType.readerCard:
          // Process reader card QR code (might contain JSON data)
          try {
            // Assuming QR code contains structured data
            // Format: name|studentId|class|phone|email
            final parts = event.scannedData.split('|');
            if (parts.length >= 3) {
              extractedData['name'] = parts[0];
              extractedData['studentId'] = parts[1];
              extractedData['class'] = parts[2];
              if (parts.length > 3) {
                extractedData['phone'] = parts[3];
              }
              if (parts.length > 4) {
                extractedData['email'] = parts[4];
              }
              isValid = true;
            }
          } catch (e) {
            isValid = false;
          }
          break;
      }

      emit(ScannerInputProcessed(
        scannedData: event.scannedData,
        extractedData: extractedData,
        isValid: isValid,
      ));
    } catch (e) {
      emit(BorrowError(message: 'Lỗi xử lý dữ liệu quét: $e'));
    }
  }

  Future<void> _onValidateFormData(
    ValidateFormDataEvent event,
    Emitter<BorrowState> emit,
  ) async {
    final validation = BorrowCardValidator.validateFormData(
      borrowerName: event.formData.borrowerName,
      borrowerClass: event.formData.borrowerClass,
      borrowerStudentId: event.formData.borrowerStudentId,
      borrowerPhone: event.formData.borrowerPhone,
      bookName: event.formData.bookName,
      bookCode: event.formData.bookCode,
      borrowDate: event.formData.borrowDate,
      expectedReturnDate: event.formData.expectedReturnDate,
      actualReturnDate: event.formData.actualReturnDate,
    );

    validation.fold(
      (failure) {
        // Parse validation errors from the failure message
        final errors = <String, String>{'general': failure.message};
        emit(BorrowFormValidated(
          formData: event.formData,
          validationErrors: errors,
          isValid: false,
        ));
      },
      (_) => emit(BorrowFormValidated(
        formData: event.formData,
        validationErrors: const {},
        isValid: true,
      )),
    );
  }

  Future<void> _onResetForm(
    ResetFormEvent event,
    Emitter<BorrowState> emit,
  ) async {
    final now = DateTime.now();
    final defaultFormData = BorrowFormData(
      borrowerName: '',
      bookName: '',
      borrowDate: now,
      expectedReturnDate: now.add(const Duration(days: 14)), // Default 2 weeks
    );

    emit(BorrowFormDataLoaded(
      formData: defaultFormData,
      isEditing: false,
    ));
  }

  Future<void> _onLoadFormData(
    LoadFormDataEvent event,
    Emitter<BorrowState> emit,
  ) async {
    if (event.borrowId != null) {
      // Load existing borrow card for editing
      emit(const BorrowLoading());
      
      final result = await repository.getById(event.borrowId!);
      
      result.fold(
        (failure) => emit(BorrowError(message: _mapFailureToMessage(failure))),
        (borrowCard) {
          if (borrowCard != null) {
            final formData = BorrowFormData.fromBorrowCard(borrowCard);
            emit(BorrowFormDataLoaded(
              formData: formData,
              isEditing: true,
            ));
          } else {
            emit(const BorrowError(message: 'Không tìm thấy thẻ mượn'));
          }
        },
      );
    } else {
      // Create new form
      add(const ResetFormEvent());
    }
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case DatabaseFailure:
        return 'Lỗi cơ sở dữ liệu: ${failure.message}';
      case NetworkFailure:
        return 'Lỗi kết nối mạng: ${failure.message}';
      case ValidationFailure:
        return 'Dữ liệu không hợp lệ: ${failure.message}';
      default:
        return 'Đã xảy ra lỗi: ${failure.message}';
    }
  }
}