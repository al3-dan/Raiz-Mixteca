import 'package:flutter_test/flutter_test.dart';
import 'package:raiz_mixteca/repositories/lote_repository.dart';

void main() {
  group('QR y código de lote', () {
    test('genera identificadores con prefijo LOT y seis dígitos', () {
      expect(LoteRepository.generarCodigoLote(1), 'LOT-000001');
      expect(LoteRepository.generarCodigoLote(12), 'LOT-000012');
      expect(LoteRepository.generarCodigoLote(123456), 'LOT-123456');
    });

    test('extrae el identificador de lote desde una URL o texto plano', () {
      expect(
        LoteRepository.extraerCodigoLote(
          'https://raizmixteca.example/lote/LOT-000021',
        ),
        'LOT-000021',
      );
      expect(LoteRepository.extraerCodigoLote('LOT-000002'), 'LOT-000002');
      expect(LoteRepository.extraerCodigoLote('ABC-999'), isNull);
    });
  });
}
