# Indexes - Tối Ưu Performance

Indexes là data structures giúp database tìm data nhanh hơn, giống như mục lục trong sách.

## Why Indexes Matter

```sql
-- Không có index: Full table scan
SELECT * FROM products WHERE name = 'iPhone 15 Pro Max';
-- MySQL phải scan TẤT CẢ rows

-- Có index: Index lookup
CREATE INDEX idx_products_name ON products(name);
SELECT * FROM products WHERE name = 'iPhone 15 Pro Max';
-- MySQL chỉ cần lookup trong index
```

**Performance difference:**
- No index: O(n) - linear scan
- With index: O(log n) - binary search tree

## Types of Indexes

### 1. Primary Key (Clustered Index)

```sql
-- Automatically created
CREATE TABLE products (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255)
);
```

**Đặc điểm:**
- Mỗi table chỉ có 1 primary key
- Data được sắp xếp theo primary key
- Fastest for lookups

### 2. Unique Index

```sql
-- Đảm bảo uniqueness
CREATE UNIQUE INDEX idx_customers_email ON customers(email);

-- Hoặc khi tạo table
CREATE TABLE customers (
    id INT PRIMARY KEY,
    email VARCHAR(255) UNIQUE
);
```

### 3. Regular Index (Secondary Index)

```sql
-- Index cho search queries
CREATE INDEX idx_products_price ON products(price);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created ON orders(created_at);
```

### 4. Composite Index (Multi-Column)

```sql
-- Index nhiều columns
CREATE INDEX idx_orders_customer_status ON orders(customer_id, status);
CREATE INDEX idx_products_category_price ON products(category_id, price);
```

**Thứ tự columns quan trọng!**
```sql
-- Index: (customer_id, status, created_at)
SELECT * FROM orders WHERE customer_id = 1;  -- ✅ Dùng được
SELECT * FROM orders WHERE customer_id = 1 AND status = 'pending';  -- ✅ Dùng được
SELECT * FROM orders WHERE status = 'pending';  -- ❌ KHÔNG dùng được
```

**Leftmost Prefix Rule:** Index có thể dùng cho queries bắt đầu từ column đầu tiên.

### 5. Full-Text Index

```sql
-- Search text
CREATE FULLTEXT INDEX idx_products_name_desc ON products(name, description);

-- Use with MATCH AGAINST
SELECT * FROM products
WHERE MATCH(name, description) AGAINST('iPhone');
```

## Creating Indexes

### Basic Syntax

```sql
-- CREATE INDEX
CREATE INDEX index_name ON table_name(column_name);

-- Multi-column
CREATE INDEX idx_orders_composite ON orders(customer_id, status, created_at);

-- Unique
CREATE UNIQUE INDEX idx_unique_email ON customers(email);

-- Full-text
CREATE FULLTEXT INDEX idx_fulltext_products ON products(name);
```

### Practical Examples

```sql
-- Foreign keys (cải thiện JOIN performance)
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
CREATE INDEX idx_reviews_product_id ON reviews(product_id);
CREATE INDEX idx_reviews_customer_id ON reviews(customer_id);

-- Common filters
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_products_category_id ON products(category_id);

-- Date ranges
CREATE INDEX idx_orders_created_at ON orders(created_at);

-- Composite for common queries
CREATE INDEX idx_orders_status_created ON orders(status, created_at);
CREATE INDEX idx_products_cat_price ON products(category_id, price);
```

## Viewing Indexes

### SHOW INDEXES

```sql
-- Tất cả indexes của table
SHOW INDEXES FROM products;

-- Specific database
SHOW INDEXES FROM products FROM ecommerce_db;
```

### Information Schema

```sql
-- Detailed index information
SELECT
    TABLE_NAME,
    INDEX_NAME,
    COLUMN_NAME,
    SEQ_IN_INDEX,
    INDEX_TYPE,
    NON_UNIQUE
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'ecommerce_db'
  AND TABLE_NAME = 'products'
ORDER BY TABLE_NAME, INDEX_NAME, SEQ_IN_INDEX;
```

## Using EXPLAIN

EXPLAIN shows query execution plan.

