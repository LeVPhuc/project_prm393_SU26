import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'app_state.dart';
import 'mock_data.dart';
import '../models/transaction_model.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class ChatbotService extends ChangeNotifier {
  static final ChatbotService _instance = ChatbotService._internal();
  factory ChatbotService() => _instance;
  ChatbotService._internal() {
    // Thêm tin nhắn chào mừng ban đầu
    _history.add(ChatMessage(
      text: 'Xin chào! Tôi là **Vún Vén AI**, trợ lý tài chính cá nhân của bạn. 🧠💵\n\nTôi có thể giúp bạn:\n- 📊 Phân tích ví và lập báo cáo tài chính cá nhân.\n- 💡 Đưa ra các lời khuyên tiết kiệm chi tiêu hiệu quả.\n- 📈 Cập nhật và tư vấn về biến động thị trường & vàng.\n- 🛡️ Hướng dẫn hoàn thành các thử thách tiết kiệm.\n\nHãy chọn các gợi ý bên dưới hoặc đặt câu hỏi cho tôi nhé!',
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  final List<ChatMessage> _history = [];
  bool _isLoading = false;

  List<ChatMessage> get history => List.unmodifiable(_history);
  bool get isLoading => _isLoading;

  void clearHistory() {
    _history.clear();
    _history.add(ChatMessage(
      text: 'Tôi đã làm mới cuộc hội thoại. Hãy hỏi tôi bất cứ điều gì về tài chính nhé!',
      isUser: false,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    _history.add(ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    _isLoading = true;
    notifyListeners();

    String responseText = '';
    final apiKey = AppState().geminiApiKey.trim();

    if (apiKey.isEmpty) {
      // Local mock fallback
      await Future.delayed(const Duration(milliseconds: 1200)); // Simulate thinking
      responseText = _generateLocalResponse(text);
    } else {
      // Gemini API call
      try {
        responseText = await _callGeminiApi(text, apiKey);
      } catch (e) {
        // Fallback to local with error notice
        await Future.delayed(const Duration(milliseconds: 800));
        final localResp = _generateLocalResponse(text);
        responseText = '⚠️ **Không thể kết nối đến Gemini AI (Lỗi: $e). Tạm thời sử dụng Trợ lý Ngoại tuyến:**\n\n$localResp';
      }
    }

    _history.add(ChatMessage(
      text: responseText,
      isUser: false,
      timestamp: DateTime.now(),
    ));
    _isLoading = false;
    notifyListeners();
  }

  // Tạo system prompt chi tiết chứa dữ liệu tài chính của người dùng
  String _buildSystemPrompt() {
    final userName = AppState().userName;
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

    // Chuẩn bị thông tin ví
    final walletsInfo = MockData.wallets.map((w) {
      return '- **${w.name}**: ${formatter.format(w.balance)} (Loại: ${w.type})';
    }).join('\n');

    // Chuẩn bị thông tin giao dịch gần đây (tối đa 8 giao dịch)
    final recentTxns = MockData.transactions.take(8).map((t) {
      final typeStr = t.type == TransactionType.income ? 'Thu nhập (+)' : 'Chi tiêu (-)';
      final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(t.date);
      final noteStr = t.note != null && t.note!.isNotEmpty ? ' (Ghi chú: ${t.note})' : '';
      return '- $dateStr | $typeStr: **${t.title}** | Số tiền: **${formatter.format(t.amount)}** | Danh mục: ${t.category.name}$noteStr';
    }).join('\n');

    // Chuẩn bị thông tin thử thách
    final challengesInfo = MockData.challenges.map((c) {
      final percent = (c.savedAmount / c.targetAmount * 100).toStringAsFixed(1);
      final deadlineStr = DateFormat('dd/MM/yyyy').format(c.deadline);
      final duelStr = c.isAiDuel ? ' (Thử thách đối đầu với AI)' : '';
      return '- **${c.title}**$duelStr: Đã tiết kiệm **${formatter.format(c.savedAmount)}** / Mục tiêu **${formatter.format(c.targetAmount)}** ($percent%). Hạn chót: $deadlineStr. Chuỗi tích lũy: ${c.currentStreak} ngày.';
    }).join('\n');

    return '''
Bạn là "Vún Vén AI" - trợ lý tài chính cá nhân thông minh, hóm hỉnh và tận tâm trong ứng dụng "Vún Vén".
Nhiệm vụ của bạn là giải đáp các thắc mắc về tài chính cá nhân, đầu tư, phân tích biến động thị trường và đưa ra những lời khuyên hữu ích cho người dùng.

Dưới đây là thông tin tài chính hiện tại của người dùng tên là "$userName":
- Tổng tài sản hiện tại: ${formatter.format(MockData.totalBalance)}
- Tiền đang bị đóng băng trong các thử thách: ${formatter.format(MockData.frozenAmount)}
- Tổng Thu nhập từ đầu kỳ: ${formatter.format(MockData.totalIncome)}
- Tổng Chi tiêu từ đầu kỳ: ${formatter.format(MockData.totalExpense)}
- Số thử thách đang chạy: ${MockData.activeChallengeCount}

DANH SÁCH VÍ TIỀN CỦA NGƯỜI DÙNG:
$walletsInfo

CÁC GIAO GIAO DỊCH GẦN ĐÂY:
$recentTxns

CÁC THỬ THÁCH TIẾT KIỆM ĐANG THAM GIA:
$challengesInfo

HƯỚNG DẪN TRẢ LỜI NGƯỜI DÙNG:
1. Trả lời hoàn toàn bằng tiếng Việt với văn phong thân thiện, tích cực, truyền cảm hứng chi tiêu tiết kiệm, kỷ luật.
2. Hãy cá nhân hóa câu trả lời của bạn. Nếu họ hỏi về tình hình tài chính của mình, hãy đọc dữ liệu được cung cấp ở trên để trả lời chính xác số dư, các giao dịch cụ thể, các thử thách cụ thể của họ.
3. Khi người dùng hỏi về lời khuyên chi tiêu, hãy phân tích dữ liệu giao dịch ở trên. Ví dụ: chỉ ra họ đang tiêu nhiều tiền vào đâu (như Ăn uống, Mua sắm, đi lại) và đề xuất cách cắt giảm hoặc gợi ý các thử thách phù hợp.
4. Định dạng câu trả lời sử dụng Markdown thật đẹp mắt. Sử dụng chữ in đậm, danh sách gạch đầu dòng và bảng biểu (nếu cần thiết) để câu trả lời trông chuyên nghiệp và dễ theo dõi.
5. Nếu được hỏi về biến động thị trường (giá vàng, lãi suất tiết kiệm, bất động sản, lạm phát), hãy đưa ra nhận định tổng quan, khách quan, khuyên họ nên đa dạng hóa tài sản và giữ một quỹ dự phòng khẩn cấp (như Thử thách "Quỹ khẩn cấp 3 tháng" họ đang có).
6. Hãy trả lời ngắn gọn, trực diện vào câu hỏi của người dùng, tránh nói lan man dài dòng trừ khi họ yêu cầu phân tích sâu.
''';
  }

  // Gọi API Gemini thực tế
  Future<String> _callGeminiApi(String message, String apiKey) async {
    final systemPrompt = _buildSystemPrompt();

    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      systemInstruction: Content.system(systemPrompt),
    );

    // Chuyển lịch sử trò chuyện sang định dạng của thư viện
    // Tối đa lấy 10 tin nhắn gần nhất để tránh tràn token
    final listHistory = _history.where((m) => m.text.isNotEmpty).toList();
    if (listHistory.length > 10) {
      listHistory.removeRange(0, listHistory.length - 10);
    }

    final chatHistory = listHistory.map((m) {
      if (m.isUser) {
        return Content.text(m.text);
      } else {
        return Content.model([TextPart(m.text)]);
      }
    }).toList();

    // Khởi tạo phiên chat với lịch sử
    final chat = model.startChat(history: chatHistory);
    final response = await chat.sendMessage(Content.text(message));

    return response.text ?? 'Xin lỗi, tôi không nhận được phản hồi từ hệ thống AI.';
  }

  // Bộ phân tích từ khóa ngoại tuyến (Local Engine)
  String _generateLocalResponse(String message) {
    final query = message.toLowerCase();
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

    // 1. Phân tích tài chính cá nhân người dùng
    if (query.contains('báo cáo') ||
        query.contains('tổng quan') ||
        query.contains('tài sản') ||
        query.contains('ví') ||
        query.contains('số dư') ||
        query.contains('tiền') ||
        query.contains('chi tiêu') ||
        query.contains('thu nhập') ||
        query.contains('giao dịch')) {
      
      final totalBalance = MockData.totalBalance;
      final walletsList = MockData.wallets.map((w) => '- **${w.name}**: ${formatter.format(w.balance)} (${w.type})').join('\n');
      final activeChallenges = MockData.challenges.map((c) => '- **${c.title}**: ${formatter.format(c.savedAmount)} / ${formatter.format(c.targetAmount)}').join('\n');
      
      // Tìm danh mục chi tiêu nhiều nhất
      final expenses = MockData.transactions.where((t) => t.type == TransactionType.expense);
      final categoryMap = <TransactionCategory, double>{};
      double maxExpense = 0;
      TransactionCategory? maxCategory;
      
      for (final tx in expenses) {
        categoryMap[tx.category] = (categoryMap[tx.category] ?? 0) + tx.amount;
        if (categoryMap[tx.category]! > maxExpense) {
          maxExpense = categoryMap[tx.category]!;
          maxCategory = tx.category;
        }
      }

      String maxCategoryStr = maxCategory != null 
          ? '${_getCategoryName(maxCategory)} (${formatter.format(maxExpense)})' 
          : 'Không có chi tiêu nào';

      return '''
### 📊 BÁO CÁO TÀI CHÍNH CÁ NHÂN CỦA BẠN

Dưới đây là thống kê tài chính thời gian thực mà tôi đã phân tích từ tài khoản của bạn:

*   **Tổng tài sản hiện tại:** `${formatter.format(totalBalance)}`
*   **Tổng Thu nhập đã ghi nhận:** `${formatter.format(MockData.totalIncome)}`
*   **Tổng Chi tiêu đã ghi nhận:** `${formatter.format(MockData.totalExpense)}`
*   **Quỹ đang đóng băng (tiết kiệm):** `${formatter.format(MockData.frozenAmount)}`

#### 🏦 Chi tiết số dư các ví:
$walletsList

#### 📈 Tình hình chi tiêu theo danh mục:
*   Danh mục tiêu dùng nhiều nhất: **$maxCategoryStr**

#### 🛡️ Thử thách tiết kiệm đang chạy (${MockData.activeChallengeCount}):
$activeChallenges

💡 **Lời khuyên nhanh:** Bạn đang tiết kiệm được khoảng `${((MockData.totalIncome - MockData.totalExpense) / (MockData.totalIncome > 0 ? MockData.totalIncome : 1) * 100).toStringAsFixed(1)}%` từ thu nhập của mình. Hãy duy trì tỉ lệ tiết kiệm trên 20% để đảm bảo an toàn tài chính dài hạn nhé!
''';
    }

    // 2. Lời khuyên quản lý tài chính / Quy tắc 50/30/20
    if (query.contains('khuyên') ||
        query.contains('tiết kiệm') ||
        query.contains('quản lý') ||
        query.contains('50/30/20') ||
        query.contains('phương pháp') ||
        query.contains('quy tắc')) {
      
      return '''
### 💡 LỜI KHUYÊN QUẢN LÝ TÀI CHÍNH THÔNG MINH

Để quản lý tài chính cá nhân hiệu quả, bạn nên áp dụng **Quy tắc 6 chiếc hũ** hoặc **Công thức 50/30/20** tiêu biểu dưới đây:

1.  **50% - Nhu cầu thiết yếu (Needs):** Chi trả cho tiền nhà, ăn uống cơ bản, hóa đơn điện nước, đi lại.
2.  **30% - Sở thích cá nhân (Wants):** Mua sắm quần áo, cafe, giải trí, ăn ngoài (hãy cẩn thận với khoản này!).
3.  **20% - Tích lũy & Đầu tư (Savings/Investment):** Gửi tiết kiệm, đầu tư dài hạn và tích lũy quỹ khẩn cấp.

#### 🎯 Áp dụng thực tế cho bạn:
*   **Hạn chế ăn uống bên ngoài:** Hiện tại bạn đang có thử thách **"Hạn chế ăn ngoài"** sắp đến hạn. Hãy cố gắng nấu ăn tại nhà để tăng chuỗi tiết kiệm (hiện tại là `${MockData.challenges[2].currentStreak} ngày`).
*   **Tích lũy quỹ khẩn cấp:** Đừng quên phân bổ tiền vào thử thách **"Quỹ khẩn cấp 3 tháng"** (Mục tiêu `15,000,000đ`, hiện có `5,000,000đ`). Quỹ này sẽ bảo vệ bạn khỏi các biến động đột xuất như hỏng xe hay ốm đau.
*   **Tránh bẫy mua sắm:** Hãy áp dụng **Quy tắc 48 giờ** trước khi mua bất cứ thứ gì không thiết yếu (như thiết bị công nghệ hay quần áo đắt tiền). Nếu sau 48 giờ bạn vẫn muốn mua nó, hãy cân nhắc xem nó có nằm trong ngân sách 30% sở thích không nhé!
''';
    }

    // 3. Biến động thị trường, vàng, lãi suất
    if (query.contains('thị trường') ||
        query.contains('biến động') ||
        query.contains('vàng') ||
        query.contains('lãi suất') ||
        query.contains('lạm phát') ||
        query.contains('cổ phiếu') ||
        query.contains('đầu tư') ||
        query.contains('đất')) {
      
      return '''
### 📈 TỔNG QUAN BIẾN ĐỘNG THỊ TRƯỜNG & TƯ VẤN ĐẦU TƯ (CẬP NHẬT)

Dưới đây là một số thông tin thị trường tài chính tham khảo:

| Tài sản | Trạng thái / Chỉ số | Xu hướng & Lời khuyên |
| :--- | :--- | :--- |
| **Vàng SJC** | ~82.5 - 84.5 triệu/lượng | Vàng biến động tăng nhẹ do tâm lý phòng ngừa rủi ro. Nên nắm giữ tối đa 10% tài sản bằng vàng vật chất để bảo toàn vốn. |
| **Lãi suất tiết kiệm** | Kỳ hạn 12 tháng: 5.5% - 6.2%/năm | Lãi suất ngân hàng có xu hướng đi ngang. Thích hợp cho dòng tiền nhàn rỗi muốn an toàn cao hoặc tích lũy quỹ dự phòng. |
| **Cổ phiếu (VN-Index)** | Dao động quanh vùng 1,220 - 1,280 điểm | Thị trường phân hóa mạnh. Nếu đầu tư cổ phiếu, hãy ưu tiên các nhóm ngành có nền tảng vững chắc (Ngân hàng, Công nghệ, Bán lẻ). |
| **Bất động sản** | Phục hồi nhẹ ở phân khúc chung cư | Giá bất động sản ở trung tâm vẫn neo cao. Phù hợp đầu tư dài hạn từ 3-5 năm, tránh đòn bẩy tài chính quá lớn thời điểm này. |

⚠️ **Khuyến nghị tài chính:** Trong bối cảnh lạm phát nhẹ (~3.2%), việc để toàn bộ tiền mặt trong ví sẽ khiến tiền bị mất giá trị mua sắm. Bạn hãy chia tài sản thành nhiều giỏ khác nhau:
1.  **Thanh khoản cao (Ví tiền mặt, Vietcombank):** Để chi tiêu sinh hoạt hàng ngày.
2.  **Quỹ dự phòng (Gửi tiết kiệm trực tuyến):** Chiếm từ 3 - 6 tháng chi phí sinh hoạt.
3.  **Tích sản (Vàng hoặc Chứng chỉ quỹ):** Đầu tư định kỳ hàng tháng để chống lạm phát.
''';
    }

    // 4. Đấu trí trà sữa / Thử thách
    if (query.contains('đấu trí') || query.contains('trà sữa') || query.contains('vun vén bot') || query.contains('thử thách')) {
      return '''
### 🎮 MẸO THẮNG "ĐẤU TRÍ TRÀ SỮA VỚI AI"

Bạn đang tham gia thử thách **"Đấu trí trà sữa với AI"** (đối đầu với Vun Vén Bot của tôi):
- **Ngân sách:** `300.000₫`
- **Tiền cược:** `100.000₫`
- **Hạn chót:** Chỉ còn vài ngày nữa!
- **Tình trạng hiện tại:** Bạn đã tiêu `120.000₫`, trong khi Vun Vén Bot mới chỉ tiêu `90.000₫`! Bạn đang bị tụt lại phía sau một chút đấy nhé!

#### 🏆 Làm sao để chiến thắng?
1.  **Cắt giảm hoàn toàn ăn vặt trong 3 ngày tới:** Hãy uống nước lọc hoặc tự pha trà ở cơ quan thay vì đặt trà sữa trên ứng dụng giao đồ ăn.
2.  **Ghi chép giao dịch ngay lập tức:** Đảm bảo mọi chi tiêu ăn vặt nhỏ nhất đều được ghi nhận để kiểm soát chặt chẽ ngân sách.
3.  **Sử dụng "Lá chắn bảo vệ":** Nếu bạn lỡ tiêu quá tay, hãy kiểm tra xem bạn có còn chiếc khiên nào trong kho đồ không để cứu nguy cho chuỗi ngày của mình nhé!
''';
    }

    // 5. Câu trả lời mặc định
    return '''
Tôi chưa hiểu rõ câu hỏi của bạn. Tôi là **Vún Vén AI**, trợ lý tài chính cá nhân của bạn. 

Bạn hãy thử hỏi tôi bằng cách nhấn vào các nút gợi ý nhanh ở dưới hoặc nhập các câu hỏi như:
- *"Báo cáo tài chính của tôi có ổn không?"*
- *"Hãy cho tôi lời khuyên tiết kiệm chi tiêu"*
- *"Tình hình giá vàng và thị trường hôm nay thế nào?"*
- *"Làm sao để thắng thử thách Đấu trí trà sữa?"*

*(Mẹo: Bạn có thể cài đặt **Gemini API Key** bằng cách bấm vào biểu tượng ⚙️ cài đặt ở góc trên bên phải để kích hoạt trí tuệ nhân tạo thông minh nhất!)*
''';
  }

  String _getCategoryName(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.food:
        return 'Ăn uống';
      case TransactionCategory.transport:
        return 'Đi lại';
      case TransactionCategory.shopping:
        return 'Mua sắm';
      case TransactionCategory.work:
        return 'Công việc';
      case TransactionCategory.health:
        return 'Sức khỏe';
      case TransactionCategory.entertainment:
        return 'Giải trí';
      default:
        return 'Khác';
    }
  }
}
