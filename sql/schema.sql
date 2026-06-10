-- ====================================================================
-- E-COMMERCE PERFORMANCE DASHBOARD - DATABASE SCHEMA (schema.sql)
-- Target Database: PostgreSQL (easily adaptable to MySQL)
-- ====================================================================

-- --------------------------------------------------------------------
-- Drop tables in reverse order of dependencies (if they exist)
-- --------------------------------------------------------------------
DROP TABLE IF EXISTS returns;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS calendar;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS channels;

-- --------------------------------------------------------------------
-- 1. CHANNELS TABLE
-- Meta-data for sales platforms and commissions.
-- --------------------------------------------------------------------
CREATE TABLE channels (
    channel_id VARCHAR(10) PRIMARY KEY,
    channel_name VARCHAR(50) NOT NULL UNIQUE,
    platform_fee_pct NUMERIC(5, 4) NOT NULL CONSTRAINT chk_platform_fee CHECK (platform_fee_pct >= 0 AND platform_fee_pct <= 1)
);

-- Comment block for documentation (supported in PG)
COMMENT ON TABLE channels IS 'Sales channels where orders can originate, including platform commission rates.';

-- --------------------------------------------------------------------
-- 2. PRODUCTS TABLE
-- Catalog containing 150 items across 6 categories.
-- --------------------------------------------------------------------
CREATE TABLE products (
    product_id VARCHAR(10) PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    cost NUMERIC(10, 2) NOT NULL CONSTRAINT chk_product_cost CHECK (cost >= 0),
    price NUMERIC(10, 2) NOT NULL CONSTRAINT chk_product_price CHECK (price >= 0),
    sku VARCHAR(50) NOT NULL UNIQUE,
    CONSTRAINT chk_margin_safety CHECK (price > cost)
);

COMMENT ON TABLE products IS 'Product catalog with cost price and selling price margins.';

-- --------------------------------------------------------------------
-- 3. CUSTOMERS TABLE
-- Customer profiles, demographic locations, and signup details.
-- --------------------------------------------------------------------
CREATE TABLE customers (
    customer_id VARCHAR(10) PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(50),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(2) NOT NULL,
    zip_code VARCHAR(15) NOT NULL,
    country VARCHAR(50) NOT NULL DEFAULT 'United States',
    region VARCHAR(20) NOT NULL CONSTRAINT chk_customer_region CHECK (region IN ('Northeast', 'Midwest', 'South', 'West')),
    signup_date DATE NOT NULL
);

COMMENT ON TABLE customers IS 'Customer profiles, demographic locations, and signup dates.';

-- --------------------------------------------------------------------
-- 4. CALENDAR TABLE
-- Date dimension helper table covering exactly 2024-01-01 to 2025-12-31.
-- --------------------------------------------------------------------
CREATE TABLE calendar (
    date DATE PRIMARY KEY,
    year INT NOT NULL,
    quarter INT NOT NULL CONSTRAINT chk_calendar_quarter CHECK (quarter BETWEEN 1 AND 4),
    month INT NOT NULL CONSTRAINT chk_calendar_month CHECK (month BETWEEN 1 AND 12),
    month_name VARCHAR(20) NOT NULL,
    day INT NOT NULL CONSTRAINT chk_calendar_day CHECK (day BETWEEN 1 AND 31),
    day_of_week INT NOT NULL CONSTRAINT chk_calendar_dow CHECK (day_of_week BETWEEN 1 AND 7),
    day_name VARCHAR(20) NOT NULL,
    is_weekend INT NOT NULL CONSTRAINT chk_calendar_weekend CHECK (is_weekend IN (0, 1))
);

COMMENT ON TABLE calendar IS 'Date dimension helper table for e-commerce performance analytics.';

-- --------------------------------------------------------------------
-- 5. ORDERS TABLE
-- Transactional ledger containing 10,000 order records.
-- --------------------------------------------------------------------
CREATE TABLE orders (
    order_id VARCHAR(10) PRIMARY KEY,
    customer_id VARCHAR(10) NOT NULL REFERENCES customers(customer_id) ON DELETE RESTRICT,
    product_id VARCHAR(10) NOT NULL REFERENCES products(product_id) ON DELETE RESTRICT,
    channel_id VARCHAR(10) NOT NULL REFERENCES channels(channel_id) ON DELETE RESTRICT,
    order_date DATE NOT NULL REFERENCES calendar(date) ON DELETE RESTRICT,
    quantity INT NOT NULL CONSTRAINT chk_order_qty CHECK (quantity > 0),
    unit_price NUMERIC(10, 2) NOT NULL CONSTRAINT chk_unit_price CHECK (unit_price >= 0),
    discount_pct NUMERIC(4, 2) NOT NULL CONSTRAINT chk_discount_pct CHECK (discount_pct >= 0 AND discount_pct <= 1),
    shipping_cost NUMERIC(10, 2) NOT NULL CONSTRAINT chk_shipping CHECK (shipping_cost >= 0),
    order_status VARCHAR(20) NOT NULL CONSTRAINT chk_order_status CHECK (order_status IN ('Completed', 'Returned', 'Refunded', 'Cancelled')),
    total_amount NUMERIC(10, 2) NOT NULL CONSTRAINT chk_total_amount CHECK (total_amount >= 0)
);

COMMENT ON TABLE orders IS 'Main transactional order database capturing items, pricing, discounts, shipping, and order status.';

-- --------------------------------------------------------------------
-- 6. RETURNS TABLE
-- Returns logs detailing returned order lines and reasonings.
-- --------------------------------------------------------------------
CREATE TABLE returns (
    return_id VARCHAR(10) PRIMARY KEY,
    order_id VARCHAR(10) NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    return_date DATE NOT NULL REFERENCES calendar(date) ON DELETE RESTRICT,
    return_reason VARCHAR(50) NOT NULL CONSTRAINT chk_return_reason CHECK (return_reason IN ('Damaged Item', 'Wrong Size', 'Late Delivery', 'Changed Mind', 'Product Not as Described', 'Defective Item')),
    refund_amount NUMERIC(10, 2) NOT NULL CONSTRAINT chk_refund_amount CHECK (refund_amount >= 0)
);

COMMENT ON TABLE returns IS 'Log of returned orders, reason codes, and processed refunds.';

-- --------------------------------------------------------------------
-- DATABASE INDEXES FOR PERFORMANCE OPTIMIZATION
-- Designed for analytical queries, aggregations, and dashboard filters.
-- --------------------------------------------------------------------

-- Index on order_date to speed up sales timeline queries, daily/monthly aggregations
CREATE INDEX idx_orders_order_date ON orders(order_date);

-- Indexes on foreign keys for high performance table joins
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_product_id ON orders(product_id);
CREATE INDEX idx_orders_channel_id ON orders(channel_id);

-- Index on region (customers table) to accelerate regional performance analysis
CREATE INDEX idx_customers_region ON customers(region);

-- Index on product category to support category sales aggregations
CREATE INDEX idx_products_category ON products(category);

-- Index on order status to optimize filter operations for completed/cancelled/returned orders
CREATE INDEX idx_orders_status ON orders(order_status);
