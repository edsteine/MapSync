// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/mockito.dart';
// import 'package:mobile/core/network.dart';
// import 'package:mobile/core/storage.dart';
// import 'package:mobile/features/map/repositories/map_repository.dart';

// class MockNetworkClient extends Mock implements NetworkClient {}
// class MockStorage extends Mock implements Storage {}

// void main() {
//   late MapRepository repository;
//   late MockNetworkClient mockNetwork;
//   late MockStorage mockStorage;

//   setUp(() {
//     mockNetwork = MockNetworkClient();
//     mockStorage = MockStorage();
//     repository = MapRepository(mockNetwork, mockStorage);
//   });

//   group('MapRepository Tests', () {
//     final testMarkers = [
//       {'id': '1', 'latitude': 0.0, 'longitude': 0.0, 'title': 'Test'}
//     ];

//     test('getMapMarkers returns cached data when available', () async {
//       when(mockStorage.getMapData('markers')).thenReturn(testMarkers);

//       final result = await repository.getMapMarkers();

//       expect(result, equals(testMarkers));
//       verify(mockStorage.getMapData('markers')).called(1);
//       verifyNever(mockNetwork.get('/markers'));
//     });

//     test('getMapMarkers fetches new data when force refresh', () async {
//       when(mockNetwork.get('/markers'))
//           .thenAnswer((_) async => Response(data: testMarkers));

//       final result = await repository.getMapMarkers(forceRefresh: true);

//       expect(result, equals(testMarkers));
//       verify(mockNetwork.get('/markers')).called(1);
//       verify(mockStorage.saveMapData('markers', testMarkers)).called(1);
//     });
//   });
// }
