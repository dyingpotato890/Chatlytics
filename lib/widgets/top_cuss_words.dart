import 'package:chatlytics/models/data.dart';
import 'package:chatlytics/widgets/colors.dart';
import 'package:chatlytics/widgets/show_more_button.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class _CussWordData {
  final String word;
  final int count;
  final double normalizedCount;

  const _CussWordData({
    required this.word,
    required this.count,
    required this.normalizedCount,
  });
}

class _TopCussWordData {
  final String word;
  final int count;
  final int rank;
  final Color medalColor;
  final Color backgroundColor;

  const _TopCussWordData({
    required this.word,
    required this.count,
    required this.rank,
    required this.medalColor,
    required this.backgroundColor,
  });
}

class TopCussWordsWidget extends StatefulWidget {
  final Data messageData;

  const TopCussWordsWidget({
    super.key,
    required this.messageData,
  });

  @override
  State<TopCussWordsWidget> createState() => _TopCussWordsWidgetState();
}

class _TopCussWordsWidgetState extends State<TopCussWordsWidget> {
  late final List<_TopCussWordData> _topThreeCussWords;
  late final List<_CussWordData> _remainingCussWords;
  late final int _totalCussWordCount;
  late final bool _hasCussWords;
  late final double _maxCount;
  bool _showAll = false;
  static const int _initialCount = 7;

  // Pre-computed color constants with red/warning theme
  static const List<Color> _medalColors = [
    Color(0xFFFF4444), // Red
    Color(0xFFFF8800), // Orange
    Color(0xFFFFBB33), // Yellow-orange
  ];

  static const List<Color> _bgColors = [
    Color(0xFFFFEBEE), // Light red
    Color(0xFFFFF3E0), // Light orange
    Color(0xFFFFF8E1), // Light yellow
  ];

  @override
  void initState() {
    super.initState();
    _precomputeCussWordData();
  }

  void _precomputeCussWordData() {
    final Map<String, int> topCussWords = widget.messageData.mostUsedCussWords;
    
    // Calculate total cuss word count
    _totalCussWordCount = topCussWords.values.fold(0, (sum, count) => sum + count);
    
    // Convert to sorted list
    final List<MapEntry<String, int>> sortedCussWords = topCussWords.entries
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    _hasCussWords = sortedCussWords.isNotEmpty;
    
    if (!_hasCussWords) {
      _topThreeCussWords = [];
      _remainingCussWords = [];
      _maxCount = 0;
      return;
    }

    // Pre-compute top 3 cuss words with colors
    final int topWordsCount = min(3, sortedCussWords.length);
    _topThreeCussWords = List.generate(topWordsCount, (index) {
      final entry = sortedCussWords[index];
      return _TopCussWordData(
        word: entry.key,
        count: entry.value,
        rank: index,
        medalColor: _medalColors[index],
        backgroundColor: _bgColors[index],
      );
    });

    // Pre-compute remaining cuss words with normalized counts
    if (sortedCussWords.length > 3) {
      _maxCount = sortedCussWords[2].value.toDouble();
      
      _remainingCussWords = sortedCussWords
          .skip(3)
          .map((entry) => _CussWordData(
                word: entry.key,
                count: entry.value,
                normalizedCount: entry.value / _maxCount,
              ))
          .toList();
    } else {
      _remainingCussWords = [];
      _maxCount = 0;
    }
  }

