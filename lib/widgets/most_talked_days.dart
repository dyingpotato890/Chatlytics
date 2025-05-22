import 'package:flutter/material.dart';
import 'package:chatlytics/widgets/colors.dart';
import 'package:chatlytics/models/data.dart';

class MostTalkedDaysWidget extends StatelessWidget {
  final Data messageData;

  const MostTalkedDaysWidget({super.key, required this.messageData});

  @override
  Widget build(BuildContext context) {
    // Get days data and sort by value (message count) in descending order
    final Map<String, int> daysData = Map.from(messageData.mostTalkedDays);
    final List<MapEntry<String, int>> sortedDays = daysData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
        
    // Function to convert day number to name
    String getDayName(String dayNumber) {
      final List<String> days = [
        'Monday', 'Tuesday', 'Wednesday', 
        'Thursday', 'Friday', 'Saturday', 'Sunday'
      ];
      
      try {
        int index = int.parse(dayNumber) - 1;
        if (index >= 0 && index < days.length) {
          return days[index];
        }
      } catch (e) {
        // In case the day number is not in expected format
      }
      
      return dayNumber;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Days summary header
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
                    "Most Active Days",
                    style: TextStyle(fontSize: 14, color: ColorUtils.whatsappSecondaryText),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    getDayName(sortedDays.isNotEmpty ? sortedDays.first.key : ""),
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
                  Icons.calendar_today_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
        ),

        const Divider(color: ColorUtils.whatsappDivider, height: 20),
        SizedBox(height: 10,),

        // Days breakdown
        ...sortedDays.take(7).map((entry) {
          final String dayKey = entry.key;
          final String dayName = getDayName(dayKey);
          final int dayMessages = entry.value;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ColorUtils.whatsappLightGreen.withAlpha(26),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: ColorUtils.whatsappSecondaryText,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      dayName,
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
                    "$dayMessages",
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