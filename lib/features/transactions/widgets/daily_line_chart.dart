// lib/features/transactions/widgets/daily_line_chart.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mone/data/models/chart_model.dart';
import 'package:mone/data/providers/transaction_provider.dart';

class DailyLineChart extends ConsumerStatefulWidget {
  final String userId;

  const DailyLineChart({super.key, required this.userId});

  @override
  ConsumerState<DailyLineChart> createState() => _DailyLineChartState();
}

class _DailyLineChartState extends ConsumerState<DailyLineChart> {
  double _getBottomReservedSize(int dataLength) {
    if (dataLength <= 7) return 20;
    if (dataLength <= 14) return 25;
    if (dataLength <= 31) return 30;
    return 35;
  }

  double _getLeftReservedSize(double maxValue) {
    if (maxValue < 100) return 30;
    if (maxValue < 1000) return 35;
    if (maxValue < 10000) return 40;
    if (maxValue < 100000) return 45;
    return 50;
  }

  @override
  Widget build(BuildContext context) {
    final chartState = ref.watch(chartProvider);

    // Show loading state
    if (chartState.isLoading) {
      return Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.all(16),

        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    // Show error state
    if (chartState.error != null) {
      return Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.all(16),

        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
              const SizedBox(height: 12),
              Text(
                'Error loading chart data',
                style: TextStyle(color: Colors.red.shade600, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                chartState.error!,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final chartData = chartState.chartData;
    if (chartData == null) {
      return _buildEmptyState(context);
    }

    final dailyData = chartData.dailyData;

    // Find max value for Y axis
    double maxY = 0;
    for (final data in dailyData) {
      if (data.incomeAmount > maxY) {
        maxY = data.incomeAmount;
      }
      if (data.expenseAmount > maxY) {
        maxY = data.expenseAmount;
      }
    }

    // Add some padding to max value
    maxY = maxY * 1.1;
    if (maxY == 0) maxY = 100; // Default minimum

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),

      child: Column(
        children: [
          const SizedBox(height: 20),

          if (dailyData.isEmpty)
            _buildEmptyState(context)
          else
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxY / 5,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade300,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: _getBottomReservedSize(dailyData.length),
                        interval: _getBottomInterval(dailyData.length),
                        getTitlesWidget:
                            (value, meta) =>
                                _buildBottomTitle(value, meta, dailyData),
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: _getLeftReservedSize(maxY),
                        interval: maxY / 5,
                        getTitlesWidget:
                            (value, meta) => _buildLeftTitle(value, meta),
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                      left: BorderSide(color: Colors.grey.shade300, width: 1),
                    ),
                  ),
                  minX: 0,
                  maxX: dailyData.length.toDouble() - 1,
                  minY: 0,
                  maxY: maxY,
                  lineBarsData: _buildLineBarsData(dailyData, chartState),
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBorderRadius: BorderRadius.circular(8),
                      getTooltipItems: (List<LineBarSpot> touchedSpots) {
                        return touchedSpots.map((LineBarSpot touchedSpot) {
                          final date = dailyData[touchedSpot.x.toInt()].date;
                          final isIncome = touchedSpot.barIndex == 0;
                          final label = isIncome ? 'Income' : 'Expenses';
                          final color = isIncome ? Colors.green : Colors.red;

                          return LineTooltipItem(
                            '${DateFormat('MMM dd').format(date)}\n$label: \$${touchedSpot.y.toStringAsFixed(2)}',
                            TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SizedBox(
      height: 250,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'No transaction data available',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  List<LineChartBarData> _buildLineBarsData(
    List<DailyChartDataModel> dailyData,
    ChartStateModel chartState,
  ) {
    List<LineChartBarData> lines = [];

    if (chartState.showIncome) {
      lines.add(
        LineChartBarData(
          spots:
              dailyData.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value.incomeAmount);
              }).toList(),
          isCurved: true,
          gradient: LinearGradient(
            colors: [Colors.green.shade400, Colors.green.shade600],
          ),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                Colors.green.shade200.withValues(alpha: 0.3),
                Colors.green.shade100.withValues(alpha: 0.1),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      );
    }

    if (chartState.showExpenses) {
      lines.add(
        LineChartBarData(
          spots:
              dailyData.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value.expenseAmount);
              }).toList(),
          isCurved: true,
          gradient: LinearGradient(
            colors: [Colors.red.shade400, Colors.red.shade600],
          ),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                Colors.red.shade200.withValues(alpha: 0.3),
                Colors.red.shade100.withValues(alpha: 0.1),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      );
    }

    return lines;
  }

  double _getBottomInterval(int dataLength) {
    if (dataLength <= 7) return 1;
    if (dataLength <= 14) return 2;
    if (dataLength <= 31) return 5;
    return 7;
  }

  Widget _buildBottomTitle(
    double value,
    TitleMeta meta,
    List<DailyChartDataModel> dailyData,
  ) {
    if (value.toInt() >= dailyData.length) return const SizedBox();

    final date = dailyData[value.toInt()].date;
    return SideTitleWidget(
      meta: meta,
      child: Text(
        DateFormat('dd').format(date),
        style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
      ),
    );
  }

  Widget _buildLeftTitle(double value, TitleMeta meta) {
    if (value < 1000) {
      return SideTitleWidget(
        meta: meta,
        child: Text(
          '${value.toInt()}',
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
      );
    } else {
      return SideTitleWidget(
        meta: meta,
        child: Text(
          '${(value / 1000).toStringAsFixed(1)}k',
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
      );
    }
  }
}
