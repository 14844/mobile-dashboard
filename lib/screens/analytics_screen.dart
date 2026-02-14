import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_dashboard/models/order.dart';
import 'package:mobile_dashboard/providers/order_provider.dart';
import 'package:mobile_dashboard/utils/constants.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OrderProvider>(context);
    final chartData = _getChartData(provider.orders);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Revenue Line Chart
            const Text(
              'Revenue Over Time (\$)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildChartContainer(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true, drawVerticalLine: false),
                  titlesData: _getTitlesData(chartData),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: chartData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.revenue)).toList(),
                      isCurved: true,
                      gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [const Color(0xFF6366F1).withOpacity(0.3), const Color(0xFF6366F1).withOpacity(0)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Order Volume Bar Chart
            const Text(
              'Order Volume',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildChartContainer(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: chartData.isEmpty ? 10 : chartData.map((e) => e.count).reduce((a, b) => a > b ? a : b) + 2,
                  titlesData: _getTitlesData(chartData),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: chartData.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.count,
                          color: Constants.primaryColor,
                          width: 16,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            const Text(
              'Daily Breakdown',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...chartData.reversed.map((d) => _DailyItem(label: d.fullLabel, count: d.count.toInt(), revenue: d.revenue)),
          ],
        ),
      ),
    );
  }

  Widget _buildChartContainer({required double height, required Widget child}) {
    return Container(
      height: height,
      padding: const EdgeInsets.only(top: 16, left: 8, right: 16, bottom: 8),
      decoration: BoxDecoration(
        color: Constants.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: child,
    );
  }

  FlTitlesData _getTitlesData(List<_ChartEntry> data) {
    return FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 32,
          interval: 1,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index < 0 || index >= data.length) return const SizedBox();
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                data[index].label,
                style: const TextStyle(color: Constants.textMutedColor, fontSize: 10),
              ),
            );
          },
        ),
      ),
      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  List<_ChartEntry> _getChartData(List<Order> dynamicOrders) {
    if (dynamicOrders.isEmpty) return [];

    final Map<String, _ChartEntry> entries = {};
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key = DateFormat('MM/dd').format(date);
      entries[key] = _ChartEntry(label: key, fullLabel: DateFormat('EEEE, MMM dd').format(date), count: 0, revenue: 0);
    }

    for (var order in dynamicOrders) {
      final key = DateFormat('MM/dd').format(order.createdAt);
      if (entries.containsKey(key)) {
        entries[key] = _ChartEntry(
          label: key,
          fullLabel: entries[key]!.fullLabel,
          count: entries[key]!.count + 1,
          revenue: entries[key]!.revenue + order.price,
        );
      }
    }

    return entries.values.toList();
  }
}

class _ChartEntry {
  final String label;
  final String fullLabel;
  final double count;
  final double revenue;
  _ChartEntry({required this.label, required this.fullLabel, required this.count, required this.revenue});
}

class _DailyItem extends StatelessWidget {
  final String label;
  final int count;
  final double revenue;
  const _DailyItem({required this.label, required this.count, required this.revenue});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Constants.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                '\$${revenue.toStringAsFixed(2)}',
                style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Orders', style: TextStyle(color: Constants.textMutedColor, fontSize: 13)),
              Text('$count', style: const TextStyle(color: Colors.white, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}
