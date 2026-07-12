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

  List<Transaction> get _filteredTransactions {
    final now = DateTime.now();
    if (_selectedPeriod == 0) {
      // Tuần này (Thứ Hai đến Chủ Nhật)
      final startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 7));
      return MockData.transactions.where((tx) {
        return (tx.date.isAtSameMomentAs(startOfWeek) || tx.date.isAfter(startOfWeek)) &&
            tx.date.isBefore(endOfWeek);
      }).toList();
    } else {
      // Tháng này
      return MockData.transactions.where((tx) {
        return tx.date.year == now.year && tx.date.month == now.month;
      }).toList();
    }
  }

  Map<TransactionCategory, double> get _expenseByCategory {
    final Map<TransactionCategory, double> map = {};
    for (final tx in _filteredTransactions) {
      if (tx.type == TransactionType.expense) {
        map[tx.category] = (map[tx.category] ?? 0) + tx.amount;
      }
    }
    return map;
  }

  double get _totalIncomeForPeriod {
    return _filteredTransactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get _totalExpenseForPeriod {
    return _filteredTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
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

    // Tính toán dữ liệu cho biểu đồ cột
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final List<double> incomeValues = List.filled(7, 0.0);
    final List<double> expenseValues = List.filled(7, 0.0);

    for (int i = 0; i < 7; i++) {
      final dayDate = startOfWeek.add(Duration(days: i));
      for (final tx in MockData.transactions) {
        if (tx.date.year == dayDate.year &&
            tx.date.month == dayDate.month &&
            tx.date.day == dayDate.day) {
          if (tx.type == TransactionType.income) {
            incomeValues[i] += tx.amount;
          } else {
            expenseValues[i] += tx.amount;
          }
        }
      }
    }

    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final numWeeks = (daysInMonth > 28) ? 5 : 4;
    final List<double> monthlyIncomeValues = List.filled(numWeeks, 0.0);
    final List<double> monthlyExpenseValues = List.filled(numWeeks, 0.0);

    for (final tx in MockData.transactions) {
      if (tx.date.year == now.year && tx.date.month == now.month) {
        final day = tx.date.day;
        int weekIndex = (day - 1) ~/ 7;
        if (weekIndex >= numWeeks) {
          weekIndex = numWeeks - 1;
        }
        if (tx.type == TransactionType.income) {
          monthlyIncomeValues[weekIndex] += tx.amount;
        } else {
          monthlyExpenseValues[weekIndex] += tx.amount;
        }
      }
    }

    double maxVal = 100000;
    if (_selectedPeriod == 0) {
      for (int i = 0; i < 7; i++) {
        if (incomeValues[i] > maxVal) maxVal = incomeValues[i];
        if (expenseValues[i] > maxVal) maxVal = expenseValues[i];
      }
    } else {
      for (int i = 0; i < numWeeks; i++) {
        if (monthlyIncomeValues[i] > maxVal) maxVal = monthlyIncomeValues[i];
        if (monthlyExpenseValues[i] > maxVal) maxVal = monthlyExpenseValues[i];
      }
    }
    final maxY = maxVal * 1.15;

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
                      value: formatter.format(_totalIncomeForPeriod),
                      color: AppColors.success,
                      icon: Icons.arrow_upward_rounded,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Tổng chi',
                      value: formatter.format(_totalExpenseForPeriod),
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
                      child: total == 0
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.pie_chart_outline_rounded,
                                    size: 60,
                                    color: AppColors.textMuted.withValues(alpha: 0.8),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Không có dữ liệu chi tiêu',
                                    style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Row(
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
                                SingleChildScrollView(
                                  child: Column(
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
                      _selectedPeriod == 0 ? 'Thu chi tuần này' : 'Thu chi tháng này',
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
                          maxY: maxY,
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipColor: (group) => isDark ? AppColors.darkCard : Colors.white,
                              tooltipBorder: BorderSide(
                                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                                width: 1,
                              ),
                              tooltipRoundedRadius: 8,
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                final isIncome = rodIndex == 0;
                                final label = isIncome ? 'Thu' : 'Chi';
                                return BarTooltipItem(
                                  '$label: ${formatter.format(rod.toY)}',
                                  TextStyle(
                                    color: isIncome ? AppColors.success : AppColors.accent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, _) {
                                  if (_selectedPeriod == 0) {
                                    final days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
                                    final idx = value.toInt();
                                    if (idx >= 0 && idx < 7) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          days[idx],
                                          style: const TextStyle(
                                            color: AppColors.textMuted,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      );
                                    }
                                  } else {
                                    final idx = value.toInt();
                                    if (idx >= 0 && idx < numWeeks) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          'Tuần ${idx + 1}',
                                          style: const TextStyle(
                                            color: AppColors.textMuted,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                  return const Text('');
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
                          barGroups: List.generate(
                            _selectedPeriod == 0 ? 7 : numWeeks,
                            (i) {
                              final double inc = _selectedPeriod == 0 ? incomeValues[i] : monthlyIncomeValues[i];
                              final double exp = _selectedPeriod == 0 ? expenseValues[i] : monthlyExpenseValues[i];
                              return BarChartGroupData(
                                x: i,
                                barRods: [
                                  BarChartRodData(
                                    toY: inc,
                                    color: AppColors.success,
                                    width: 10,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  BarChartRodData(
                                    toY: exp,
                                    color: AppColors.accent,
                                    width: 10,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ],
                              );
                            },
                          ),
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
