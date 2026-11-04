// Modelos compartidos para Reservas, Salidas, Rutas, Paradas
export type ReservaEstado = "pendientePago" | "reservada" | "cancelada" | "abordada";
export type SalidaEstado = "programada" | "enCurso" | "finalizada" | "cancelada";
export type ReporteEstado = "abierto" | "enRevision" | "cerrado";

export interface ReservaDocument {
  uid: string; // {salidaId}_{usuarioId}
  salidaId: string;
  usuarioId: string;
  usuarioNombre: string;
  asiento: number;
  estado: ReservaEstado;
  monto: number;
  metodoPago?: string;
  creadaEn: FirebaseFirestore.Timestamp;
  pagadaEn?: FirebaseFirestore.Timestamp;
  abordadaEn?: FirebaseFirestore.Timestamp;
  canceladaEn?: FirebaseFirestore.Timestamp;
  canceladaPor?: "usuario" | "operador" | "admin" | "sistema";
  motivoCancelacion?: string;
}

export interface SalidaDocument {
  rutaId: string;
  horaSalida: FirebaseFirestore.Timestamp;
  cupoTotal: number;
  cuposDisponibles: number;
  operadorId: string;
  vehiculoId: string;
  estado: SalidaEstado;
  qrGenerado: boolean;
  qrGeneradoEn?: FirebaseFirestore.Timestamp;
  abordados: number;
  ubicacion?: FirebaseFirestore.GeoPoint;
  velocidad?: number;
  rumbo?: number;
  ubicacionActualizadaEn?: FirebaseFirestore.Timestamp;
  iniciadaEn?: FirebaseFirestore.Timestamp;
  finalizadaEn?: FirebaseFirestore.Timestamp;
  creadaEn: FirebaseFirestore.Timestamp;
  creadaPor: string;
}

export interface RutaDocument {
  nombre: string;
  descripcion: string;
  polilinea: FirebaseFirestore.GeoPoint[]; // Puntos de la ruta
  paradas: ParadaReference[]; // Ordenadas
  activa: boolean;
  creadaEn: FirebaseFirestore.Timestamp;
}

export interface ParadaReference {
  paradaId: string;
  orden: number;
  tiempoEstimadoMin: number; // Minutos desde salida
}

export interface ParadaDocument {
  nombre: string;
  direccion: string;
  ubicacion: FirebaseFirestore.GeoPoint;
  rutaIds: string[]; // Qué rutas pasan por aquí
  activa: boolean;
}

export interface VehiculoDocument {
  placa: string;
  modelo: string;
  capacidad: number;
  operadorId?: string; // Asignado actualmente
  activo: boolean;
}

export interface ReporteDocument {
  uid: string;
  tipo: "incidente" | "sugerencia" | "felicitacion" | "otro";
  titulo: string;
  descripcion: string;
  usuarioId: string;
  usuarioNombre: string;
  salidaId?: string;
  rutaId?: string;
  paradaId?: string;
  fotosUrls: string[];
  estado: ReporteEstado;
  prioridad: "baja" | "media" | "alta" | "critica";
  creadaEn: FirebaseFirestore.Timestamp;
  actualizadaEn: FirebaseFirestore.Timestamp;
  asignadoA?: string;
  resueltoEn?: FirebaseFirestore.Timestamp;
  resolucion?: string;
}