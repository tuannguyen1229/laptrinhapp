import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../bloc/statistics_bloc.dart';
import '../../data/models/statistics_data.dart';
import '../../data/services/chart_data_service.dart';
import 'statistics_table_widget.dart';

class UserStatisticsTab extends StatelessWidget {
  const UserStatisticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StatisticsBloc, StatisticsState>(
      builder: (context, state) {
        if (state is StatisticsLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is StatisticsError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Lỗi: ${state.message}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<StatisticsBloc>().add(const RefreshStatisticsEvent());
                  },
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        } else if (state is StatisticsLoaded || state is UserStatisticsLoaded) {
          final userStats = state is StatisticsLoaded 
              ? state.userStatistics 
              : (state as UserStatisticsLoaded).userStatistics;

          if (userStats.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Không có dữ liệu người dùng',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildChartSection(userStats),
                const SizedBox(height: 24),
                _buildTableSection(userStats),
              ],
            ),
          );
        }

        return const Center(
          child: Text(
            'Chưa có dữ liệu thống kê',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        );
      },
    );
  }

  Widget _buildChartSection(List<UserStatistics> userStats) {
    final chartDataService = ChartDataService();
    final barData = chartDataService.convertUserStatsToBarChart(userStats);
    final labels = chartDataService.getUserLabels(userStats);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Biểu đồ số lần mượn theo người dùng',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: _getMaxY(userStats),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: const Color(0xFF6A11CB),
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final userName = labels.length > groupIndex 
                        ? labels[groupIndex] 
                        : 'Người dùng ${groupIndex + 1}';
                    return BarTooltipItem(
                      '$userName\n${rod.toY.round()} lần mượn',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < labels.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            labels[index],
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      return const Text('');
                    },
                    reservedSize: 40,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      );
                    },
                    reservedSize: 40,
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              barGroups: barData,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: _getGridInterval(userStats),
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withOpacity(0.2),
                    strokeWidth: 1,
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableSection(List<UserStatistics> userStats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chi tiết thống kê người dùng',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 16),
        StatisticsTableWidget(
          headers: const [
            'Tên người mượn',
            'Tổng mượn',
            'Đang mượn',
            'Đã trả',
            'Quá hạn',
            'Lần mượn cuối',
          ],
          rows: userStats.map((stats) => [
            stats.borrowerName,
            stats.totalBorrows.toString(),
            stats.activeBorrows.toString(),
            stats.returnedBorrows.toString(),
            stats.overdueBorrows.toString(),
            stats.lastBorrowDate?.toString().split(' ')[0] ?? 'Chưa có',
          ]).toList(),
          onRowTap: (index) {
            // Could navigate to user detail screen
          },
        ),
      ],
    );
  }

  double _getMaxY(List<UserStatistics> userStats) {
    if (userStats.isEmpty) return 10;
    final maxBorrows = userStats.map((s) => s.totalBorrows).reduce((a, b) => a > b ? a : b);
    return (maxBorrows * 1.2).ceilToDouble();
  }

  double _getGridInterval(List<UserStatistics> userStats) {
    final maxY = _getMaxY(userStats);
    if (maxY <= 10) return 1;
    if (maxY <= 50) return 5;
    if (maxY <= 100) return 10;
    return (maxY / 10).ceilToDouble();
  }
}