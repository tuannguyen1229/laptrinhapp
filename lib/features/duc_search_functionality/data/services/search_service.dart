import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../shared/models/borrow_card.dart';
import '../../../../shared/repositories/borrow_card_repository.dart';
import '../../domain/entities/search_query.dart';

class SearchService {
  final BorrowCardRepository _borrowRepository;

  SearchService(this._borrowRepository);

  /// Chuyển đổi tiếng Việt có dấu sang không dấu
  String _removeVietnameseTones(String str) {
    str = str.toLowerCase();
    str = str.replaceAll(RegExp(r'[àáạảãâầấậẩẫăằắặẳẵ]'), 'a');
    str = str.replaceAll(RegExp(r'[èéẹẻẽêềếệểễ]'), 'e');
    str = str.replaceAll(RegExp(r'[ìíịỉĩ]'), 'i');
    str = str.replaceAll(RegExp(r'[òóọỏõôồốộổỗơờớợởỡ]'), 'o');
    str = str.replaceAll(RegExp(r'[ùúụủũưừứựửữ]'), 'u');
    str = str.replaceAll(RegExp(r'[ỳýỵỷỹ]'), 'y');
    str = str.replaceAll(RegExp(r'[đ]'), 'd');
    return str;
  }

  /// Kiểm tra xem text có chứa query không (hỗ trợ không dấu)
  bool _containsQuery(String text, String query) {
    final textLower = text.toLowerCase();
    final queryLower = query.toLowerCase().trim();
    
    // Tìm kiếm bình thường
    if (textLower.contains(queryLower)) {
      return true;
    }
    
    // Tìm kiếm không dấu
    final textNoTone = _removeVietnameseTones(textLower);
    final queryNoTone = _removeVietnameseTones(queryLower);
    return textNoTone.contains(queryNoTone);
  }

  /// Tìm kiếm theo tên người mượn
  Future<Either<Failure, List<BorrowCard>>> searchByBorrowerName(
    String query,
  ) async {
    if (query.trim().isEmpty) {
      return const Right([]);
    }

    final result = await _borrowRepository.getAll();

    return result.fold(
      (failure) => Left(failure),
      (cards) {
        final filtered = cards.where((card) {
          return _containsQuery(card.borrowerName, query);
        }).toList();

        // Sort by relevance (exact match first)
        filtered.sort((a, b) {
          final aLower = a.borrowerName.toLowerCase();
          final bLower = b.borrowerName.toLowerCase();
          final queryLower = query.toLowerCase().trim();

          // Exact match first
          if (aLower == queryLower) return -1;
          if (bLower == queryLower) return 1;

          // Starts with query
          if (aLower.startsWith(queryLower) && !bLower.startsWith(queryLower)) {
            return -1;
          }
          if (bLower.startsWith(queryLower) && !aLower.startsWith(queryLower)) {
            return 1;
          }

          // Alphabetical
          return aLower.compareTo(bLower);
        });

        return Right(filtered);
      },
    );
  }

  /// Tìm kiếm theo tên sách
  Future<Either<Failure, List<BorrowCard>>> searchByBookName(
    String query,
  ) async {
    if (query.trim().isEmpty) {
      return const Right([]);
    }

    final result = await _borrowRepository.getAll();

    return result.fold(
      (failure) => Left(failure),
      (cards) {
        final filtered = cards.where((card) {
          return _containsQuery(card.bookName, query);
        }).toList();

        // Sort by relevance
        filtered.sort((a, b) {
          final aLower = a.bookName.toLowerCase();
          final bLower = b.bookName.toLowerCase();
          final queryLower = query.toLowerCase().trim();

          if (aLower == queryLower) return -1;
          if (bLower == queryLower) return 1;

          if (aLower.startsWith(queryLower) && !bLower.startsWith(queryLower)) {
            return -1;
          }
          if (bLower.startsWith(queryLower) && !aLower.startsWith(queryLower)) {
            return 1;
          }

          return aLower.compareTo(bLower);
        });

        return Right(filtered);
      },
    );
  }

