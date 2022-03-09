import 'dart:io';

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'models/chat_message.dart';
import 'models/chat_user.dart';
import 'conversation.dart';
import 'utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Isar
  final dir = await getApplicationSupportDirectory();
  final Isar _isar = await Isar.open(
      schemas: [ChatMessageSchema, ChatUserSchema], directory: dir.path);
  final chatMessages = await _isar.chatMessages.where().findAll();

  // Download files
  final modelDir = await downloadModelFiles("dialogpt-medium");

  runApp(ElizaApp(modelDir: modelDir, isar: _isar, chatMessages: chatMessages));
}

class ElizaApp extends StatelessWidget {
  const ElizaApp(
      {Key? key,
      required this.modelDir,
      required this.isar,
      required this.chatMessages})
      : super(key: key);

  final Directory modelDir;
  final Isar isar;
  final List<ChatMessage> chatMessages;

  static const String _title = 'Eliza';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: _title,
          home: MyStatefulWidget(
              modelDir: modelDir, isar: isar, chatMessages: chatMessages),
        ));
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget(
      {Key? key,
      required this.modelDir,
      required this.isar,
      required this.chatMessages})
      : super(key: key);

  final Directory modelDir;
  final Isar isar;
  final List<ChatMessage> chatMessages;

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: <Widget>[
          NavigationRail(
            backgroundColor: const Color(0xff1f2225),
            selectedLabelTextStyle: const TextStyle(color: Color(0xffffffff)),
            selectedIconTheme: const IconThemeData(color: Color(0xffffffff)),
            unselectedLabelTextStyle: const TextStyle(color: Color(0xff808183)),
            unselectedIconTheme: const IconThemeData(color: Color(0xff808183)),
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.selected,
            destinations: const <NavigationRailDestination>[
              NavigationRailDestination(
                icon: Icon(Icons.chat_bubble_outline),
                selectedIcon: Icon(Icons.chat_bubble),
                label: Text('Chat'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.library_books_outlined),
                selectedIcon: Icon(Icons.library_books),
                label: Text('Docs'),
              ),
            ],
          ),
          const VerticalDivider(
              thickness: 1, width: 1, color: Color(0xff474747)),
          // This is the main content.
          Expanded(
            child: ConversationHome(),
          )
        ],
      ),
    );
  }
}
