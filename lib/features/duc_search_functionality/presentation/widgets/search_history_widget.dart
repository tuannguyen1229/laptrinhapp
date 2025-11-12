import 'package:flutter/material.dart';

class SearchHistoryWidget extends StatelessWidget {
  final List<String> history;
  final ValueChanged<String> onHistoryTap;
  final VoidCallback onClearHistory;

  const SearchHistoryWidget({
    Key? key,
    required this.history,
    required this.onHistoryTap,
    required this.onClearHistory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const SizedBox();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.history_rounded,
                size: 20,
                color: Colors.grey,
              ),
              const SizedBox(width: 8),
              const Text(
                'Tìm kiếm gần đây',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onClearHistory,
                child: const Text(
                  'Xóa tất cả',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: history.map((query) {
              return ActionChip(
                label: Text(query),
                onPressed: () => onHistoryTap(query),
                avatar: const Icon(Icons.history, size: 16),
                backgroundColor: Colors.grey[100],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
