import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transporte_estudiantil/src/features/profile/data/models/perfil_firestore_mapper.dart';
import 'package:transporte_estudiantil/src/features/profile/domain/entities/perfil_estudiante.dart';

void main() {
  group('PerfilFirestoreMapper', () {
    test('perfilDesde arma matrícula, teléfono y credencial', () {
      final perfil = PerfilFirestoreMapper.perfilDesde({
        'matricula': '202601234',
        'carrera': 'IDS',
        'telefono': '7770000234',
        'estadoVerificacion': 'aprobada',
        'credencialAprobadaEl': Timestamp.fromDate(DateTime(2026, 10, 21)),
        'contactoEmergencia': {
          'nombre': 'Ana',
          'parentesco': 'Madre',
          'telefono': '7770000235',
        },
      });

      expect(perfil, isNotNull);
      expect(perfil!.matricula, '202601234');
      expect(perfil.telefono, '7770000234');
      expect(perfil.credencial, EstadoCredencial.aprobada);
      expect(perfil.contactoEmergencia?.nombre, 'Ana');
    });

    test('perfilDesde rechaza verificación desconocida', () {
      expect(
        PerfilFirestoreMapper.perfilDesde({'estadoVerificacion': 'otro'}),
        isNull,
      );
    });

    test('preferenciasDesde usa defaults si faltan', () {
      final prefs = PerfilFirestoreMapper.preferenciasDesde(null);
      expect(prefs.recordatoriosSalida, isTrue);
      expect(prefs.estadoReportes, isTrue);
      expect(prefs.avisosGenerales, isFalse);
    });

    test('preferenciasAFirestore serializa los tres flags', () {
      const prefs = PreferenciasNotificacion(
        recordatoriosSalida: false,
        estadoReportes: true,
        avisosGenerales: true,
      );
      expect(PerfilFirestoreMapper.preferenciasAFirestore(prefs), {
        'recordatoriosSalida': false,
        'estadoReportes': true,
        'avisosGenerales': true,
      });
    });

    test('contactoDesde ignora mapas incompletos', () {
      expect(
        PerfilFirestoreMapper.contactoDesde({'nombre': 'Ana'}),
        isNull,
      );
    });
  });
}
