import 'package:chatlytics/models/data.dart';
import 'package:chatlytics/widgets/colors.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AIAnalysisPage extends StatefulWidget {
  final Data messageData;

  const AIAnalysisPage({super.key, required this.messageData});

  @override
  State<AIAnalysisPage> createState() => _AIAnalysisPageState();
}

class _AIAnalysisPageState extends State<AIAnalysisPage> {
  DateTime? selectedDate;
  bool isAnalyzing = false;
  String? aiSummary;
  bool isServiceReady = false;
  String? sentiment;
  List<String> topics = [];
  Map<String, dynamic>? analysisData;

  // static const String backendUrl = 'http://10.0.2.2:8000';
  static const String backendUrl = 'https://chatlytics-ai-hp8o.onrender.com';

  @override
  void initState() {
    super.initState();
    _testAIConnection();
  }

  // Wake Service Up
  Future<void> _wakeUpServiceIfNeeded() async {
    if (!isServiceReady) {
      try {
        // Call the wake endpoint first
        final wakeResponse = await http
            .get(Uri.parse('$backendUrl/wake'))
            .timeout(const Duration(seconds: 60));

        if (wakeResponse.statusCode == 200) {
          await _testAIConnection();
        }
      } catch (e) {
        // Ignore
      }
    }
  }

