import 'package:flutter_test/flutter_test.dart';

import 'package:raiz_mixteca/main.dart';

void main() {
  testWidgets('La aplicación RaízMixteca inicia correctamente', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RaizMixtecaApp());

    expect(find.text('RaízMixteca'), findsOneWidget);
  });
}
