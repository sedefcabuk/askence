import 'dart:async';
import 'package:askence/services/chat_web_service.dart';
import 'package:askence/theme/colors.dart';
import 'package:askence/widgets/search_bar_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';

class Message {
  final String text;
  final bool isUser;
  final bool isSource;
  final String? url;
  final List<Map<String, dynamic>>? sources; // Yeni alan
  Message({
    required this.text,
    this.isUser = false,
    this.isSource = false,
    this.url,
    this.sources,
  });
}

class ChatPage extends StatefulWidget {
  final String question;
  const ChatPage({super.key, required this.question});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Message> messages = [];
  final TextEditingController textEditingController = TextEditingController();
  final ChatWebService chatService = ChatWebService();
  StreamSubscription<Map<String, dynamic>>? _contentSubscription;
  StreamSubscription<Map<String, dynamic>>? _searchSubscription;
  bool isLoading = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // İlk soruyu ekle
    messages.add(Message(text: widget.question, isUser: true));
    // Stream’lere abone ol
    _contentSubscription = chatService.contentStream.listen(
      (data) {
        final chunk = data['data'];
        if (chunk == null) return;
        setState(() {
          if (messages.isNotEmpty &&
              !messages.last.isUser &&
              !messages.last.isSource) {
            // Mevcut cevaba ekle
            messages.last = Message(
              text: messages.last.text + chunk,
              isUser: false,
              isSource: false,
            );
          } else {
            // Yeni cevap ekle
            messages.add(Message(text: chunk, isUser: false));
          }
          isLoading = false;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          });
        });
      },
      onError: (error) {
        setState(() {
          messages.add(Message(text: "Hata: $error", isUser: false));
          isLoading = false;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          });
        });
      },
    );
    _searchSubscription = chatService.searchResultStream.listen(
      (data) {
        setState(() {
          messages.add(
            Message(
              text: '',
              isUser: false,
              isSource: true,
              sources: List<Map<String, dynamic>>.from(data['data']),
            ),
          );
          isLoading = false;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          });
        });
      },
      onError: (error) {
        setState(() {
          messages.add(Message(text: "Kaynak hatası: $error", isUser: false));
          isLoading = false;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          });
        });
      },
    );
    // İlk soruyu gönder
    chatService.chat(widget.question);
  }

  @override
  void dispose() {
    _contentSubscription?.cancel();
    _searchSubscription?.cancel();
    textEditingController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (textEditingController.text.isNotEmpty) {
      setState(() {
        messages.add(Message(text: textEditingController.text, isUser: true));
        isLoading = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      });
      chatService.chat(textEditingController.text);
      textEditingController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(24.0),
              itemCount: messages.length + (isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length && isLoading) {
                  return const Skeletonizer(
                    enabled: true,
                    child: Text('Yükleniyor...'),
                  );
                }
                final message = messages[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: message.isUser
                      ? Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.cardColor,
                              border: Border.all(width: 1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              message.text,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        )
                      : message.isSource
                      ? Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: (message.sources ?? []).map((res) {
                            return Container(
                              width: 150,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.cardColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    res['title'] ?? 'No title',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (res['url'] != null) ...[
                                    const SizedBox(height: 8),
                                    GestureDetector(
                                      onTap: () =>
                                          launchUrl(Uri.parse(res['url'])),
                                      child: Text(
                                        res['url'],
                                        style: const TextStyle(
                                          color: Colors.blue,
                                          fontSize: 12,
                                          decoration: TextDecoration.underline,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          }).toList(),
                        )
                      : Markdown(
                          data: message.text.isEmpty ? "_" : message.text,
                          shrinkWrap: true,
                          styleSheet:
                              MarkdownStyleSheet.fromTheme(
                                Theme.of(context),
                              ).copyWith(
                                codeblockDecoration: BoxDecoration(
                                  color: AppColors.cardColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                code: const TextStyle(fontSize: 16),
                              ),
                        ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(7.0),
            child: Container(
              width: 800,
              height: 109,
              decoration: BoxDecoration(
                color: AppColors.cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.searchBarBorder,
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: textEditingController,
                      decoration: InputDecoration(
                        hintText: "Ask anything...",
                        hintStyle: TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onSubmitted: (value) => _sendMessage(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        SearchBarButton(icon: Icons.add, text: 'Attach'),
                        const Spacer(),
                        GestureDetector(
                          onTap: _sendMessage,
                          child: Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: AppColors.submitButton,
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: Icon(
                              Icons.arrow_forward,
                              color: AppColors.background,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
