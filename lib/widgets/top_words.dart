import 'package:chatlytics/models/data.dart';
import 'package:chatlytics/widgets/colors.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class TopWordsWidget extends StatelessWidget {
  final Data messageData;

  const TopWordsWidget({
    super.key,
    required this.messageData,
  });

  @override
  Widget build(BuildContext context) {
    // Get word data from the actual data source
    final Map<String, int> topWords = messageData.mostUsedWords;

    // Get top words
    final List<MapEntry<String, int>> topWordsList =
        topWords.entries.take(100).toList();

    return Column(
      children: [
        // Introduction section
        Container(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Most Used Words",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ColorUtils.whatsappDarkGreen,
                ),
              ),
              Text(
                "Total Words: ${messageData.wordCount}",
                style: const TextStyle(fontSize: 14, color: ColorUtils.whatsappSecondaryText),
              ),
            ],
          ),
        ),

        const Divider(color: ColorUtils.whatsappDivider, height: 24),

        // Top 3 Words with special highlight
        if (topWordsList.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: List.generate(
                min(3, topWordsList.length),
                (index) => Expanded(
                  child: _buildTopWordCard(
                    topWordsList[index].key,
                    topWordsList[index].value,
                    index,
                  ),
                ),
              ),
            ),
          ),

        // Word cloud for remaining words
        if (topWordsList.length > 3)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Other Frequent Words",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: ColorUtils.whatsappDarkGreen,
                  ),
                ),

                const SizedBox(height: 12),
                
                Column(
                  children: List.generate(
                    min(100, topWordsList.length - 3),
                    (index) {
                      final word = topWordsList[index + 3].key;
                      final count = topWordsList[index + 3].value;
                      final maxCount =
                          topWordsList[2].value
                              .toDouble();

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 60,
                              child: Text(
                                word,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: ColorUtils.whatsappDarkGreen,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            const SizedBox(width: 8),

                            Expanded(
                              child: Stack(
                                children: [
                                  Container(
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE0F2F1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  FractionallySizedBox(
                                    widthFactor: count / maxCount,
                                    child: Container(
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: ColorUtils.whatsappLightGreen,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              count.toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                color: ColorUtils.whatsappSecondaryText,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFECF3F3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.info_outline,
                size: 16,
                color: ColorUtils.whatsappSecondaryText,
              ),
              const SizedBox(width: 8),
              Text(
                "Based on ${messageData.messageCount} messages analyzed",
                style: const TextStyle(fontSize: 14, color: ColorUtils.whatsappSecondaryText),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopWordCard(String word, int count, int index) {
    final List<Color> medalColors = [
      const Color(0xFFFFD700), // Gold
      const Color(0xFFC0C0C0), // Silver
      const Color(0xFFCD7F32), // Bronze
    ];

    final List<Color> bgColors = [
      const Color(0xFFFFF9E6), // Light gold
      const Color(0xFFF8F8F8), // Light silver
      const Color(0xFFFFF1E6), // Light bronze
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColors[index],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: medalColors[index].withAlpha(51),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: medalColors[index].withAlpha(77)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Medal icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: medalColors[index].withAlpha(51),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.emoji_events_rounded,
              color: medalColors[index],
              size: 18,
            ),
          ),
          const SizedBox(height: 8),
          // Word
          Text(
            word,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: medalColors[index].withAlpha(204),
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Count
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ColorUtils.whatsappDarkGreen.withAlpha(230),
            ),
          ),
        ],
      ),
    );
  }
}