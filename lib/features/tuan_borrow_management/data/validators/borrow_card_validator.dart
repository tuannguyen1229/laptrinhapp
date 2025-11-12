import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../shared/models/borrow_card.dart';

class BorrowCardValidator {
  static Either<Failure, bool> validateBorrowCard(BorrowCard borrowCard) {
    // Validate borrower name
    final borrowerNameValidation = validateBorrowerName(borrowCard.borrowerName);
    if (borrowerNameValidation.isLeft()) {
      return borrowerNameValidation;
    }

    // Validate book name
    final bookNameValidation = validateBookName(borrowCard.bookName);
    if (bookNameValidation.isLeft()) {
      return bookNameValidation;
    }

    // Validate dates
    final dateValidation = validateDates(borrowCard.borrowDate, borrowCard.expectedReturnDate);
    if (dateValidation.isLeft()) {
      return dateValidation;
    }

    // Validate phone number if provided
    if (borrowCard.borrowerPhone != null && borrowCard.borrowerPhone!.isNotEmpty) {
      final phoneValidation = validatePhoneNumber(borrowCard.borrowerPhone!);
      if (phoneValidation.isLeft()) {
        return phoneValidation;
      }
    }

    // Validate student ID if provided
    if (borrowCard.borrowerStudentId != null && borrowCard.borrowerStudentId!.isNotEmpty) {
      final studentIdValidation = validateStudentId(borrowCard.borrowerStudentId!);
      if (studentIdValidation.isLeft()) {
        return studentIdValidation;
      }
    }

    // Validate book code if provided
    if (borrowCard.bookCode != null && borrowCard.bookCode!.isNotEmpty) {
      final bookCodeValidation = validateBookCode(borrowCard.bookCode!);
      if (bookCodeValidation.isLeft()) {
        return bookCodeValidation;
      }
    }

    return const Right(true);
  }

  static Either<Failure, bool> validateBorrowerName(String name) {
    if (name.trim().isEmpty) {
      return const Left(ValidationFailure('Tên người mượn không được để trống'));
    }

    if (name.trim().length < 2) {
      return const Left(ValidationFailure('Tên người mượn phải có ít nhất 2 ký tự'));
    }

    if (name.trim().length > 255) {
      return const Left(ValidationFailure('Tên người mượn không được vượt quá 255 ký tự'));
    }

    // Check for valid characters (letters, spaces, Vietnamese characters)
    final nameRegex = RegExp(r'^[a-zA-ZÀ-ỹ\s]+$');
    if (!nameRegex.hasMatch(name.trim())) {
      return const Left(ValidationFailure('Tên người mượn chỉ được chứa chữ cái và khoảng trắng'));
    }

    return const Right(true);
  }

  static Either<Failure, bool> validateBookName(String bookName) {
    if (bookName.trim().isEmpty) {
      return const Left(ValidationFailure('Tên sách không được để trống'));
    }

    if (bookName.trim().length < 2) {
      return const Left(ValidationFailure('Tên sách phải có ít nhất 2 ký tự'));
    }

    if (bookName.trim().length > 500) {
      return const Left(ValidationFailure('Tên sách không được vượt quá 500 ký tự'));
    }

    return const Right(true);
  }

  static Either<Failure, bool> validateDates(DateTime borrowDate, DateTime expectedReturnDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final borrowDateOnly = DateTime(borrowDate.year, borrowDate.month, borrowDate.day);
    final returnDateOnly = DateTime(expectedReturnDate.year, expectedReturnDate.month, expectedReturnDate.day);

    // Borrow date should not be in the future (can be today)
    if (borrowDateOnly.isAfter(today)) {
      return const Left(ValidationFailure('Ngày mượn không được là ngày trong tương lai'));
    }

    // Borrow date should not be too far in the past (e.g., more than 1 year ago)
    final oneYearAgo = today.subtract(const Duration(days: 365));
    if (borrowDateOnly.isBefore(oneYearAgo)) {
      return const Left(ValidationFailure('Ngày mượn không được quá 1 năm trước'));
    }

    // Expected return date should be after borrow date
    if (returnDateOnly.isBefore(borrowDateOnly) || returnDateOnly.isAtSameMomentAs(borrowDateOnly)) {
      return const Left(ValidationFailure('Ngày trả dự kiến phải sau ngày mượn'));
    }

    // Expected return date should not be too far in the future (e.g., more than 6 months)
    final sixMonthsFromNow = today.add(const Duration(days: 180));
    if (returnDateOnly.isAfter(sixMonthsFromNow)) {
      return const Left(ValidationFailure('Ngày trả dự kiến không được quá 6 tháng từ hôm nay'));
    }

    // Loan period should not exceed 30 days (typical library policy)
    final loanPeriod = returnDateOnly.difference(borrowDateOnly).inDays;
    if (loanPeriod > 30) {
      return const Left(ValidationFailure('Thời gian mượn không được vượt quá 30 ngày'));
    }

    return const Right(true);
  }

  static Either<Failure, bool> validatePhoneNumber(String phoneNumber) {
    if (phoneNumber.trim().isEmpty) {
      return const Right(true); // Phone number is optional
    }

    // Remove all spaces and special characters for validation
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Vietnamese phone number patterns
    final phoneRegex = RegExp(r'^(0|\+84)(3|5|7|8|9)[0-9]{8}$');
    
    if (!phoneRegex.hasMatch(cleanPhone)) {
      return const Left(ValidationFailure('Số điện thoại không hợp lệ. Vui lòng nhập số điện thoại Việt Nam hợp lệ'));
    }

    return const Right(true);
  }

