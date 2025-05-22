import 'package:flutter/material.dart';
import 'package:chatlytics/widgets/colors.dart';
import 'package:chatlytics/models/data.dart';

class MostTalkedHoursWidget extends StatelessWidget {
  final Data messageData;

  const MostTalkedHoursWidget({super.key, required this.messageData});

  @override
  Widget build(BuildContext context) {
    // Get hours data and sort by value (message count) in descending order
    final Map<String, int> hoursData = Map.from(messageData.mostTalkedHours);
    final List<MapEntry<String, int>> sortedHours =
        hoursData.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    // Function to parse hour from various formats
    int parseHour(String hourKey) {
      try {
        // Handle "12 PM" or "1 AM" format
        if (hourKey.contains(' ')) {
          List<String> parts = hourKey.split(' ');
          int hour = int.parse(parts[0]);
          String period = parts[1].toUpperCase();

          if (period == 'AM') {
            return hour == 12 ? 0 : hour;
          } else {
            // PM
            return hour == 12 ? 12 : hour + 12;
          }
        }
        // Handle 24-hour format
        return int.parse(hourKey);
      } catch (e) {
        return 0;
      }
    }

    // Function to format hour for display
    String formatHourDisplay(String hourKey) {
      try {
        // If already formatted (contains space), return as is
        if (hourKey.contains(' ')) {
          return hourKey;
        }

        int hour = int.parse(hourKey);
        if (hour == 0) return "12 AM";
        if (hour == 12) return "12 PM";
        return hour > 12 ? "${hour - 12} PM" : "$hour AM";
      } catch (e) {
        return hourKey;
      }
    }

    // Most active hour period (morning/afternoon/evening/night)
    String getMostActiveTimePeriod() {
      if (sortedHours.isEmpty) return "Unknown";

      try {
        int mostActiveHour = parseHour(sortedHours.first.key);

        if (mostActiveHour >= 0 && mostActiveHour < 4) return "Midnight";
        if (mostActiveHour >= 4 && mostActiveHour < 7) return "Early Morning";
        if (mostActiveHour >= 7 && mostActiveHour < 12) return "Morning";
        if (mostActiveHour >= 12 && mostActiveHour < 17) return "Afternoon";
        if (mostActiveHour >= 17 && mostActiveHour < 20) return "Evening";
        if (mostActiveHour >= 20 && mostActiveHour < 24) return "Night";

        return "Unknown";
      } catch (e) {
        return "Unknown";
      }
    }

    // Get icon for time period
    IconData getTimeIcon(String hourKey) {
      try {
        int hour = parseHour(hourKey);

        if (hour >= 0 && hour < 4) return Icons.nightlight_round; // Midnight
        if (hour >= 4 && hour < 7) {
          return Icons.bedtime_rounded; // Early Morning
        }
        if (hour >= 7 && hour < 12) return Icons.wb_sunny_rounded; // Morning
        if (hour >= 12 && hour < 17) {
          return Icons.wb_cloudy_rounded; // Afternoon
        }
        if (hour >= 17 && hour < 20) {
          return Icons.wb_twilight_rounded; // Evening
        }
        if (hour >= 20 && hour < 24) return Icons.nights_stay_rounded; // Night

        return Icons.help_outline; // fallback for unexpected hour
      } catch (e) {
        return Icons.schedule_rounded; // fallback for parsing error
      }
    }

    // Create normalized data for 24-hour grid (convert all to 24-hour format)
    Map<int, int> normalizedHourData = {};
    for (var entry in hoursData.entries) {
      int hour24 = parseHour(entry.key);
      normalizedHourData[hour24] =
          (normalizedHourData[hour24] ?? 0) + entry.value;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hours summary header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Most Active Hours",
                    style: TextStyle(
                      fontSize: 14,
                      color: ColorUtils.whatsappSecondaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    getMostActiveTimePeriod(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: ColorUtils.whatsappDarkGreen,
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
                  Icons.schedule_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
        ),

        const Divider(color: ColorUtils.whatsappDivider, height: 32),

        // Create time slots grouping for better visualization
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Hourly Activity",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: ColorUtils.whatsappDarkGreen,
                ),
              ),
              const SizedBox(height: 16),

              // Hour slots visualization - grid of hours
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: 24,
                itemBuilder: (context, index) {
                  final int hourMessages = normalizedHourData[index] ?? 0;
                  final int maxMessages =
                      normalizedHourData.values.isEmpty
                          ? 1
                          : normalizedHourData.values.reduce(
                            (a, b) => a > b ? a : b,
                          );
                  final double intensity =
                      hourMessages > 0 ? hourMessages / maxMessages : 0;

                  return Container(
                    decoration: BoxDecoration(
                      color: ColorUtils.whatsappLightGreen.withAlpha(
                        (25 + (intensity * 200)).round(),
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: ColorUtils.whatsappDivider,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          formatHourDisplay(index.toString()),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color:
                                intensity > 0.5
                                    ? Colors.white
                                    : ColorUtils.whatsappTextColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        if (hourMessages > 0)
                          Text(
                            hourMessages.toString(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color:
                                  intensity > 0.5
                                      ? Colors.white
                                      : ColorUtils.whatsappSecondaryText,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Top 5 hours breakdown
        const Text(
          "Top Active Hours",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: ColorUtils.whatsappDarkGreen,
          ),
        ),
        const SizedBox(height: 12),

        ...sortedHours.take(5).map((entry) {
          final String hourKey = entry.key;
          final String hourDisplay = formatHourDisplay(hourKey);
          final int hourMessages = entry.value;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ColorUtils.whatsappSecondaryText.withAlpha(30),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        getTimeIcon(hourKey),
                        size: 18,
                        color: ColorUtils.whatsappSecondaryText,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      hourDisplay,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: ColorUtils.whatsappTextColor,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: ColorUtils.whatsappLightGreen.withAlpha(50),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "$hourMessages",
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
