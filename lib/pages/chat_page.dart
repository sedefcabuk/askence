import 'package:askence/widgets/answer_section.dart';
import 'package:askence/widgets/sources_section.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  final String question;
  const ChatPage({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Row(
          children: [
            const SizedBox(width: 100),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question,
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 24),
                    SourcesSection(),
                    SizedBox(height: 24),
                    AnswerSection(),
                  ],
                ),
              ),
            ),
            SizedBox(width: 100),
          ],
        ),
      ),
    );
  }
}
