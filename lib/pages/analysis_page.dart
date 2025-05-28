import 'package:chatlytics/models/data.dart';
import 'package:chatlytics/pages/home_page.dart';
import 'package:chatlytics/widgets/ai_summary.dart';
import 'package:chatlytics/widgets/chats_per_week.dart';
import 'package:chatlytics/widgets/chats_per_year.dart';
import 'package:chatlytics/widgets/colors.dart';
import 'package:chatlytics/widgets/emoji_analysis.dart';
import 'package:chatlytics/widgets/first_last_message.dart';
import 'package:chatlytics/widgets/messages_per_user.dart';
import 'package:chatlytics/widgets/most_talked_days.dart';
import 'package:chatlytics/widgets/most_talked_hours.dart';
import 'package:chatlytics/widgets/chats_per_months.dart';
import 'package:chatlytics/widgets/overview.dart';
import 'package:chatlytics/widgets/panel.dart';
import 'package:chatlytics/widgets/streak.dart';
import 'package:chatlytics/widgets/top_words.dart';
import 'package:flutter/material.dart';

class AnalysisPage extends StatefulWidget {
  final Data messageData;

  const AnalysisPage({super.key, required this.messageData});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  late final List<_PanelItem> _panelItems;

  @override
  void initState() {
    super.initState();

    _panelItems = [
      _PanelItem(
        title: "Messages per User",
        icon: Icons.people_alt_rounded,
        builder: () => MessagesPerUserWidget(messageData: widget.messageData),
      ),

      _PanelItem(
        title: "Chat Streaks",
        icon: Icons.star_rounded,
        builder: () => DayStreakWidget(messageData: widget.messageData),
      ),

      _PanelItem(
        title: "First & Last Messages",
        icon: Icons.people_alt_rounded,
        builder: () => FirstLastMessageWidget(messageData: widget.messageData),
      ),

      _PanelItem(
        title: "Top 100 Words",
        icon: Icons.text_fields_rounded,
        builder: () => TopWordsWidget(messageData: widget.messageData),
      ),

      _PanelItem(
        title: "Emoji Analysis",
        icon: Icons.emoji_emotions_rounded,
        builder: () => EmojiAnalysisWidget(messageData: widget.messageData),
      ),

      _PanelItem(
        title: "Hourly Activity",
        icon: Icons.schedule_rounded,
        builder: () => MostTalkedHoursWidget(messageData: widget.messageData),
      ),

      _PanelItem(
        title: "Most Active Days",
        icon: Icons.calendar_today_rounded,
        builder: () => MostTalkedDaysWidget(messageData: widget.messageData),
      ),

      _PanelItem(
        title: "Weekly Analysis",
        icon: Icons.date_range_rounded,
        builder: () => ChatByWeekWidget(messageData: widget.messageData),
      ),

      _PanelItem(
        title: "Monthly Activity",
        icon: Icons.date_range_rounded,
        builder: () => ChatByMonthWidget(messageData: widget.messageData),
      ),

      _PanelItem(
        title: "Yearly Activity",
        icon: Icons.date_range_rounded,
        builder: () => ChatByYearWidget(messageData: widget.messageData),
      ),

      _PanelItem(
        title: "AI Daily Analysis",
        icon: Icons.psychology_rounded,
        builder: () => AIDailyAnalysisWidget(messageData: widget.messageData),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chat Analysis',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF25D366),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 24, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const HomePage()),
              (Route<dynamic> route) => false,
            );
          },
        ),
      ),
      backgroundColor: ColorUtils.whatsappDivider,

      body: SafeArea(
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: _panelItems.length + 3,
          itemBuilder: (context, index) {
            // Header with date range
            if (index == 0) {
              return Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                alignment: Alignment.centerLeft,
                child: Text(
                  "${widget.messageData.firstMessage.date} - ${widget.messageData.lastMessage.date}",
                  style: const TextStyle(
                    color: Color(0xFF667781),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }

            // Overview widget
            if (index == 1) {
              return OverviewWidget(messageData: widget.messageData);
            }

            // Section title
            if (index == 2) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: const [
                    Text(
                      "DETAILED INSIGHTS",
                      style: TextStyle(
                        color: Color(0xFF075E54),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              );
            }

            // Panel items
            final panelIndex = index - 3;
            final panel = _panelItems[panelIndex];

            return PanelWidget(
              title: panel.title,
              color: ColorUtils.whatsappLightBackground,
              icon: panel.icon,
              content: panel.builder(),
            );
          },
        ),
      ),
    );
  }
}

class _PanelItem {
  final String title;
  final IconData icon;
  final Widget Function() builder;

  _PanelItem({required this.title, required this.icon, required this.builder});
}
