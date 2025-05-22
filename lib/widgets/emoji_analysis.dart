import 'package:chatlytics/models/data.dart';
import 'package:chatlytics/widgets/colors.dart';
import 'package:flutter/material.dart';

class EmojiAnalysisWidget extends StatelessWidget {
  final Data messageData;

  const EmojiAnalysisWidget({
    super.key,
    required this.messageData,
  });

  @override
  Widget build(BuildContext context) {
    // Get emoji data from the actual data source
    final Map<String, int> topEmojis = messageData.mostUsedEmojies;

    // Calculate total emojis
    int totalEmojis = 0;
    topEmojis.forEach((_, count) {
      totalEmojis += count;
    });

    // Get top emojis
    final List<MapEntry<String, int>> topEmojisList =
        topEmojis.entries.toList();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Emoji Usage",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ColorUtils.whatsappDarkGreen,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: ColorUtils.whatsappLightGreen.withAlpha(50),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "$totalEmojis Total",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: ColorUtils.whatsappDarkGreen,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Emoji grid with modern look
        topEmojisList.isNotEmpty
            ? Wrap(
              spacing: 12,
              runSpacing: 16,
              alignment: WrapAlignment.spaceEvenly,
              children: List.generate(
                topEmojisList.length,
                (index) => _buildEmojiItem(
                  topEmojisList[index].key,
                  topEmojisList[index].value,
                  index,
                ),
              ),
            )
            : const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 30.0),
                child: Text(
                  "No emojis found in chat",
                  style: TextStyle(
                    fontSize: 16,
                    color: ColorUtils.whatsappSecondaryText,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),

        const SizedBox(height: 20),

        // Emoji statistics
        topEmojisList.isNotEmpty
            ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 249, 246, 246),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.emoji_emotions_rounded,
                        color: ColorUtils.whatsappSecondaryText,
                        size: 16,
                      ),

                      SizedBox(width: 8),

                      Text(
                        "Emoji Stats",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: ColorUtils.whatsappDarkGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildEmojiStat(
                        (totalEmojis / messageData.messageCount)
                            .toStringAsFixed(2),
                        "Per Message",
                      ),

                      Container(height: 24, width: 1, color: ColorUtils.whatsappDivider),
                      
                      _buildEmojiStat(
                        "${((messageData.messageCount > 0) ? (totalEmojis / messageData.messageCount * 100).round() : 0)}%",
                        "Of Messages",
                      ),
                    ],
                  ),
                ],
              ),
            )
            : const SizedBox.shrink(),
      ],
    );
  }

  Widget _buildEmojiStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: ColorUtils.whatsappDarkGreen,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: ColorUtils.whatsappSecondaryText),
        ),
      ],
    );
  }

  Widget _buildEmojiItem(String emoji, int count, int index) {
    Color borderColor = Colors.transparent;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(50),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(emoji, style: const TextStyle(fontSize: 24)),
        ),
        const SizedBox(height: 6),
        Text(
          count.toString(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: ColorUtils.whatsappTextColor,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}