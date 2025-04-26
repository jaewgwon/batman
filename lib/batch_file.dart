import 'dart:async';
import 'dart:io';

class BatchFile {
  final String path;
  bool isRunning;
  Process? process;
  StreamSubscription? stdoutSubscription;
  StreamSubscription? stderrSubscription;
  Timer? statusCheckTimer;

  BatchFile({required this.path, this.isRunning = false, this.process});

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
}
