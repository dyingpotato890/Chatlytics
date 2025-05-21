import 'package:chatlytics/models/message.dart';

class Data {
  int messageCount;
  int wordCount;
  Map<String, int> userMessagesCount;
  int mediaShared;
  int activeDays;
  int participants;
  Message firstMessage;
  Message lastMessage;
  Map<String, int> mostUsedWords;
  Map<String, int> mostUsedEmojies;
  Map<String, int> mostTalkedDays;
  Map<String, int> mostTalkedHours;

  Data({
    required this.messageCount,
    required this.wordCount,
    required this.userMessagesCount,
    required this.mediaShared,
    required this.activeDays,
    required this.participants,
    required this.firstMessage,
    required this.lastMessage,
    required this.mostUsedWords,
    required this.mostUsedEmojies,
    required this.mostTalkedDays,
    required this.mostTalkedHours,
  });
}
