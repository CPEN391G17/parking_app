import 'package:flutter_test/flutter_test.dart';
import 'package:parking_app/models/parking_provider.dart';

void main() {
  test('create parking provider and modify', () async {
    final parkingProvider = ParkingProvider(
        ppid: 'ppid', email: 'email', displayName: 'name', parking: null);

    // check if parking provider created
    expect(parkingProvider.ppid, 'ppid');
    expect(parkingProvider.email, 'email');
    expect(parkingProvider.displayName, 'name');

    // modify parking provider
    parkingProvider.ppid = 'newPpid';
    parkingProvider.email = 'newEmail';
    parkingProvider.displayName = 'newName';

    // check if parking provider modified
    expect(parkingProvider.ppid, 'newPpid');
    expect(parkingProvider.email, 'newEmail');
    expect(parkingProvider.displayName, 'newName');
  });
}
