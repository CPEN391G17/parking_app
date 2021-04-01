import 'package:flutter_test/flutter_test.dart';
import 'package:parking_app/models/coin.dart';

void main() {
  test('coin test', () async {
    final coin = Coin(amount: 100);

    // check amount
    expect(coin.amount, 100);

    // modify amount
    coin.amount = 200;

    // check modified amount
    expect(coin.amount, 200); 
  });
}
