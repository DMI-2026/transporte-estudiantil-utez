// Modelos alineados a docs/05-datos.md y firestore.rules
export type ReservaEstado = "pendientePago" | "reservada" | "cancelada" | "abordada";
export type SalidaEstado = "programada" | "enCurso" | "finalizada" | "cancelada";
export type ReporteEstado = "abierto" | "enRevision" | "cerrado";

export interface ReservaDocument {
  // Id documento: {salidaId}_{estudianteId}
  salidaId: string;
  estudianteId: string;
  paradaId: string;
  estado: ReservaEstado;
  creadaEn: FirebaseFirestore.Timestamp;
  actualizadoEn?: FirebaseFirestore.Timestamp;
  abordadaEn?: FirebaseFirestore.Timestamp;
  motivoCancelacion?: string;
}

export interface SalidaDocument {
  rutaId: string;
  operadorId: string;
  fechaHoraSalida: FirebaseFirestore.Timestamp;
  estado: SalidaEstado;
  asientosTotales: number;
  asientosDisponibles: number;
  ubicacionActual?: FirebaseFirestore.GeoPoint;
  actualizadoEn?: FirebaseFirestore.Timestamp;
  qrGenerado?: boolean;
  qrGeneradoEn?: FirebaseFirestore.Timestamp;
  abordados?: number;
  iniciadaEn?: FirebaseFirestore.Timestamp;
  finalizadaEn?: FirebaseFirestore.Timestamp;
}

export interface RutaDocument {
  nombre: string;
  descripcion: string;
  activa: boolean;
  polyline?: string; // encoded polyline (Routes/ORS)
  creadoEn: FirebaseFirestore.Timestamp;
  actualizadoEn?: FirebaseFirestore.Timestamp;
}

export interface ParadaDocument {
  rutaId: string;
  nombre: string;
  orden: number;
  ubicacion: FirebaseFirestore.GeoPoint;
  activa: boolean;
}

export interface ReporteDocument {
  reportadoPor: string;
  tipo: string;
  descripcion: string;
  estado: ReporteEstado;
  creadoEn: FirebaseFirestore.Timestamp;
  salidaId?: string;
  fotoUrl?: string;
  actualizadoEn?: FirebaseFirestore.Timestamp;
}
