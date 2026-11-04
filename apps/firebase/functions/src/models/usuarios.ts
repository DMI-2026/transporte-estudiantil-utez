// Modelos compartidos para Usuarios y Roles
export type UserRole = "estudiante" | "operador" | "admin";

export type VerificationStatus = "pendiente" | "aprobada" | "rechazada";

export interface UserDocument {
  uid: string;
  email: string;
  displayName: string | null;
  rol: UserRole;
  estadoVerificacion: VerificationStatus;
  fotoCredencialUrl?: string;
  creadoEn: FirebaseFirestore.Timestamp;
  actualizadoEn: FirebaseFirestore.Timestamp;
  aprobadoEn?: FirebaseFirestore.Timestamp;
  aprobadoPor?: string;
  rechazadoEn?: FirebaseFirestore.Timestamp;
  rechazadoPor?: string;
  motivoRechazo?: string;
}

export interface UserCustomClaims {
  rol: UserRole;
  verificado: boolean;
  operadorSalidaId?: string; // Para reglas de QR privado
}

export interface DeviceTokenDocument {
  token: string;
  plataforma: "android" | "ios" | "web";
  appVersion: string;
  registradoEn: FirebaseFirestore.Timestamp;
  ultimoUsoEn: FirebaseFirestore.Timestamp;
}