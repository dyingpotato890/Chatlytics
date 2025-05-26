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
          decoration: BoxDecoration(
            color: ColorUtils.whatsappLightBackground,
            borderRadius: BorderRadius.circular(12),
          ),
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
                  const SizedBox(height: 8),
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
                    style: const TextStyle(
                      fontSize: 12,
                      color: ColorUtils.whatsappSecondaryText,
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

        // Yearly activity chart
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ColorUtils.whatsappLightBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: SizedBox(
            height: 140,
            child: _buildYearlyChart(context, yearEntries, mostActiveYear.value),
          ),
        ),

        const SizedBox(height: 16),

        // All years breakdown (in chronological order)
        ...yearEntries.map((entry) {
          final String year = entry.key;
          final int yearMessages = entry.value;
          final double percentage = totalYearMessages > 0 
              ? (yearMessages / totalYearMessages) * 100 
              : 0;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ColorUtils.whatsappLightBackground,
              borderRadius: BorderRadius.circular(12),
            ),
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
                    color: ColorUtils.whatsappDarkGreen,
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

  Widget _buildYearlyChart(
    BuildContext context,
    List<MapEntry<String, int>> yearEntries,
    int maxValue,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ...yearEntries.map((entry) {
          final double percentage = maxValue > 0 ? entry.value / maxValue : 0;
          final String year = entry.key;

          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Value label (only show if > 0)
                  SizedBox(
                    height: 16,
                    child:
                        entry.value > 0
                            ? Text(
                              entry.value.toString(),
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                                color: ColorUtils.whatsappSecondaryText,
                              ),
                            )
                            : null,
                  ),
                  const SizedBox(height: 4),

                  // Bar (minimum height of 2 for years with 0 messages)
                  Container(
                    height: (80 * percentage).clamp(
                      entry.value == 0 ? 2 : 8,
                      80,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors:
                            entry.value > 0
                                ? [
                                  ColorUtils.whatsappLightGreen,
                                  ColorUtils.whatsappLightGreen.withAlpha(179),
                                ]
                                : [
                                  Colors.grey.withAlpha(100),
                                  Colors.grey.withAlpha(50),
                                ],
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ),

                  // Year label
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      "'$year",
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: ColorUtils.whatsappTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}