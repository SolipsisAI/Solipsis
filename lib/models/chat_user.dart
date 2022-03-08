import 'package:isar/isar.dart';

part 'chat_user.g.dart';

@Collection()
class ChatUser {
  @Id()
  int? id;

  late int createdAt;
  late int updatedAt;
  late String nick;
  late String firstName;
  late String lastName;
  late String imageUrl;
  late String uuid;
}
