import 'package:equatable/equatable.dart';
import '../../../../shared/models/borrow_card.dart';
import '../../../../shared/models/book.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {
  const SearchInitial();
}

class SearchLoading extends SearchState {
  const SearchLoading();
}

class SearchLoaded extends SearchState {
  final List<BorrowCard> results;
  final String query;
  final int totalResults;
  final bool fromCache;

  const SearchLoaded({
    required this.results,
    required this.query,
    required this.totalResults,
    this.fromCache = false,
  });

  @override
  List<Object?> get props => [results, query, totalResults, fromCache];
}

class SearchEmpty extends SearchState {
  final String query;

  const SearchEmpty(this.query);

  @override
  List<Object?> get props => [query];
}

class SearchError extends SearchState {
  final String message;

  const SearchError(this.message);

  @override
  List<Object?> get props => [message];
}

class SearchHistoryLoaded extends SearchState {
  final List<String> history;

  const SearchHistoryLoaded(this.history);

  @override
  List<Object?> get props => [history];
}

class SearchSuggestionsLoaded extends SearchState {
  final List<String> suggestions;

  const SearchSuggestionsLoaded(this.suggestions);

  @override
  List<Object?> get props => [suggestions];
}

class BooksSearchLoaded extends SearchState {
  final List<Book> books;
  final String query;

  const BooksSearchLoaded({
    required this.books,
    required this.query,
  });

  @override
  List<Object?> get props => [books, query];
}