  /// Tìm kiếm nâng cao với nhiều tiêu chí
  Future<Either<Failure, List<BorrowCard>>> advancedSearch(
    SearchQuery query,
  ) async {
    if (query.isEmpty) {
      return const Right([]);
    }

    final result = await _borrowRepository.getAll();

    return result.fold(
      (failure) => Left(failure),
      (cards) {
        var filtered = cards;

        // Filter by borrower name
        if (query.borrowerName != null && query.borrowerName!.isNotEmpty) {
          filtered = filtered.where((card) {
            return card.borrowerName
                .toLowerCase()
                .contains(query.borrowerName!.toLowerCase().trim());
          }).toList();
        }

        // Filter by book name
        if (query.bookName != null && query.bookName!.isNotEmpty) {
          filtered = filtered.where((card) {
            return card.bookName
                .toLowerCase()
                .contains(query.bookName!.toLowerCase().trim());
          }).toList();
        }

        // Filter by class
        if (query.borrowerClass != null && query.borrowerClass!.isNotEmpty) {
          filtered = filtered.where((card) {
            return card.borrowerClass
                    ?.toLowerCase()
                    .contains(query.borrowerClass!.toLowerCase().trim()) ??
                false;
          }).toList();
        }

        // Filter by status
        if (query.status != null) {
          filtered = filtered.where((card) {
            return card.status == query.status;
          }).toList();
        }

        // Filter by borrow date range
        if (query.borrowDateFrom != null) {
          filtered = filtered.where((card) {
            return card.borrowDate.isAfter(query.borrowDateFrom!) ||
                card.borrowDate.isAtSameMomentAs(query.borrowDateFrom!);
          }).toList();
        }

        if (query.borrowDateTo != null) {
          filtered = filtered.where((card) {
            return card.borrowDate.isBefore(query.borrowDateTo!) ||
                card.borrowDate.isAtSameMomentAs(query.borrowDateTo!);
          }).toList();
        }

        // Filter by return date range
        if (query.returnDateFrom != null) {
          filtered = filtered.where((card) {
            return card.expectedReturnDate.isAfter(query.returnDateFrom!) ||
                card.expectedReturnDate
                    .isAtSameMomentAs(query.returnDateFrom!);
          }).toList();
        }

        if (query.returnDateTo != null) {
          filtered = filtered.where((card) {
            return card.expectedReturnDate.isBefore(query.returnDateTo!) ||
                card.expectedReturnDate.isAtSameMomentAs(query.returnDateTo!);
          }).toList();
        }

        return Right(filtered);
      },
    );
  }

  /// Lấy suggestions cho tên người mượn
  Future<Either<Failure, List<String>>> getBorrowerNameSuggestions(
    String prefix,
  ) async {
    if (prefix.trim().isEmpty) {
      return const Right([]);
    }

    final result = await _borrowRepository.getAll();

    return result.fold(
      (failure) => Left(failure),
      (cards) {
        final names = cards
            .map((card) => card.borrowerName)
            .where((name) =>
                name.toLowerCase().startsWith(prefix.toLowerCase().trim()))
            .toSet()
            .toList();

        names.sort();
        return Right(names.take(10).toList());
      },
    );
  }

  /// Lấy suggestions cho tên sách
  Future<Either<Failure, List<String>>> getBookNameSuggestions(
    String prefix,
  ) async {
    if (prefix.trim().isEmpty) {
      return const Right([]);
    }

    final result = await _borrowRepository.getAll();

    return result.fold(
      (failure) => Left(failure),
      (cards) {
        final books = cards
            .map((card) => card.bookName)
            .where((name) =>
                name.toLowerCase().startsWith(prefix.toLowerCase().trim()))
            .toSet()
            .toList();

        books.sort();
        return Right(books.take(10).toList());
      },
    );
  }
}
