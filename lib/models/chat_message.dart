import 'package:isar/isar.dart';

part 'chat_message.g.dart';

@Collection()
class ChatMessage {
  @Id()
  int? id;

  late int createdAt;
  late String text;
  late String uuid;
  late String userUuid;
}
