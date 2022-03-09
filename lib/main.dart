import 'dart:io';

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'chat.dart';
import 'models/chat_message.dart';
import 'models/chat_user.dart';

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
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.selected,
            destinations: const <NavigationRailDestination>[
              NavigationRailDestination(
                icon: Icon(Icons.favorite_border),
                selectedIcon: Icon(Icons.favorite),
                label: Text('First'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.bookmark_border),
                selectedIcon: Icon(Icons.book),
                label: Text('Second'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.star_border),
                selectedIcon: Icon(Icons.star),
                label: Text('Third'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // This is the main content.
          Expanded(
            child: Center(
              child: Text('selectedIndex: $_selectedIndex'),
            ),
          )
        ],
      ),
    );
  }
}
