import '../../features/auth/domain/entities/user.dart';

/// Helper class để kiểm tra quyền của user
class PermissionHelper {
  /// Check if user is admin
  static bool isAdmin(User? user) {
    return user?.role == UserRole.admin;
  }

  /// Check if user is librarian
  static bool isLibrarian(User? user) {
    return user?.role == UserRole.librarian;
  }

  /// Check if user is regular user
  static bool isRegularUser(User? user) {
    return user?.role == UserRole.user;
  }

  /// Check if user can create/edit/delete borrow cards
  static bool canManageBorrowCards(User? user) {
    return isAdmin(user) || isLibrarian(user);
  }

  /// Check if user can view all borrow cards
  static bool canViewAllBorrowCards(User? user) {
    return isAdmin(user) || isLibrarian(user);
  }

  /// Check if user can view statistics
  static bool canViewStatistics(User? user) {
    return isAdmin(user) || isLibrarian(user);
  }

  /// Check if user can manage users (ADMIN ONLY)
  static bool canManageUsers(User? user) {
    return isAdmin(user);
  }

  /// Check if user can send notifications
  static bool canSendNotifications(User? user) {
    return isAdmin(user) || isLibrarian(user);
  }

  /// Check if user can export reports (ADMIN ONLY)
  static bool canExportReports(User? user) {
    return isAdmin(user);
  }

  /// Check if user can delete borrow cards (ADMIN ONLY)
  static bool canDeleteBorrowCards(User? user) {
    return isAdmin(user);
  }

  /// Check if user can edit statistics settings (ADMIN ONLY)
  static bool canEditStatisticsSettings(User? user) {
    return isAdmin(user);
  }

  /// Get role display name in Vietnamese
  static String getRoleDisplayName(String? role) {
    switch (role) {
      case 'admin':
        return 'Quản trị viên';
      case 'librarian':
        return 'Thủ thư';
      case 'user':
        return 'Người dùng';
      default:
        return 'Không xác định';
    }
  }

  /// Get available menu items based on user role
  static List<int> getAvailableMenuIndexes(User? user) {
    print('🔐 Checking permissions for user: ${user?.username} (role: ${user?.role})');
    
    if (user == null) {
      print('⚠️ User is null, returning default menus');
      return [0, 3]; // Default for unauthenticated
    }
    
    if (isAdmin(user)) {
      print('✅ User is ADMIN - Full access (all 6 menus + full permissions)');
      // Admin: Dashboard, Borrow, Overdue, Search, Status, Statistics
      return [0, 1, 2, 3, 4, 5];
    } else if (isLibrarian(user)) {
      print('✅ User is LIBRARIAN - Full menus but limited permissions');
      // Librarian: Dashboard, Borrow, Overdue, Search, Status, Statistics (view only)
      return [0, 1, 2, 3, 4, 5];
    } else {
      print('✅ User is REGULAR USER - Minimal access (2 menus)');
      // User: Dashboard, Search only
      return [0, 3];
    }
  }

  /// Get menu titles based on role
  static List<String> getMenuTitles(User? user) {
    if (isAdmin(user) || isLibrarian(user)) {
      return [
        'Trang chủ',
        'Quản lý mượn',
        'Cảnh báo',
        'Tìm kiếm',
        'Danh sách thẻ',
        'Thống kê',
      ];
    } else {
      return [
        'Trang chủ',
        'Tìm kiếm',
      ];
    }
  }
}
