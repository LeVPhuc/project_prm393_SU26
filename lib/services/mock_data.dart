import '../models/transaction_model.dart';
import '../models/wallet_model.dart';
import '../models/challenge_model.dart';

class MockData {
  static final List<Wallet> wallets = [
    const Wallet(
      id: 'w1',
      name: 'Ví Tiền Mặt',
      balance: 2450000,
      icon: '💵',
      colorIndex: 0,
      type: 'Tiền mặt',
    ),
    const Wallet(
      id: 'w2',
      name: 'Vietcombank',
      balance: 15780000,
      icon: '🏦',
      colorIndex: 1,
      type: 'Ngân hàng',
    ),
    const Wallet(
      id: 'w3',
      name: 'MoMo',
      balance: 830000,
      icon: '📱',
      colorIndex: 2,
      type: 'Ví điện tử',
    ),
  ];

  static final List<Transaction> transactions = [
    Transaction(
      id: 't1',
      title: 'Lương tháng 7',
      amount: 12000000,
      type: TransactionType.income,
      category: TransactionCategory.work,
      date: DateTime.now().subtract(const Duration(days: 1)),
      walletId: 'w2',
      note: 'Lương cứng + phụ cấp',
    ),
    Transaction(
      id: 't2',
      title: 'Bữa trưa văn phòng',
      amount: 65000,
      type: TransactionType.expense,
      category: TransactionCategory.food,
      date: DateTime.now().subtract(const Duration(hours: 3)),
      walletId: 'w1',
    ),
    Transaction(
      id: 't3',
      title: 'Grab về nhà',
      amount: 45000,
      type: TransactionType.expense,
      category: TransactionCategory.transport,
      date: DateTime.now().subtract(const Duration(hours: 5)),
      walletId: 'w3',
    ),
    Transaction(
      id: 't4',
      title: 'Mua áo UNIQLO',
      amount: 490000,
      type: TransactionType.expense,
      category: TransactionCategory.shopping,
      date: DateTime.now().subtract(const Duration(days: 2)),
      walletId: 'w2',
    ),
    Transaction(
      id: 't5',
      title: 'Cafe buổi sáng',
      amount: 55000,
      type: TransactionType.expense,
      category: TransactionCategory.food,
      date: DateTime.now().subtract(const Duration(days: 2)),
      walletId: 'w1',
    ),
    Transaction(
      id: 't6',
      title: 'Khám sức khỏe định kỳ',
      amount: 350000,
      type: TransactionType.expense,
      category: TransactionCategory.health,
      date: DateTime.now().subtract(const Duration(days: 3)),
      walletId: 'w2',
    ),
    Transaction(
      id: 't7',
      title: 'Netflix subscription',
      amount: 180000,
      type: TransactionType.expense,
      category: TransactionCategory.entertainment,
      date: DateTime.now().subtract(const Duration(days: 4)),
      walletId: 'w3',
    ),
    Transaction(
      id: 't8',
      title: 'Freelance project',
      amount: 3500000,
      type: TransactionType.income,
      category: TransactionCategory.work,
      date: DateTime.now().subtract(const Duration(days: 5)),
      walletId: 'w2',
      note: 'Thiết kế UI/UX cho khách hàng mới',
    ),
    Transaction(
      id: 't9',
      title: 'Siêu thị cuối tuần',
      amount: 680000,
      type: TransactionType.expense,
      category: TransactionCategory.shopping,
      date: DateTime.now().subtract(const Duration(days: 6)),
      walletId: 'w2',
    ),
    Transaction(
      id: 't10',
      title: 'Đi xe bus',
      amount: 9000,
      type: TransactionType.expense,
      category: TransactionCategory.transport,
      date: DateTime.now().subtract(const Duration(days: 6)),
      walletId: 'w1',
    ),
  ];

  static final List<Challenge> challenges = [
    Challenge(
      id: 'c1',
      title: 'Mua iPhone 15 Pro',
      description: 'Tiết kiệm để mua điện thoại mới cuối năm',
      icon: '📱',
      targetAmount: 28000000,
      savedAmount: 12500000,
      deadline: DateTime.now().add(const Duration(days: 120)),
      currentStreak: 12,
      dailySpending: const [120000.0, 45000.0, 0.0, 250000.0, 60000.0],
    ),
    Challenge(
      id: 'c2',
      title: 'Du lịch Đà Lạt',
      description: 'Chuyến đi 4 ngày 3 đêm cùng bạn bè',
      icon: '🌄',
      targetAmount: 5000000,
      savedAmount: 3200000,
      deadline: DateTime.now().add(const Duration(days: 45)),
      currentStreak: 4,
    ),
    Challenge(
      id: 'c3',
      title: 'Hạn chế ăn ngoài',
      description: 'Tự nấu ăn tại nhà để tiết kiệm và an toàn',
      icon: '🥗',
      targetAmount: 2000000,
      savedAmount: 1650000,
      deadline: DateTime.now().add(const Duration(days: 8)),
      betAmount: 150000.0,
      shields: 1,
      maxViolations: 2,
      currentViolations: 0,
      currentStreak: 7,
      dailySpending: const [80000.0, 120000.0, 45000.0, 200000.0, 0.0, 95000.0, 110000.0],
    ),
    Challenge(
      id: 'c4',
      title: 'Quỹ khẩn cấp 3 tháng',
      description: 'Dự phòng tương đương 3 tháng chi phí sinh hoạt',
      icon: '🛡️',
      targetAmount: 15000000,
      savedAmount: 5000000,
      deadline: DateTime.now().add(const Duration(days: 200)),
      currentStreak: 25,
    ),
    Challenge(
      id: 'c5',
      title: 'Đấu trí trà sữa với AI',
      description: 'Cược chi tiêu ăn vặt xem ai tiết kiệm hơn Vun Vén Bot!',
      icon: '🍵',
      targetAmount: 300000,
      savedAmount: 120000,
      deadline: DateTime.now().add(const Duration(days: 7)),
      betAmount: 100000.0,
      isAiDuel: true,
      aiSpent: 90000.0,
      currentStreak: 5,
      shields: 0,
      maxViolations: 1,
      currentViolations: 0,
      dailySpending: const [30000.0, 45000.0, 0.0, 45000.0, 0.0],
    ),
  ];

  static double get totalBalance =>
      wallets.fold(0, (sum, w) => sum + w.balance);

  static double get totalIncome => transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0, (sum, t) => sum + t.amount);

  static double get totalExpense => transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0, (sum, t) => sum + t.amount);

  // Quỹ đóng băng - tiền được khóa trong các challenge
  static double get frozenAmount =>
      challenges.fold(0, (sum, c) => sum + c.savedAmount);

  // Số challenge đang chạy (chưa hoàn thành)
  static int get activeChallengeCount =>
      challenges.where((c) => !c.isCompleted).length;

  // XP & Level system
  static int currentXP = 250;
  static int level = 3;
  static int xpForNextLevel = 400;

  // Challenge gần nhất (sắp đến hạn nhất)
  static Challenge? get nearestChallenge {
    final active = challenges.where((c) => !c.isCompleted).toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));
    return active.isNotEmpty ? active.first : null;
  }
}
