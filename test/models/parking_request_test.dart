import 'package:flutter_test/flutter_test.dart';
import 'package:parking_app/models/parking_request.dart';

void main() {
  test('Create parking request and modify', () async {
    final parkingRequest = ParkingRequest(
        prid: 'prid',
        uid: 'uid',
        pid: 'pid',
        ppid: 'ppid',
        timeOfBooking: DateTime.now());

    // check if parking request has been created
    expect(parkingRequest.prid, 'prid');
    expect(parkingRequest.uid, 'uid');
    expect(parkingRequest.pid, 'pid');
    expect(parkingRequest.ppid, 'ppid');

    // modify the fields
    parkingRequest.prid = 'newPrid';
    parkingRequest.uid = 'newUid';
    parkingRequest.pid = 'newPid';
    parkingRequest.ppid = 'newPpid';

    // check if modification occured
    expect(parkingRequest.prid, 'newPrid');
    expect(parkingRequest.uid, 'newUid');
    expect(parkingRequest.pid, 'newPid');
    expect(parkingRequest.ppid, 'newPpid');
  });
}
