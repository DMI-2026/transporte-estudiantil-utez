// Utilidades de Firestore - Helpers para transacciones, queries, etc.
import { getFirestore, Transaction, WriteBatch, DocumentReference, Query, DocumentSnapshot } from "firebase-admin/firestore";

const db = getFirestore();

/**
 * Ejecuta transacción con reintentos automáticos
 */
export async function runTransactionWithRetry<T>(
  updateFn: (transaction: Transaction) => Promise<T>,
  maxAttempts = 3
): Promise<T> {
  let lastError: Error | null = null;

  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      return await db.runTransaction(updateFn);
    } catch (error) {
      lastError = error as Error;
      if (attempt === maxAttempts) break;
      // Backoff exponencial: 100ms, 200ms, 400ms...
      await new Promise((resolve) => setTimeout(resolve, 100 * 2 ** (attempt - 1)));
    }
  }

  throw lastError;
}

/**
 * Batch write con commit automático cada 500 operaciones (límite Firestore)
 */
export class BatchWriter {
  private batch = db.batch();
  private count = 0;
  private readonly maxBatchSize = 500;

  set(docRef: DocumentReference, data: any, options?: { merge?: boolean }) {
    this.batch.set(docRef, data, options);
    this.count++;
    if (this.count >= this.maxBatchSize) {
      this.flush();
    }
  }

  update(docRef: DocumentReference, data: any) {
    this.batch.update(docRef, data);
    this.count++;
    if (this.count >= this.maxBatchSize) {
      this.flush();
    }
  }

  delete(docRef: DocumentReference) {
    this.batch.delete(docRef);
    this.count++;
    if (this.count >= this.maxBatchSize) {
      this.flush();
    }
  }

  async flush() {
    if (this.count > 0) {
      await this.batch.commit();
      this.batch = db.batch();
      this.count = 0;
    }
  }

  async commit() {
    await this.flush();
  }
}

/**
 * Convierte DocumentSnapshot a tipo tipado
 */
export function docToData<T>(snap: DocumentSnapshot): T | null {
  if (!snap.exists) return null;
  return { uid: snap.id, ...snap.data() } as T;
}

/**
 * Convierte QuerySnapshot a array tipado
 */
export function queryToData<T>(snap: FirebaseFirestore.QuerySnapshot): T[] {
  return snap.docs.map((doc) => ({ uid: doc.id, ...doc.data() } as T));
}

/**
 * Cursor para paginación
 */
export interface PaginationResult<T> {
  data: T[];
  nextCursor: string | null;
  hasMore: boolean;
}

export async function paginateQuery<T>(
  query: Query,
  limit: number,
  cursor?: string
): Promise<PaginationResult<T>> {
  let q = query.limit(limit + 1);

  if (cursor) {
    const cursorDoc = await db.collection(query.firestore.collection(query.path).id).doc(cursor).get();
    if (cursorDoc.exists) {
      q = q.startAfter(cursorDoc);
    }
  }

  const snap = await q.get();
  const docs = snap.docs.slice(0, limit);
  const data = docs.map((doc) => ({ uid: doc.id, ...doc.data() } as T));
  const nextCursor = snap.docs.length > limit ? snap.docs[limit].id : null;

  return { data, nextCursor, hasMore: nextCursor !== null };
}