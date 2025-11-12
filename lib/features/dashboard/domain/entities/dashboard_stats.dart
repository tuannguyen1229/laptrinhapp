import 'package:equatable/equatable.dart';

class DashboardStats extends Equatable {
  final int activeBorrows;
  final int overdueBorrows;
  final int upcomingDueBorrows;
  final int returnedBorrows;
  final int totalBooks;
  final List<PopularBook> popularBooks;

  const DashboardStats({
    required this.activeBorrows,
    required this.overdueBorrows,
    required this.upcomingDueBorrows,
    required this.returnedBorrows,
    required this.totalBooks,
    this.popularBooks = const [],
  });

  @override
  List<Object?> get props => [
        activeBorrows,
        overdueBorrows,
        upcomingDueBorrows,
        returnedBorrows,
        totalBooks,
        popularBooks,
      ];
}

class RecentActivity extends Equatable {
  final String bookTitle;
  final String borrowerName;
  final String action; // 'borrowed', 'returned', 'overdue'
  final DateTime date;

  const RecentActivity({
    required this.bookTitle,
    required this.borrowerName,
    required this.action,
    required this.date,
  });

  @override
  List<Object?> get props => [bookTitle, borrowerName, action, date];
}

class PopularBook extends Equatable {
  final String bookName;
  final int borrowCount;
  final int availableCopies;

  const PopularBook({
    required this.bookName,
    required this.borrowCount,
    this.availableCopies = 0,
  });

  @override
  List<Object?> get props => [bookName, borrowCount, availableCopies];
}
