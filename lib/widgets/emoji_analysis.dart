import 'package:chatlytics/models/data.dart';
import 'package:chatlytics/widgets/colors.dart';
import 'package:flutter/material.dart';

class _EmojiData {
  final String emoji;
  final int count;
  final int rank;

  const _EmojiData({
    required this.emoji,
    required this.count,
    required this.rank,
  });
}

class _EmojiStats {
  final int totalEmojis;
  final String perMessage;
  final String messagePercentage;

  const _EmojiStats({
    required this.totalEmojis,
    required this.perMessage,
    required this.messagePercentage,
  });
}

class EmojiAnalysisWidget extends StatefulWidget {
  final Data messageData;

  const EmojiAnalysisWidget({
    super.key,
    required this.messageData,
  });

  @override
  State<EmojiAnalysisWidget> createState() => _EmojiAnalysisWidgetState();
}

class _EmojiAnalysisWidgetState extends State<EmojiAnalysisWidget> {
  late final List<_EmojiData> _emojiList;
  late final _EmojiStats _stats;
  late final bool _hasEmojis;

  @override
  void initState() {
    super.initState();
    _precomputeEmojiData();
  }

  void _precomputeEmojiData() {
    final Map<String, int> topEmojis = widget.messageData.mostUsedEmojies;
    
    // Calculate total emojis once
    int totalEmojis = 0;
    for (final count in topEmojis.values) {
      totalEmojis += count;
    }

    // Pre-compute emoji list with rankings
    _emojiList = topEmojis.entries
        .map((entry) => _EmojiData(
              emoji: entry.key,
              count: entry.value,
              rank: 0,
            ))
        .toList();

    // Sort once and assign rankings
    _emojiList.sort((a, b) => b.count.compareTo(a.count));
    for (int i = 0; i < _emojiList.length; i++) {
      _emojiList[i] = _EmojiData(
        emoji: _emojiList[i].emoji,
        count: _emojiList[i].count,
        rank: i,
      );
    }

    // Pre-compute statistics
    final messageCount = widget.messageData.messageCount;
    _stats = _EmojiStats(
      totalEmojis: totalEmojis,
      perMessage: messageCount > 0 
          ? (totalEmojis / messageCount).toStringAsFixed(2)
          : "0.00",
      messagePercentage: messageCount > 0 
          ? "${(totalEmojis / messageCount * 100).round()}%"
          : "0%",
    );

    _hasEmojis = _emojiList.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
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
            DecoratedBox(
              decoration: BoxDecoration(
                color: ColorUtils.whatsappLightGreen.withAlpha(50),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Text(
                  "${_stats.totalEmojis} Total",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: ColorUtils.whatsappDarkGreen,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Emoji grid with modern look
        _hasEmojis
            ? Wrap(
                spacing: 12,
                runSpacing: 16,
                alignment: WrapAlignment.spaceEvenly,
                children: List.generate(
                  _emojiList.length,
                  (index) => _buildEmojiItem(_emojiList[index]),
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
        if (_hasEmojis) _buildStatsSection(),
      ],
    );
  }

  Widget _buildStatsSection() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 249, 246, 246),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                _buildEmojiStat(_stats.perMessage, "Per Message"),
                DecoratedBox(
                  decoration: const BoxDecoration(
                    color: ColorUtils.whatsappDivider,
                  ),
                  child: const SizedBox(height: 24, width: 1),
                ),
                _buildEmojiStat(_stats.messagePercentage, "Of Messages"),
              ],
            ),
          ],
        ),
      ),
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
          style: const TextStyle(
            fontSize: 12, 
            color: ColorUtils.whatsappSecondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildEmojiItem(_EmojiData emojiData) {
    return Column(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.transparent, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(50),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              emojiData.emoji, 
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          emojiData.count.toString(),
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