  static Either<Failure, bool> validateStudentId(String studentId) {
    if (studentId.trim().isEmpty) {
      return const Right(true); // Student ID is optional
    }

    if (studentId.trim().length < 5) {
      return const Left(ValidationFailure('Mã số sinh viên phải có ít nhất 5 ký tự'));
    }

    if (studentId.trim().length > 20) {
      return const Left(ValidationFailure('Mã số sinh viên không được vượt quá 20 ký tự'));
    }

    // Student ID should contain only alphanumeric characters
    final studentIdRegex = RegExp(r'^[a-zA-Z0-9]+$');
    if (!studentIdRegex.hasMatch(studentId.trim())) {
      return const Left(ValidationFailure('Mã số sinh viên chỉ được chứa chữ cái và số'));
    }

    return const Right(true);
  }

  static Either<Failure, bool> validateBookCode(String bookCode) {
    if (bookCode.trim().isEmpty) {
      return const Right(true); // Book code is optional
    }

    if (bookCode.trim().length > 100) {
      return const Left(ValidationFailure('Mã sách không được vượt quá 100 ký tự'));
    }

    // Book code should contain only alphanumeric characters and some special characters
    final bookCodeRegex = RegExp(r'^[a-zA-Z0-9\-_\.]+$');
    if (!bookCodeRegex.hasMatch(bookCode.trim())) {
      return const Left(ValidationFailure('Mã sách chỉ được chứa chữ cái, số, dấu gạch ngang, gạch dưới và dấu chấm'));
    }

    return const Right(true);
  }

  static Either<Failure, bool> validateClass(String? className) {
    if (className == null || className.trim().isEmpty) {
      return const Right(true); // Class is optional
    }

    if (className.trim().length > 100) {
      return const Left(ValidationFailure('Tên lớp không được vượt quá 100 ký tự'));
    }

    // Class name should contain alphanumeric characters and some special characters
    final classRegex = RegExp(r'^[a-zA-Z0-9À-ỹ\s\-_\.]+$');
    if (!classRegex.hasMatch(className.trim())) {
      return const Left(ValidationFailure('Tên lớp chỉ được chứa chữ cái, số, khoảng trắng và một số ký tự đặc biệt'));
    }

    return const Right(true);
  }

  static Either<Failure, bool> validateReturnDate(DateTime? actualReturnDate, DateTime borrowDate) {
    if (actualReturnDate == null) {
      return const Right(true); // Actual return date is optional (for active borrows)
    }

    final borrowDateOnly = DateTime(borrowDate.year, borrowDate.month, borrowDate.day);
    final returnDateOnly = DateTime(actualReturnDate.year, actualReturnDate.month, actualReturnDate.day);

    // Actual return date should not be before borrow date
    if (returnDateOnly.isBefore(borrowDateOnly)) {
      return const Left(ValidationFailure('Ngày trả thực tế không được trước ngày mượn'));
    }

    // Actual return date should not be in the future
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (returnDateOnly.isAfter(today)) {
      return const Left(ValidationFailure('Ngày trả thực tế không được là ngày trong tương lai'));
    }

    return const Right(true);
  }

  /// Validate form data before creating/updating borrow card
  static Either<Failure, Map<String, String>> validateFormData({
    required String borrowerName,
    String? borrowerClass,
    String? borrowerStudentId,
    String? borrowerPhone,
    required String bookName,
    String? bookCode,
    required DateTime borrowDate,
    required DateTime expectedReturnDate,
    DateTime? actualReturnDate,
  }) {
    final errors = <String, String>{};

    // Validate borrower name
    final borrowerNameValidation = validateBorrowerName(borrowerName);
    borrowerNameValidation.fold(
      (failure) => errors['borrowerName'] = failure.message,
      (_) {},
    );

    // Validate book name
    final bookNameValidation = validateBookName(bookName);
    bookNameValidation.fold(
      (failure) => errors['bookName'] = failure.message,
      (_) {},
    );

    // Validate dates
    final dateValidation = validateDates(borrowDate, expectedReturnDate);
    dateValidation.fold(
      (failure) => errors['dates'] = failure.message,
      (_) {},
    );

    // Validate optional fields
    if (borrowerPhone != null && borrowerPhone.isNotEmpty) {
      final phoneValidation = validatePhoneNumber(borrowerPhone);
      phoneValidation.fold(
        (failure) => errors['borrowerPhone'] = failure.message,
        (_) {},
      );
    }

    if (borrowerStudentId != null && borrowerStudentId.isNotEmpty) {
      final studentIdValidation = validateStudentId(borrowerStudentId);
      studentIdValidation.fold(
        (failure) => errors['borrowerStudentId'] = failure.message,
        (_) {},
      );
    }

    if (bookCode != null && bookCode.isNotEmpty) {
      final bookCodeValidation = validateBookCode(bookCode);
      bookCodeValidation.fold(
        (failure) => errors['bookCode'] = failure.message,
        (_) {},
      );
    }

    if (borrowerClass != null && borrowerClass.isNotEmpty) {
      final classValidation = validateClass(borrowerClass);
      classValidation.fold(
        (failure) => errors['borrowerClass'] = failure.message,
        (_) {},
      );
    }

    if (actualReturnDate != null) {
      final returnDateValidation = validateReturnDate(actualReturnDate, borrowDate);
      returnDateValidation.fold(
        (failure) => errors['actualReturnDate'] = failure.message,
        (_) {},
      );
    }

    if (errors.isNotEmpty) {
      return Left(ValidationFailure('Dữ liệu không hợp lệ: ${errors.values.join(', ')}'));
    }

    return const Right({});
  }
}