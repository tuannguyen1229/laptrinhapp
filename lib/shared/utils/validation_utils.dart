class ValidationUtils {
  /// Validate if string is not empty
  static bool isNotEmpty(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  /// Validate email format
  static bool isValidEmail(String? email) {
    if (email == null || email.isEmpty) return false;
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Validate phone number (Vietnamese format)
  static bool isValidPhoneNumber(String? phone) {
    if (phone == null || phone.isEmpty) return false;
    
    // Remove spaces and special characters
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // Vietnamese phone number patterns
    final phoneRegex = RegExp(r'^(0|\+84)[3-9][0-9]{8}$');
    return phoneRegex.hasMatch(cleanPhone);
  }

  /// Validate student ID format
  static bool isValidStudentId(String? studentId) {
    if (studentId == null || studentId.isEmpty) return false;
    
    // Assuming student ID is alphanumeric and 6-12 characters
    final studentIdRegex = RegExp(r'^[A-Za-z0-9]{6,12}$');
    return studentIdRegex.hasMatch(studentId);
  }

  /// Validate book code format
  static bool isValidBookCode(String? bookCode) {
    if (bookCode == null || bookCode.isEmpty) return false;
    
    // Book code should be alphanumeric and 3-20 characters
    final bookCodeRegex = RegExp(r'^[A-Za-z0-9\-_]{3,20}$');
    return bookCodeRegex.hasMatch(bookCode);
  }

  /// Validate ISBN format
  static bool isValidISBN(String? isbn) {
    if (isbn == null || isbn.isEmpty) return false;
    
    // Remove hyphens and spaces
    final cleanISBN = isbn.replaceAll(RegExp(r'[\s\-]'), '');
    
    // ISBN-10 or ISBN-13 format
    final isbnRegex = RegExp(r'^(97[89])?\d{9}[\dX]$');
    return isbnRegex.hasMatch(cleanISBN);
  }

  /// Validate date range (start date should be before end date)
  static bool isValidDateRange(DateTime? startDate, DateTime? endDate) {
    if (startDate == null || endDate == null) return false;
    return startDate.isBefore(endDate) || startDate.isAtSameMomentAs(endDate);
  }

  /// Validate borrow period (should not exceed maximum days)
  static bool isValidBorrowPeriod(DateTime borrowDate, DateTime returnDate, {int maxDays = 30}) {
    final difference = returnDate.difference(borrowDate).inDays;
    return difference > 0 && difference <= maxDays;
  }

  /// Validate positive integer
  static bool isPositiveInteger(String? value) {
    if (value == null || value.isEmpty) return false;
    
    final number = int.tryParse(value);
    return number != null && number > 0;
  }

  /// Validate non-negative integer
  static bool isNonNegativeInteger(String? value) {
    if (value == null || value.isEmpty) return false;
    
    final number = int.tryParse(value);
    return number != null && number >= 0;
  }

  /// Get validation error message for required field
  static String? validateRequired(String? value, String fieldName) {
    if (!isNotEmpty(value)) {
      return '$fieldName là bắt buộc';
    }
    return null;
  }

  /// Get validation error message for email
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) return null;
    
    if (!isValidEmail(email)) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  /// Get validation error message for phone number
  static String? validatePhoneNumber(String? phone) {
    if (phone == null || phone.isEmpty) return null;
    
    if (!isValidPhoneNumber(phone)) {
      return 'Số điện thoại không hợp lệ';
    }
    return null;
  }

  /// Get validation error message for student ID
  static String? validateStudentId(String? studentId) {
    if (studentId == null || studentId.isEmpty) return null;
    
    if (!isValidStudentId(studentId)) {
      return 'Mã sinh viên không hợp lệ (6-12 ký tự alphanumeric)';
    }
    return null;
  }

  /// Get validation error message for book code
  static String? validateBookCode(String? bookCode) {
    if (bookCode == null || bookCode.isEmpty) return null;
    
    if (!isValidBookCode(bookCode)) {
      return 'Mã sách không hợp lệ (3-20 ký tự alphanumeric)';
    }
    return null;
  }

  /// Get validation error message for ISBN
  static String? validateISBN(String? isbn) {
    if (isbn == null || isbn.isEmpty) return null;
    
    if (!isValidISBN(isbn)) {
      return 'ISBN không hợp lệ';
    }
    return null;
  }

  /// Get validation error message for positive integer
  static String? validatePositiveInteger(String? value, String fieldName) {
    if (value == null || value.isEmpty) return null;
    
    if (!isPositiveInteger(value)) {
      return '$fieldName phải là số nguyên dương';
    }
    return null;
  }

  /// Get validation error message for non-negative integer
  static String? validateNonNegativeInteger(String? value, String fieldName) {
    if (value == null || value.isEmpty) return null;
    
    if (!isNonNegativeInteger(value)) {
      return '$fieldName phải là số nguyên không âm';
    }
    return null;
  }

  /// Get validation error message for date range
  static String? validateDateRange(DateTime? startDate, DateTime? endDate) {
    if (startDate == null || endDate == null) return null;
    
    if (!isValidDateRange(startDate, endDate)) {
      return 'Ngày bắt đầu phải trước ngày kết thúc';
    }
    return null;
  }

  /// Get validation error message for borrow period
  static String? validateBorrowPeriod(DateTime? borrowDate, DateTime? returnDate, {int maxDays = 30}) {
    if (borrowDate == null || returnDate == null) return null;
    
    if (!isValidBorrowPeriod(borrowDate, returnDate, maxDays: maxDays)) {
      return 'Thời gian mượn không hợp lệ (tối đa $maxDays ngày)';
    }
    return null;
  }

  /// Validate minimum length
  static String? validateMinLength(String? value, int minLength, String fieldName) {
    if (value == null || value.isEmpty) return null;
    
    if (value.length < minLength) {
      return '$fieldName phải có ít nhất $minLength ký tự';
    }
    return null;
  }

  /// Validate maximum length
  static String? validateMaxLength(String? value, int maxLength, String fieldName) {
    if (value == null || value.isEmpty) return null;
    
    if (value.length > maxLength) {
      return '$fieldName không được vượt quá $maxLength ký tự';
    }
    return null;
  }

  /// Combine multiple validators
  static String? combineValidators(String? value, List<String? Function(String?)> validators) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) return error;
    }
    return null;
  }
}