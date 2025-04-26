import 'package:flutter_test/flutter_test.dart';
import 'package:batman/batch_file.dart';
import 'dart:convert';

void main() {
  group('BatchFile Serialization Tests', () {
    test('Convert BatchFile to JSON', () {
      // Setup
      final batchFile = BatchFile(
        path: 'C:\\test\\example.bat',
        isRunning: true,
      );

      // Execute
      final json = batchFile.toJson();

      // Verify
      expect(json, isA<Map<String, dynamic>>());
      expect(json['path'], 'C:\\test\\example.bat');
      expect(json['isRunning'], false); // toJson always returns false
    });

    test('Convert JSON to BatchFile', () {
      // Setup
      final json = {
        'path': 'C:\\test\\example.bat',
        'isRunning': true, // This value is ignored
      };

      // Execute
      final batchFile = BatchFile.fromJson(json);

      // Verify
      expect(batchFile, isA<BatchFile>());
      expect(batchFile.path, 'C:\\test\\example.bat');
      expect(batchFile.isRunning, false); // fromJson always sets false
    });

    test('Serialize and deserialize BatchFile list', () {
      // Setup
      final batchFiles = [
        BatchFile(path: 'C:\\test\\first.bat'),
        BatchFile(path: 'C:\\test\\second.bat'),
        BatchFile(path: 'C:\\test\\third.bat'),
      ];

      // Execute: Serialize
      final jsonList = batchFiles.map((file) => file.toJson()).toList();
      final encodedString = jsonEncode(jsonList);

      // Execute: Deserialize
      final decodedList = jsonDecode(encodedString) as List<dynamic>;
      final decodedBatchFiles =
          decodedList
              .map((item) => BatchFile.fromJson(item as Map<String, dynamic>))
              .toList();

      // Verify
      expect(jsonList.length, 3);
      expect(decodedBatchFiles.length, 3);
      expect(decodedBatchFiles[0].path, 'C:\\test\\first.bat');
      expect(decodedBatchFiles[1].path, 'C:\\test\\second.bat');
      expect(decodedBatchFiles[2].path, 'C:\\test\\third.bat');
      expect(decodedBatchFiles.every((file) => file.isRunning == false), true);
    });

    test('Serialize and deserialize empty list', () {
      // Setup
      final emptyList = <BatchFile>[];

      // Execute: Serialize
      final jsonList = emptyList.map((file) => file.toJson()).toList();
      final encodedString = jsonEncode(jsonList);

      // Execute: Deserialize
      final decodedList = jsonDecode(encodedString) as List<dynamic>;
      final decodedBatchFiles =
          decodedList
              .map((item) => BatchFile.fromJson(item as Map<String, dynamic>))
              .toList();

      // Verify
      expect(jsonList.isEmpty, true);
      expect(decodedBatchFiles.isEmpty, true);
    });
  });
}
