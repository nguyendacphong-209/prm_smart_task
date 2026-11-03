# PayOS VIP Payment Setup

Configure these environment variables on the backend deployment (for example Render):

```env
PAYOS_CLIENT_ID=<PayOS Client ID>
PAYOS_API_KEY=<PayOS API Key>
PAYOS_CHECKSUM_KEY=<PayOS Checksum Key>
PAYOS_API_BASE_URL=https://api-merchant.payos.vn
PAYOS_RETURN_URL=<public frontend success URL>
PAYOS_CANCEL_URL=<public frontend cancel URL>
```

Recommended webhook URL in PayOS merchant settings:

```text
https://prm-smart-task-api.onrender.com/api/payments/payos/webhook
```

Apply migration:

```text
docs/migrations/002_add_vip_payment.sql
```

Never commit actual PayOS keys to the repository. Rotate keys if they have already been committed or shared in source control.