  // Test AI connection to FastAPI backend
  Future<void> _testAIConnection() async {
    try {
      final response = await http
          .get(Uri.parse('$backendUrl/test_connection'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            isServiceReady = true;
          });
        } else {
          _showErrorSnackBar("AI service test failed: ${data['message']}");
        }
      } else {
        _showErrorSnackBar(
          "AI service connection failed. Status: ${response.statusCode}",
        );
      }
    } catch (e) {
      _showErrorSnackBar("AI service error: Cannot connect to backend");
    }
  }

  // Check health of the backend service
  Future<void> _checkHealth() async {
    try {
      final response = await http
          .get(Uri.parse('$backendUrl/health'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['gemini_model_loaded'] == false) {
          _showErrorSnackBar(
            "Gemini model not loaded. Check API key configuration.",
          );
        }
      }
    } catch (e) {
      // Ignore
    }
  }

  Future<void> _analyzeDay() async {
    if (selectedDate == null) return;

    setState(() {
      isAnalyzing = true;
      aiSummary = null;
      analysisData = null;
    });

    try {
      // Wake up service if needed
      await _wakeUpServiceIfNeeded();

      // Get messages for the selected date
      final dateKey = _getDateKey(selectedDate!);

      final messagesForDate = widget.messageData.messagesByDate[dateKey] ?? [];

      if (messagesForDate.isEmpty) {
        setState(() {
          isAnalyzing = false;
          aiSummary = "No messages found for ${_formatDate(selectedDate!)}.";
          analysisData = {
            'messageCount': 0,
            'sentiment': 'Neutral',
            'topics': <String>[],
            'wordCount': 0,
            'avgMessageLength': 0.0,
          };
        });
        return;
      }

      // Convert Message objects to strings for AI analysis
      final messageStrings =
          messagesForDate
              .map((message) => "${message.sender}: ${message.message}")
              .toList();

      // Call the FastAPI backend with extended timeout
      await _analyzeMessages(messageStrings);
    } catch (e) {
      if (mounted) {
        setState(() {
          isAnalyzing = false;
          aiSummary =
              "Analysis failed due to an unexpected error:\n$e\n\nPlease check your internet connection and try again.";
          analysisData = {
            'messageCount': 0,
            'sentiment': 'Error',
            'topics': <String>[],
            'wordCount': 0,
            'avgMessageLength': 0.0,
          };
        });
        _showErrorSnackBar("Analysis failed: ${e.toString()}");
      }
    }
  }

  // Method to analyse messages
  Future<void> _analyzeMessages(List<String> messages) async {
    if (!mounted) return;

    setState(() {
      isAnalyzing = true;
    });

    try {
      final response = await http
          .post(
            Uri.parse('$backendUrl/analyze_chat/'),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"messages": messages}),
          )
          .timeout(const Duration(seconds: 90)); // Extended timeout

      if (!mounted) return;

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        setState(() {
          aiSummary = data['summary'];
          sentiment = data['sentiment'];
          topics = List<String>.from(data['topics'] ?? []);
          analysisData = {
            'messageCount': data['messageCount'] ?? 0,
            'wordCount': data['wordCount'] ?? 0,
            'avgMessageLength': (data['avgMessageLength'] ?? 0.0).toDouble(),
            'sentiment': data['sentiment'] ?? 'Neutral',
            'topics': data['topics'] ?? [],
          };
        });

        if (data['error'] != null) {
          _showErrorSnackBar(
            "Analysis completed with warnings: ${data['error']}",
          );
        } else {
          _showSuccessSnackBar("Analysis completed successfully!");
        }
      } else {
        final errorData = jsonDecode(response.body);
        _showErrorSnackBar(
          "AI analysis failed: ${errorData['detail'] ?? response.body}",
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar("Error during analysis: ${e.toString()}");
      }
    } finally {
      if (mounted) {
        setState(() {
          isAnalyzing = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: const Text(
            'AI Daily Analysis',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: const Color(0xFF25D366),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 24, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isServiceReady ? Icons.cloud_done : Icons.cloud_off,
              color: Colors.white,
            ),
            onPressed: () {
              if (isServiceReady) {
                _checkHealth();
                _showSuccessSnackBar("AI service is ready (Google Gemini)");
              } else {
                _showErrorSnackBar(
                  "AI service not available. Server Maintanance is scheduled.",
                );
              }
            },
          ),
        ],
      ),
      backgroundColor: ColorUtils.whatsappDivider,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!isServiceReady) _buildServiceWarning(),
                _buildDateSelector(),
                const SizedBox(height: 20),
                if (selectedDate != null) ...[
                  _buildAnalyzeButton(),
                  const SizedBox(height: 20),
                ],
                if (isAnalyzing) _buildLoadingWidget(),
                if (aiSummary != null && !isAnalyzing) _buildAnalysisResults(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceWarning() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border.all(color: Colors.orange.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "AI service not ready. Please wait a few seconds for the services to load.",
              style: TextStyle(
                color: Colors.orange.shade700,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF25D366).withAlpha(26),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  color: Color(0xFF25D366),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Select Date to Analyze",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2C34),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Choose a specific date to get AI insights about your conversations on that day.",
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF667781),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _selectDate,
              icon: const Icon(Icons.date_range_rounded),
              label: Text(
                selectedDate != null
                    ? _formatDate(selectedDate!)
                    : "Choose Date",
                style: const TextStyle(fontSize: 16),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF25D366),
                side: const BorderSide(color: Color(0xFF25D366), width: 2),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyzeButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: (isAnalyzing || !isServiceReady) ? null : _analyzeDay,
        icon: const Icon(Icons.psychology_rounded, size: 20),
        label: Text(
          !isServiceReady
              ? "AI Service Not Ready"
              : isAnalyzing
              ? "Analyzing..."
              : "Analyze with AI",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              !isServiceReady ? Colors.grey.shade400 : const Color(0xFF25D366),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF25D366)),
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          const Text(
            "Analyzing your chats...",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2C34),
            ),
          ),
          const SizedBox(height: 8),
          if (selectedDate != null)
            Text(
              "Processing messages from ${_formatDate(selectedDate!)}",
              style: const TextStyle(fontSize: 14, color: Color(0xFF667781)),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 12),
          const Text(
            "This may take 15-30 seconds...",
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF667781),
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisResults() {
    return Column(
      children: [
        _buildSummaryCard(),
        const SizedBox(height: 16),
        _buildInsightsGrid(),
        if (analysisData != null &&
            analysisData!['topics'] != null &&
            (analysisData!['topics'] as List).isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildTopicsCard(),
        ],
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF128C7E), Color(0xFF25D366)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF25D366).withAlpha(77),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(51),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  selectedDate != null
                      ? "AI Summary - ${_formatDate(selectedDate!)}"
                      : "AI Summary",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(51),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "Gemini",
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            aiSummary ?? "No summary available",
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsGrid() {
    if (analysisData == null) return const SizedBox.shrink();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInsightCard(
                "Messages",
                "${analysisData!['messageCount'] ?? 0}",
                Icons.chat_bubble_rounded,
                const Color(0xFF34B7F1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInsightCard(
                "Words",
                "${analysisData!['wordCount'] ?? 0}",
                Icons.notes_rounded,
                const Color(0xFF9B59B6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildInsightCard(
                "Sentiment",
                _extractSentiment(
                  analysisData!['sentiment']?.toString() ?? "Neutral",
                ),
                _getSentimentIcon(
                  analysisData!['sentiment']?.toString() ?? "Neutral",
                ),
                _getSentimentColor(
                  analysisData!['sentiment']?.toString() ?? "Neutral",
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInsightCard(
                "Avg Length",
                "${(analysisData!['avgMessageLength'] ?? 0.0).toStringAsFixed(0)} chars",
                Icons.straighten_rounded,
                const Color(0xFFE67E22),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTopicsCard() {
    final topics = analysisData!['topics'] as List? ?? [];
    if (topics.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE74C3C).withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.topic_rounded,
                  color: Color(0xFFE74C3C),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Key Topics Discussed",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2C34),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                topics
                    .take(5)
                    .map(
                      (topic) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE74C3C).withAlpha(26),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFE74C3C).withAlpha(77),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          topic.toString(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFE74C3C),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF667781),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2C34),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF25D366),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF1F2C34),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        aiSummary = null;
        analysisData = null;
      });
    }
  }

  String _getDateKey(DateTime date) {
    // Format date to match both DD/MM/YY and DD/MM/YYYY formats
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final shortYear = year.substring(2);
    
    // Try both formats when looking up messages
    final yyFormat = "$day/$month/$shortYear";
    final yyyyFormat = "$day/$month/$year";
    
    // Return the format that exists in messagesByDate, defaulting to YY format
    return widget.messageData.messagesByDate.containsKey(yyyyFormat) ? yyyyFormat : yyFormat;
  }

  String _extractSentiment(String sentimentText) {
    // Extract clean sentiment from AI response
    final text = sentimentText.toLowerCase();
    if (text.contains('positive')) return 'Positive';
    if (text.contains('negative')) return 'Negative';
    if (text.contains('neutral')) return 'Neutral';
    return sentimentText; // Return as-is if no clear sentiment found
  }

  IconData _getSentimentIcon(String sentiment) {
    final clean = _extractSentiment(sentiment).toLowerCase();
    switch (clean) {
      case 'positive':
        return Icons.sentiment_very_satisfied_rounded;
      case 'negative':
        return Icons.sentiment_dissatisfied_rounded;
      case 'neutral':
      default:
        return Icons.sentiment_neutral_rounded;
    }
  }

  Color _getSentimentColor(String sentiment) {
    final clean = _extractSentiment(sentiment).toLowerCase();
    switch (clean) {
      case 'positive':
        return const Color(0xFF27AE60);
      case 'negative':
        return const Color(0xFFE74C3C);
      case 'neutral':
      default:
        return const Color(0xFFF39C12);
    }
  }

  String _formatDate(DateTime date) {
    const List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }
}