```sql
-- Basic EXPLAIN
EXPLAIN SELECT * FROM orders WHERE customer_id = 1;

-- EXPLAIN ANALYZE (MySQL 8.0+)
EXPLAIN ANALYZE
SELECT * FROM orders WHERE customer_id = 1 AND status = 'delivered';
```

**Important columns:**
- `type`: JOIN type (system, const, ref, range, index, ALL)
- `possible_keys`: Indexes MySQL có thể dùng
- `key`: Index MySQL thực sự dùng
- `rows`: Số rows MySQL estimate
- `Extra`: Thông tin thêm

### EXPLAIN Examples

```sql
-- Full table scan (bad!)
EXPLAIN SELECT * FROM products WHERE name = 'iPhone';
-- type: ALL (scan toàn bộ table)

-- Index scan (good!)
CREATE INDEX idx_products_name ON products(name);
EXPLAIN SELECT * FROM products WHERE name = 'iPhone';
-- type: ref (dùng index)

-- Index range scan
EXPLAIN SELECT * FROM products WHERE price BETWEEN 1000000 AND 2000000;
-- type: range

-- Using index for ORDER BY
EXPLAIN SELECT * FROM orders ORDER BY created_at DESC LIMIT 10;
-- Extra: Using index
```

## When to Create Indexes

### ✅ Create indexes for:

**1. Primary Keys & Foreign Keys**
```sql
-- Foreign keys
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
```

**2. Columns in WHERE clauses**
```sql
-- Frequent filters
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_customers_city ON customers(city);
```

**3. Columns in JOIN conditions**
```sql
-- JOIN performance
CREATE INDEX idx_products_category_id ON products(category_id);
```

**4. Columns in ORDER BY**
```sql
-- Sorting
CREATE INDEX idx_orders_created_at ON orders(created_at);
```

**5. Columns in GROUP BY**
```sql
-- Grouping
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
```

### ❌ Don't create indexes for:

**1. Small tables (< 1000 rows)**
```sql
-- Không cần index cho categories (chỉ 10 rows)
```

**2. Columns với low cardinality**
```sql
-- BAD: status chỉ có 4-5 values
CREATE INDEX idx_orders_status ON orders(status);  -- Có thể không cần

-- GOOD: customer_id có nhiều unique values
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
```

**3. Columns hay update**
```sql
-- Columns update thường xuyên làm chậm INSERT/UPDATE
CREATE INDEX idx_products_stock ON products(stock);  -- Cân nhắc
```

**4. Large text columns**
```sql
-- BAD
CREATE INDEX idx_products_description ON products(description);

-- GOOD (full-text)
CREATE FULLTEXT INDEX idx_ft_description ON products(description);
```

## Index Best Practices

### 1. Use Composite Indexes Wisely

```sql
-- Order columns từ most selective → least selective
CREATE INDEX idx_orders_status_customer_created
ON orders(status, customer_id, created_at);

-- Status: 5 unique values
-- Customer_id: 100 unique values
-- Created_at: Very many unique values

-- BETTER:
CREATE INDEX idx_orders_customer_status_created
ON orders(customer_id, status, created_at);
```

### 2. Include Covering Indexes

```sql
-- Query cần: customer_id, status, total_amount
SELECT customer_id, status, total_amount
FROM orders
WHERE customer_id = 1 AND status = 'delivered';

-- Covering index: Include tất cả columns trong query
CREATE INDEX idx_orders_covering
ON orders(customer_id, status, total_amount);

-- MySQL không cần access table data, chỉ cần index!
```

### 3. Avoid Over-Indexing

```sql
-- TOO MANY indexes!
CREATE INDEX idx1 ON orders(customer_id);
CREATE INDEX idx2 ON orders(status);
CREATE INDEX idx3 ON orders(customer_id, status);
CREATE INDEX idx4 ON orders(status, customer_id);
CREATE INDEX idx5 ON orders(created_at);
CREATE INDEX idx6 ON orders(customer_id, created_at);

-- BETTER: Chỉ cần 2-3 indexes well-designed
CREATE INDEX idx_orders_customer_status ON orders(customer_id, status);
CREATE INDEX idx_orders_created ON orders(created_at);
```

### 4. Index Column Prefixes

```sql
-- Index chỉ phần đầu của long strings
CREATE INDEX idx_customers_email_prefix ON customers(email(20));

-- Tiết kiệm space nhưng vẫn hiệu quả
```

