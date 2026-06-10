-- ====================================================================
-- E-COMMERCE PERFORMANCE DASHBOARD - DATA TRANSFORMATION & CLEANING (cleaning_queries.sql)
-- Target Database: PostgreSQL / MySQL
-- ====================================================================

-- --------------------------------------------------------------------
-- 1. DIMENSION VIEWS
-- Standardizes text fields, handles missing values, and creates business views.
-- --------------------------------------------------------------------

-- A. dim_customer View
CREATE OR REPLACE VIEW dim_customer AS
SELECT 
    customer_id,
    -- Standardize names and concatenate
    CONCAT(INITCAP(TRIM(first_name)), ' ', INITCAP(TRIM(last_name))) AS customer_name,
    LOWER(TRIM(email)) AS email,
    -- Handle missing phone numbers
    COALESCE(TRIM(phone), 'N/A') AS phone,
    INITCAP(TRIM(city)) AS city,
    UPPER(TRIM(state)) AS state,
    TRIM(zip_code) AS zip_code,
    INITCAP(TRIM(country)) AS country,
    -- Standardize and validate region
    CASE 
        WHEN TRIM(region) IN ('Northeast', 'Midwest', 'South', 'West') THEN TRIM(region)
        ELSE 'Other'
    END AS region,
    signup_date
FROM customers;

-- B. dim_product View
CREATE OR REPLACE VIEW dim_product AS
SELECT 
    product_id,
    INITCAP(TRIM(product_name)) AS product_name,
    INITCAP(TRIM(category)) AS category,
    cost,
    price,
    UPPER(TRIM(sku)) AS sku
FROM products;

-- C. dim_channel View
CREATE OR REPLACE VIEW dim_channel AS
SELECT 
    channel_id,
    -- Standardize channel name (e.g. WooCommerce, Shopify)
    CASE 
        WHEN LOWER(TRIM(channel_name)) = 'shopify' THEN 'Shopify'
        WHEN LOWER(TRIM(channel_name)) = 'amazon' THEN 'Amazon'
        WHEN LOWER(TRIM(channel_name)) = 'etsy' THEN 'Etsy'
        WHEN LOWER(TRIM(channel_name)) = 'woocommerce' THEN 'WooCommerce'
        WHEN LOWER(TRIM(channel_name)) = 'manual order' THEN 'Manual Order'
        ELSE INITCAP(TRIM(channel_name))
    END AS channel_name,
    platform_fee_pct
FROM channels;

-- D. dim_calendar View
CREATE OR REPLACE VIEW dim_calendar AS
SELECT 
    date,
    year,
    quarter,
    month,
    INITCAP(TRIM(month_name)) AS month_name,
    day,
    day_of_week,
    INITCAP(TRIM(day_name)) AS day_name,
    is_weekend
FROM calendar;


-- --------------------------------------------------------------------
-- 2. FACT SALES TABLE
-- Creates a clean physical fact table with all transformed and calculated fields.
-- We use a physical table instead of a view for performance in dashboards.
-- --------------------------------------------------------------------

DROP TABLE IF EXISTS fact_sales;

CREATE TABLE fact_sales (
    order_id VARCHAR(10) PRIMARY KEY,
    customer_id VARCHAR(10) NOT NULL,
    product_id VARCHAR(10) NOT NULL,
    channel_id VARCHAR(10) NOT NULL,
    order_date DATE NOT NULL,
    quantity INT NOT NULL,
    unit_price NUMERIC(10, 2) NOT NULL,
    discount_pct NUMERIC(4, 2) NOT NULL,
    shipping_cost NUMERIC(10, 2) NOT NULL,
    order_status VARCHAR(20) NOT NULL,
    
    -- Calculated Financial Metrics
    gross_revenue NUMERIC(10, 2) NOT NULL,
    discount_amount NUMERIC(10, 2) NOT NULL,
    net_revenue NUMERIC(10, 2) NOT NULL,
    product_cost_total NUMERIC(10, 2) NOT NULL,
    platform_fee NUMERIC(10, 4) NOT NULL,
    gross_profit NUMERIC(10, 2) NOT NULL,
    profit_margin NUMERIC(10, 4) NOT NULL,
    
    -- Returns & Refunds Metrics
    is_returned INT NOT NULL,
    return_amount NUMERIC(10, 2) NOT NULL,
    
    -- Analytical Dimensions
    discount_band VARCHAR(20) NOT NULL,
    customer_type VARCHAR(20) NOT NULL
);

