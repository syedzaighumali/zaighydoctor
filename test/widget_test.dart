import 'package:flutter_test/flutter_test.dart';

import 'package:doctorassistent/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SehatGuideApp());

    // Verify that the title is present on the screen.
    expect(find.text('Sehat Guide'), findsWidgets);
  });
}
