import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../models/transaction_model.dart';
import '../../services/mock_data.dart';
import '../../theme/app_theme.dart';
import '../main_navigation.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  int _selectedPeriod = 0; // 0 = Tuần, 1 = Tháng
  int _touchedIndex = -1;

  final List<String> _periods = ['Tuần này', 'Tháng này'];

  Map<TransactionCategory, double> get _expenseByCategory {
    final Map<TransactionCategory, double> map = {};
    for (final tx in MockData.transactions) {
      if (tx.type == TransactionType.expense) {
        map[tx.category] = (map[tx.category] ?? 0) + tx.amount;
      }
    }
    return map;
  }

  Color _categoryColor(TransactionCategory cat) {
    switch (cat) {
      case TransactionCategory.food: return AppColors.catFood;
      case TransactionCategory.transport: return AppColors.catTransport;
      case TransactionCategory.shopping: return AppColors.catShopping;
      case TransactionCategory.work: return AppColors.catWork;
      case TransactionCategory.health: return AppColors.catHealth;
      case TransactionCategory.entertainment: return AppColors.catEntertainment;
      case TransactionCategory.other: return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    final expenseMap = _expenseByCategory;
    final total = expenseMap.values.fold(0.0, (a, b) => a + b);
    final categories = expenseMap.entries.toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
              onPressed: () {
                final navState = context.findAncestorStateOfType<MainNavigationState>();
                if (navState != null) {
                  navState.onTabTapped(0);
                }
              },
            ),
            backgroundColor: const Color(0xFF1A0A10),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0F172A), Color(0xFF3D0C22), Color(0xFFF43F5E)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Text('📈', style: TextStyle(fontSize: 28)),
                            SizedBox(width: 10),
                            Text(
                              'Thống kê',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Period selector
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: List.generate(
                    _periods.length,
                    (index) => Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedPeriod = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedPeriod == index
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _periods[index],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _selectedPeriod == index
                                  ? Colors.white
                                  : AppColors.textMuted,
                              fontWeight: _selectedPeriod == index
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Summary row
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Tổng thu',
                      value: formatter.format(MockData.totalIncome),
                      color: AppColors.success,
                      icon: Icons.arrow_upward_rounded,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Tổng chi',
                      value: formatter.format(MockData.totalExpense),
                      color: AppColors.accent,
                      icon: Icons.arrow_downward_rounded,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Pie chart
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chi tiêu theo danh mục',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 220,
                      child: Row(
                        children: [
                          Expanded(
                            child: PieChart(
                              PieChartData(
                                pieTouchData: PieTouchData(
                                  touchCallback: (event, response) {
                                    setState(() {
                                      if (!event.isInterestedForInteractions ||
                                          response == null ||
                                          response.touchedSection == null) {
                                        _touchedIndex = -1;
                                        return;
                                      }
                                      _touchedIndex = response.touchedSection!.touchedSectionIndex;
                                    });
                                  },
                                ),
                                borderData: FlBorderData(show: false),
                                sectionsSpace: 3,
                                centerSpaceRadius: 48,
                                sections: List.generate(categories.length, (i) {
                                  final entry = categories[i];
                                  final isTouched = i == _touchedIndex;
                                  final percentage = (entry.value / total * 100).toStringAsFixed(1);
                                  return PieChartSectionData(
                                    color: _categoryColor(entry.key),
                                    value: entry.value,
                                    title: isTouched ? '$percentage%' : '',
                                    radius: isTouched ? 72 : 60,
                                    titleStyle: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: categories
                                .map(
                                  (e) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            color: _categoryColor(e.key),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _categoryLabel(e.key),
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bar chart (daily income vs expense)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thu chi 7 ngày qua',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(width: 12, height: 12, decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(3))),
                        const SizedBox(width: 6),
                        Text('Thu', style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(width: 16),
                        Container(width: 12, height: 12, decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(3))),
                        const SizedBox(width: 6),
                        Text('Chi', style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 180,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 15000000,
                          barTouchData: BarTouchData(enabled: false),
                          titlesData: FlTitlesData(
                            show: true,
                            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, _) {
                                  final days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
                                  return Text(
                                    days[value.toInt() % 7],
                                    style: const TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 11,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (_) => FlLine(
                              color: isDark
                                  ? AppColors.darkBorder.withValues(alpha: 0.4)
                                  : AppColors.lightBorder,
                              strokeWidth: 1,
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: List.generate(7, (i) {
                            final incomeValues = [12000000.0, 0.0, 3500000.0, 0.0, 0.0, 0.0, 0.0];
                            final expenseValues = [0.0, 500000.0, 1200000.0, 800000.0, 350000.0, 680000.0, 64000.0];
                            return BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(
                                  toY: incomeValues[i],
                                  color: AppColors.success,
                                  width: 10,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                BarChartRodData(
                                  toY: expenseValues[i],
                                  color: AppColors.accent,
                                  width: 10,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  String _categoryLabel(TransactionCategory cat) {
    switch (cat) {
      case TransactionCategory.food: return 'Ăn uống';
      case TransactionCategory.transport: return 'Di chuyển';
      case TransactionCategory.shopping: return 'Mua sắm';
      case TransactionCategory.work: return 'Thu nhập';
      case TransactionCategory.health: return 'Sức khỏe';
      case TransactionCategory.entertainment: return 'Giải trí';
      case TransactionCategory.other: return 'Khác';
    }
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final bool isDark;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
