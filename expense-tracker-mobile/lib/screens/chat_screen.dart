import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker_mobile/services/api_service.dart';
import 'package:expense_tracker_mobile/providers/user_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isTyping = false;
  int _quotaRemaining = -1; // -1 indicates loading

  @override
  void initState() {
    super.initState();
    _fetchQuota();
  }

  void _fetchQuota() async {
    try {
      final api = context.read<ApiService>();
      final user = context.read<UserProvider>().user;
      if (user != null) {
        final quota = await api.getChatStatus(user.id);
        if (mounted) {
          setState(() {
            _quotaRemaining = quota;
          });
        }
      }
    } catch (e) {
      // Ignore errors initially, will update on first message
    }
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    setState(() {
      _messages.add({"role": "user", "content": text});
      _isTyping = true;
    });
    _scrollToBottom();

    try {
      final api = context.read<ApiService>();
      final user = context.read<UserProvider>().user;
      
      if (user != null) {
        // Collect history: ["User: msg", "AI: response", ...]
        List<String> history = _messages
          .where((m) => m['role'] != 'user' || m['content'] != text) // Exclude current sending message from history to avoid dupes? No, _messages already has it.
          // Actually, we just want previous messages. 
          // But wait, we added current message to _messages at line 26 so it shows in UI.
          // The backend prompt uses history to set context. It appends "PREVIOUS HISTORY".
          // So we should send everything except the *current* user message we are sending to 'ask' API.
          // Because 'text' is the current userMessage key.
          .where((m) => m != _messages.last) // Rough way to exclude current
          .map((m) => "${m['role'] == 'user' ? 'User' : 'Assistant'}: ${m['content']}")
          .toList();

        final response = await api.sendMessage(user.id, text, history: history);
        setState(() {
          _messages.add({"role": "ai", "content": response['response']});
          _quotaRemaining = response['remainingQuota'];
          _isTyping = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({"role": "ai", "content": "Error: $e"});
          _isTyping = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Finance Assistant", style: TextStyle(color: Colors.white, fontSize: 16)),
            Text(
              _quotaRemaining == -1
                  ? "Quota: Checking..."
                  : "Quota: $_quotaRemaining messages left today",
               style: const TextStyle(color: Colors.grey, fontSize: 10)
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.auto_awesome, size: 48, color: Color(0xFF6366F1)),
                          const SizedBox(height: 16),
                          const Text(
                            "Ask me anything about your finances!",
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Here are some examples:",
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 24),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: [
                              _buildSuggestionChip("How much did I spend on Food?"),
                              _buildSuggestionChip("Do I have any unpaid bills?"),
                              _buildSuggestionChip("What is my highest expense this month?"),
                              _buildSuggestionChip("Show me recent Uber transactions"),
                              _buildSuggestionChip("Total spent on subscriptions?"),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isUser = msg['role'] == 'user';
                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(12),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                          decoration: BoxDecoration(
                            color: isUser ? const Color(0xFF6366F1) : const Color(0xFF334155),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(12),
                              topRight: const Radius.circular(12),
                              bottomLeft: isUser ? const Radius.circular(12) : const Radius.circular(0),
                              bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(12),
                            ),
                          ),
                          child: Text(
                            msg['content']!,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (_isTyping)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("AI is thinking...", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
              ),
            ),
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF1E293B),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Ask about your expenses...",
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 12),
                CircleAvatar(
                  backgroundColor: const Color(0xFF6366F1),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String label) {
    return ActionChip(
      label: Text(label, style: const TextStyle(color: Colors.white)),
      backgroundColor: const Color(0xFF334155),
      onPressed: () {
        _controller.text = label;
        _sendMessage();
      },
    );
  }
}
