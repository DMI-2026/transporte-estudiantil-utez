// Servicio Mercado Pago - Wrapper tipado
import { createHmac, timingSafeEqual } from "node:crypto";
import { MercadoPagoConfig, Payment, Preference } from "mercadopago";
import { MercadoPagoPayment, MercadoPagoPreference } from "../models/pagos";

export class MercadoPagoService {
  private readonly preference: Preference;
  private readonly payment: Payment;

  constructor() {
    const accessToken = process.env.MERCADOPAGO_ACCESS_TOKEN;
    if (!accessToken) {
      throw new Error("MERCADOPAGO_ACCESS_TOKEN no configurado en Functions config");
    }

    const client = new MercadoPagoConfig({ accessToken });
    this.preference = new Preference(client);
    this.payment = new Payment(client);
  }

  async createPreference(params: {
    externalReference: string;
    amount: number;
    paymentMethodId: string;
    backUrls: { success: string; failure: string; pending: string };
  }): Promise<Preference> {
    return this.preference.create({
      body: {
        external_reference: params.externalReference,
        items: [
          {
            title: "Reserva de asiento transporte UTEZ",
            quantity: 1,
            unit_price: params.amount,
            currency_id: "MXN",
          },
        ],
        payment_methods: {
          default_payment_method_id: params.paymentMethodId,
          installments: 1,
        },
        back_urls: params.backUrls,
        auto_return: "approved",
        notification_url: `https://${process.env.GCLOUD_PROJECT}.cloudfunctions.net/mercadoPagoWebhook`,
      },
    }) as Promise<MercadoPagoPreference>;
  }

  async getPayment(paymentId: string): Promise<MercadoPagoPayment> {
    return this.payment.get({ id: paymentId }) as Promise<MercadoPagoPayment>;
  }

  async createRefund(paymentId: string, amount?: number): Promise<any> {
    return this.payment.refund({
      id: paymentId,
      ...(amount === undefined ? {} : { body: { amount } }),
    });
  }

  static verifySignature(
    dataId: string,
    requestId: string,
    signature: string,
    secret: string,
    nowSeconds = Math.floor(Date.now() / 1000),
  ): boolean {
    const values = new Map(
      signature.split(",").map((part) => {
        const [key, value] = part.trim().split("=", 2);
        return [key, value];
      }),
    );
    const timestamp = values.get("ts");
    const receivedHash = values.get("v1");
    const timestampNumber = Number(timestamp);

    if (
      !timestamp ||
      !receivedHash ||
      !Number.isSafeInteger(timestampNumber) ||
      Math.abs(nowSeconds - timestampNumber) > 5 * 60
    ) {
      return false;
    }

    const manifest = `id:${dataId};request-id:${requestId};ts:${timestamp};`;
    const expectedHash = createHmac("sha256", secret).update(manifest).digest("hex");
    const expected = Buffer.from(expectedHash, "hex");
    const received = Buffer.from(receivedHash, "hex");

    return expected.length === received.length && timingSafeEqual(expected, received);
  }
}