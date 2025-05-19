// lib/screens/chatbot_screen.dart
import 'package:flutter/material.dart';
// import 'package:provider/provider.dart'; // İleride ChatProvider için
// import 'package:flutter_application_1/providers/chat_provider.dart'; // İleride

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController(); // Mesajları otomatik aşağı kaydırmak için

  // Sahte mesaj listesi (UI testi için)
  final List<Map<String, String>> _messages = [
    {"sender": "Pati", "text": "Merhaba! Ben Pati, sana nasıl yardımcı olabilirim?"},
    // {"sender": "User", "text": "Kedim için mama önerisi istiyorum."},
  ];

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _messages.add({"sender": "User", "text": text});
        // [AI Entegrasyonu] Bu mesajı API'ye gönder ve Pati'nin yanıtını al
        // Şimdilik sahte bir yanıt ekleyelim
        _messages.add({"sender": "Pati", "text": "'$text' hakkında bilgi arıyorum..."});
      });
      _messageController.clear();
      // Yeni mesaj sonrası listenin sonuna kaydır
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pati ile Sohbet Et'),
        backgroundColor: Colors.orangeAccent, // Farklı bir renk
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final bool isUserMessage = message['sender'] == 'User';
                return Align(
                  alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                    padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
                    decoration: BoxDecoration(
                      color: isUserMessage ? Colors.teal.shade300 : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Text(
                      message['text']!,
                      style: TextStyle(color: isUserMessage ? Colors.white : Colors.black87),
                    ),
                  ),
                );
              },
            ),
          ),
          // Mesaj Giriş Alanı
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Pati\'ye bir şeyler yaz...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                    ),
                    onSubmitted: (value) => _sendMessage(), // Enter'a basınca gönder
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.teal),
                  onPressed: _sendMessage,
                  tooltip: 'Gönder',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}