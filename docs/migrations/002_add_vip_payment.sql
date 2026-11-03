ALTER TABLE users ADD COLUMN IF NOT EXISTS is_vip BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS vip_expires_at TIMESTAMP;

CREATE TABLE IF NOT EXISTS payment_orders (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    order_code BIGINT NOT NULL UNIQUE,
    amount BIGINT NOT NULL,
    plan_code VARCHAR(50) NOT NULL,
    status VARCHAR(20) NOT NULL,
    checkout_url TEXT,
    qr_code TEXT,
    created_at TIMESTAMP NOT NULL,
    paid_at TIMESTAMP,
    vip_expires_at TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_payment_orders_user_id ON payment_orders(user_id);
CREATE INDEX IF NOT EXISTS idx_payment_orders_status ON payment_orders(status);
