import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pos_kasir/app.dart';

void main() {
  testWidgets('App launches without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: PosKasirApp()));
    expect(find.byType(PosKasirApp), findsOneWidget);
  });
}
