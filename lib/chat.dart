import 'dart:developer' as logger;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:bubble/bubble.dart';
import 'package:http/http.dart' as http;
import 'package:isar/isar.dart';

import 'models/chat_message.dart';
import 'ffi.dart';
import 'utils.dart';

class SolipsisChatHome extends StatefulWidget {
  const SolipsisChatHome(
      {Key? key,
      required this.modelDir,
      required this.isar,
      required this.chatMessages})
      : super(key: key);

  final Directory modelDir;
  final Isar isar;
  final List<ChatMessage> chatMessages;

  @override
  _SolipsisChatHomeState createState() => _SolipsisChatHomeState();
}

class _SolipsisChatHomeState extends State<SolipsisChatHome> {
  bool _showTyping = false;
  int _page = 0;

  List<types.Message> _messages = [];

  final _user = const types.User(id: '06c33e8b-e835-4736-80f4-63f44b66666c');
  final _bot = const types.User(id: '09778d0f-fb94-4ac6-8d72-96112805f3ad');

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < widget.chatMessages.length; i++) {
      setState(() {
        _messages.insert(
            0,
            types.TextMessage(
                author: types.User(id: widget.chatMessages[i].userUuid),
                id: widget.chatMessages[i].uuid,
                createdAt: widget.chatMessages[i].createdAt,
                text: widget.chatMessages[i].text));
      });
    }
  }

  Future<void> _handleEndReached() async {
    final uri = Uri.parse(
      'https://reqres.in/api/unknown?page=$_page&per_page=20',
    );
    final response = await http.get(uri);
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final data = json['data'] as List<dynamic>;
    logger.log('data: $data');
    final messages = data
        .map(
          (e) => types.TextMessage(
            author: _user,
            id: '$e["id"]',
            text: e['name'] as String,
          ),
        )
        .toList();
    logger.log('messages: $messages');
    setState(() {
      _messages = [..._messages, ...messages];
      _page = _page + 1;
    });
  }

  Future<void> _handleBotResponse(String text) async {
    final filesWereDownloaded =
        await verifyModelFilesDownloaded("dialogpt-medium");

    if (filesWereDownloaded == false) {
      logger.log("[WARNING] Files still downloading...");
      return;
    }

    _showTyping = true;
    final modelDirPath = widget.modelDir.path;
    final responseText = await api.chat(modelDirPath: modelDirPath, text: text);

    final message = types.TextMessage(
        author: _bot,
        createdAt: currentTimestamp(),
        id: randomString(),
        text: responseText);

    await Future.delayed(
        Duration(seconds: messageDelay(message)), () => _showTyping = false);

    _addMessage(message);
  }

  void _addMessage(types.TextMessage message) async {
    final newMessage = ChatMessage()
      ..createdAt = message.createdAt!
      ..userUuid = message.author.id
      ..uuid = message.id
      ..text = message.text;

    await widget.isar.writeTxn((isar) async {
      await isar.chatMessages.put(newMessage);
    });

    setState(() {
      _messages.insert(0, message);
    });
    logger.log('data: $message');
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: currentTimestamp(),
      id: randomString(),
      text: message.text,
    );

    _addMessage(textMessage);
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
      color: _user.id != message.author.id ||
              message.type == types.MessageType.image
          ? const Color(0xff2a2a2b)
          : const Color(0xff147efb),
      margin: nextMessageInGroup
          ? const BubbleEdges.symmetric(horizontal: 6)
          : null,
      nip: nextMessageInGroup
          ? BubbleNip.no
          : _user.id != message.author.id
              ? BubbleNip.leftBottom
              : BubbleNip.rightBottom,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Eliza"), backgroundColor: const Color(0xff8e8e93)),
      body: SafeArea(
        bottom: false,
        child: Chat(
          messages: _messages,
          onSendPressed: _handleSendPressed,
          user: _user,
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
