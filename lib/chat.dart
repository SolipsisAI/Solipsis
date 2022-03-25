import 'dart:developer' as logger;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:bubble/bubble.dart';
import 'package:isar/isar.dart';

import 'models/chat_message.dart';
import 'ffi.dart';
import 'utils.dart';

class SolipsisChatHome extends StatefulWidget {
  const SolipsisChatHome(
      {Key? key, this.recipient, required this.modelDir, required this.isar})
      : super(key: key);

  final types.User? recipient;

  final Directory modelDir;
  final Isar isar;

  @override
  _SolipsisChatHomeState createState() => _SolipsisChatHomeState();
}

class _SolipsisChatHomeState extends State<SolipsisChatHome> {
  bool _showTyping = false;
  int _page = 0;
  final List<types.TextMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    loadMessages();
  }

  Future<List<ChatMessage>> getChatMessages() async {
    if (widget.recipient == null) {
      return [];
    }

    final results = await widget.isar.chatMessages
        .filter()
        .recipientUuidEqualTo(widget.recipient!.id)
        .sortByCreatedAtDesc()
        .limit(10)
        .findAll();

    results.sort(((a, b) => a.createdAt.compareTo(b.createdAt)));

    return results;
  }

  Future<void> loadMessages() async {
    if (widget.recipient == null) return;

    if (_messages.isNotEmpty &&
        _messages.last.author.id == widget.recipient!.id) {
      return;
    }

    final chatMessages = await getChatMessages();

    final results = chatMessages.map((e) => convertMessage(e));

    if (mounted) {
      for (var message in results) {
        setState(() {
          _addMessage(message, false);
        });
      }
    }

    logger.log("[MESSAGES] Added message ${results.length}");
  }

  Future<void> _handleEndReached() async {
    // final uri = Uri.parse(
    //   'https://reqres.in/api/unknown?page=$_page&per_page=20',
    // );
    // final response = await http.get(uri);
    // final json = jsonDecode(response.body) as Map<String, dynamic>;
    // final data = json['data'] as List<dynamic>;
    // logger.log('data: $data');
    // final messages = data
    //     .map(
    //       (e) => types.TextMessage(
    //         author: myUser,
    //         id: '$e["id"]',
    //         text: e['name'] as String,
    //       ),
    //     )
    //     .toList();
    // logger.log('messages: $messages');
    // setState(() {
    //   messages = [..._messages, ...messages];
    //   _page = _page + 1;
    // });
  }

  Future<void> _handleBotResponse(String text) async {
    if (widget.recipient == null) {
      return;
    }

    final filesWereDownloaded =
        await verifyModelFilesDownloaded("dialogpt-medium");

    if (filesWereDownloaded == false) {
      logger.log("[WARNING] Files still downloading...");
      return;
    }

    final modelDirPath = widget.modelDir.path;

    _showTyping = true;

    final responseText = await api.chat(text: text);

    final message = types.TextMessage(
        author: widget.recipient!,
        createdAt: currentTimestamp(),
        id: randomString(),
        text: responseText);

    _showTyping = false;

    _addMessage(message, true);
  }

  void _addMessage(types.TextMessage message, bool write) async {
    final newMessage = ChatMessage()
      ..createdAt = message.createdAt!
      ..authorUuid = message.author.id
      ..uuid = message.id
      ..text = message.text
      ..recipientUuid = widget.recipient!.id;

    if (write == true) {
      await widget.isar.writeTxn((isar) async {
        await isar.chatMessages.put(newMessage);
      });
    }

    if (mounted) {
      setState(() {
        _messages.insert(0, message);
      });
    }
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: myUser,
      createdAt: currentTimestamp(),
      id: randomString(),
      text: message.text,
    );

    _addMessage(textMessage, true);
    _handleBotResponse(message.text);
  }

  Widget _bubbleBuilder(
    Widget child, {
    required message,
    required nextMessageInGroup,
  }) {
    return Bubble(
      radius: const Radius.circular(15),
      child: child,
      color: myUser.id != message.author.id ||
              message.type == types.MessageType.image
          ? const Color(0xff2a2a2b)
          : const Color(0xff147efb),
      margin: nextMessageInGroup
          ? const BubbleEdges.symmetric(horizontal: 6)
          : null,
      nip: nextMessageInGroup
          ? BubbleNip.no
          : myUser.id != message.author.id
              ? BubbleNip.leftBottom
              : BubbleNip.rightBottom,
    );
  }

  @override
  Widget build(BuildContext context) {
    String userName =
        widget.recipient != null && widget.recipient!.firstName != null
            ? "${widget.recipient!.firstName}"
            : "";
    return Scaffold(
      appBar: AppBar(
          title: Text(userName), backgroundColor: const Color(0xff212429)),
      endDrawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Drawer Header'),
            ),
            ListTile(
              title: const Text('Item 1'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Item 2'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Chat(
          messages: _messages,
          onSendPressed: _handleSendPressed,
          user: myUser,
          bubbleBuilder: _bubbleBuilder,
          onEndReached: _handleEndReached,
          showTyping: _showTyping,
          showUserAvatars: true,
          showUserNames: true,
          theme: const DarkChatTheme(
              backgroundColor: Color(0xff171717),
              receivedMessageBodyTextStyle: TextStyle(
                  color: neutral7,
                  fontSize: 13,
                  fontWeight: FontWeight.w300,
                  height: 1.5),
              sentMessageBodyTextStyle: TextStyle(
                  color: neutral7,
                  fontSize: 13,
                  fontWeight: FontWeight.w300,
                  height: 1.5),
              inputTextStyle: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w300,
                height: 1.5,
              ),
              inputBackgroundColor: Color(0xff2d2d2d),
              inputMargin: EdgeInsets.all(10),
              inputBorderRadius: BorderRadius.all(Radius.circular(25))),
        ),
      ),
    );
  }
}
