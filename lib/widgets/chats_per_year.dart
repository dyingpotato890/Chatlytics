import 'package:flutter/material.dart';
import 'package:chatlytics/widgets/colors.dart';
import 'package:chatlytics/models/data.dart';

class ChatByYearWidget extends StatelessWidget {
  final Data messageData;

  const ChatByYearWidget({super.key, required this.messageData});

  @override
  Widget build(BuildContext context) {
    // Get year data
    final Map<String, int> yearData = messageData.yearCount;
    final List<MapEntry<String, int>> yearEntries = yearData.entries.toList();

    print(yearEntries);

    // Sort chronologically
    yearEntries.sort((a, b) => a.key.compareTo(b.key));

    // Get total messages for calculations
    final int totalYearMessages = yearData.values.fold(
      0,
      (sum, count) => sum + count,
    );

    // Find year with most messages
    MapEntry<String, int> mostActiveYear = yearEntries.isNotEmpty
        ? yearEntries.fold(yearEntries.first, (a, b) => a.value > b.value ? a : b)
        : MapEntry("N/A", 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Year summary header
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
                    "Activity by Year",
                    style: TextStyle(
                      fontSize: 14,
                      color: ColorUtils.whatsappSecondaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "20${mostActiveYear.key}",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: ColorUtils.whatsappDarkGreen,
                    ),
                  ),
                  Text(
                    mostActiveYear.value > 0 
                        ? "Most active year"
                        : "No activity recorded",
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
                  Icons.calendar_today_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
        ),

        const Divider(color: ColorUtils.whatsappDivider, height: 32),

        const SizedBox(height: 20),

        // All years breakdown (in chronological order)
        ...yearEntries.map((entry) {
          final String year = entry.key;
          final int yearMessages = entry.value;
          final double percentage = totalYearMessages > 0 
              ? (yearMessages / totalYearMessages) * 100 
              : 0;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),

            child: Row(
              children: [
                // Year icon
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

                // Year info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "20$year",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: ColorUtils.whatsappTextColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "$yearMessages messages",
                        style: const TextStyle(
                          fontSize: 13,
                          color: ColorUtils.whatsappSecondaryText,
                        ),
                      ),
                    ],
                  ),
                ),

                // Percentage badge
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
                    "${percentage.toStringAsFixed(1)}%",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: ColorUtils.whatsappDarkGreen,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}