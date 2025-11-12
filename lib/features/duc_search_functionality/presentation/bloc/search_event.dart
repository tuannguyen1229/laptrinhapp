import 'package:equatable/equatable.dart';
import '../../domain/entities/search_query.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchByBorrowerNameEvent extends SearchEvent {
  final String query;

  const SearchByBorrowerNameEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class SearchByBookNameEvent extends SearchEvent {
  final String query;

  const SearchByBookNameEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class ApplyAdvancedSearchEvent extends SearchEvent {
  final SearchQuery query;

  const ApplyAdvancedSearchEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class LoadSearchHistoryEvent extends SearchEvent {
  const LoadSearchHistoryEvent();
}

class SaveSearchHistoryEvent extends SearchEvent {
  final String query;

  const SaveSearchHistoryEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class ClearSearchHistoryEvent extends SearchEvent {
  const ClearSearchHistoryEvent();
}

class LoadSuggestionsEvent extends SearchEvent {
  final String prefix;
  final SuggestionType type;

  const LoadSuggestionsEvent({
    required this.prefix,
    required this.type,
  });

  @override
  List<Object?> get props => [prefix, type];
}

class ClearSearchEvent extends SearchEvent {
  const ClearSearchEvent();
}

class SearchBooksFromDatabaseEvent extends SearchEvent {
  final String query;

  const SearchBooksFromDatabaseEvent(this.query);

  @override
  List<Object?> get props => [query];
}

enum SuggestionType {
  borrower,
  book,
}
