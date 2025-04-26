import 'dart:async';
import 'dart:io';

class BatchFile {
  final String path;
  bool isRunning;
  Process? process;
  StreamSubscription? stdoutSubscription;
  StreamSubscription? stderrSubscription;
  Timer? statusCheckTimer;
  DateTime? startTime;

  BatchFile({
    required this.path,
    this.isRunning = false,
    this.process,
    this.startTime,
  });

  void dispose() {
    stdoutSubscription?.cancel();
    stderrSubscription?.cancel();
    statusCheckTimer?.cancel();
    process?.kill();
  }

  Map<String, dynamic> toJson() {
    return {'path': path, 'isRunning': false};
  }

  factory BatchFile.fromJson(Map<String, dynamic> json) {
    return BatchFile(path: json['path'], isRunning: false);
  }

  String getRunningTime() {
    if (!isRunning || startTime == null) {
      return "";
    }

    final difference = DateTime.now().difference(startTime!);
    final minutes = difference.inMinutes;
    final seconds = difference.inSeconds % 60;

    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }
}
