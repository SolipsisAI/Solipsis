import 'dart:io';

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import 'chat.dart';
import 'models/chat_message.dart';
import 'utils.dart';
import 'layouts/two_columns.dart';

class ConversationHome extends StatefulWidget {
  const ConversationHome({Key? key, required this.modelDir, required this.isar})
      : super(key: key);

  final Directory modelDir;
  final Isar isar;

  @override
  _ConversationHomeState createState() => _ConversationHomeState();
}

class _ConversationHomeState extends State<ConversationHome> {
  List<types.User> items = [botUser, dummyUser, anotherUser];
  ValueNotifier<types.User?> _selected = ValueNotifier(null);

  void _selectValue(types.User? val) => _selected.value = val;
  void _clearSelected() => _selected.value = null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[300],
      body: ValueListenableBuilder(
        builder: (context, _, child) {
          return TwoColumns(
            paneProportion: 30,
            showPane2: (_selected.value != null) ? true : false,
            onClosePane2Popup: _clearSelected,
            pane1: ConversationList(
                recipient: _selected.value,
                items: items,
                selectValue: _selectValue),
            pane2: ConversationView(
              recipient: _selected.value,
              modelDir: widget.modelDir,
              isar: widget.isar,
            ),
          );
        },
        valueListenable: _selected,
      ),
    );
  }
}

class ConversationList extends StatelessWidget {
  const ConversationList({
    Key? key,
    this.recipient,
    required this.selectValue,
    required this.items,
  }) : super(key: key);

  final types.User? recipient;
  final void Function(types.User?) selectValue;
  final List<types.User> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xff232323),
      child: ListView(
        children: [
          ...items.map(
            (e) => Card(
              color: (recipient != null && e.id == recipient!.id)
                  ? const Color(0xff3a3a3a)
                  : const Color(0xff232323),
              child: ListTile(
                textColor: Colors.white,
                title: Text("${e.firstName} ${e.lastName}"),
                onTap: () => selectValue(e),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class ConversationView extends StatelessWidget {
  const ConversationView(
      {Key? key, this.recipient, required this.modelDir, required this.isar})
      : super(key: key);

  final types.User? recipient;
  final Directory modelDir;
  final Isar isar;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: recipient == null
            ? const Text("Click on a person")
            : SolipsisChatHome(
                key: ValueKey(recipient!.id),
                isar: isar,
                modelDir: modelDir,
                recipient: recipient));
  }
}
