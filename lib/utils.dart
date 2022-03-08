import 'dart:developer' as logger;

import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

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
