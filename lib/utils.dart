import 'dart:developer' as logger;

import 'dart:io';
import 'dart:convert';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

const myUser = types.User(
    id: '06c33e8b-e835-4736-80f4-63f44b66666c',
    firstName: 'Al',
    lastName: 'Julian');
const botUser = types.User(
    id: '09778d0f-fb94-4ac6-8d72-96112805f3ad',
    firstName: 'Eliza',
    lastName: '');
const dummyUser = types.User(
    id: '6b340874-fd30-485e-b0ca-e04fb4030309',
    firstName: 'Grace',
    lastName: 'Hopper');

const String loremIpsumApiUrl =
    'https://litipsum.com/api/dr-jekyll-and-mr-hyde/1/json';
const int wordsPerMinute = 100;

const resources = {
  'distilbart-cnn-12-6': {
    'model': {
      'url':
          'https://huggingface.co/sshleifer/distilbart-cnn-12-6/resolve/main/rust_model.ot',
      'filename': 'rust_model.ot',
      'type': 'bytes',
    },
    'config': {
      'url':
          'https://cdn.huggingface.co/sshleifer/distilbart-cnn-12-6/config.json',
      'filename': 'config.json',
      'type': 'string',
    },
    'merges': {
      'url':
          'https://cdn.huggingface.co/sshleifer/distilbart-cnn-12-6/merges.txt',
      'filename': 'merges.txt',
      'type': 'string',
    },
    'vocab': {
      'url':
          'https://cdn.huggingface.co/sshleifer/distilbart-cnn-12-6/vocab.json',
      'filename': 'vocab.json',
      'type': 'string'
    }
  },
  'dialogpt-medium': {
    'model': {
      'url':
          'https://huggingface.co/microsoft/DialoGPT-medium/resolve/main/rust_model.ot',
      'filename': 'rust_model.ot',
      'type': 'bytes',
    },
    'merges': {
      'url':
          'https://huggingface.co/microsoft/DialoGPT-medium/resolve/main/merges.txt',
      'filename': 'merges.txt',
      'type': 'string',
    },
    'vocab': {
      'url':
          'https://huggingface.co/microsoft/DialoGPT-medium/resolve/main/vocab.json',
      'filename': 'vocab.json',
      'type': 'string',
    },
    'config': {
      'url':
          'https://huggingface.co/microsoft/DialoGPT-medium/resolve/main/config.json',
      'filename': 'config.json',
      'type': 'string',
    }
  }
};

Future<String> getModelDirPath(String modelName) async {
  String appdirpath = (await getApplicationSupportDirectory()).path;
  return '$appdirpath/cortex/models/$modelName';
}

Future<bool> verifyModelFilesDownloaded(String modelName) async {
  final resource = resources[modelName];

  // TODO: This is not correct
  if (resource == null) {
    return false;
  }

  var isDownloaded = true;

  final modelDirPath = await getModelDirPath(modelName);
  final modelDir = Directory(modelDirPath);

  if (modelDir.existsSync() == false) {
    return false;
  }

  for (var v in resource.values) {
    var file = File("$modelDirPath/${v['filename']}");
    if (file.existsSync() == false) {
      isDownloaded = false;
      break;
    }
  }

  return isDownloaded;
}

Future<Directory> downloadModelFiles(String modelName) async {
  String appdirpath = (await getApplicationSupportDirectory()).path;

  logger.log('[APPDIR] $appdirpath');

  final downloaddir = await Directory('$appdirpath/cortex/models/$modelName')
      .create(recursive: true);

  final resource = resources[modelName];

  if (resource != null) {
    for (var v in resource.values) {
      downloadFile(v['url'], v['filename'], v['type'], downloaddir.path);
    }
  } else {
    logger.log("[FAIL] Resource $modelName does not exist");
  }

  return downloaddir;
}

void downloadFile(
    String? url, String? filename, String? type, String? downloaddir) async {
  String filepath = '$downloaddir/$filename';

  logger.log('[DOWNLOAD] $url -> $filepath');

  if (File(filepath).existsSync()) {
    logger.log('[SKIP] Exists');
    return;
  }

  final client = http.Client();
  final response = await client.get(Uri.parse(url!));

  File file = File(filepath);

  if (type == 'bytes') {
    await file.writeAsBytes(response.bodyBytes);
  } else {
    await file.writeAsString(response.body);
  }

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
