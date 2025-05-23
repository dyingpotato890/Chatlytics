import 'package:chatlytics/models/streak_info.dart';
import 'package:flutter/material.dart';
import 'package:chatlytics/widgets/colors.dart';
import 'package:chatlytics/models/data.dart';
import 'package:intl/intl.dart';

class DayStreakWidget extends StatelessWidget {
  final Data messageData;

  const DayStreakWidget({super.key, required this.messageData});

  String _formatDateRange(DateTime start, DateTime end) {
    final DateFormat formatter = DateFormat('MMM d, yyyy');
    if (start.isAtSameMomentAs(end)) {
      return formatter.format(start);
    }
    return '${formatter.format(start)} - ${formatter.format(end)}';
  }

  @override
  Widget build(BuildContext context) {
    final int highestStreak = messageData.highestDayStreak;
    final int activeDays = messageData.activeDays;
    final StreakInfo? longestStreak = messageData.longestStreak;
    final List<StreakInfo> allStreaks = messageData.allStreaks;

    // Filter streaks greater than 2 days and sort by length (descending)
    final List<StreakInfo> significantStreaks =
        allStreaks.where((streak) => streak.length > 2).toList()
          ..sort((a, b) => b.length.compareTo(a.length));

    // Calculate streak percentage relative to total active days
    final double streakPercentage =
        activeDays > 0 ? (highestStreak / activeDays) * 100 : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main streak header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Longest Streak",
                    style: TextStyle(
                      fontSize: 14,
                      color: ColorUtils.whatsappSecondaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$highestStreak",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: ColorUtils.whatsappDarkGreen,
                    ),
                  ),
                  Text(
                    highestStreak > 0
                        ? "Consecutive days"
                        : "No streak recorded",
                    style: TextStyle(
                      fontSize: 12,
                      color: ColorUtils.whatsappSecondaryText.withAlpha(204),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ColorUtils.whatsappLightGreen,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.local_fire_department_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
        ),

        const Divider(color: ColorUtils.whatsappDivider, height: 32),

        // Longest Streak Details
        if (longestStreak != null) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ColorUtils.whatsappLightGreen.withAlpha(26),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    size: 20,
                    color: ColorUtils.whatsappSecondaryText,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Longest Streak Record",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: ColorUtils.whatsappTextColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${longestStreak.length} days • ${_formatDateRange(longestStreak.startDate, longestStreak.endDate)}",
                        style: const TextStyle(
                          fontSize: 13,
                          color: ColorUtils.whatsappSecondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: ColorUtils.whatsappLightGreen.withAlpha(50),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    "${streakPercentage.toStringAsFixed(1)}%",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: ColorUtils.whatsappDarkGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Total Active Days with Streak Count
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ColorUtils.whatsappLightGreen.withAlpha(26),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  size: 20,
                  color: ColorUtils.whatsappSecondaryText,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total Active Days",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: ColorUtils.whatsappTextColor,
                      ),
                    ),
                    Text(
                      "${significantStreaks.length} streaks (3+ days)",
                      style: const TextStyle(
                        fontSize: 13,
                        color: ColorUtils.whatsappSecondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Longest Streaks Section (3+ days only)
        if (significantStreaks.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Longest Streaks",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ColorUtils.whatsappTextColor,
                ),
              ),
              Text(
                "${significantStreaks.length} total",
                style: TextStyle(
                  fontSize: 14,
                  color: ColorUtils.whatsappSecondaryText.withAlpha(153),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Show top streaks (3+ days only)
          ...significantStreaks.take(8).toList().asMap().entries.map((entry) {
            int index = entry.key;
            StreakInfo streak = entry.value;
            bool isLongest = index == 0; // First in sorted list is longest

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    isLongest
                        ? ColorUtils.whatsappLightGreen.withAlpha(26)
                        : ColorUtils.whatsappSecondaryText.withAlpha(13),
                borderRadius: BorderRadius.circular(8),
                border:
                    isLongest
                        ? Border.all(
                          color: ColorUtils.whatsappLightGreen.withAlpha(76),
                          width: 1,
                        )
                        : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color:
                          isLongest
                              ? ColorUtils.whatsappLightGreen
                              : ColorUtils.whatsappSecondaryText.withAlpha(76),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child:
                          isLongest
                              ? const Icon(
                                Icons.emoji_events_rounded,
                                size: 14,
                                color: Colors.white,
                              )
                              : Text(
                                "${index + 1}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${streak.length} days",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color:
                                isLongest
                                    ? ColorUtils.whatsappTextColor
                                    : ColorUtils.whatsappSecondaryText,
                          ),
                        ),
                        Text(
                          _formatDateRange(streak.startDate, streak.endDate),
                          style: TextStyle(
                            fontSize: 12,
                            color: ColorUtils.whatsappSecondaryText.withAlpha(
                              179,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),

          if (significantStreaks.length > 8) ...[
            const SizedBox(height: 8),
            Center(
              child: Text(
                "... and ${significantStreaks.length - 8} more streaks",
                style: TextStyle(
                  fontSize: 12,
                  color: ColorUtils.whatsappSecondaryText.withAlpha(153),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ] else ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ColorUtils.whatsappSecondaryText.withAlpha(13),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: ColorUtils.whatsappSecondaryText.withAlpha(153),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  "No streaks of 3+ days found",
                  style: TextStyle(
                    fontSize: 14,
                    color: ColorUtils.whatsappSecondaryText.withAlpha(153),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
