import '../../../../core/errors/app_failure.dart';
import '../../../incidents/domain/entities/reporte.dart';
import '../../domain/entities/pasajero.dart';
import '../../domain/entities/perfil_operador.dart';
import '../../domain/entities/salida_operador.dart';
import 'operator_datasource.dart';

/// Datos de DEMOSTRACIÓN del operador (Figma "02 App Operador").
/// No usa Firebase, GPS ni cámara. La lectura de QR es simulada: la tercera
/// lectura devuelve un QR no válido para poder revisar la pantalla 12.
class DemoOperatorDataSource implements OperatorDataSource {
  DemoOperatorDataSource({this.latencia = const Duration(milliseconds: 400)});

  final Duration latencia;

  static final fechaDemo = DateTime(2026, 10, 26);

  final Map<String, SalidaOperador> _salidas = {
    'SAL-001': SalidaOperador(
      id: 'SAL-001',
      rutaCodigo: 'R01',
      rutaNombre: 'Centro de Cuernavaca — UTEZ',
      fecha: fechaDemo,
      horaSalida: '06:40',
      horaLlegada: '07:25',
      unidad: 'Combi 01',
      cupoTotal: 16,
      reservas: 12,
      abordados: 0,
      paradas: const [
        ParadaRecorrido(nombre: 'Centro', hora: '06:40'),
        ParadaRecorrido(nombre: 'Las Palmas', hora: '06:52'),
        ParadaRecorrido(nombre: 'Temixco Centro', hora: '07:10'),
        ParadaRecorrido(nombre: 'UTEZ', hora: '07:25'),
      ],
    ),
    'SAL-005': SalidaOperador(
      id: 'SAL-005',
      rutaCodigo: 'R01',
      rutaNombre: 'UTEZ — Centro de Cuernavaca',
      fecha: fechaDemo,
      horaSalida: '14:10',
      horaLlegada: '14:55',
      unidad: 'Combi 01',
      cupoTotal: 16,
      reservas: 9,
      abordados: 0,
      paradas: const [
        ParadaRecorrido(nombre: 'UTEZ', hora: '14:10'),
        ParadaRecorrido(nombre: 'Temixco Centro', hora: '14:25'),
        ParadaRecorrido(nombre: 'Las Palmas', hora: '14:43'),
        ParadaRecorrido(nombre: 'Centro', hora: '14:55'),
      ],
    ),
  };

  final Map<String, List<Pasajero>> _pasajeros = {
    'SAL-001': [
      for (final (folio, nombre, parada) in const [
        ('UTEZ-1048', 'Mariana L.', 'Centro'),
        ('UTEZ-1049', 'Diego R.', 'Centro'),
        ('UTEZ-1050', 'Sofía L.', 'Centro'),
        ('UTEZ-1051', 'Carlos V.', 'Centro'),
        ('UTEZ-1052', 'Lucía N.', 'Centro'),
        ('UTEZ-1053', 'Andrea P.', 'Las Palmas'),
        ('UTEZ-1054', 'Jorge M.', 'Las Palmas'),
        ('UTEZ-1055', 'Valeria C.', 'Las Palmas'),
        ('UTEZ-1056', 'Iván T.', 'Temixco Centro'),
        ('UTEZ-1057', 'Paola G.', 'Temixco Centro'),
        ('UTEZ-1058', 'Hugo S.', 'Temixco Centro'),
        ('UTEZ-1059', 'Renata F.', 'Temixco Centro'),
      ])
        Pasajero(
          folio: folio,
          nombre: nombre,
          parada: parada,
          estado: EstadoAbordaje.reservada,
        ),
    ],
    'SAL-005': [
      for (var i = 0; i < 9; i++)
        Pasajero(
          folio: 'UTEZ-11${(i + 10).toString()}',
          nombre: 'Estudiante ${i + 1}',
          parada: 'UTEZ',
          estado: EstadoAbordaje.reservada,
        ),
    ],
  };

  final Map<String, int> _lecturas = {};
  int _siguienteReporte = 27;

  final List<Reporte> _reportes = [
    Reporte(
      folio: 'INC-026',
      tipo: 'Luz interior sin funcionar',
      descripcion:
          'La luz interior trasera no enciende. Reporto con la unidad detenida en Las Palmas.',
      referencia: 'SAL-001 · Combi 01 · Carlos M.',
      fecha: DateTime(2026, 10, 26, 6, 52),
      estado: EstadoReporte.abierto,
    ),
    Reporte(
      folio: 'INC-021',
      tipo: 'Limpieza de la unidad',
      descripcion: 'Se derramó una bebida en el pasillo.',
      referencia: 'R01 · Combi 01 · Carlos M.',
      fecha: DateTime(2026, 10, 21, 7, 30),
      estado: EstadoReporte.cerrado,
      actualizacion:
          'La limpieza se completó el 21 oct a las 12:00. Administración registró el cierre.',
    ),
  ];

  Future<void> _red() => Future<void>.delayed(latencia);

  SalidaOperador _buscar(String id) {
    final salida = _salidas[id];
    if (salida == null) {
      throw const GenericFailure('No encontramos esa salida.');
    }
    final abordados = _pasajeros[id]!
        .where((p) => p.estado == EstadoAbordaje.abordada)
        .length;
    return salida.copyWith(abordados: abordados);
  }

