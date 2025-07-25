import 'package:askence/pages/chat_page.dart';
import 'package:askence/services/chat_web_service.dart';
import 'package:askence/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchSection extends StatefulWidget {
  const SearchSection({super.key});

  @override
  State<SearchSection> createState() => _SearchSectionState();
}

class _SearchSectionState extends State<SearchSection> {
  final queryController = TextEditingController();

  @override
  void dispose() {
    queryController.dispose();
    super.dispose();
  }

  void _sendQuery() {
    final query = queryController.text.trim();
    if (query.isNotEmpty) {
      ChatWebService().chat(query);
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => ChatPage(question: query)),
      );
      queryController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Askence",
          style: GoogleFonts.ibmPlexMono(
            fontSize: 40,
            fontWeight: FontWeight.w400,
            height: 1.2,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 32),
        Container(
          width: 800,
          height: 109,
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.searchBarBorder, width: 1.5),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: TextField(
                  controller: queryController,
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
                  onSubmitted: (value) => _sendQuery(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(7.0),
                child: Row(
                  children: [
                    const Spacer(),
                    GestureDetector(
                      onTap: _sendQuery,
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
      ],
    );
  }
}
