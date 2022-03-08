import 'dart:developer' as logger;

import 'dart:io';
import 'dart:convert';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

const String loremIpsumApiUrl =
    'https://litipsum.com/api/dr-jekyll-and-mr-hyde/1/json';
const int wordsPerMinute = 100;
const modelUrl =
    "https://huggingface.co/dbmdz/bert-large-cased-finetuned-conll03-english/resolve/main/rust_model.ot";
const configUrl =
    "https://huggingface.co/bert-large-cased-whole-word-masking-finetuned-squad/resolve/main/config.json";
const vocabUrl =
    "https://huggingface.co/bert-large-cased-whole-word-masking-finetuned-squad/resolve/main/vocab.txt";
const downloads = [
  {'url': modelUrl, 'filename': 'rust_model.ot'},
  {'url': configUrl, 'filename': 'config.json'},
  {'url': vocabUrl, 'filename': 'vocab.txt'}
];

Future<String> getModelDirPath(String modelName) async {
  String appdirpath = (await getApplicationSupportDirectory()).path;
  return '$appdirpath/cortex/models/$modelName';
}

void downloadModelFiles() async {
  String appdirpath = (await getApplicationSupportDirectory()).path;
  logger.log(appdirpath);
  final downloaddir = await Directory('$appdirpath/cortex/models/distilbert-qa')
      .create(recursive: true);
  for (var i = 0; i < downloads.length; i++) {
    var download = downloads[i];
    logger.log("[DOWNLOAD] ${download['url']}");
    downloadFile(download['url'], download['filename'], downloaddir.path);
  }
}

void downloadFile(String? url, String? filename, String? downloaddir) async {
  String filepath = '$downloaddir/$filename';

  if (File(filepath).existsSync()) {
    return;
  }

  final client = http.Client();
  final response = await client.get(Uri.parse(url!));
  final bytes = response.bodyBytes;

  File file = File(filepath);

  await file.writeAsBytes(bytes);

  logger.log("[SUCCESS] Downloaded $filepath");
}

String randomString() {
  const uuid = Uuid();
  return uuid.v4();
}

int currentTimestamp() {
  return DateTime.now().millisecondsSinceEpoch;
}

Future<types.TextMessage> randomMessage(types.User user) async {
  final uri = Uri.parse(loremIpsumApiUrl);
  final response = await http.get(uri);
  final json = jsonDecode(response.body) as Map<String, dynamic>;
  final data = json['text'] as List<dynamic>;
  final text = data[0];
  return types.TextMessage(
    author: user,
    createdAt: DateTime.now().millisecondsSinceEpoch,
    id: randomString(),
    text: text,
  );
}

int messageDelay(types.TextMessage message) {
  final List words = message.text.split(" ");
  final int wordCount = words.length;
  return (wordCount ~/ wordsPerMinute) * 60;
}
