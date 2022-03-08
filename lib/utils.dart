import 'dart:developer' as logger;

import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

void downloadModelFiles() {
  final client = http.Client();

  final modelUrl = Uri.parse(
      "https://huggingface.co/dbmdz/bert-large-cased-finetuned-conll03-english/resolve/main/rust_model.ot");
  final configUrl = Uri.parse(
      "https://huggingface.co/bert-large-cased-whole-word-masking-finetuned-squad/resolve/main/config.json");
  final vocabUrl = Uri.parse(
      "https://huggingface.co/bert-large-cased-whole-word-masking-finetuned-squad/resolve/main/vocab.txt");
  final uris = [modelUrl, configUrl, vocabUrl];

  logger.log("[DOWNLOAD] Downloading model files..");
  uris.map((uri) async => {await client.get(uri)});
}

Future<File> download(String url, String filename) async {
  String appdir = (await getApplicationSupportDirectory()).path;
  final client = http.Client();
  final response = await client.get(Uri.parse(url));
  final bytes = response.bodyBytes;
  File file = File('$appdir/$filename');
  await file.writeAsBytes(bytes);
  return file;
}
