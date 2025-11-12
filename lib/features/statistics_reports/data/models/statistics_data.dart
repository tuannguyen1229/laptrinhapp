import 'package:equatable/equatable.dart';

/// Model for user statistics data
class UserStatistics extends Equatable {
  final String borrowerName;
  final int totalBorrows;
  final int activeBorrows;
  final int returnedBorrows;
  final int overdueBorrows;
  final DateTime? lastBorrowDate;
  final List<String> borrowedBooks;

  const UserStatistics({
    required this.borrowerName,
    required this.totalBorrows,
    required this.activeBorrows,
    required this.returnedBorrows,
    required this.overdueBorrows,
    this.lastBorrowDate,
    required this.borrowedBooks,
  });

  factory UserStatistics.fromJson(Map<String, dynamic> json) {
    return UserStatistics(
      borrowerName: json['borrower_name'] as String,
      totalBorrows: json['total_borrows'] as int,
      activeBorrows: json['active_borrows'] as int,
      returnedBorrows: json['returned_borrows'] as int,
      overdueBorrows: json['overdue_borrows'] as int,
      lastBorrowDate: json['last_borrow_date'] != null
          ? DateTime.parse(json['last_borrow_date'] as String)
          : null,
      borrowedBooks: List<String>.from(json['borrowed_books'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'borrower_name': borrowerName,
      'total_borrows': totalBorrows,
      'active_borrows': activeBorrows,
      'returned_borrows': returnedBorrows,
      'overdue_borrows': overdueBorrows,
      'last_borrow_date': lastBorrowDate?.toIso8601String(),
      'borrowed_books': borrowedBooks,
    };
  }

  @override
  List<Object?> get props => [
        borrowerName,
        totalBorrows,
        activeBorrows,
        returnedBorrows,
        overdueBorrows,
        lastBorrowDate,
        borrowedBooks,
      ];
}

/// Model for monthly statistics data
class MonthlyStatistics extends Equatable {
  final int year;
  final int month;
  final int totalBorrows;
  final int totalReturns;
  final int newBorrows;
  final int overdueCount;
  final List<String> popularBooks;
  final List<String> activeBorrowers;

  const MonthlyStatistics({
    required this.year,
    required this.month,
    required this.totalBorrows,
    required this.totalReturns,
    required this.newBorrows,
    required this.overdueCount,
    required this.popularBooks,
    required this.activeBorrowers,
  });

  String get monthName {
    const months = [
      'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6',
      'Tháng 7', 'Tháng 8', 'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12'
    ];
    return months[month - 1];
  }

  factory MonthlyStatistics.fromJson(Map<String, dynamic> json) {
    return MonthlyStatistics(
      year: json['year'] as int,
      month: json['month'] as int,
      totalBorrows: json['total_borrows'] as int,
      totalReturns: json['total_returns'] as int,
      newBorrows: json['new_borrows'] as int,
      overdueCount: json['overdue_count'] as int,
      popularBooks: List<String>.from(json['popular_books'] as List),
      activeBorrowers: List<String>.from(json['active_borrowers'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'month': month,
      'total_borrows': totalBorrows,
      'total_returns': totalReturns,
      'new_borrows': newBorrows,
      'overdue_count': overdueCount,
      'popular_books': popularBooks,
      'active_borrowers': activeBorrowers,
    };
  }

  @override
  List<Object?> get props => [
        year,
        month,
        totalBorrows,
        totalReturns,
        newBorrows,
        overdueCount,
        popularBooks,
        activeBorrowers,
      ];
}

/// Model for chart data points
class ChartDataPoint extends Equatable {
  final String label;
  final double value;
  final DateTime? date;
  final Map<String, dynamic>? metadata;

  const ChartDataPoint({
    required this.label,
    required this.value,
    this.date,
    this.metadata,
  });

  factory ChartDataPoint.fromJson(Map<String, dynamic> json) {
    return ChartDataPoint(
      label: json['label'] as String,
      value: (json['value'] as num).toDouble(),
      date: json['date'] != null ? DateTime.parse(json['date'] as String) : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'value': value,
      'date': date?.toIso8601String(),
      'metadata': metadata,
    };
  }

  @override
  List<Object?> get props => [label, value, date, metadata];
}

/// Model for overall statistics summary
class StatisticsSummary extends Equatable {
  final int totalBorrows;
  final int activeBorrows;
  final int returnedBorrows;
  final int overdueBorrows;
  final int uniqueBorrowers;
  final int uniqueBooks;
  final double averageBorrowDuration;
  final String mostPopularBook;
  final String mostActiveBorrower;
  final DateTime dateRange;

  const StatisticsSummary({
    required this.totalBorrows,
    required this.activeBorrows,
    required this.returnedBorrows,
    required this.overdueBorrows,
    required this.uniqueBorrowers,
    required this.uniqueBooks,
    required this.averageBorrowDuration,
    required this.mostPopularBook,
    required this.mostActiveBorrower,
    required this.dateRange,
  });

  factory StatisticsSummary.fromJson(Map<String, dynamic> json) {
    return StatisticsSummary(
      totalBorrows: json['total_borrows'] as int,
      activeBorrows: json['active_borrows'] as int,
      returnedBorrows: json['returned_borrows'] as int,
      overdueBorrows: json['overdue_borrows'] as int,
      uniqueBorrowers: json['unique_borrowers'] as int,
      uniqueBooks: json['unique_books'] as int,
      averageBorrowDuration: (json['average_borrow_duration'] as num).toDouble(),
      mostPopularBook: json['most_popular_book'] as String,
      mostActiveBorrower: json['most_active_borrower'] as String,
      dateRange: DateTime.parse(json['date_range'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_borrows': totalBorrows,
      'active_borrows': activeBorrows,
      'returned_borrows': returnedBorrows,
      'overdue_borrows': overdueBorrows,
      'unique_borrowers': uniqueBorrowers,
      'unique_books': uniqueBooks,
      'average_borrow_duration': averageBorrowDuration,
      'most_popular_book': mostPopularBook,
      'most_active_borrower': mostActiveBorrower,
      'date_range': dateRange.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        totalBorrows,
        activeBorrows,
        returnedBorrows,
        overdueBorrows,
        uniqueBorrowers,
        uniqueBooks,
        averageBorrowDuration,
        mostPopularBook,
        mostActiveBorrower,
        dateRange,
      ];
}