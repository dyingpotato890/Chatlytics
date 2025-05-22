import 'package:chatlytics/models/data.dart';
import 'package:chatlytics/models/message.dart';
import 'package:chatlytics/services/whatsapp.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'analysis_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = false;
  bool _isFileSelected = false;
  String _fileName = '';

  final Whatsapp obj = Whatsapp();

  Data attributes = Data(
    messageCount: 0,
    wordCount: 0,
    userMessagesCount: {},
    mediaShared: 0,
    activeDays: 0,
    participants: 0,
    mostUsedWords: {},
    mostUsedEmojies: {},
    mostTalkedDays: {},
    mostTalkedHours: {},
    monthCount: {},
    weekCount: {
      "Sunday" : 0,
      "Monday" : 0,
      "Tuesday" : 0,
      "Wednesday" : 0,
      "Thursday" : 0,
      "Friday" : 0,
      "Saturday" : 0,
    },
    yearCount: {},
    firstMessage: Message(date: '', time: '', sender: '', message: ''),
    lastMessage: Message(date: '', time: '', sender: '', message: ''),
  );

  Future<void> _pickFile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result != null) {
        setState(() {
          _isFileSelected = true;
          _fileName = result.files.first.name;
        });

        String? filePath = result.files.first.path;
        attributes = await obj.getAttributes(filePath);
      }
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking file: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _analyzeChat() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => AnalysisPage(messageData: attributes,)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF075E54),
              Color(0xFF128C7E),
            ], // WhatsApp green gradient
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo and app name
                    const Icon(
                      Icons.chat_bubble_outline,
                      size: 80,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'WhatsApp Chat Analyzer',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Upload your exported WhatsApp chat to get detailed analytics and insights',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    const SizedBox(height: 48),

                    // Upload area
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(26),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: _isLoading ? null : _pickFile,
                            child: Container(
                              padding: const EdgeInsets.all(30),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFE0E0E0),
                                  width: 2,
                                ),
                              ),
                              child:
                                  _isLoading
                                      ? const CircularProgressIndicator(
                                        color: Color(0xFF075E54),
                                      )
                                      : Column(
                                        children: [
                                          Icon(
                                            _isFileSelected
                                                ? Icons.check_circle
                                                : Icons.cloud_upload,
                                            size: 60,
                                            color:
                                                _isFileSelected
                                                    ? const Color(0xFF075E54)
                                                    : Colors.grey,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            _isFileSelected
                                                ? _fileName
                                                : 'Tap to select your exported chat file',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color:
                                                  _isFileSelected
                                                      ? const Color(0xFF075E54)
                                                      : Colors.grey[700],
                                              fontWeight:
                                                  _isFileSelected
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Supports .zip, .rar, and .txt files',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _isFileSelected ? _analyzeChat : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF075E54),
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Analyze Chat',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Instructions
                    const SizedBox(height: 48),
                    const Text(
                      'How to export your WhatsApp chat:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInstructionStep('1', 'Open the chat in WhatsApp'),
                    _buildInstructionStep(
                      '2',
                      'Tap the three dots menu and select "More"',
                    ),
                    _buildInstructionStep(
                      '3',
                      'Choose "Export chat" and select "Without media"',
                    ),
                    _buildInstructionStep(
                      '4',
                      'Share the exported file to this app',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(51),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
