import 'package:flutter/material.dart';
import 'package:chatlytics/widgets/colors.dart';
import 'package:chatlytics/models/data.dart';

class ChatByMonthWidget extends StatelessWidget {
  final Data messageData;

  const ChatByMonthWidget({super.key, required this.messageData});

  @override
  Widget build(BuildContext context) {
    // Get month data and ensure all 12 months are present
    final Map<String, int> monthData = _getAllMonthsData();
    final List<MapEntry<String, int>> monthEntries = monthData.entries.toList();

    // Sort chronologically (01 to 12)
    monthEntries.sort((a, b) => a.key.compareTo(b.key));

    // Get total messages for calculations
    final int totalMonthMessages = monthData.values.fold(
      0,
      (sum, count) => sum + count,
    );

    // Find month with most messages (excluding months with 0 messages)
    MapEntry<String, int> mostActiveMonth = monthEntries
        .where((entry) => entry.value > 0)
        .fold(MapEntry("01", 0), (a, b) => a.value > b.value ? a : b);

    // If no active months, default to January
    if (mostActiveMonth.value == 0) {
      mostActiveMonth = MapEntry("01", 0);
    }

    // Format month name for display
    String formatMonthDisplay(String monthKey) {
      final Map<String, String> months = {
        "01": "January",
        "02": "February",
        "03": "March",
        "04": "April",
        "05": "May",
        "06": "June",
        "07": "July",
        "08": "August",
        "09": "September",
        "10": "October",
        "11": "November",
        "12": "December",
      };

      return months[monthKey] ?? "Unknown";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month summary header
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
                    "Activity by Month",
                    style: TextStyle(
                      fontSize: 14,
                      color: ColorUtils.whatsappSecondaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatMonthDisplay(mostActiveMonth.key),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: ColorUtils.whatsappDarkGreen,
                    ),
                  ),
                  Text(
                    mostActiveMonth.value > 0 
                        ? "Most active month"
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
                  Icons.date_range_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
        ),

        const Divider(color: ColorUtils.whatsappDivider, height: 32),

        // Monthly activity chart
        Container(
          height: 180,
          margin: const EdgeInsets.only(bottom: 16, top: 8),
          child: _buildMonthlyChart(
            context,
            monthEntries,
            mostActiveMonth.value,
          ),
        ),

        const SizedBox(height: 20),

        // All months breakdown 
        ..._getActiveMonthsChronological(monthEntries).map((entry) {
          final String monthKey = entry.key;
          final String monthDisplay = formatMonthDisplay(monthKey.trim());
          final int monthMessages = entry.value;
          final double percentage = totalMonthMessages > 0 
              ? (monthMessages / totalMonthMessages) * 100 
              : 0;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),

            child: Row(
              children: [
                // Month icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ColorUtils.whatsappLightGreen.withAlpha(26),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.calendar_month_rounded,
                    size: 20,
                    color: ColorUtils.whatsappSecondaryText,
                  ),
                ),

                const SizedBox(width: 16),

                // Month info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        monthDisplay,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: ColorUtils.whatsappTextColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "$monthMessages messages",
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

  // Get all 12 months data, filling in 0 for missing months
  Map<String, int> _getAllMonthsData() {
    final Map<String, int> allMonths = {
      "01": 0,
      "02": 0,
      "03": 0,
      "04": 0,
      "05": 0,
      "06": 0,
      "07": 0,
      "08": 0,
      "09": 0,
      "10": 0,
      "11": 0,
      "12": 0,
    };

    // Merge with actual data
    final originalData = Map.from(messageData.monthCount);
    for (String month in originalData.keys) {
      String monthKey = month.trim();
      // Handle different possible formats
      if (monthKey.length == 1) {
        monthKey = "0$monthKey";
      }
      if (allMonths.containsKey(monthKey)) {
        allMonths[monthKey] = originalData[month];
      }
    }

    return allMonths;
  }

  // Build the monthly activity chart (now shows all 12 months)
  Widget _buildMonthlyChart(
    BuildContext context,
    List<MapEntry<String, int>> monthEntries,
    int maxValue,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ...monthEntries.map((entry) {
            final double percentage = maxValue > 0 ? entry.value / maxValue : 0;
            final String shortMonthName = _getShortMonthName(entry.key);

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              width: 28,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Value label (only show if > 0)
                  SizedBox(
                    height: 16,
                    child: entry.value > 0 
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

                  // Bar (minimum height of 2 for months with 0 messages)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutQuart,
                    height: (120 * percentage).clamp(entry.value == 0 ? 2 : 8, 120),
                    width: 28,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: entry.value > 0 
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

                  // Month label
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      shortMonthName,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: ColorUtils.whatsappTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // Get a short name for the month
  String _getShortMonthName(String monthKey) {
    final Map<String, String> shortMonths = {
      "01": "Jan",
      "02": "Feb",
      "03": "Mar",
      "04": "Apr",
      "05": "May",
      "06": "Jun",
      "07": "Jul",
      "08": "Aug",
      "09": "Sep",
      "10": "Oct",
      "11": "Nov",
      "12": "Dec",
    };

    return shortMonths[monthKey] ?? "???";
  }

  // Get only active months in chronological order
  List<MapEntry<String, int>> _getActiveMonthsChronological(
    List<MapEntry<String, int>> monthEntries,
  ) {
    // Filter out months with 0 messages and keep chronological order (01 to 12)
    final activeEntries = monthEntries
        .where((entry) => entry.value > 0)
        .toList();

    // Sort chronologically (already sorted from _getAllMonthsData, but just to be sure)
    activeEntries.sort((a, b) => a.key.compareTo(b.key));

    return activeEntries;
  }
}