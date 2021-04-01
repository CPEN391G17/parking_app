import 'package:flutter_test/flutter_test.dart';
import 'package:parking_app/models/parking.dart';

void main() {
  test('Create parking and modify ...', () async {
    final parking = Parking(
        pid: 'pid',
        ppid: 'ppid',
        count: 5,
        lat: null,
        lng: null,
        qrValue: 'qrValue');

    // check if parking created
    expect(parking.pid, 'pid');
    expect(parking.ppid, 'ppid');
    expect(parking.count, 5);
    expect(parking.qrValue, 'qrValue');

    // modify parking
    parking.pid = 'newPid';
    parking.ppid = 'newPpid';
    parking.count = 10;
    parking.qrValue = 'newQrValue';

    // check modified parking
    expect(parking.pid, 'newPid');
    expect(parking.ppid, 'newPpid');
    expect(parking.count, 10);
    expect(parking.qrValue, 'newQrValue');
  });
}