### 5. Monitor Index Usage

```sql
-- Check unused indexes (MySQL 5.7+)
SELECT
    OBJECT_SCHEMA,
    OBJECT_NAME,
    INDEX_NAME
FROM performance_schema.table_io_waits_summary_by_index_usage
WHERE INDEX_NAME IS NOT NULL
  AND COUNT_STAR = 0
  AND OBJECT_SCHEMA = 'ecommerce_db'
ORDER BY OBJECT_SCHEMA, OBJECT_NAME;

-- Drop unused indexes
ALTER TABLE products DROP INDEX idx_unused_index;
```

## Dropping Indexes

```sql
-- DROP INDEX
DROP INDEX index_name ON table_name;

-- ALTER TABLE
ALTER TABLE products DROP INDEX idx_products_name;

-- Multiple indexes
ALTER TABLE products
    DROP INDEX idx1,
    DROP INDEX idx2,
    DROP INDEX idx3;
```

## Index Maintenance

### Analyze Tables

```sql
-- Update index statistics
ANALYZE TABLE products;
ANALYZE TABLE orders;

-- Check table
CHECK TABLE products;
```

### Optimize Tables

```sql
-- Defragment và rebuild indexes
OPTIMIZE TABLE products;
OPTIMIZE TABLE orders;
```

**Note:** OPTIMIZE TABLE locks table, chạy trong off-peak hours.

## Practical Optimization Examples

### 1. Slow Query: Find Orders

```sql
-- SLOW: Full table scan
SELECT * FROM orders
WHERE status = 'delivered'
  AND created_at >= '2024-01-01'
  AND customer_id = 100;

-- Analyze
EXPLAIN SELECT * FROM orders
WHERE status = 'delivered'
  AND created_at >= '2024-01-01'
  AND customer_id = 100;
-- type: ALL, rows: 1000000

-- FIX: Create composite index
CREATE INDEX idx_orders_customer_status_created
ON orders(customer_id, status, created_at);

-- Now FAST
EXPLAIN SELECT * FROM orders
WHERE status = 'delivered'
  AND created_at >= '2024-01-01'
  AND customer_id = 100;
-- type: ref, rows: 50
```

### 2. Slow JOIN Query

```sql
-- SLOW
SELECT
    o.id,
    c.name,
    p.name
FROM orders o
JOIN customers c ON o.customer_id = c.id
JOIN order_items oi ON o.id = oi.order_id
JOIN products p ON oi.product_id = p.id
WHERE o.status = 'delivered';

-- FIX: Index all foreign keys
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
CREATE INDEX idx_orders_status ON orders(status);
```

### 3. Slow Aggregation

```sql
-- SLOW
SELECT
    customer_id,
    COUNT(*) AS order_count,
    SUM(total_amount) AS total_spent
FROM orders
WHERE status = 'delivered'
GROUP BY customer_id
HAVING total_spent > 1000000;

-- FIX: Composite index
CREATE INDEX idx_orders_status_customer_amount
ON orders(status, customer_id, total_amount);
```

## Real-World Index Strategy

### E-commerce Database Indexes

```sql
-- CUSTOMERS table
ALTER TABLE customers
    ADD INDEX idx_customers_email (email),
    ADD INDEX idx_customers_city (city),
    ADD INDEX idx_customers_created (created_at);

-- PRODUCTS table
ALTER TABLE products
    ADD INDEX idx_products_category (category_id),
    ADD INDEX idx_products_price (price),
    ADD INDEX idx_products_stock (stock),
    ADD INDEX idx_products_cat_price (category_id, price),
    ADD FULLTEXT INDEX idx_ft_products_name (name);

-- ORDERS table
ALTER TABLE orders
    ADD INDEX idx_orders_customer (customer_id),
    ADD INDEX idx_orders_status (status),
    ADD INDEX idx_orders_created (created_at),
    ADD INDEX idx_orders_customer_status (customer_id, status),
    ADD INDEX idx_orders_status_created (status, created_at);

-- ORDER_ITEMS table
ALTER TABLE order_items
    ADD INDEX idx_order_items_order (order_id),
    ADD INDEX idx_order_items_product (product_id);

-- REVIEWS table
ALTER TABLE reviews
    ADD INDEX idx_reviews_product (product_id),
    ADD INDEX idx_reviews_customer (customer_id),
    ADD INDEX idx_reviews_rating (rating);
```

