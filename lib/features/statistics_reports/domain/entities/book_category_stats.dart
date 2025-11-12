import 'package:equatable/equatable.dart';

class BookCategoryStats extends Equatable {
  final String category;
  final int totalBooks;
  final int availableBooks;
  final int borrowedBooks;

  const BookCategoryStats({
    required this.category,
    required this.totalBooks,
    required this.availableBooks,
    required this.borrowedBooks,
  });

  double get availabilityPercentage {
    if (totalBooks == 0) return 0;
    return (availableBooks / totalBooks) * 100;
  }

  @override
  List<Object?> get props => [category, totalBooks, availableBooks, borrowedBooks];
}
