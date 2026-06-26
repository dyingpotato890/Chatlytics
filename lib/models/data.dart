import 'package:chatlytics/models/message.dart';
import 'package:chatlytics/models/streak_info.dart';

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
  Map<String, int> mostUsedCussWords;
  Map<String, int> cussWordsByLanguage;
  Map<String, int> personMostUsedCussWords;
  Map<String, int> mostUsedEmojies;
  Map<String, int> mostTalkedDays;
  Map<String, int> mostTalkedHours;
  Map<String, int> monthCount;
  Map<String, int> weekCount;
  Map<String, int> yearCount;
  int highestDayStreak;
  StreakInfo? longestStreak;
  List<StreakInfo> allStreaks;
  Map<String, List<Message>> messagesByDate; 
  Map<String, int> linksByPlatform;
  Map<String, int> linksSharedByUser;
  Map<String, int> avgResponseTime;
  Map<String, int> responseCount;

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
    required this.mostUsedCussWords,
    required this.cussWordsByLanguage,
    required this.personMostUsedCussWords,
    required this.mostUsedEmojies,
    required this.mostTalkedDays,
    required this.mostTalkedHours,
    required this.monthCount,
    required this.weekCount,
    required this.yearCount,
    required this.highestDayStreak,
    this.longestStreak,
    required this.allStreaks,
    required this.messagesByDate,
    required this.linksByPlatform,
    required this.linksSharedByUser,
    required this.avgResponseTime,
    required this.responseCount,
  });
}