-- --------------------------------------------------------------------
-- 3. TRANSFORMATION & INSERTION PIPELINE
-- Filters duplicates, standardizes statuses, and applies e-commerce calculations.
-- --------------------------------------------------------------------
INSERT INTO fact_sales (
    order_id, customer_id, product_id, channel_id, order_date, quantity, unit_price,
    discount_pct, shipping_cost, order_status, gross_revenue, discount_amount,
    net_revenue, product_cost_total, platform_fee, gross_profit, profit_margin,
    is_returned, return_amount, discount_band, customer_type
)
WITH deduped_orders AS (
    -- Task 1: Deduplicate orders in case multiple rows exist for the same order_id
    SELECT 
        o.*,
        ROW_NUMBER() OVER (PARTITION BY o.order_id ORDER BY o.order_date DESC) as rn
    FROM orders o
),
customer_ranks AS (
    -- Task 8: Generate dynamic customer purchase ranking to classify New vs Repeat customers
    SELECT 
        order_id,
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date ASC, order_id ASC) as purchase_seq
    FROM orders
),
joined_sales AS (
    -- Task 5: Join orders with dimensions and returns
    SELECT 
        o.order_id,
        o.customer_id,
        o.product_id,
        o.channel_id,
        o.order_date,
        o.quantity,
        o.unit_price,
        o.discount_pct,
        o.shipping_cost AS raw_shipping_cost,
        -- Task 2: Standardize order status
        INITCAP(TRIM(o.order_status)) AS order_status,
        
        -- Dimension properties for calculations
        p.cost AS unit_cost,
        ch.platform_fee_pct,
        
        -- Returns join
        COALESCE(r.refund_amount, 0.00) AS refund_amount,
        CASE WHEN r.return_id IS NOT NULL THEN 1 ELSE 0 END AS returned_flag,
        
        -- Customer Rank for type
        cr.purchase_seq
    FROM deduped_orders o
    JOIN products p ON o.product_id = p.product_id
    JOIN channels ch ON o.channel_id = ch.channel_id
    JOIN customer_ranks cr ON o.order_id = cr.order_id
    LEFT JOIN returns r ON o.order_id = r.order_id
    WHERE o.rn = 1 -- Keep only primary deduped orders
)
SELECT 
    order_id,
    customer_id,
    product_id,
    channel_id,
    order_date,
    quantity,
    unit_price,
    discount_pct,
    
    -- Task 4: Exclude cancelled orders from revenue and cash calculations
    CASE WHEN order_status = 'Cancelled' THEN 0.00 ELSE raw_shipping_cost END AS shipping_cost,
    order_status,
    
    -- Gross Revenue = quantity * unit_price (or 0 if Cancelled)
    CASE WHEN order_status = 'Cancelled' THEN 0.00 ELSE ROUND(quantity * unit_price, 2) END AS gross_revenue,
    
    -- Discount Amount = gross_revenue * discount_pct
    CASE WHEN order_status = 'Cancelled' THEN 0.00 ELSE ROUND(quantity * unit_price * discount_pct, 2) END AS discount_amount,
    
    -- Net Revenue = quantity * unit_price * (1 - discount_pct)
    CASE 
        WHEN order_status = 'Cancelled' THEN 0.00 
        ELSE ROUND((quantity * unit_price) - (quantity * unit_price * discount_pct), 2) 
    END AS net_revenue,
    
    -- Total Product Cost = quantity * wholesale unit cost
    CASE WHEN order_status = 'Cancelled' THEN 0.00 ELSE ROUND(quantity * unit_cost, 2) END AS product_cost_total,
    
    -- Platform Fee = net_revenue * platform_fee_pct
    CASE WHEN order_status = 'Cancelled' THEN 0.0000 ELSE ROUND(((quantity * unit_price * (1 - discount_pct)) * platform_fee_pct), 4) END AS platform_fee,
    
    -- Gross Profit = net_revenue - product_cost_total - shipping_cost - platform_fee
    -- For Cancelled, gross profit is 0.00. For Returned, we still incurred COGS and shipping/platform fees (refund is handled separately).
    CASE 
        WHEN order_status = 'Cancelled' THEN 0.00 
        ELSE ROUND(
            ((quantity * unit_price * (1 - discount_pct)) - (quantity * unit_cost) - (CASE WHEN order_status = 'Cancelled' THEN 0.00 ELSE raw_shipping_cost END) - ((quantity * unit_price * (1 - discount_pct)) * platform_fee_pct)), 
            2
        ) 
    END AS gross_profit,
    
    -- Profit Margin = gross_profit / net_revenue (0 if Cancelled/No Revenue)
    CASE 
        WHEN order_status = 'Cancelled' THEN 0.0000 
        WHEN ROUND((quantity * unit_price * (1 - discount_pct)), 2) = 0 THEN 0.0000
        ELSE ROUND(
            ROUND(
                ((quantity * unit_price * (1 - discount_pct)) - (quantity * unit_cost) - (CASE WHEN order_status = 'Cancelled' THEN 0.00 ELSE raw_shipping_cost END) - ((quantity * unit_price * (1 - discount_pct)) * platform_fee_pct)), 
                2
            ) / ROUND((quantity * unit_price * (1 - discount_pct)), 2), 
            4
        ) 
    END AS profit_margin,
    
    -- Returns variables
    returned_flag AS is_returned,
    refund_amount AS return_amount,
    
    -- Discount Band
    CASE 
        WHEN discount_pct = 0.00 THEN 'No Discount'
        WHEN discount_pct > 0.00 AND discount_pct <= 0.10 THEN '1-10%'
        WHEN discount_pct > 0.10 AND discount_pct <= 0.20 THEN '11-20%'
        WHEN discount_pct > 0.20 AND discount_pct <= 0.30 THEN '21-30%'
        ELSE '31%+'
    END AS discount_band,
    
    -- Customer Type
    CASE 
        WHEN purchase_seq = 1 THEN 'New'
        ELSE 'Repeat'
    END AS customer_type
FROM joined_sales;

-- --------------------------------------------------------------------
-- CREATE FACT INDEXES
-- Creates indexes on fact_sales to optimize BI reports and filters.
-- --------------------------------------------------------------------
CREATE INDEX idx_fact_order_date ON fact_sales(order_date);
CREATE INDEX idx_fact_customer_id ON fact_sales(customer_id);
CREATE INDEX idx_fact_product_id ON fact_sales(product_id);
CREATE INDEX idx_fact_channel_id ON fact_sales(channel_id);
CREATE INDEX idx_fact_status ON fact_sales(order_status);
CREATE INDEX idx_fact_cust_type ON fact_sales(customer_type);