  SalidaOperador _guardar(SalidaOperador salida) {
    _salidas[salida.id] = salida;
    return _buscar(salida.id);
  }

  @override
  Future<List<SalidaOperador>> fetchSalidas() async {
    await _red();
    return [for (final id in _salidas.keys) _buscar(id)];
  }

  @override
  Future<SalidaOperador> fetchSalida(String id) async {
    await _red();
    return _buscar(id);
  }

  @override
  Future<SalidaOperador> fetchSalidaActiva() async {
    await _red();
    final todas = [for (final id in _salidas.keys) _buscar(id)];
    for (final estado in [EstadoSalida.enCurso, EstadoSalida.programada]) {
      for (final s in todas) {
        if (s.estado == estado) return s;
      }
    }
    throw const GenericFailure('No tienes salidas activas por ahora.');
  }

  @override
  Future<SalidaOperador> iniciarRecorrido(String id) async {
    await _red();
    final salida = _buscar(id);
    if (salida.estado != EstadoSalida.programada) {
      throw const GenericFailure('Este recorrido ya se inició.');
    }
    final otraEnCurso = _salidas.values.any(
      (s) => s.estado == EstadoSalida.enCurso,
    );
    if (otraEnCurso) {
      throw const GenericFailure(
        'Finaliza el recorrido en curso antes de iniciar otro.',
      );
    }
    return _guardar(
      salida.copyWith(
        estado: EstadoSalida.enCurso,
        indiceParadaActual: 0,
        iniciadaA: salida.horaSalida,
      ),
    );
  }

  @override
  Future<SalidaOperador> marcarLlegada(String id) async {
    await _red();
    final salida = _buscar(id);
    if (salida.estado != EstadoSalida.enCurso) {
      throw const GenericFailure('Primero inicia el recorrido.');
    }
    if (salida.enUltimaParada) {
      throw const GenericFailure('Ya llegaste a la última parada.');
    }
    return _guardar(
      salida.copyWith(indiceParadaActual: salida.indiceParadaActual + 1),
    );
  }

  @override
  Future<SalidaOperador> finalizarRecorrido(String id) async {
    await _red();
    final salida = _buscar(id);
    if (salida.estado != EstadoSalida.enCurso) {
      throw const GenericFailure('Este recorrido no está en curso.');
    }
    return _guardar(
      salida.copyWith(
        estado: EstadoSalida.finalizada,
        indiceParadaActual: salida.paradas.length - 1,
        finalizadaA: salida.horaLlegada,
      ),
    );
  }

  @override
  Future<List<Pasajero>> fetchPasajeros(String salidaId) async {
    await _red();
    _buscar(salidaId);
    return List.unmodifiable(_pasajeros[salidaId]!);
  }

  @override
  Future<LecturaQr> leerQrSimulado(String salidaId) async {
    await _red();
    final salida = _buscar(salidaId);
    if (salida.estado == EstadoSalida.finalizada) {
      throw const GenericFailure('Esta salida ya finalizó.');
    }
    final lectura = _lecturas[salidaId] = (_lecturas[salidaId] ?? 0) + 1;
    if (lectura == 3) {
      return LecturaQr.invalida(
        motivo:
            'La reserva está cancelada, no tiene pago aprobado o corresponde a otra salida.',
        salida: salida,
      );
    }
    final lista = _pasajeros[salidaId]!;
    final indice = lista.indexWhere((p) => p.estado == EstadoAbordaje.reservada);
    if (indice < 0) {
      return LecturaQr.invalida(
        motivo: 'Todas las reservas de esta salida ya abordaron.',
        salida: salida,
      );
    }
    final abordado = lista[indice].abordar();
    lista[indice] = abordado;
    return LecturaQr.valida(pasajero: abordado, salida: _buscar(salidaId));
  }

  @override
  Future<List<Reporte>> fetchMisReportes() async {
    await _red();
    return List.unmodifiable(_reportes);
  }

  @override
  Future<Reporte> enviarReporte(NuevoReporte reporte) async {
    await _red();
    final nuevo = Reporte(
      folio: 'INC-0${_siguienteReporte++}',
      tipo: reporte.tipo,
      descripcion: reporte.descripcion.trim(),
      referencia: reporte.referencia,
      fecha: DateTime.now(),
      estado: EstadoReporte.abierto,
      evidencia: reporte.evidencia,
    );
    _reportes.insert(0, nuevo);
    return nuevo;
  }

  @override
  Future<PerfilOperador> fetchPerfil() async {
    await _red();
    return PerfilOperador(
      nombre: 'Carlos Méndez Ruiz',
      numero: 'OP-007',
      correo: 'carlos.operador@example.com',
      telefono: '777 000 0707',
      direccion: 'Calle del Transporte 7, Col. Centro, Temixco, Morelos',
      unidad: 'Combi 01',
      cupoUnidad: 16,
      contactoNombre: 'Rosa Ruiz Torres',
      contactoParentesco: 'Madre',
      contactoTelefono: '777 000 0710',
      licencia: 'DEMO-LIC-007',
      vigenciaLicencia: DateTime(2027, 12, 31),
      documentos: const [
        'ine_carlos_demo.pdf · 1.1 MB',
        'licencia_carlos_demo.pdf · 0.8 MB',
        'domicilio_carlos_demo.pdf · 0.6 MB',
      ],
    );
  }
}
