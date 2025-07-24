import 'package:askence/services/chat_web_service.dart';
import 'package:askence/widgets/search_section.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    ChatWebService().connect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          //SideBar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(children: [Expanded(child: SearchSection())]),
            ),
          ),
        ],
      ),
    );
  }
}
