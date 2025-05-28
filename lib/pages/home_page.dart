import 'package:chatlytics/models/data.dart';
import 'package:chatlytics/models/message.dart';
import 'package:chatlytics/services/whatsapp.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_handler/share_handler.dart';
import 'dart:async';
import 'dart:io';
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
  late StreamSubscription _intentDataStreamSubscription;

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
      "Sunday": 0,
      "Monday": 0,
      "Tuesday": 0,
      "Wednesday": 0,
      "Thursday": 0,
      "Friday": 0,
      "Saturday": 0,
    },
    yearCount: {},
    firstMessage: Message(date: '', time: '', sender: '', message: ''),
    lastMessage: Message(date: '', time: '', sender: '', message: ''),
    highestDayStreak: 0,
    longestStreak: null,
    allStreaks: [],
    messagesByDate: {},
  );

  @override
  void initState() {
    super.initState();
    _initializeShareIntent();
  }

  void _initializeShareIntent() {
    // Listen to shared media
    _intentDataStreamSubscription = ShareHandler.instance.sharedMediaStream
        .listen(
          (SharedMedia media) {
            if (media.attachments?.isNotEmpty == true) {
              final attachment = media.attachments!.first;
              if (attachment?.path != null) {
                _handleSharedFile(attachment!.path);
              }
            }
          },
          onError: (err) {
            // Ignore
          },
        );

    // Handle initial shared content (when app is launched via share)
    ShareHandler.instance.getInitialSharedMedia().then((SharedMedia? media) {
      if (media?.attachments?.isNotEmpty == true) {
        final attachment = media!.attachments!.first;
        if (attachment?.path != null) {
          _handleSharedFile(attachment!.path);
        }
      }
    });
  }

  void _handleSharedFile(String filePath) async {
    // Check if the file is a zip file
    if (!filePath.toLowerCase().endsWith('.zip')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please share a valid WhatsApp chat export (.zip file)',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _isFileSelected = true;
      _fileName = filePath.split('/').last;
    });

    try {
      // Verify the file exists
      File file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File not found');
      }

      attributes = await obj.getAttributes(filePath);

      setState(() {
        _isLoading = false;
      });

      _analyzeChat();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isFileSelected = false;
        _fileName = '';
      });

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error processing shared file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickFile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );

      if (result != null) {
        setState(() {
          _isFileSelected = true;
          _fileName = result.files.first.name;
        });

        String? filePath = result.files.first.path;
        attributes = await obj.getAttributes(filePath);

        setState(() {
          _isLoading = false;
        });

        _analyzeChat();
      } else {
        // User canceled the picker
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _analyzeChat() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AnalysisPage(messageData: attributes),
      ),
    );
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.sizeOf(context);

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
                    Image.asset('assets/img/chatlytics-logo-transparent.png'),

                    SizedBox(height: media.height * 0.03),

                    const Text(
                      'Upload your exported WhatsApp chat to get detailed analytics and insights',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),

                    SizedBox(height: media.height * 0.03),

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
                                          SizedBox(height: media.height * 0.02),
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
                          SizedBox(height: media.height * 0.03),
                          const Text(
                            'Supports only .zip files\nYou can also share files directly to this app!',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),

                    // Instructions
                    SizedBox(height: media.height * 0.05),

                    const Text(
                      'How to export your WhatsApp chat:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(height: media.height * 0.02),

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
                      'Share the exported file directly to Chatlytics or tap above to browse',
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
