// Punto de entrada principal - exporta todas las Cloud Functions
import * as functions from "firebase-functions";

// API endpoints por feature
export * from "./api/pagos";
export * from "./api/qr";
export * from "./api/notificaciones";
export * from "./api/admin";
export * from "./api/catalogo";

// Triggers de Firestore (reaccionan a cambios en BD)
export * from "./triggers/reservas";
export * from "./triggers/salidas";
export * from "./triggers/reportes";