import 'dart:io';

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import 'chat.dart';
import 'models/chat_message.dart';
import 'models/chat_user.dart';
import 'utils.dart';
import 'layouts/two_columns.dart';

class ConversationHome extends StatefulWidget {
  const ConversationHome(
      {Key? key,
      required this.modelDir,
      required this.isar,
      required this.chatMessages})
      : super(key: key);

  final Directory modelDir;
  final Isar isar;
  final List<ChatMessage> chatMessages;

  @override
  _ConversationHomeState createState() => _ConversationHomeState();
}

class _ConversationHomeState extends State<ConversationHome> {
  List<types.User> items = [botUser];
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
            pane1: ConversationList(items: items, selectValue: _selectValue),
            pane2: ConversationView(value: _selected.value),
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
    required this.selectValue,
    required this.items,
  }) : super(key: key);

  final void Function(types.User?) selectValue;
  final List<types.User> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView(
        children: [
          ...items.map(
            (e) => Card(
              child: ListTile(
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
  final types.User? value;

  const ConversationView({Key? key, this.value}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 48.0),
        child: Padding(
            padding: const EdgeInsets.all(48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Item card',
                  style: Theme.of(context)
                      .textTheme
                      .headline5!
                      .copyWith(color: Colors.blue[300]),
                ),
                SizedBox(height: 48),
                (value != null)
                    ? Text('User ${value!.id}')
                    : Text(
                        'No Selected value .',
                        style: Theme.of(context)
                            .textTheme
                            .bodyText2!
                            .copyWith(color: Colors.red[300]),
                      ),
              ],
            )),
      ),
    );
  }
}
