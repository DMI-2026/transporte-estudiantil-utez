import 'package:transporte_estudiantil/src/core/errors/app_failure.dart';
import 'package:transporte_estudiantil/src/features/incidents/domain/entities/reporte.dart';
import 'package:transporte_estudiantil/src/features/operator/domain/entities/pasajero.dart';
import 'package:transporte_estudiantil/src/features/operator/domain/entities/perfil_operador.dart';
import 'package:transporte_estudiantil/src/features/operator/domain/entities/salida_operador.dart';
import 'package:transporte_estudiantil/src/features/operator/domain/repositories/operator_repository.dart';

abstract final class FixturesOperador {
  static final salida = SalidaOperador(
    id: 'SAL-001',
    rutaCodigo: 'R01',
    rutaNombre: 'Centro de Cuernavaca — UTEZ',
    fecha: DateTime(2026, 10, 26),
    horaSalida: '06:40',
    horaLlegada: '07:25',
    unidad: 'Combi 01',
    cupoTotal: 16,
    reservas: 2,
    abordados: 0,
    paradas: const [
      ParadaRecorrido(nombre: 'Centro', hora: '06:40'),
      ParadaRecorrido(nombre: 'Las Palmas', hora: '06:52'),
      ParadaRecorrido(nombre: 'UTEZ', hora: '07:25'),
    ],
  );

  static const pasajeros = [
    Pasajero(
      folio: 'UTEZ-1048',
      nombre: 'Mariana L.',
      parada: 'Centro',
      estado: EstadoAbordaje.abordada,
    ),
    Pasajero(
      folio: 'UTEZ-1050',
      nombre: 'Sofía L.',
      parada: 'Centro',
      estado: EstadoAbordaje.reservada,
    ),
  ];

  static final perfil = PerfilOperador(
    nombre: 'Carlos Méndez Ruiz',
    numero: 'OP-007',
    correo: 'carlos.operador@example.com',
    telefono: '777 000 0707',
    direccion: 'Calle del Transporte 7',
    unidad: 'Combi 01',
    cupoUnidad: 16,
    contactoNombre: 'Rosa Ruiz Torres',
    contactoParentesco: 'Madre',
    contactoTelefono: '777 000 0710',
    licencia: 'DEMO-LIC-007',
    vigenciaLicencia: DateTime(2027, 12, 31),
    documentos: const ['ine_carlos_demo.pdf'],
  );
}

class FakeOperatorRepository implements OperatorRepository {
  FakeOperatorRepository({
    List<SalidaOperador>? salidas,
    List<Pasajero>? pasajeros,
    List<Reporte>? reportes,
    this.failure,
    this.actionFailure,
    this.siguienteLectura,
  }) : salidas = salidas ?? [FixturesOperador.salida],
       pasajeros = pasajeros ?? FixturesOperador.pasajeros,
       reportes = reportes ?? [];

  List<SalidaOperador> salidas;
  List<Pasajero> pasajeros;
  List<Reporte> reportes;
  AppFailure? failure;
  AppFailure? actionFailure;

  /// Resultado que devolverá la próxima lectura simulada.
  LecturaQr? siguienteLectura;
  NuevoReporte? ultimoReporte;

  SalidaOperador _buscar(String id) => salidas.firstWhere((s) => s.id == id);

  SalidaOperador _cambiar(String id, SalidaOperador Function(SalidaOperador) f) {
    final nueva = f(_buscar(id));
    salidas = [for (final s in salidas) s.id == id ? nueva : s];
    return nueva;
  }

  OperatorResult<T> _ok<T>(T value) => (value: value, failure: null);
  OperatorResult<T> _err<T>(AppFailure f) => (value: null, failure: f);

  @override
  Future<OperatorResult<List<SalidaOperador>>> fetchSalidas() async =>
      failure != null ? _err(failure!) : _ok(salidas);

  @override
  Future<OperatorResult<SalidaOperador>> fetchSalida(String id) async =>
      failure != null ? _err(failure!) : _ok(_buscar(id));

  @override
  Future<OperatorResult<SalidaOperador>> fetchSalidaActiva() async =>
      failure != null ? _err(failure!) : _ok(salidas.first);

  @override
  Future<OperatorResult<SalidaOperador>> iniciarRecorrido(String id) async {
    if (actionFailure != null) return _err(actionFailure!);
    return _ok(
      _cambiar(
        id,
        (s) => s.copyWith(estado: EstadoSalida.enCurso, iniciadaA: s.horaSalida),
      ),
    );
  }

  @override
  Future<OperatorResult<SalidaOperador>> marcarLlegada(String id) async {
    if (actionFailure != null) return _err(actionFailure!);
    return _ok(
      _cambiar(
        id,
        (s) => s.copyWith(indiceParadaActual: s.indiceParadaActual + 1),
      ),
    );
  }

  @override
  Future<OperatorResult<SalidaOperador>> finalizarRecorrido(String id) async {
    if (actionFailure != null) return _err(actionFailure!);
    return _ok(
      _cambiar(
        id,
        (s) => s.copyWith(estado: EstadoSalida.finalizada, finalizadaA: s.horaLlegada),
      ),
    );
  }

  @override
  Future<OperatorResult<List<Pasajero>>> fetchPasajeros(String salidaId) async =>
      failure != null ? _err(failure!) : _ok(pasajeros);

  @override
  Future<OperatorResult<LecturaQr>> leerQrSimulado(String salidaId) async {
    if (actionFailure != null) return _err(actionFailure!);
    return _ok(
      siguienteLectura ??
          LecturaQr.valida(
            pasajero: pasajeros.last.abordar(),
            salida: _cambiar(salidaId, (s) => s.copyWith(abordados: s.abordados + 1)),
          ),
    );
  }

  @override
  Future<OperatorResult<List<Reporte>>> fetchMisReportes() async =>
      failure != null ? _err(failure!) : _ok(reportes);

  @override
  Future<OperatorResult<Reporte>> enviarReporte(NuevoReporte reporte) async {
    if (actionFailure != null) return _err(actionFailure!);
    ultimoReporte = reporte;
    final creado = Reporte(
      folio: 'INC-200',
      tipo: reporte.tipo,
      descripcion: reporte.descripcion,
      referencia: reporte.referencia,
      fecha: DateTime(2026, 10, 26, 7),
      estado: EstadoReporte.abierto,
    );
    reportes = [creado, ...reportes];
    return _ok(creado);
  }

  @override
  Future<OperatorResult<PerfilOperador>> fetchPerfil() async =>
      failure != null ? _err(failure!) : _ok(FixturesOperador.perfil);
}
