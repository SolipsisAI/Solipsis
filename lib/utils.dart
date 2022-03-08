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
  final downloaddir = await Directory('$appdirpath/cortex/models/distilbert-qa')
      .create(recursive: true);
  downloads.map((d) => download(d['url'], d['filename'], downloaddir.path));
}

Future<File> download(
    String? url, String? filename, String? downloaddir) async {
  final client = http.Client();
  final response = await client.get(Uri.parse(url!));
  final bytes = response.bodyBytes;
  String filepath = '$downloaddir/$filename';
  File file = File(filepath);
  await file.writeAsBytes(bytes);
  logger.log("[SUCCESS] Downloaded $filepath");
  return file;
}
