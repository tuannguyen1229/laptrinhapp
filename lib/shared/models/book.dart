import 'package:equatable/equatable.dart';

class Book extends Equatable {
  final int? id;
  final String bookCode;
  final String title;
  final String? author;
  final String? category;
  final String? isbn;
  final int totalCopies;
  final int availableCopies;
  final DateTime? createdAt;

  const Book({
    this.id,
    required this.bookCode,
    required this.title,
    this.author,
    this.category,
    this.isbn,
    this.totalCopies = 1,
    this.availableCopies = 1,
    this.createdAt,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as int?,
      bookCode: json['book_code'] as String,
      title: json['title'] as String,
      author: json['author'] as String?,
      category: json['category'] as String?,
      isbn: json['isbn'] as String?,
      totalCopies: json['total_copies'] as int? ?? 1,
      availableCopies: json['available_copies'] as int? ?? 1,
      createdAt: json['created_at'] == null
          ? null
          : (json['created_at'] is String
              ? DateTime.parse(json['created_at'] as String)
              : DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'book_code': bookCode,
      'title': title,
      'author': author,
      'category': category,
      'isbn': isbn,
      'total_copies': totalCopies,
      'available_copies': availableCopies,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  Book copyWith({
    int? id,
    String? bookCode,
    String? title,
    String? author,
    String? category,
    String? isbn,
    int? totalCopies,
    int? availableCopies,
    DateTime? createdAt,
  }) {
    return Book(
      id: id ?? this.id,
      bookCode: bookCode ?? this.bookCode,
      title: title ?? this.title,
      author: author ?? this.author,
      category: category ?? this.category,
      isbn: isbn ?? this.isbn,
      totalCopies: totalCopies ?? this.totalCopies,
      availableCopies: availableCopies ?? this.availableCopies,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isAvailable => availableCopies > 0;

  @override
  List<Object?> get props => [
        id,
        bookCode,
        title,
        author,
        category,
        isbn,
        totalCopies,
        availableCopies,
        createdAt,
      ];
}