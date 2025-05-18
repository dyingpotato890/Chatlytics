import 'dart:io';
import 'package:chatlytics/models/data.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:path_provider/path_provider.dart';

class Whatsapp {
  final RegExp messageLineRegex = RegExp(
    r'^(\d{1,2}/\d{1,2}/\d{2,4}),\s(\d{1,2}:\d{2}(?:\s?[ap]m)?)\s-\s([^:]+)(?::\s(.+))?$',
    caseSensitive: false,
  );

  // Media detection regex
  final RegExp mediaRegex = RegExp(
    r'<Media omitted>|image omitted|video omitted|audio omitted|sticker omitted|document omitted|GIF omitted',
    caseSensitive: false,
  );

  // Emoji detection regex (simplified version)
  final RegExp emojiRegex = RegExp(
    r'[\u{1F600}-\u{1F64F}|\u{1F300}-\u{1F5FF}|\u{1F680}-\u{1F6FF}|\u{2600}-\u{26FF}|\u{2700}-\u{27BF}|\u{1F900}-\u{1F9FF}|\u{1F1E0}-\u{1F1FF}]',
    unicode: true,
  );

  Data messageData = Data(
    messageCount: 0,
    wordCount: 0,
    userMessagesCount: {},
    mediaShared: 0,
    activeDays: 0,
    participants: 0,
    mostUsedWords: {},
    mostUsedEmojies: {},
    mostTalkedDays: {},
    mostTalkedHours: {},
  );

  // Set to track unique days for active days count
  final Set<String> uniqueDays = {};
  // Set to track unique participants
  final Set<String> uniqueParticipants = {};

  Future<List<String>> extractZipAndReadTxt(String zipPath) async {
    try {
      // Get a directory to extract files
      final outputDir = await getTemporaryDirectory();
      final destinationDir = Directory('${outputDir.path}/extracted');
      if (!destinationDir.existsSync()) {
        destinationDir.createSync(recursive: true);
      }

      // Extract the zip file
      final zipFile = File(zipPath);
      await ZipFile.extractToDirectory(
        zipFile: zipFile,
        destinationDir: destinationDir,
      );

      // Find the .txt file
      final txtFile = destinationDir
          .listSync(recursive: true)
          .whereType<File>()
          .firstWhere((f) => f.path.endsWith('.txt'), orElse: () => File(''));

      if (txtFile.path.isEmpty || !(await txtFile.exists())) {
        return ["No .txt file found in archive."];
      }

      // Read line by line
      final lines = await txtFile.readAsLines();
      return lines;
    } catch (e) {
      return [e.toString()];
    }
  }

  void processMessage(String date, String time, String sender, String? message) {
    messageData.messageCount++;
    
    // Unique User
    uniqueParticipants.add(sender);
    messageData.participants = uniqueParticipants.length;
    
    // Track user message counts
    if (!messageData.userMessagesCount.containsKey(sender)) {
      messageData.userMessagesCount[sender] = 1;
    } else {
      messageData.userMessagesCount[sender] = messageData.userMessagesCount[sender]! + 1;
    }
    
    // Process date and time metrics
    String dayKey = date;
    String hourKey = time.split(':')[0];
    
    // Track unique days
    uniqueDays.add(dayKey);
    messageData.activeDays = uniqueDays.length;
    
    // Most talked days
    if (!messageData.mostTalkedDays.containsKey(dayKey)) {
      messageData.mostTalkedDays[dayKey] = 1;
    } else {
      messageData.mostTalkedDays[dayKey] = messageData.mostTalkedDays[dayKey]! + 1;
    }
    
    // Most talked hours
    if (!messageData.mostTalkedHours.containsKey(hourKey)) {
      messageData.mostTalkedHours[hourKey] = 1;
    } else {
      messageData.mostTalkedHours[hourKey] = messageData.mostTalkedHours[hourKey]! + 1;
    }
    
    // Process message content if available
    if (message != null && message.isNotEmpty) {
      // Check for media
      if (mediaRegex.hasMatch(message)) {
        messageData.mediaShared++;
      } else {
        // Count words
        List<String> words = message.split(RegExp(r'\s+'));
        messageData.wordCount += words.length;
        
        // Process most used words
        for (String word in words) {
          String cleanWord = word.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
          if (cleanWord.isNotEmpty && cleanWord.length > 3) { // Skip very short words
            if (!messageData.mostUsedWords.containsKey(cleanWord)) {
              messageData.mostUsedWords[cleanWord] = 1;
            } else {
              messageData.mostUsedWords[cleanWord] = messageData.mostUsedWords[cleanWord]! + 1;
            }
          }
        }
        
        // Process emojis
        final emojis = emojiRegex.allMatches(message);
        for (Match emoji in emojis) {
          String emojiChar = emoji.group(0)!;
          if (!messageData.mostUsedEmojies.containsKey(emojiChar)) {
            messageData.mostUsedEmojies[emojiChar] = 1;
          } else {
            messageData.mostUsedEmojies[emojiChar] = messageData.mostUsedEmojies[emojiChar]! + 1;
          }
        }
      }
    }
  }

  Future<Data> getAttributes(String? filePath) async {
    try {
      filePath = filePath ?? "";

      if (filePath.isNotEmpty) {
        final List<String> content = await extractZipAndReadTxt(filePath);
        String? currentDate, currentTime, currentSender;
        String currentMessage = "";
        bool inMultiLineMessage = false;

        for (var line in content) {
          if (messageLineRegex.hasMatch(line)) {
            // If we were processing a multiline message, finalize it before starting new one
            if (inMultiLineMessage && currentDate != null && currentSender != null) {
              processMessage(currentDate, currentTime!, currentSender, currentMessage);
            }
            
            // Start new message
            final match = messageLineRegex.firstMatch(line)!;
            currentDate = match.group(1);
            currentTime = match.group(2);
            currentSender = match.group(3)?.trim();
            currentMessage = match.group(4) ?? "";
            inMultiLineMessage = true;
          } else if (inMultiLineMessage) {
            // This is a continuation of the previous message
            currentMessage += "\n$line";
          }
        }
        
        // Process the last message if there was one
        if (inMultiLineMessage && currentDate != null && currentSender != null) {
          processMessage(currentDate, currentTime!, currentSender, currentMessage);
        }
        
        // Sort the maps by value in descending order to get "most used"
        messageData.mostUsedWords = _sortMapByValueDesc(messageData.mostUsedWords);
        messageData.mostUsedEmojies = _sortMapByValueDesc(messageData.mostUsedEmojies);
        messageData.mostTalkedDays = _sortMapByValueDesc(messageData.mostTalkedDays);
        messageData.mostTalkedHours = _sortMapByValueDesc(messageData.mostTalkedHours);
      }
      
      return messageData;
    } catch (e) {
      print("Error in getAttributes: $e");
      return messageData;
    }
  }
  
  // Helper method to sort maps by value in descending order
  Map<String, int> _sortMapByValueDesc(Map<String, int> map) {
    List<MapEntry<String, int>> entries = map.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    
    Map<String, int> sortedMap = {};
    for (var entry in entries) {
      sortedMap[entry.key] = entry.value;
    }
    
    return sortedMap;
  }
}