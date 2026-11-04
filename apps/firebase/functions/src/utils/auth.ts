// Utilidades de Auth - Custom claims, verificación de roles
import { getAuth } from "firebase-admin/auth";

const auth = getAuth();

export type UserRole = "estudiante" | "operador" | "admin";

export interface UserCustomClaims {
  rol: UserRole;
  verificado: boolean;
  operadorSalidaId?: string;
}

/**
 * Establece custom claims para un usuario
 */
export async function setUserRole(uid: string, role: UserRole, verified = true): Promise<void> {
  await auth.setCustomUserClaims(uid, {
    rol: role,
    verificado: verified,
  });
}

/**
 * Quita custom claims (usuario rechazado/eliminado)
 */
export async function clearUserClaims(uid: string): Promise<void> {
  await auth.setCustomUserClaims(uid, { verificado: false });
}

/**
 * Asigna salida a operador (para reglas QR privado)
 */
export async function assignOperadorSalida(uid: string, salidaId: string): Promise<void> {
  const user = await auth.getUser(uid);
  const currentClaims = (user.customClaims as UserCustomClaims) || { rol: "operador", verificado: true };
  await auth.setCustomUserClaims(uid, {
    ...currentClaims,
    operadorSalidaId: salidaId,
  });
}

/**
 * Remueve asignación de salida a operador
 */
export async function removeOperadorSalida(uid: string): Promise<void> {
  const user = await auth.getUser(uid);
  const currentClaims = (user.customClaims as UserCustomClaims) || { rol: "operador", verificado: true };
  const { operadorSalidaId, ...rest } = currentClaims;
  await auth.setCustomUserClaims(uid, rest);
}

/**
 * Verifica si un uid tiene rol admin (útil en callable functions)
 */
export async function isAdmin(uid: string): Promise<boolean> {
  const user = await auth.getUser(uid);
  return (user.customClaims?.rol as UserRole) === "admin";
}

/**
 * Verifica si un uid tiene rol operador
 */
export async function isOperador(uid: string): Promise<boolean> {
  const user = await auth.getUser(uid);
  return (user.customClaims?.rol as UserRole) === "operador";
}

/**
 * Obtiene claims completos de un usuario
 */
export async function getUserClaims(uid: string): Promise<UserCustomClaims | null> {
  const user = await auth.getUser(uid);
  return user.customClaims as UserCustomClaims | null;
}