  String toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasCussWords) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Introduction section
        Padding(
          padding: const EdgeInsets.only(bottom: 12, left: 5, right: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Profanity Analysis",
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
                    "$_totalCussWordCount Total",
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
        ),

        const Divider(color: ColorUtils.whatsappDivider, height: 24),

        // Top 3 Cuss Words with special highlight
        if (_topThreeCussWords.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: _topThreeCussWords
                  .map((wordData) => Expanded(child: _buildTopCussWordCard(wordData)))
                  .toList(),
            ),
          ),

        // Remaining cuss words
        if (_remainingCussWords.isNotEmpty) 
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildRemainingCussWordsSection(),
          ),

        // User-wise cuss word usage
        _buildUserCussWordsSection(),

        const SizedBox(height: 16),

        // Language-wise breakdown
        _buildLanguageBreakdownSection(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: const [
            Icon(
              Icons.sentiment_satisfied_alt_rounded,
              size: 48,
              color: ColorUtils.whatsappLightGreen,
            ),
            SizedBox(height: 12),
            Text(
              "Clean Conversation!",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ColorUtils.whatsappDarkGreen,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "No profanity detected in this chat",
              style: TextStyle(
                fontSize: 14,
                color: ColorUtils.whatsappSecondaryText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemainingCussWordsSection() {
    final visible = _showAll ? _remainingCussWords : _remainingCussWords.take(_initialCount).toList();
    final hasMore = _remainingCussWords.length > _initialCount;

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
              "Other Frequent Profanity",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: ColorUtils.whatsappDarkGreen,
              ),
            ),
            const SizedBox(height: 12),
            Column(
              children: visible.map((wordData) => _buildCussWordProgressBar(wordData)).toList(),
            ),
            if (hasMore)
              ShowMoreButton(
                showAll: _showAll,
                total: _remainingCussWords.length,
                initialCount: _initialCount,
                onTap: () => setState(() => _showAll = !_showAll),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCussWordsSection() {
    final Map<String, int> userCussWords = widget.messageData.personMostUsedCussWords;
    
    if (userCussWords.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sort users by cuss word count
    final sortedUsers = userCussWords.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Find max for normalization
    final maxUserCount = sortedUsers.first.value.toDouble();

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
            Row(
              children: const [
                Icon(
                  Icons.person_outline,
                  size: 18,
                  color: ColorUtils.whatsappDarkGreen,
                ),
                SizedBox(width: 8),
                Text(
                  "Most Profane Users",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: ColorUtils.whatsappDarkGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...sortedUsers.map((entry) => _buildUserBar(
              entry.key,
              entry.value,
              entry.value / maxUserCount,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildUserBar(String username, int count, double normalized) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: ColorUtils.getAvatarColor(username),
                    child: Text(
                      username.isNotEmpty ? username[0] : "?",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    username,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: ColorUtils.whatsappTextColor,
                    ),
                  ),
                ],
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4444).withAlpha(50),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  child: Text(
                    count.toString(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF4444),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: ColorUtils.whatsappDivider,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const SizedBox(
                  height: 10,
                  width: double.infinity,
                ),
              ),
              FractionallySizedBox(
                widthFactor: normalized,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFFF8A80),
                        const Color(0xFFFF8A80).withAlpha(179),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "$count cuss words",
            style: const TextStyle(
              fontSize: 13,
              color: ColorUtils.whatsappSecondaryText,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildLanguageBreakdownSection() {
    final Map<String, int> languageCounts = widget.messageData.cussWordsByLanguage;

    if (languageCounts.isEmpty) return const SizedBox.shrink();

    final sortedLanguages = languageCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final total = languageCounts.values.fold(0, (sum, count) => sum + count);

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
            Row(
              children: const [
                Icon(Icons.language_rounded, size: 18, color: ColorUtils.whatsappDarkGreen),
                SizedBox(width: 8),
                Text(
                  "Language Distribution",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: ColorUtils.whatsappDarkGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...sortedLanguages.map((entry) {
              final percentage = (entry.value / total * 100).toStringAsFixed(1);
              return _buildLanguageCard(
                toTitleCase(entry.key),
                entry.value,
                percentage,
                entry.value / total,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageCard(String language, int count, String percentage, double normalized) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                language,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: ColorUtils.whatsappTextColor,
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
                    "$percentage%",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: ColorUtils.whatsappDarkGreen,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: ColorUtils.whatsappDivider,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const SizedBox(height: 10, width: double.infinity),
              ),
              FractionallySizedBox(
                widthFactor: normalized,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ColorUtils.whatsappLightGreen,
                        ColorUtils.whatsappLightGreen.withAlpha(179),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "$count words",
            style: const TextStyle(fontSize: 13, color: ColorUtils.whatsappSecondaryText),
          ),
        ],
      ),
    );
  }

  Widget _buildCussWordProgressBar(_CussWordData wordData) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
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
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const SizedBox(height: 14, width: double.infinity),
                ),
                FractionallySizedBox(
                  widthFactor: wordData.normalizedCount,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF8A80),
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

  Widget _buildTopCussWordCard(_TopCussWordData wordData) {
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
              // Warning icon
              DecoratedBox(
                decoration: BoxDecoration(
                  color: wordData.medalColor.withAlpha(51),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.warning_rounded,
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