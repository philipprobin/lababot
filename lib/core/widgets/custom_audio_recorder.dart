import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class CustomAudioRecorder extends StatefulWidget {
  final Function(String) onRecordingComplete;

  const CustomAudioRecorder({super.key, required this.onRecordingComplete});

  @override
  _CustomAudioRecorderState createState() => _CustomAudioRecorderState();
}

class _CustomAudioRecorderState extends State<CustomAudioRecorder> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  bool _isRecorderInitialized = false; // Recorder-Status verfolgen
  String? _filePath;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
  }

  /// Initialisiert den Recorder und fragt Berechtigungen ab.
  Future<void> _initializeRecorder() async {
    try {
      await _requestPermissions();

      if (!_isRecorderInitialized) {
        await _recorder.openRecorder();
        setState(() => _isRecorderInitialized = true);
      }
    } catch (e) {
      debugPrint("Recorder initialization failed: $e");
    }
  }

  /// Fragt Mikrofonberechtigungen an.
  Future<void> _requestPermissions() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }
  }

  /// Startet die Aufnahme.
  Future<void> _startRecording() async {
    if (!_isRecorderInitialized) {
      await _initializeRecorder();
    }

    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

    try {
      await _recorder.startRecorder(toFile: path, codec: Codec.aacMP4);
      setState(() {
        _isRecording = true;
        _filePath = path;
      });
    } catch (e) {
      debugPrint("Error starting recording: $e");
    }
  }


  /// Stoppt die Aufnahme und sendet den Pfad.
  Future<void> _stopRecording() async {
    try {
      await _recorder.stopRecorder();
      setState(() => _isRecording = false);

      if (_filePath != null) {
        widget.onRecordingComplete(_filePath!);
      }
    } catch (e) {
      debugPrint("Error stopping recording: $e");
    }
  }

  @override
  void dispose() {
    if (_isRecorderInitialized) {
      _recorder.closeRecorder();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          icon: Icon(
            _isRecording ? Icons.stop_circle : Icons.mic,
            size: 24,
            color: _isRecording ? Colors.red : Theme.of(context).primaryColor,
          ),
          onPressed: () {
            if (_isRecording) {
              _stopRecording();
            } else {
              _startRecording();
            }
          },
        ),
      ],
    );
  }
}
