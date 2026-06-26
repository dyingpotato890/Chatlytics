import 'package:chatlytics/models/data.dart';
import 'package:chatlytics/widgets/colors.dart';
import 'package:flutter/material.dart';

class ConversationStarterWidget extends StatefulWidget {
  final Data messageData;

  const ConversationStarterWidget({super.key, required this.messageData});

  @override
  State<ConversationStarterWidget> createState() => _ConversationStarterWidgetState();
}

class _ConversationStarterWidgetState extends State<ConversationStarterWidget> {
  late final List<MapEntry<String, int>> _sorted;
  late final bool _hasData;
  late final int _totalDays;

  @override
  void initState() {
    super.initState();
    _sorted = widget.messageData.conversationStarters.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    _hasData = _sorted.isNotEmpty;
    _totalDays = _sorted.fold(0, (sum, e) => sum + e.value);
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasData) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(Icons.chat_bubble_outline_rounded, size: 48, color: ColorUtils.whatsappLightGreen),
              SizedBox(height: 12),
              Text(
                'No Data',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ColorUtils.whatsappDarkGreen,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final top = _sorted.first;
    final maxCount = top.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12, left: 5, right: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Conversation Starters',
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
                    '$_totalDays days',
                    style: const TextStyle(
                      fontSize: 13,
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

        _buildTopCard(top.key, top.value),

        const SizedBox(height: 16),

        _buildRankingList(maxCount),
      ],
    );
  }

  Widget _buildTopCard(String name, int count) {
    final pct = _totalDays > 0 ? (count / _totalDays * 100).round() : 0;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF075E54), Color(0xFF128C7E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF075E54).withAlpha(60),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            DecoratedBox(
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(Icons.wb_sunny_rounded, color: Colors.white, size: 28),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Most Days Started',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$count days',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$pct% of chats',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingList(int maxCount) {
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
          children: List.generate(_sorted.length, (index) {
            final entry = _sorted[index];
            final pct = _totalDays > 0 ? (entry.value / _totalDays * 100).round() : 0;
            final barFactor = maxCount > 0 ? entry.value / maxCount : 0.0;
            final isTop = index == 0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: ColorUtils.getAvatarColor(entry.key),
                        child: Text(
                          entry.key.isNotEmpty ? entry.key[0].toUpperCase() : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: ColorUtils.whatsappTextColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isTop)
                        const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Icon(Icons.wb_sunny_rounded, size: 16, color: Color(0xFFFFC107)),
                        ),
                      Text(
                        '$pct%',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isTop ? ColorUtils.whatsappDarkGreen : ColorUtils.whatsappTextColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Stack(
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: ColorUtils.whatsappDivider,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const SizedBox(height: 8, width: double.infinity),
                      ),
                      FractionallySizedBox(
                        widthFactor: barFactor,
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isTop
                                  ? [const Color(0xFF25D366), const Color(0xFF128C7E)]
                                  : [
                                      ColorUtils.whatsappLightGreen.withAlpha(150),
                                      ColorUtils.whatsappLightGreen.withAlpha(80),
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${entry.value} ${entry.value == 1 ? 'day' : 'days'}',
                    style: const TextStyle(fontSize: 12, color: ColorUtils.whatsappSecondaryText),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
