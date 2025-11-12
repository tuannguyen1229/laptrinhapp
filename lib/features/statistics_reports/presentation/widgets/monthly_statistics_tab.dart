import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../bloc/statistics_bloc.dart';
import '../../data/models/statistics_data.dart';
import '../../data/services/chart_data_service.dart';
import 'statistics_table_widget.dart';

class MonthlyStatisticsTab extends StatelessWidget {
  const MonthlyStatisticsTab({super.key});

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
        } else if (state is StatisticsLoaded || state is MonthlyStatisticsLoaded) {
          final monthlyStats = state is StatisticsLoaded 
              ? state.monthlyStatistics 
              : (state as MonthlyStatisticsLoaded).monthlyStatistics;

          if (monthlyStats.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_month_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Không có dữ liệu theo tháng',
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
                _buildLineChartSection(monthlyStats),
                const SizedBox(height: 24),
                _buildBarChartSection(monthlyStats),
                const SizedBox(height: 24),
                _buildTableSection(monthlyStats),
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

  Widget _buildLineChartSection(List<MonthlyStatistics> monthlyStats) {
    final chartDataService = ChartDataService();
    final lineData = chartDataService.convertMonthlyToMultiLineChart(monthlyStats);
    final labels = chartDataService.getMonthlyLabels(monthlyStats);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Xu hướng mượn/trả sách theo tháng',
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
          child: LineChart(
            LineChartData(
              lineBarsData: lineData,
              maxY: _getMaxYForLine(monthlyStats),
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
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: _getGridIntervalForLine(monthlyStats),
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withOpacity(0.2),
                    strokeWidth: 1,
                  );
                },
              ),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  tooltipBgColor: const Color(0xFF6A11CB),
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final monthIndex = spot.x.toInt();
                      final monthName = monthIndex < labels.length 
                          ? labels[monthIndex] 
                          : 'Tháng ${monthIndex + 1}';
                      final isFirstLine = spot.barIndex == 0;
                      final label = isFirstLine ? 'Mượn' : 'Trả';
                      return LineTooltipItem(
                        '$monthName\n$label: ${spot.y.toInt()}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem('Số lần mượn', const Color(0xFF2196F3)),
            const SizedBox(width: 24),
            _buildLegendItem('Số lần trả', const Color(0xFF4CAF50)),
          ],
        ),
      ],
    );
  }

  Widget _buildBarChartSection(List<MonthlyStatistics> monthlyStats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'So sánh mượn/trả/quá hạn theo tháng',
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
              maxY: _getMaxYForBar(monthlyStats),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: const Color(0xFF6A11CB),
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final monthStats = monthlyStats[groupIndex];
                    final labels = ['Mượn', 'Trả', 'Quá hạn'];
                    return BarTooltipItem(
                      '${monthStats.monthName}\n${labels[rodIndex]}: ${rod.toY.round()}',
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
                      if (index >= 0 && index < monthlyStats.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            monthlyStats[index].monthName,
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
              barGroups: monthlyStats.asMap().entries.map((entry) {
                final index = entry.key;
                final stats = entry.value;
                
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: stats.totalBorrows.toDouble(),
                      color: const Color(0xFF2196F3),
                      width: 12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    BarChartRodData(
                      toY: stats.totalReturns.toDouble(),
                      color: const Color(0xFF4CAF50),
                      width: 12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    BarChartRodData(
                      toY: stats.overdueCount.toDouble(),
                      color: const Color(0xFFF44336),
                      width: 12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ],
                );
              }).toList(),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: _getGridIntervalForBar(monthlyStats),
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
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem('Mượn', const Color(0xFF2196F3)),
            const SizedBox(width: 16),
            _buildLegendItem('Trả', const Color(0xFF4CAF50)),
            const SizedBox(width: 16),
            _buildLegendItem('Quá hạn', const Color(0xFFF44336)),
          ],
        ),
      ],
    );
  }

  Widget _buildTableSection(List<MonthlyStatistics> monthlyStats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chi tiết thống kê theo tháng',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 600),
            child: StatisticsTableWidget(
              headers: const [
                'Tháng/Năm',
                'Tổng mượn',
                'Tổng trả',
                'Quá hạn',
              ],
              rows: monthlyStats.map((stats) => [
                '${stats.monthName}/${stats.year}',
                stats.totalBorrows.toString(),
                stats.totalReturns.toString(),
                stats.overdueCount.toString(),
              ]).toList(),
              onRowTap: (index) {
                // Could show detailed monthly breakdown
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  double _getMaxYForLine(List<MonthlyStatistics> monthlyStats) {
    if (monthlyStats.isEmpty) return 10;
    final maxBorrows = monthlyStats.map((s) => s.totalBorrows).reduce((a, b) => a > b ? a : b);
    final maxReturns = monthlyStats.map((s) => s.totalReturns).reduce((a, b) => a > b ? a : b);
    final max = maxBorrows > maxReturns ? maxBorrows : maxReturns;
    return (max * 1.2).ceilToDouble();
  }

  double _getMaxYForBar(List<MonthlyStatistics> monthlyStats) {
    if (monthlyStats.isEmpty) return 10;
    final maxValue = monthlyStats.map((s) => s.totalBorrows).reduce((a, b) => a > b ? a : b);
    return (maxValue * 1.2).ceilToDouble();
  }

  double _getGridIntervalForLine(List<MonthlyStatistics> monthlyStats) {
    final maxY = _getMaxYForLine(monthlyStats);
    if (maxY <= 10) return 1;
    if (maxY <= 50) return 5;
    if (maxY <= 100) return 10;
    return (maxY / 10).ceilToDouble();
  }

  double _getGridIntervalForBar(List<MonthlyStatistics> monthlyStats) {
    final maxY = _getMaxYForBar(monthlyStats);
    if (maxY <= 10) return 1;
    if (maxY <= 50) return 5;
    if (maxY <= 100) return 10;
    return (maxY / 10).ceilToDouble();
  }
}