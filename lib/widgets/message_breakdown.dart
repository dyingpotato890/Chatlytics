import 'package:chatlytics/models/data.dart';
import 'package:chatlytics/widgets/colors.dart';
import 'package:flutter/material.dart';

class MessageBreakdownWidget extends StatefulWidget {
  final Data messageData;

  const MessageBreakdownWidget({super.key, required this.messageData});

  @override
  State<MessageBreakdownWidget> createState() => _MessageBreakdownWidgetState();
}

class _MessageBreakdownWidgetState extends State<MessageBreakdownWidget> {
  late final List<MapEntry<String, int>> _sorted;
  late final int _total;

  @override
  void initState() {
    super.initState();
    _sorted = widget.messageData.deletedMessages.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    _total = _sorted.fold(0, (s, e) => s + e.value);
  }

  @override
  Widget build(BuildContext context) {
    if (_sorted.isEmpty) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(Icons.delete_outline_rounded, size: 48, color: ColorUtils.whatsappLightGreen),
              SizedBox(height: 12),
              Text(
                'No Deleted Messages',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ColorUtils.whatsappDarkGreen,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'No one deleted any messages in this chat',
                style: TextStyle(fontSize: 14, color: ColorUtils.whatsappSecondaryText),
                textAlign: TextAlign.center,
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
                'Deleted Messages',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ColorUtils.whatsappDarkGreen,
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935).withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: Text(
                    '$_total total',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFE53935),
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
            const DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Icon(Icons.delete_outline_rounded, color: Colors.white, size: 28),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Most Deletions',
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
            Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
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
            final barFactor = entry.value / maxCount;
            final isTop = index == 0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
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
                          child: Icon(Icons.delete_rounded, size: 16, color: Color(0xFFE53935)),
                        ),
                      Text(
                        '${entry.value}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isTop ? const Color(0xFFE53935) : ColorUtils.whatsappTextColor,
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
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
