import 'package:chatlytics/models/data.dart';
import 'package:chatlytics/widgets/chats_per_year.dart';
import 'package:chatlytics/widgets/colors.dart';
import 'package:chatlytics/widgets/emoji_analysis.dart';
import 'package:chatlytics/widgets/first_last_message.dart';
import 'package:chatlytics/widgets/messages_per_user.dart';
import 'package:chatlytics/widgets/most_talked_days.dart';
import 'package:chatlytics/widgets/most_talked_hours.dart';
import 'package:chatlytics/widgets/most_talked_months.dart';
import 'package:chatlytics/widgets/overview.dart';
import 'package:chatlytics/widgets/panel.dart';
import 'package:chatlytics/widgets/top_words.dart';
import 'package:flutter/material.dart';

class AnalysisPage extends StatefulWidget {
  final Data messageData;

  const AnalysisPage({super.key, required this.messageData});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
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
        backgroundColor: const Color(0xFF25D366), // WhatsApp light green
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 24, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, size: 24, color: Colors.white),
            onPressed: () {}, // Add functionality as needed
          ),
        ],
      ),
      backgroundColor: ColorUtils.whatsappDivider,

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Header with date range
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                alignment: Alignment.centerLeft,
                child: Text(
                  "${widget.messageData.firstMessage.date} - ${widget.messageData.lastMessage.date}",
                  style: TextStyle(
                    color: Color(0xFF667781), // WhatsApp secondary text color
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              OverviewWidget(messageData: widget.messageData),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: const [
                    Text(
                      "DETAILED INSIGHTS",
                      style: TextStyle(
                        color: Color(0xFF075E54), // WhatsApp dark green
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),

              // Messages per user panel
              PanelWidget(
                title: "Messages per User",
                color: ColorUtils.whatsappLightBackground,
                icon: Icons.people_alt_rounded,
                content: MessagesPerUserWidget(messageData: widget.messageData),
              ),

              // First And Last Messages
              PanelWidget(
                title: "Messages per User",
                color: ColorUtils.whatsappLightBackground,
                icon: Icons.people_alt_rounded,
                content: FirstLastMessageWidget(
                  messageData: widget.messageData,
                ),
              ),

              // Top Words panel
              PanelWidget(
                title: "Top 100 Words",
                color: ColorUtils.whatsappLightBackground,
                icon: Icons.text_fields_rounded,
                content: TopWordsWidget(messageData: widget.messageData),
              ),

              // Emoji Analysis panel
              PanelWidget(
                title: "Emoji Analysis",
                color: ColorUtils.whatsappLightBackground,
                icon: Icons.emoji_emotions_rounded,
                content: EmojiAnalysisWidget(messageData: widget.messageData),
              ),

              // Hours(s) Analysis
              PanelWidget(
                title: "Hourly Activity",
                color: ColorUtils.whatsappLightBackground,
                icon: Icons.schedule_rounded,
                content: MostTalkedHoursWidget(messageData: widget.messageData),
              ),

              // Day(s) Analysis
              PanelWidget(
                title: "Most Active Days",
                color: ColorUtils.whatsappLightBackground,
                icon: Icons.calendar_today_rounded,
                content: MostTalkedDaysWidget(messageData: widget.messageData),
              ),

              // Months(s) Analysis
              PanelWidget(
                title: "Monthly Activity",
                color: ColorUtils.whatsappLightBackground,
                icon: Icons.date_range_rounded,
                content: ChatByMonthWidget(messageData: widget.messageData),
              ),

              // Year(s) Analysis
              PanelWidget(
                title: "Yearly Activity",
                color: ColorUtils.whatsappLightBackground,
                icon: Icons.date_range_rounded,
                content: ChatByYearWidget(messageData: widget.messageData),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
