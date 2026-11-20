// Utilidades de Auth - Custom claims, verificación de roles
import { getAuth } from "firebase-admin/auth";

const auth = getAuth();

export type UserRole = "estudiante" | "operador" | "administrador";

export interface UserCustomClaims {
  rol: UserRole;
  verificado: boolean;
  operadorSalidaId?: string;
}

export async function setUserRole(uid: string, role: UserRole, verified = true): Promise<void> {
  await auth.setCustomUserClaims(uid, {
    rol: role,
    verificado: verified,
  });
}

export async function clearUserClaims(uid: string): Promise<void> {
  await auth.setCustomUserClaims(uid, { verificado: false });
}

export async function assignOperadorSalida(uid: string, salidaId: string): Promise<void> {
  const user = await auth.getUser(uid);
  const currentClaims = (user.customClaims as UserCustomClaims) || {
    rol: "operador",
    verificado: true,
  };
  await auth.setCustomUserClaims(uid, {
    ...currentClaims,
    operadorSalidaId: salidaId,
  });
}

export async function removeOperadorSalida(uid: string): Promise<void> {
  const user = await auth.getUser(uid);
  const currentClaims = (user.customClaims as UserCustomClaims) || {
    rol: "operador",
    verificado: true,
  };
  const { operadorSalidaId: _omit, ...rest } = currentClaims;
  await auth.setCustomUserClaims(uid, rest);
}

export async function isAdmin(uid: string): Promise<boolean> {
  const user = await auth.getUser(uid);
  return (user.customClaims?.rol as UserRole) === "administrador";
}

export async function isOperador(uid: string): Promise<boolean> {
  const user = await auth.getUser(uid);
  return (user.customClaims?.rol as UserRole) === "operador";
}

export async function getUserClaims(uid: string): Promise<UserCustomClaims | null> {
  const user = await auth.getUser(uid);
  return user.customClaims as UserCustomClaims | null;
}
