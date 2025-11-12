import '../../../../shared/models/borrow_card.dart';

class CachedResult {
  final List<BorrowCard> results;
  final DateTime timestamp;

  CachedResult({
    required this.results,
    required this.timestamp,
  });

  bool get isExpired {
    return DateTime.now().difference(timestamp).inMinutes > 5;
  }
}

class SearchCacheService {
  final Map<String, CachedResult> _cache = {};

  /// Cache kết quả search
  void cacheResults(String query, List<BorrowCard> results) {
    _cache[query.toLowerCase().trim()] = CachedResult(
      results: results,
      timestamp: DateTime.now(),
    );
  }

  /// Lấy cached results
  List<BorrowCard>? getCachedResults(String query) {
    final cached = _cache[query.toLowerCase().trim()];
    
    if (cached == null) {
      return null;
    }

    if (cached.isExpired) {
      _cache.remove(query.toLowerCase().trim());
      return null;
    }

    return cached.results;
  }

  /// Clear toàn bộ cache
  void clearCache() {
    _cache.clear();
  }

  /// Invalidate cache (gọi khi có update data)
  void invalidateCache() {
    _cache.clear();
  }

  /// Get cache size
  int get cacheSize => _cache.length;

  /// Check if query is cached
  bool isCached(String query) {
    final cached = _cache[query.toLowerCase().trim()];
    return cached != null && !cached.isExpired;
  }
}
