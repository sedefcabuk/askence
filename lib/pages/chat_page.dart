import 'dart:async';
import 'package:askence/services/chat_web_service.dart';
import 'package:askence/theme/colors.dart';
import 'package:askence/widgets/loading_dots.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class Message {
  final String text;
  final bool isUser;
  final bool isSource;
  final String? url;
  final List<Map<String, dynamic>>? sources;

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
    messages.add(Message(text: widget.question, isUser: true));
    _contentSubscription = chatService.contentStream.listen(
      (data) {
        final chunk = data['data'];
        if (chunk == null) return;
        setState(() {
          if (messages.isNotEmpty &&
              !messages.last.isUser &&
              !messages.last.isSource) {
            messages.last = Message(
              text: messages.last.text + chunk,
              isUser: false,
              isSource: false,
            );
          } else {
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
        });
      },
      onError: (error) {
        setState(() {
          messages.add(Message(text: "Kaynak hatası: $error", isUser: false));
          isLoading = false;
        });
      },
    );

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
      appBar: kIsWeb
          ? null // Web platformundaysa AppBar yok
          : PreferredSize(
              preferredSize: const Size.fromHeight(55),
              child: SafeArea(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.sideNav, // rengini burada belirle
                    borderRadius: BorderRadius.circular(10), // dairesellik
                  ),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: Row(
                    children: [
                      // Dairesel Geri Butonu
                      Container(
                        decoration: BoxDecoration(
                          // buton arka plan rengi
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                          ),
                          onPressed: () async {
                            await _contentSubscription?.cancel();
                            await _searchSubscription?.cancel();
                            // ignore: use_build_context_synchronously
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Eğer sağ üst köşeye buton istersen buraya eklenebilir
                    ],
                  ),
                ),
              ),
            ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(24.0),
              itemCount: messages.length + (isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length && isLoading) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: LoadingDots(),
                    ),
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
                          children: (message.sources ?? [])
                              .map((res) => SourceCard(source: res))
                              .toList(),
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

// 🔻 Hover'lı, clickable kaynak kartı
class SourceCard extends StatefulWidget {
  final Map<String, dynamic> source;
  const SourceCard({super.key, required this.source});

  @override
  State<SourceCard> createState() => _SourceCardState();
}

class _SourceCardState extends State<SourceCard> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    final res = widget.source;
    return MouseRegion(
      onEnter: (_) => setState(() => isHovering = true),
      onExit: (_) => setState(() => isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if (res['url'] != null) {
            launchUrl(Uri.parse(res['url']));
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 150,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isHovering
                ? AppColors
                      .proButton // hover'da koyulaşan renk
                : AppColors.cardColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isHovering
                ? [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                res['title'] ?? 'No title',
                style: const TextStyle(fontWeight: FontWeight.w500),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (res['url'] != null) ...[
                const SizedBox(height: 8),
                Text(
                  res['url'],
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 12,
                    decoration: TextDecoration.underline,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
