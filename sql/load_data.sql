-- ====================================================================
-- E-COMMERCE PERFORMANCE DASHBOARD - DATA LOAD SCRIPTS (load_data.sql)
-- Target Database: PostgreSQL / MySQL
-- ====================================================================

-- --------------------------------------------------------------------
-- OPTION A: PostgreSQL Client-Side Loading (RECOMMENDED)
-- Run this inside the `psql` shell or by executing:
-- psql -h localhost -U username -d dbname -f sql/load_data.sql
-- (No superuser privileges required. Reads CSVs from local client path.)
-- --------------------------------------------------------------------

-- IMPORTANT: Ensure that your shell's working directory is the project root 
-- (where the `data/` folder is located) when running these command lines.

-- 1. Load Channels
\echo 'Loading Channels...'
\copy channels(channel_id, channel_name, platform_fee_pct) FROM 'data/channels.csv' DELIMITER ',' CSV HEADER;

-- 2. Load Products
\echo 'Loading Products...'
\copy products(product_id, product_name, category, cost, price, sku) FROM 'data/products.csv' DELIMITER ',' CSV HEADER;

-- 3. Load Customers
\echo 'Loading Customers...'
\copy customers(customer_id, first_name, last_name, email, phone, city, state, zip_code, country, region, signup_date) FROM 'data/customers.csv' DELIMITER ',' CSV HEADER;

-- 4. Load Calendar
\echo 'Loading Calendar...'
\copy calendar(date, year, quarter, month, month_name, day, day_of_week, day_name, is_weekend) FROM 'data/calendar.csv' DELIMITER ',' CSV HEADER;

-- 5. Load Orders
\echo 'Loading Orders...'
\copy orders(order_id, customer_id, product_id, channel_id, order_date, quantity, unit_price, discount_pct, shipping_cost, order_status, total_amount) FROM 'data/orders.csv' DELIMITER ',' CSV HEADER;

-- 6. Load Returns
\echo 'Loading Returns...'
\copy returns(return_id, order_id, return_date, return_reason, refund_amount) FROM 'data/returns.csv' DELIMITER ',' CSV HEADER;

\echo 'All data loaded successfully!'


/*
-- --------------------------------------------------------------------
-- OPTION B: PostgreSQL Server-Side Loading (Alternative)
-- Requires superuser permissions and the CSV files to reside on the 
-- database server's local storage with 'postgres' user read permissions.
-- Replace absolute paths below with your server-specific filesystem paths.
-- --------------------------------------------------------------------

TRUNCATE TABLE returns CASCADE;
TRUNCATE TABLE orders CASCADE;
TRUNCATE TABLE calendar CASCADE;
TRUNCATE TABLE customers CASCADE;
TRUNCATE TABLE products CASCADE;
TRUNCATE TABLE channels CASCADE;

COPY channels(channel_id, channel_name, platform_fee_pct) 
FROM '/absolute/path/to/project/data/channels.csv' DELIMITER ',' CSV HEADER;

COPY products(product_id, product_name, category, cost, price, sku) 
FROM '/absolute/path/to/project/data/products.csv' DELIMITER ',' CSV HEADER;

COPY customers(customer_id, first_name, last_name, email, phone, city, state, zip_code, country, region, signup_date) 
FROM '/absolute/path/to/project/data/customers.csv' DELIMITER ',' CSV HEADER;

COPY calendar(date, year, quarter, month, month_name, day, day_of_week, day_name, is_weekend) 
FROM '/absolute/path/to/project/data/calendar.csv' DELIMITER ',' CSV HEADER;

COPY orders(order_id, customer_id, product_id, channel_id, order_date, quantity, unit_price, discount_pct, shipping_cost, order_status, total_amount) 
FROM '/absolute/path/to/project/data/orders.csv' DELIMITER ',' CSV HEADER;

COPY returns(return_id, order_id, return_date, return_reason, refund_amount) 
FROM '/absolute/path/to/project/data/returns.csv' DELIMITER ',' CSV HEADER;
*/


/*
-- --------------------------------------------------------------------
-- OPTION C: MySQL LOAD DATA INFILE Adaptation (For MySQL Users)
-- MySQL requires local files to be enabled (local_infile = 1).
-- Run these statements in your MySQL client after setting up the tables.
-- --------------------------------------------------------------------

LOAD DATA LOCAL INFILE 'data/channels.csv' 
INTO TABLE channels 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'data/products.csv' 
INTO TABLE products 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'data/customers.csv' 
INTO TABLE customers 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'data/calendar.csv' 
INTO TABLE calendar 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'data/orders.csv' 
INTO TABLE orders 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'data/returns.csv' 
INTO TABLE returns 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;
*/
