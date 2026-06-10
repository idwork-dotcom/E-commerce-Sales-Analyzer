-- ====================================================================
-- E-COMMERCE PERFORMANCE DASHBOARD - DATA VALIDATION QUERIES (validation_queries.sql)
-- Run these queries after loading data to verify logical & structural integrity.
-- ====================================================================

-- --------------------------------------------------------------------
-- 1. RECORD COUNT VALIDATIONS
-- Verifies that all rows from the synthetic files are successfully loaded.
-- --------------------------------------------------------------------
SELECT 
    (SELECT COUNT(*) FROM channels) AS channels_count,     -- Expected: 5
    (SELECT COUNT(*) FROM products) AS products_count,     -- Expected: 150
    (SELECT COUNT(*) FROM customers) AS customers_count,   -- Expected: 2000
    (SELECT COUNT(*) FROM calendar) AS calendar_count,     -- Expected: 731
    (SELECT COUNT(*) FROM orders) AS orders_count,         -- Expected: 10000
    (SELECT COUNT(*) FROM returns) AS returns_count;        -- Expected: 818

-- --------------------------------------------------------------------
-- 2. FINANCIAL INTEGRITY AUDIT
-- Checks if calculations match the business rules.
-- --------------------------------------------------------------------

-- A. Cancelled Orders Revenue Verification
-- Business Rule: Cancelled orders must register $0.00 in revenue, shipping, and discounts.
SELECT 
    COUNT(*) AS cancelled_orders_count,
    SUM(total_amount) AS total_cancelled_revenue,            -- Expected: $0.00
    SUM(shipping_cost) AS total_cancelled_shipping,          -- Expected: $0.00
    SUM(discount_pct) AS sum_cancelled_discounts            -- Expected: 0.00
FROM orders 
WHERE order_status = 'Cancelled';

-- B. Active Orders Revenue Calculation Verification
-- Business Rule: total_amount = (unit_price * quantity * (1 - discount_pct)) + shipping_cost
-- This query identifies any discrepancies where stored total_amount deviates from computed total.
SELECT 
    order_id, 
    total_amount AS stored_amount,
    ROUND((unit_price * quantity * (1 - discount_pct)) + shipping_cost, 2) AS computed_amount,
    (total_amount - ROUND((unit_price * quantity * (1 - discount_pct)) + shipping_cost, 2)) AS discrepancy
FROM orders
WHERE order_status != 'Cancelled'
  AND ABS(total_amount - ROUND((unit_price * quantity * (1 - discount_pct)) + shipping_cost, 2)) > 0.01;
-- Expected Result: Zero rows returned.

-- C. Margin Safety Verification
-- Business Rule: Selling price must be strictly greater than wholesale cost.
SELECT COUNT(*) AS negative_margin_products
FROM products
WHERE price <= cost;
-- Expected Result: 0

-- --------------------------------------------------------------------
-- 3. REFERENTIAL AND TEMPORAL INTEGRITY CHECKS
-- --------------------------------------------------------------------

-- A. Customer Signup vs Order Date Validation
-- Business Rule: A customer cannot place an order before their signup date.
SELECT COUNT(*) AS chronological_violations
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE c.signup_date > o.order_date;
-- Expected Result: 0

-- B. Return Date vs Order Date Validation
-- Business Rule: A return cannot occur before the order date.
SELECT COUNT(*) AS return_timeline_violations
FROM returns r
JOIN orders o ON r.order_id = o.order_id
WHERE r.return_date < o.order_date;
-- Expected Result: 0

-- C. Refund Amount Boundary Check
-- Business Rule: Refund amount cannot exceed the order line item subtotal (shipping is non-refundable).
SELECT COUNT(*) AS invalid_refund_amounts
FROM returns r
JOIN orders o ON r.order_id = o.order_id
WHERE r.refund_amount > ROUND(o.unit_price * o.quantity * (1 - o.discount_pct), 2);
-- Expected Result: 0

-- --------------------------------------------------------------------
-- 4. BASIC BUSINESS METRICS VERIFICATION (Sanity Check)
-- Computes the high-level metrics to ensure the database matches expected parameters.
-- --------------------------------------------------------------------

-- A. Overall Sales Metrics
SELECT 
    COUNT(o.order_id) AS total_orders,
    SUM(CASE WHEN o.order_status != 'Cancelled' THEN o.total_amount ELSE 0 END) AS gross_revenue,
    COALESCE(SUM(r.refund_amount), 0) AS total_refunded,
    SUM(CASE WHEN o.order_status != 'Cancelled' THEN o.total_amount ELSE 0 END) - COALESCE(SUM(r.refund_amount), 0) AS net_revenue,
    ROUND(
        (COUNT(r.return_id)::NUMERIC / COUNT(CASE WHEN o.order_status IN ('Completed', 'Returned', 'Refunded') THEN 1 END)) * 100, 
        2
    ) AS return_rate_pct
FROM orders o
LEFT JOIN returns r ON o.order_id = r.order_id;

-- B. Channel Sales Contribution
SELECT 
    c.channel_name,
    COUNT(o.order_id) AS order_volume,
    SUM(o.total_amount) AS gross_sales,
    ROUND((SUM(o.total_amount) / (SELECT SUM(total_amount) FROM orders WHERE order_status != 'Cancelled') * 100), 2) AS sales_share_pct
FROM orders o
JOIN channels c ON o.channel_id = c.channel_id
WHERE o.order_status != 'Cancelled'
GROUP BY c.channel_name
ORDER BY gross_sales DESC;
