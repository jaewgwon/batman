import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_size/window_size.dart' as window_size;
import 'package:batman/batch_file.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    window_size.setWindowTitle('Batman');
    window_size.setWindowMinSize(const Size(600, 400));
    window_size.setWindowMaxSize(Size.infinite);
  }

  runApp(const BatchManagerApp());
}

class BatchManagerApp extends StatelessWidget {
  const BatchManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Batman',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const BatchManagerHome(title: 'Batman: Batch File Manager'),
    );
  }
}

class BatchManagerHome extends StatefulWidget {
  const BatchManagerHome({super.key, required this.title});

  final String title;

  @override
  State<BatchManagerHome> createState() => _BatchManagerHomeState();
}

class _BatchManagerHomeState extends State<BatchManagerHome> {
  final List<BatchFile> _batchFiles = [];
  static const String _storageKey = 'batch_files';

  @override
  void initState() {
    super.initState();
    _loadBatchFiles();
  }

  @override
  void dispose() {
    for (var file in _batchFiles) {
      file.dispose();
    }
    super.dispose();
  }

  Future<void> _loadBatchFiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? batchFilesJson = prefs.getString(_storageKey);

      if (batchFilesJson != null) {
        final List<dynamic> decodedList = jsonDecode(batchFilesJson);
        setState(() {
          _batchFiles.clear();
          for (var item in decodedList) {
            _batchFiles.add(BatchFile.fromJson(item));
          }
        });
      }
    } catch (e) {
      debugPrint('Batch file loading error: $e');
    }
  }

  Future<void> _saveBatchFiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> jsonList =
          _batchFiles.map((file) => file.toJson()).toList();
      final String encodedList = jsonEncode(jsonList);
      await prefs.setString(_storageKey, encodedList);
    } catch (e) {
      debugPrint('Batch file saving error: $e');
    }
  }

  Future<void> _addBatchFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['bat', 'cmd'],
    );

    if (result != null) {
      String filePath = result.files.single.path!;
      setState(() {
        _batchFiles.add(BatchFile(path: filePath));
      });
      _saveBatchFiles();
    }
  }

  Future<void> _toggleBatchFile(int index) async {
    BatchFile batchFile = _batchFiles[index];

    if (batchFile.isRunning) {
      _stopBatchFile(batchFile);
    } else {
      await _startBatchFile(batchFile);
    }
  }

  Future<void> _startBatchFile(BatchFile batchFile) async {
    try {
      Process process = await Process.start('cmd.exe', [
        '/c',
        batchFile.path,
      ], mode: ProcessStartMode.normal);

      setState(() {
        batchFile.isRunning = true;
        batchFile.process = process;
      });

      batchFile.stdoutSubscription = process.stdout.listen((_) {});
      batchFile.stderrSubscription = process.stderr.listen((_) {});

      process.exitCode
          .then((exitCode) {
            if (mounted) {
              setState(() {
                batchFile.isRunning = false;
                batchFile.process = null;
              });
              batchFile.stdoutSubscription?.cancel();
              batchFile.stderrSubscription?.cancel();
            }
          })
          .catchError((error) {
            if (mounted) {
              setState(() {
                batchFile.isRunning = false;
                batchFile.process = null;
              });
              batchFile.stdoutSubscription?.cancel();
              batchFile.stderrSubscription?.cancel();
            }
          });

      batchFile.statusCheckTimer = Timer.periodic(const Duration(seconds: 5), (
        timer,
      ) {
        _checkProcessStatus(batchFile, timer);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _stopBatchFile(BatchFile batchFile) {
    batchFile.process?.kill();
    batchFile.stdoutSubscription?.cancel();
    batchFile.stderrSubscription?.cancel();
    batchFile.statusCheckTimer?.cancel();

    setState(() {
      batchFile.isRunning = false;
      batchFile.process = null;
    });
  }

  void _checkProcessStatus(BatchFile batchFile, Timer timer) {
    if (batchFile.process == null) {
      timer.cancel();

      if (batchFile.isRunning && mounted) {
        setState(() {
          batchFile.isRunning = false;
        });
      }
      return;
    }

    try {
      if (mounted) {
        batchFile.process?.exitCode.then((_) {}).catchError((_) {
          if (batchFile.isRunning && mounted) {
            setState(() {
              batchFile.isRunning = false;
              batchFile.process = null;
            });
            timer.cancel();
            batchFile.stdoutSubscription?.cancel();
            batchFile.stderrSubscription?.cancel();
          }
        });
      }
    } catch (e) {
      if (batchFile.isRunning && mounted) {
        setState(() {
          batchFile.isRunning = false;
          batchFile.process = null;
        });
        timer.cancel();
        batchFile.stdoutSubscription?.cancel();
        batchFile.stderrSubscription?.cancel();
      }
    }
  }

  void _removeBatchFile(int index) {
    BatchFile batchFile = _batchFiles[index];
    _stopBatchFile(batchFile);
    setState(() {
      _batchFiles.removeAt(index);
    });
    _saveBatchFiles();
  }

  // 모든 배치 파일 실행
  Future<void> _runAllBatchFiles() async {
    if (_batchFiles.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('실행할 배치 파일이 없습니다')));
      }
      return;
    }

    int startedCount = 0;

    // 각 배치 파일마다 실행
    for (final batchFile in _batchFiles) {
      // 이미 실행 중인 파일은 건너뜀
      if (!batchFile.isRunning) {
        await _startBatchFile(batchFile);
        startedCount++;
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$startedCount개 배치 파일 실행 시작')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'ADD BATCH FILE',
              onPressed: _addBatchFile,
            ),
          ),
        ],
      ),
      body:
          _batchFiles.isEmpty
              ? Center(
                child: Text(
                  '배치 파일을 추가해주세요.',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              )
              : ListView.builder(
                itemCount: _batchFiles.length,
                itemBuilder: (context, index) {
                  final batchFile = _batchFiles[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // 상태 표시 Marker
                          Container(
                            width: 16,
                            height: 16,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color:
                                  batchFile.isRunning
                                      ? Colors.green
                                      : Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          // 파일 정보
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  batchFile.path.split('\\').last,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  batchFile.path,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          // 액션 버튼
                          IconButton(
                            icon: Icon(
                              batchFile.isRunning
                                  ? Icons.stop
                                  : Icons.play_arrow,
                              color:
                                  batchFile.isRunning
                                      ? Colors.red
                                      : Colors.green,
                            ),
                            onPressed: () => _toggleBatchFile(index),
                            constraints: const BoxConstraints(minWidth: 40),
                            padding: EdgeInsets.zero,
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.grey),
                            onPressed: () => _removeBatchFile(index),
                            constraints: const BoxConstraints(minWidth: 40),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _runAllBatchFiles,
        tooltip: 'RUN ALL BATCH FILES',
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: const Icon(Icons.play_arrow),
      ),
    );
  }
}
