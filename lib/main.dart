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

  // Download files
  final modelDir = await downloadAll();

  runApp(SolipsisApp(modelDir: modelDir, isar: _isar));
}

class SolipsisApp extends StatelessWidget {
  const SolipsisApp({Key? key, required this.modelDir, required this.isar})
      : super(key: key);

  final Directory modelDir;
  final Isar isar;

  static const String _title = 'Solipsis';

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
          home: MyStatefulWidget(modelDir: modelDir, isar: isar),
        ));
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key, required this.modelDir, required this.isar})
      : super(key: key);

  final Directory modelDir;
  final Isar isar;

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
            child: ConversationHome(
              modelDir: widget.modelDir,
              isar: widget.isar,
            ),
          )
        ],
      ),
    );
  }
}
