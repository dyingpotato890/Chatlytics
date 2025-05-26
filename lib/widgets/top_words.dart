import 'package:chatlytics/models/data.dart';
import 'package:chatlytics/widgets/colors.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class _WordData {
  final String word;
  final int count;
  final double normalizedCount; // For progress bars

  const _WordData({
    required this.word,
    required this.count,
    required this.normalizedCount,
  });
}

class _TopWordData {
  final String word;
  final int count;
  final int rank;
  final Color medalColor;
  final Color backgroundColor;

  const _TopWordData({
    required this.word,
    required this.count,
    required this.rank,
    required this.medalColor,
    required this.backgroundColor,
  });
}

class TopWordsWidget extends StatefulWidget {
  final Data messageData;

  const TopWordsWidget({
    super.key,
    required this.messageData,
  });

  @override
  State<TopWordsWidget> createState() => _TopWordsWidgetState();
}

class _TopWordsWidgetState extends State<TopWordsWidget> {
  late final List<_TopWordData> _topThreeWords;
  late final List<_WordData> _remainingWords;
  late final int _totalWordCount;
  late final bool _hasWords;
  late final double _maxCount;

  // Pre-computed color constants
  static const List<Color> _medalColors = [
    Color(0xFFFFD700), // Gold
    Color(0xFFC0C0C0), // Silver
    Color(0xFFCD7F32), // Bronze
  ];

  static const List<Color> _bgColors = [
    Color(0xFFFFF9E6), // Light gold
    Color(0xFFF8F8F8), // Light silver
    Color(0xFFFFF1E6), // Light bronze
  ];

  @override
  void initState() {
    super.initState();
    _precomputeWordData();
  }

  void _precomputeWordData() {
    final Map<String, int> topWords = widget.messageData.mostUsedWords;
    _totalWordCount = widget.messageData.wordCount;
    
    // Convert to sorted list once
    final List<MapEntry<String, int>> sortedWords = topWords.entries
        .take(100)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    _hasWords = sortedWords.isNotEmpty;
    
    if (!_hasWords) {
      _topThreeWords = [];
      _remainingWords = [];
      _maxCount = 0;
      return;
    }

    // Pre-compute top 3 words with colors
    final int topWordsCount = min(3, sortedWords.length);
    _topThreeWords = List.generate(topWordsCount, (index) {
      final entry = sortedWords[index];
      return _TopWordData(
        word: entry.key,
        count: entry.value,
        rank: index,
        medalColor: _medalColors[index],
        backgroundColor: _bgColors[index],
      );
    });

    // Pre-compute remaining words with normalized counts for progress bars
    if (sortedWords.length > 3) {
      _maxCount = sortedWords[2].value.toDouble();
      
      _remainingWords = sortedWords
          .skip(3)
          .take(97) // Take up to 100 total words
          .map((entry) => _WordData(
                word: entry.key,
                count: entry.value,
                normalizedCount: entry.value / _maxCount,
              ))
          .toList();
    } else {
      _remainingWords = [];
      _maxCount = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Introduction section
        Padding(
          padding: const EdgeInsets.only(bottom: 12, left: 5, right: 5),
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
                "Total Words: $_totalWordCount",
                style: const TextStyle(
                  fontSize: 14, 
                  color: ColorUtils.whatsappSecondaryText,
                ),
              ),
            ],
          ),
        ),

        const Divider(color: ColorUtils.whatsappDivider, height: 24),

        // Top 3 Words with special highlight
        if (_topThreeWords.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: _topThreeWords
                  .map((wordData) => Expanded(child: _buildTopWordCard(wordData)))
                  .toList(),
            ),
          ),

        // Word cloud for remaining words
        if (_remainingWords.isNotEmpty) _buildRemainingWordsSection(),

        const SizedBox(height: 12),
        _buildInfoSection(),
      ],
    );
  }

  Widget _buildRemainingWordsSection() {
    return DecoratedBox(
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
      child: Padding(
        padding: const EdgeInsets.all(12),
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
              children: _remainingWords
                  .map((wordData) => _buildWordProgressBar(wordData))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWordProgressBar(_WordData wordData) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              wordData.word,
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
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2F1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const SizedBox(height: 14, width: double.infinity),
                ),
                FractionallySizedBox(
                  widthFactor: wordData.normalizedCount,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: ColorUtils.whatsappLightGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const SizedBox(height: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            wordData.count.toString(),
            style: const TextStyle(
              fontSize: 12,
              color: ColorUtils.whatsappSecondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFECF3F3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
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
              "Based on ${widget.messageData.messageCount} messages analyzed",
              style: const TextStyle(
                fontSize: 14, 
                color: ColorUtils.whatsappSecondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopWordCard(_TopWordData wordData) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: wordData.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: wordData.medalColor.withAlpha(51),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: wordData.medalColor.withAlpha(77)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Medal icon
              DecoratedBox(
                decoration: BoxDecoration(
                  color: wordData.medalColor.withAlpha(51),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.emoji_events_rounded,
                    color: wordData.medalColor,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Word
              Text(
                wordData.word,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: wordData.medalColor.withAlpha(204),
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Count
              Text(
                wordData.count.toString(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ColorUtils.whatsappDarkGreen.withAlpha(230),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}