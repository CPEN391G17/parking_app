import 'package:flutter_test/flutter_test.dart';
import 'package:parking_app/models/parking_user.dart';

void main() {
  test('Create parking user and modify', () async {
    
    final parkingUser = new ParkingUser(
        uid: 'uid', email: 'email', displayName: 'name', lpn: 'lpn');

    // check if user created
    expect(parkingUser.uid, "uid");
    expect(parkingUser.email, "email");
    expect(parkingUser.displayName, "name");
    expect(parkingUser.lpn, "lpn");

    // modify
    parkingUser.uid = "newUid";
    parkingUser.email = "newEmail";
    parkingUser.displayName = "newName";
    parkingUser.lpn = "newLpn";

    // check for modification
    expect(parkingUser.uid, "newUid");
    expect(parkingUser.email, "newEmail");
    expect(parkingUser.displayName, "newName");
    expect(parkingUser.lpn, "newLpn");
  });
}
