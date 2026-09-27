import 'package:flutter_test/flutter_test.dart';

import 'package:raiz_mixteca/main.dart';

void main() {
  testWidgets('La aplicación RaízMixteca inicia correctamente', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RaizMixtecaApp());

    expect(find.text('RaízMixteca'), findsNWidgets(2));

    expect(
      find.text('Productos artesanales y trazabilidad de la región Mixteca'),
      findsOneWidget,
    );
  });
}