## Monitoring Performance

### Slow Query Log

```sql
-- Enable slow query log
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL long_query_time = 2;  -- Queries > 2 seconds

-- Check slow queries
-- tail -f /var/log/mysql/slow-query.log
```

### Query Profiling

```sql
-- Enable profiling
SET profiling = 1;

-- Run query
SELECT * FROM orders WHERE customer_id = 1;

-- Show profiles
SHOW PROFILES;

-- Detail profile
SHOW PROFILE FOR QUERY 1;
```

## Index Anti-Patterns

### ❌ Don't Do This

```sql
-- 1. Index every column
CREATE INDEX idx1 ON products(id);           -- Primary key already indexed!
CREATE INDEX idx2 ON products(name);
CREATE INDEX idx3 ON products(price);
CREATE INDEX idx4 ON products(stock);
CREATE INDEX idx5 ON products(description);  -- Too large!

-- 2. Wrong column order
CREATE INDEX idx_wrong ON orders(created_at, customer_id, status);
-- Query: WHERE customer_id = ? AND status = ?
-- Index cannot be used efficiently!

-- 3. Redundant indexes
CREATE INDEX idx1 ON orders(customer_id);
CREATE INDEX idx2 ON orders(customer_id, status);  -- idx1 is redundant!

-- 4. Index low-cardinality columns
CREATE INDEX idx_bad ON orders(payment_method);  -- Only 3 values!
```

## Bài Tập

**1. Analyze Performance**
```sql
-- Tìm slow queries trong database
-- Dùng EXPLAIN để phân tích
-- Đề xuất indexes cần tạo
```

**2. Create Optimal Indexes**
```sql
-- Top 10 customers by spending
-- Products trong price range với category
-- Orders trong date range với status
```

**3. Composite Indexes**
```sql
-- Design index cho query: WHERE customer_id = ? AND status = ? AND created_at > ?
-- Design covering index cho SELECT customer_id, status, total_amount
```

**4. Monitor & Optimize**
```sql
-- Tìm unused indexes
-- Optimize tables
-- Analyze index usage statistics
```

## Đáp Án

<details>
<summary>Click để xem đáp án</summary>

```sql
-- 1. Analyze
EXPLAIN SELECT c.name, COUNT(o.id) AS orders, SUM(o.total_amount) AS spent
FROM customers c
JOIN orders o ON c.id = o.customer_id
WHERE o.status = 'delivered'
GROUP BY c.id, c.name
ORDER BY spent DESC
LIMIT 10;

-- 2. Optimal Indexes
CREATE INDEX idx_orders_status_customer_amount
ON orders(status, customer_id, total_amount);

CREATE INDEX idx_products_cat_price
ON products(category_id, price);

CREATE INDEX idx_orders_created_status
ON orders(created_at, status);

-- 3. Composite Index Design
-- Query: WHERE customer_id = ? AND status = ? AND created_at > ?
CREATE INDEX idx_orders_customer_status_created
ON orders(customer_id, status, created_at);

-- Covering: SELECT customer_id, status, total_amount
CREATE INDEX idx_orders_covering
ON orders(customer_id, status, total_amount);

-- 4. Monitor
SELECT
    TABLE_NAME,
    INDEX_NAME,
    CARDINALITY
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'ecommerce_db'
  AND NON_UNIQUE = 1
ORDER BY TABLE_NAME, INDEX_NAME;

-- Unused indexes
SELECT * FROM sys.schema_unused_indexes
WHERE object_schema = 'ecommerce_db';

-- Optimize
OPTIMIZE TABLE products, orders, customers;
```

</details>

## Tổng Kết

Indexes là công cụ quan trọng nhất để tối ưu database performance:

- ✅ Index primary keys và foreign keys
- ✅ Index columns trong WHERE, JOIN, ORDER BY
- ✅ Use composite indexes với column order đúng
- ✅ Monitor index usage và drop unused indexes
- ❌ Tránh over-indexing
- ❌ Không index small tables hoặc low-cardinality columns

## Tiếp Theo

➡️ [Transactions](02-transactions.md)

⬅️ [Level 3: Advanced](../level-3-advanced/README.md)
