import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../services/app_state.dart';
import '../../services/chatbot_service.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final ChatbotService _chatbotService = ChatbotService();
  final AppState _appState = AppState();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _chatbotService.addListener(_onServiceChange);
    _appState.addListener(_onAppStateChange);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom(isAnimated: false));
  }

  @override
  void dispose() {
    _chatbotService.removeListener(_onServiceChange);
    _appState.removeListener(_onAppStateChange);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onServiceChange() {
    if (mounted) {
      setState(() {});
      _scrollToBottom();
    }
  }

  void _onAppStateChange() {
    if (mounted) {
      setState(() {});
    }
  }

  void _scrollToBottom({bool isAnimated = true}) {
    if (_scrollController.hasClients) {
      if (isAnimated) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    }
  }

  void _handleSend() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    _chatbotService.sendMessage(text);
  }

  void _handleSuggestion(String text) {
    _chatbotService.sendMessage(text);
  }

  void _showSettingsDialog() {
    final keyController = TextEditingController(text: _appState.geminiApiKey);
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              const Icon(Icons.settings_suggest_rounded, color: AppColors.primary),
              const SizedBox(width: 10),
              Text(
                'Cấu hình Gemini AI',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nhập Gemini API Key của bạn để mở khóa chế độ Siêu trí tuệ nhân tạo (Gemini 1.5 Flash):',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.textSecondary : AppColors.textSecondaryOnLight,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: keyController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Gemini API Key',
                  hintText: 'AIzaSy...',
                  prefixIcon: const Icon(Icons.vpn_key_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '💡 Bạn chưa có API Key? Hãy truy cập Google AI Studio để tạo khóa miễn phí:',
                style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: isDark ? AppColors.textMuted : AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () {
                  // Hiển thị thông báo copy link
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vui lòng truy cập: https://aistudio.google.com/ để lấy API Key miễn phí.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Text(
                  'https://aistudio.google.com/',
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 12,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Hủy',
                style: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final key = keyController.text.trim();
                await _appState.updateGeminiApiKey(key);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(key.isEmpty
                          ? 'Đã chuyển về Trợ lý Ngoại tuyến.'
                          : 'Cập nhật Gemini API Key thành công! Đã kích hoạt Siêu AI.'),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Lưu cấu hình'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAiMode = _appState.geminiApiKey.isNotEmpty;
    final messages = _chatbotService.history;
    final isLoading = _chatbotService.isLoading;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: _buildAppBar(isDark, isAiMode),
      body: Column(
        children: [
          // Chat messages list
          Expanded(
            child: messages.isEmpty
                ? const Center(child: Text('Chưa có tin nhắn nào.'))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return _buildMessageBubble(message, isDark);
                    },
                  ),
          ),

          // Loading/Typing Indicator
          if (isLoading) _buildTypingIndicator(isDark),

          // Quick suggestion list (horizontal scrolling)
          if (!isLoading) _buildSuggestionsList(isDark),

          const SizedBox(height: 8),

          // Message input bar
          _buildInputBar(isDark),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark, bool isAiMode) {
    return AppBar(
      elevation: 0,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: isDark ? Colors.white : AppColors.textOnLight,
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          // Glowing avatar for Bot
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isAiMode
                    ? [Colors.cyan.shade700, AppColors.primary]
                    : [AppColors.primary, AppColors.primaryLight],
              ),
              boxShadow: [
                BoxShadow(
                  color: (isAiMode ? Colors.cyan : AppColors.primary).withValues(alpha: 0.3),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Center(
              child: Text(
                '🤖',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vún Vén AI',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textOnLight,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isAiMode ? Colors.cyanAccent : AppColors.secondary,
                      boxShadow: [
                        BoxShadow(
                          color: (isAiMode ? Colors.cyanAccent : AppColors.secondary).withValues(alpha: 0.5),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isAiMode ? 'Siêu AI đang chạy' : 'Trợ lý Ngoại tuyến',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isAiMode ? Colors.cyanAccent : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.delete_sweep_rounded,
            color: isDark ? Colors.white70 : AppColors.textSecondaryOnLight,
          ),
          tooltip: 'Xóa hội thoại',
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: const Text('Làm mới hội thoại?'),
                content: const Text('Toàn bộ lịch sử trò chuyện sẽ được dọn sạch.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Hủy', style: TextStyle(color: isDark ? Colors.white60 : Colors.black54)),
                  ),
                  TextButton(
                    onPressed: () {
                      _chatbotService.clearHistory();
                      Navigator.pop(context);
                    },
                    child: const Text('Đồng ý', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        ),
        IconButton(
          icon: Icon(
            Icons.settings_rounded,
            color: isAiMode
                ? Colors.cyanAccent
                : (isDark ? Colors.white70 : AppColors.textSecondaryOnLight),
          ),
          tooltip: 'Cài đặt API Key',
          onPressed: _showSettingsDialog,
        ),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isDark) {
    final isUser = message.isUser;
    final align = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor = isUser
        ? AppColors.primary
        : (isDark ? AppColors.darkCard : AppColors.lightCard);
    
    final radius = isUser
        ? const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(4),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(20),
          );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: align,
        children: [
          // Label sender
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Text(
              isUser ? 'Bạn' : 'Vún Vén AI',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textMuted : AppColors.textMuted,
              ),
            ),
          ),
          // Bubble body
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.85,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: radius,
              border: isUser
                  ? null
                  : Border.all(
                      color: isDark
                          ? AppColors.darkBorder.withValues(alpha: 0.5)
                          : AppColors.lightBorder,
                      width: 1,
                    ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: MarkdownText(
              text: message.text,
              isUser: isUser,
            ),
          ),
          // Timestamp
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 8, right: 8),
            child: Text(
              DateFormat('HH:mm').format(message.timestamp),
              style: TextStyle(
                fontSize: 9,
                color: AppColors.textMuted.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'AI đang suy nghĩ...',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textSecondary : AppColors.textSecondaryOnLight,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsList(bool isDark) {
    final suggestions = [
      {'title': '📊 Báo cáo tài chính', 'query': 'Báo cáo tài chính của tôi'},
      {'title': '💡 Lời khuyên tiết kiệm', 'query': 'Cho tôi lời khuyên tiết kiệm chi tiêu'},
      {'title': '📈 Biến động thị trường', 'query': 'Biến động thị trường hôm nay thế nào?'},
      {'title': '🎮 Mẹo Đấu Trí AI', 'query': 'Làm sao thắng Đấu Trí Trà Sữa với AI?'},
    ];

    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final item = suggestions[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ActionChip(
              label: Text(
                item['title']!,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.textPrimary : AppColors.textOnLight,
                ),
              ),
              backgroundColor: isDark ? AppColors.darkCard : Colors.white,
              side: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                width: 1,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              onPressed: () => _handleSuggestion(item['query']!),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBg : AppColors.lightBg,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder.withValues(alpha: 0.5) : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _messageController,
                style: TextStyle(color: isDark ? Colors.white : AppColors.textOnLight),
                onSubmitted: (_) => _handleSend(),
                decoration: const InputDecoration(
                  hintText: 'Nhập câu hỏi tài chính...',
                  hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Send button
          GestureDetector(
            onTap: _handleSend,
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
              ),
              child: const Center(
                child: Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Markdown renderer to avoid dependency build errors
class MarkdownText extends StatelessWidget {
  final String text;
  final bool isUser;

  const MarkdownText({super.key, required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = isUser ? Colors.white : theme.textTheme.bodyLarge?.color ?? Colors.white;

    final lines = text.split('\n');
    final List<Widget> children = [];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.trim().isEmpty) {
        children.add(const SizedBox(height: 6));
        continue;
      }

      // Check for headers (e.g., ### Header)
      if (line.startsWith('### ')) {
        children.add(Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 4),
          child: Text(
            line.substring(4),
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isUser ? Colors.white : AppColors.secondary,
            ),
          ),
        ));
      } else if (line.startsWith('#### ')) {
        children.add(Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 2),
          child: Text(
            line.substring(5),
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isUser ? Colors.white : AppColors.primaryLight,
            ),
          ),
        ));
      }
      // Check for bullet list (e.g., * item or - item)
      else if (line.trim().startsWith('* ') ||
          line.trim().startsWith('- ') ||
          line.trim().startsWith('• ')) {
        final rawLine = line.trim();
        final content = rawLine.substring(2);
        children.add(Padding(
          padding: const EdgeInsets.only(left: 8, top: 2, bottom: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("• ", style: TextStyle(color: textColor, fontSize: 13)),
              Expanded(
                child: RichText(
                  text: _parseInlineStyles(content, textColor),
                ),
              ),
            ],
          ),
        ));
      }
      // Check for simple table rows
      else if (line.trim().startsWith('|') && i < lines.length) {
        final cells = line.split('|').map((c) => c.trim()).where((c) => c.isNotEmpty).toList();
        // Separator row (e.g. | :--- | --- |)
        if (cells.every(
            (cell) => cell.startsWith('---') || cell.startsWith(':---') || cell.startsWith('---:'))) {
          continue;
        }
        children.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: isUser ? Colors.white10 : Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: cells.map((cell) {
                // If it looks like a header cell, make it bold
                final isHeaderCell = i == 2 || (i > 0 && lines[i - 1].contains('---'));
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: RichText(
                      text: _parseInlineStyles(
                        cell,
                        textColor,
                        forceBold: isHeaderCell,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ));
      }
      // Plain text with bold support
      else {
        children.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: RichText(
            text: _parseInlineStyles(line, textColor),
          ),
        ));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  TextSpan _parseInlineStyles(String text, Color baseColor, {bool forceBold = false}) {
    final List<TextSpan> spans = [];
    // Matches **bold** or `code` or normal text
    final regExp = RegExp(r'(\*\*([^*]+)\*\*|`([^`]+)`|([^*`]+))');
    final matches = regExp.allMatches(text);

    for (final match in matches) {
      if (match.group(2) != null) {
        // Bold text
        spans.add(TextSpan(
          text: match.group(2),
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: baseColor,
          ),
        ));
      } else if (match.group(3) != null) {
        // Code text (monospace font)
        spans.add(TextSpan(
          text: match.group(3),
          style: GoogleFonts.firaCode(
            backgroundColor: isUser ? Colors.white24 : Colors.black.withValues(alpha: 0.06),
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isUser ? Colors.white : AppColors.primaryDark,
          ),
        ));
      } else if (match.group(4) != null) {
        // Normal text
        spans.add(TextSpan(
          text: match.group(4),
          style: GoogleFonts.inter(
            fontWeight: forceBold ? FontWeight.bold : FontWeight.normal,
            color: baseColor,
          ),
        ));
      }
    }

    if (spans.isEmpty) {
      spans.add(TextSpan(text: text, style: GoogleFonts.inter(color: baseColor)));
    }

    return TextSpan(
      style: GoogleFonts.inter(
        color: baseColor,
        fontSize: 13.5,
        height: 1.45,
      ),
      children: spans,
    );
  }
}
