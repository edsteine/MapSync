// import 'package:flutter_test/flutter_test.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:mobile/core/services/storage_service.dart';

// void main() {
//   late Storage storage;

//   setUp(() async {
//     SharedPreferences.setMockInitialValues({});
//     storage = Storage();
//     await storage.init();
//   });

//   group('Storage Tests', () {
//     test('saves and retrieves string value', () async {
//       await storage.saveString('test_key', 'test_value');
//       expect(storage.getString('test_key'), 'test_value');
//     });

//     test('saves and retrieves bool value', () async {
//       await storage.saveBool('test_key', true);
//       expect(storage.getBool('test_key'), true);
//     });

//     test('clear removes all data', () async {
//       await storage.saveString('test_key', 'test_value');
//       await storage.clearAll();
//       expect(storage.getString('test_key'), null);
//     });
//   });
// }
