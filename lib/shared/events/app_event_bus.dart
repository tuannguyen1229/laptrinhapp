import 'dart:async';
import 'package:equatable/equatable.dart';
import '../models/borrow_card.dart';
import '../models/book.dart';
import '../models/reader.dart';

/// Base class for all application events
abstract class AppEvent extends Equatable {
  const AppEvent();
}

/// Events related to borrow cards
class BorrowCardCreatedEvent extends AppEvent {
  final BorrowCard borrowCard;

  const BorrowCardCreatedEvent(this.borrowCard);

  @override
  List<Object> get props => [borrowCard];
}

class BorrowCardUpdatedEvent extends AppEvent {
  final BorrowCard borrowCard;

  const BorrowCardUpdatedEvent(this.borrowCard);

  @override
  List<Object> get props => [borrowCard];
}

class BorrowCardReturnedEvent extends AppEvent {
  final BorrowCard borrowCard;

  const BorrowCardReturnedEvent(this.borrowCard);

  @override
  List<Object> get props => [borrowCard];
}

class BorrowCardDeletedEvent extends AppEvent {
  final int borrowCardId;

  const BorrowCardDeletedEvent(this.borrowCardId);

  @override
  List<Object> get props => [borrowCardId];
}

/// Events related to overdue detection
class OverdueDetectedEvent extends AppEvent {
  final List<BorrowCard> overdueCards;

  const OverdueDetectedEvent(this.overdueCards);

  @override
  List<Object> get props => [overdueCards];
}

class OverdueResolvedEvent extends AppEvent {
  final BorrowCard resolvedCard;

  const OverdueResolvedEvent(this.resolvedCard);

  @override
  List<Object> get props => [resolvedCard];
}

/// Events related to books
class BookCreatedEvent extends AppEvent {
  final Book book;

  const BookCreatedEvent(this.book);

  @override
  List<Object> get props => [book];
}

class BookUpdatedEvent extends AppEvent {
  final Book book;

  const BookUpdatedEvent(this.book);

  @override
  List<Object> get props => [book];
}

class BookAvailabilityChangedEvent extends AppEvent {
  final Book book;
  final int previousAvailableCopies;

  const BookAvailabilityChangedEvent(this.book, this.previousAvailableCopies);

  @override
  List<Object> get props => [book, previousAvailableCopies];
}

/// Events related to readers
class ReaderCreatedEvent extends AppEvent {
  final Reader reader;

  const ReaderCreatedEvent(this.reader);

  @override
  List<Object> get props => [reader];
}

class ReaderUpdatedEvent extends AppEvent {
  final Reader reader;

  const ReaderUpdatedEvent(this.reader);

  @override
  List<Object> get props => [reader];
}

/// Events related to search operations
class SearchPerformedEvent extends AppEvent {
  final String query;
  final int resultCount;

  const SearchPerformedEvent(this.query, this.resultCount);

  @override
  List<Object> get props => [query, resultCount];
}

/// Events related to statistics
class StatisticsRequestedEvent extends AppEvent {
  final DateTime startDate;
  final DateTime endDate;

  const StatisticsRequestedEvent(this.startDate, this.endDate);

  @override
  List<Object> get props => [startDate, endDate];
}

/// Events related to scanner operations
class QRCodeScannedEvent extends AppEvent {
  final String scannedData;
  final String scanType; // 'book' or 'reader'

  const QRCodeScannedEvent(this.scannedData, this.scanType);

  @override
  List<Object> get props => [scannedData, scanType];
}

/// Events related to notifications
class NotificationSentEvent extends AppEvent {
  final String title;
  final String message;
  final String type;

  const NotificationSentEvent(this.title, this.message, this.type);

  @override
  List<Object> get props => [title, message, type];
}

/// Events related to data synchronization
class DataSyncStartedEvent extends AppEvent {
  const DataSyncStartedEvent();

  @override
  List<Object> get props => [];
}

class DataSyncCompletedEvent extends AppEvent {
  final bool success;
  final String? errorMessage;

  const DataSyncCompletedEvent(this.success, [this.errorMessage]);

  @override
  List<Object> get props => [success, errorMessage ?? ''];
}

/// Central event bus for application-wide communication
class AppEventBus {
  static AppEventBus? _instance;
  final StreamController<AppEvent> _eventController = StreamController.broadcast();

  AppEventBus._internal();

  factory AppEventBus() {
    _instance ??= AppEventBus._internal();
    return _instance!;
  }

  /// Stream of all events
  Stream<AppEvent> get events => _eventController.stream;

  /// Stream of specific event type
  Stream<T> eventsOfType<T extends AppEvent>() {
    return _eventController.stream.where((event) => event is T).cast<T>();
  }

  /// Emit an event
  void emit(AppEvent event) {
    _eventController.add(event);
  }

  /// Listen to specific event type
  StreamSubscription<T> listen<T extends AppEvent>(
    void Function(T event) onEvent,
  ) {
    return eventsOfType<T>().listen(onEvent);
  }

  /// Listen to all events
  StreamSubscription<AppEvent> listenToAll(
    void Function(AppEvent event) onEvent,
  ) {
    return _eventController.stream.listen(onEvent);
  }

  /// Close the event bus
  void dispose() {
    _eventController.close();
  }
}

/// Mixin for classes that need to emit events
mixin EventEmitter {
  final AppEventBus _eventBus = AppEventBus();

  void emitEvent(AppEvent event) {
    _eventBus.emit(event);
  }
}

/// Mixin for classes that need to listen to events
mixin EventListener {
  final AppEventBus _eventBus = AppEventBus();
  final List<StreamSubscription> _subscriptions = [];

  void listenToEvent<T extends AppEvent>(void Function(T event) onEvent) {
    final subscription = _eventBus.listen<T>(onEvent);
    _subscriptions.add(subscription);
  }

  void listenToAllEvents(void Function(AppEvent event) onEvent) {
    final subscription = _eventBus.listenToAll(onEvent);
    _subscriptions.add(subscription);
  }

  void disposeEventListeners() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }
}