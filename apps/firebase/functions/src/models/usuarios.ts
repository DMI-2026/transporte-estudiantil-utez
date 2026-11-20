// Modelos de usuarios alineados a docs/05-datos.md
export type UserRole = "estudiante" | "operador" | "administrador";

export type VerificationStatus = "pendiente" | "aprobada" | "rechazada";

export interface UserDocument {
  email: string;
  nombreCompleto?: string;
  rol: UserRole;
  estadoVerificacion: VerificationStatus;
  creadoEn: FirebaseFirestore.Timestamp;
  actualizadoEn?: FirebaseFirestore.Timestamp;
  telefono?: string;
  matricula?: string;
  carrera?: string;
  contactoEmergencia?: {
    nombre: string;
    parentesco: string;
    telefono: string;
  };
  preferenciasNotificacion?: {
    recordatoriosSalida: boolean;
    estadoReportes: boolean;
    avisosGenerales: boolean;
  };
  fotoCredencialUrl?: string;
}

export interface UserCustomClaims {
  rol: UserRole;
  verificado: boolean;
  operadorSalidaId?: string;
}

export interface DeviceTokenDocument {
  fcmToken: string;
  plataforma: "android" | "ios" | "web";
  actualizadoEn: FirebaseFirestore.Timestamp;
}
