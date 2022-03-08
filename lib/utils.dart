import 'dart:io' show Directory;
import 'dart:developer' as logger;

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
