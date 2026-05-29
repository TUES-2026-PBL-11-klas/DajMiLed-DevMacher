import 'package:flutter_test/flutter_test.dart';

import 'package:devmatch_client/main.dart';

void main() {
  testWidgets('renders DevMatch match screen', (tester) async {
    await tester.pumpWidget(const DevMatchApp());

    expect(find.text('DevMatch'), findsOneWidget);
    expect(find.text('Recommended tasks'), findsOneWidget);
    expect(find.text('Apply'), findsWidgets);
  });
}
