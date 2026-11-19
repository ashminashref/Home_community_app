import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mahal/app/app.dart';
import 'package:mahal/app/config.dart';

void main() {
  testWidgets('Mahal app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MahalApp(),
      ),
    );

    // Initial pump
    await tester.pump();

    // Verify App Name renders
    expect(find.text(AppConfig.appName), findsOneWidget);
  });
}
