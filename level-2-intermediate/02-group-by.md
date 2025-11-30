# GROUP BY & Aggregate Functions

GROUP BY cho phép bạn nhóm rows và tính toán thống kê trên từng nhóm.

## Aggregate Functions

### COUNT - Đếm

```sql
-- Đếm tất cả rows
SELECT COUNT(*) FROM customers;

-- Đếm non-NULL values
SELECT COUNT(phone) FROM customers;

-- Đếm unique values
SELECT COUNT(DISTINCT city) FROM customers;
```

### SUM - Tổng

```sql
-- Tổng doanh thu
SELECT SUM(total_amount) FROM orders WHERE status = 'delivered';

-- Tổng giá trị tồn kho
SELECT SUM(price * stock) AS inventory_value FROM products;
```

### AVG - Trung Bình

```sql
-- Giá trung bình products
SELECT AVG(price) FROM products;

-- Giá trị đơn hàng trung bình
SELECT AVG(total_amount) FROM orders;
```

### MAX & MIN - Lớn Nhất & Nhỏ Nhất

```sql
-- Product đắt nhất và rẻ nhất
SELECT MAX(price), MIN(price) FROM products;

-- Order lớn nhất
SELECT MAX(total_amount) FROM orders;
```

## GROUP BY Basics

### Cú Pháp

```sql
SELECT column1, aggregate_function(column2)
FROM table
GROUP BY column1;
```

### Simple Example

```sql
-- Đếm customers theo thành phố
SELECT
    city,
    COUNT(*) AS customer_count
FROM customers
GROUP BY city
ORDER BY customer_count DESC;
```

**Kết quả:**
```
+---------------+----------------+
| city          | customer_count |
+---------------+----------------+
| Hà Nội        |             20 |
| Hồ Chí Minh   |             18 |
| Đà Nẵng       |             15 |
+---------------+----------------+
```

### Multiple Aggregates

```sql
-- Nhiều aggregates cùng lúc
SELECT
    city,
    COUNT(*) AS total_customers,
    COUNT(DISTINCT email) AS unique_emails,
    MIN(created_at) AS first_customer,
    MAX(created_at) AS latest_customer
FROM customers
GROUP BY city;
```

## GROUP BY với JOIN

```sql
-- Tổng doanh thu mỗi customer
SELECT
    c.name,
    c.email,
    COUNT(o.id) AS order_count,
    SUM(o.total_amount) AS total_spent,
    AVG(o.total_amount) AS avg_order_value
FROM customers c
INNER JOIN orders o ON c.id = o.customer_id
WHERE o.status = 'delivered'
GROUP BY c.id, c.name, c.email
ORDER BY total_spent DESC
LIMIT 10;
```

### Revenue by Category

```sql
SELECT
    cat.name AS category,
    COUNT(DISTINCT p.id) AS product_count,
    SUM(oi.quantity) AS total_sold,
    SUM(oi.subtotal) AS revenue
FROM categories cat
JOIN products p ON cat.id = p.category_id
JOIN order_items oi ON p.id = oi.product_id
JOIN orders o ON oi.order_id = o.id
WHERE o.status = 'delivered'
GROUP BY cat.id, cat.name
ORDER BY revenue DESC;
```

## GROUP BY Multiple Columns

```sql
-- Orders theo city và status
SELECT
    c.city,
    o.status,
    COUNT(*) AS order_count,
    SUM(o.total_amount) AS revenue
FROM customers c
JOIN orders o ON c.id = o.customer_id
GROUP BY c.city, o.status
ORDER BY c.city, revenue DESC;
```

**Kết quả:**
```
+---------------+-----------+-------------+----------+
| city          | status    | order_count | revenue  |
+---------------+-----------+-------------+----------+
| Hà Nội        | delivered |          45 | 12500000 |
| Hà Nội        | shipped   |           3 |  1200000 |
| Hồ Chí Minh   | delivered |          38 | 10800000 |
+---------------+-----------+-------------+----------+
```

## HAVING Clause

Filter AFTER grouping (WHERE filter BEFORE grouping):

```sql
-- Cities có > 10 customers
SELECT
    city,
    COUNT(*) AS customer_count
FROM customers
GROUP BY city
HAVING customer_count > 10
ORDER BY customer_count DESC;
```

### HAVING vs WHERE

```sql
-- ❌ SAI - không thể dùng aggregate trong WHERE
SELECT city, COUNT(*) AS total
FROM customers
WHERE total > 10  -- Error!
GROUP BY city;

-- ✅ ĐÚNG - dùng HAVING
SELECT city, COUNT(*) AS total
FROM customers
GROUP BY city
HAVING total > 10;

-- ✅ WHERE + HAVING
SELECT
    city,
    COUNT(*) AS total
FROM customers
WHERE created_at > '2024-01-01'  -- Filter BEFORE GROUP BY
GROUP BY city
HAVING total > 5;  -- Filter AFTER GROUP BY
```

## Practical Examples

### 1. Daily Revenue

```sql
SELECT
    DATE(created_at) AS order_date,
    COUNT(*) AS order_count,
    SUM(total_amount) AS revenue,
    AVG(total_amount) AS avg_order
FROM orders
WHERE status = 'delivered'
  AND created_at >= '2024-01-01'
GROUP BY DATE(created_at)
ORDER BY order_date DESC;
```

### 2. Monthly Revenue

```sql
SELECT
    DATE_FORMAT(created_at, '%Y-%m') AS month,
    COUNT(*) AS orders,
    SUM(total_amount) AS revenue
FROM orders
WHERE status = 'delivered'
GROUP BY DATE_FORMAT(created_at, '%Y-%m')
ORDER BY month DESC;
```

### 3. Product Performance

```sql
SELECT
    p.name,
    COUNT(oi.id) AS times_ordered,
    SUM(oi.quantity) AS total_quantity,
    SUM(oi.subtotal) AS revenue,
    AVG(r.rating) AS avg_rating,
    COUNT(DISTINCT r.id) AS review_count
FROM products p
LEFT JOIN order_items oi ON p.id = oi.product_id
LEFT JOIN reviews r ON p.id = r.product_id
GROUP BY p.id, p.name
HAVING times_ordered > 0
ORDER BY revenue DESC
LIMIT 20;
```

### 4. Customer Segments

```sql
SELECT
    CASE
        WHEN total_spent < 500000 THEN 'Bronze'
        WHEN total_spent BETWEEN 500000 AND 2000000 THEN 'Silver'
        WHEN total_spent BETWEEN 2000000 AND 5000000 THEN 'Gold'
        ELSE 'Platinum'
    END AS segment,
    COUNT(*) AS customer_count,
    AVG(total_spent) AS avg_spent
FROM (
    SELECT
        c.id,
        SUM(o.total_amount) AS total_spent
    FROM customers c
    JOIN orders o ON c.id = o.customer_id
    WHERE o.status = 'delivered'
    GROUP BY c.id
) AS customer_totals
GROUP BY segment
ORDER BY avg_spent DESC;
```

### 5. Top Products by Category

```sql
SELECT
    cat.name AS category,
    p.name AS product,
    SUM(oi.quantity) AS sold,
    SUM(oi.subtotal) AS revenue
FROM categories cat
JOIN products p ON cat.id = p.category_id
JOIN order_items oi ON p.id = oi.product_id
JOIN orders o ON oi.order_id = o.id
WHERE o.status = 'delivered'
GROUP BY cat.id, cat.name, p.id, p.name
ORDER BY cat.name, revenue DESC;
```

### 6. Payment Method Analysis

```sql
SELECT
    payment_method,
    COUNT(*) AS order_count,
    SUM(total_amount) AS revenue,
    AVG(total_amount) AS avg_value,
    MIN(total_amount) AS min_order,
    MAX(total_amount) AS max_order
FROM orders
WHERE status IN ('delivered', 'shipped')
GROUP BY payment_method
ORDER BY revenue DESC;
```

### 7. Hourly Orders

```sql
SELECT
    HOUR(created_at) AS hour,
    COUNT(*) AS order_count,
    SUM(total_amount) AS revenue
FROM orders
WHERE created_at >= CURDATE() - INTERVAL 7 DAY
GROUP BY HOUR(created_at)
ORDER BY hour;
```

## WITH ROLLUP

Tổng hợp subtotals và grand totals:

```sql
SELECT
    city,
    COUNT(*) AS customers
FROM customers
GROUP BY city WITH ROLLUP;
```

**Kết quả:**
```
+---------------+-----------+
| city          | customers |
+---------------+-----------+
| Hà Nội        |        20 |
| Hồ Chí Minh   |        18 |
| Đà Nẵng       |        15 |
| NULL          |        53 |  -- Grand total
+---------------+-----------+
```

## Common Patterns

### Running Totals (Basic)

```sql
SELECT
    DATE(created_at) AS date,
    SUM(total_amount) AS daily_revenue,
    @running_total := @running_total + SUM(total_amount) AS running_total
FROM orders, (SELECT @running_total := 0) AS init
WHERE status = 'delivered'
GROUP BY DATE(created_at)
ORDER BY date;
```

### Percentages

```sql
SELECT
    city,
    COUNT(*) AS customers,
    COUNT(*) * 100.0 / (SELECT COUNT(*) FROM customers) AS percentage
FROM customers
GROUP BY city
ORDER BY percentage DESC;
```

### Year-over-Year Growth

```sql
SELECT
    YEAR(created_at) AS year,
    COUNT(*) AS orders,
    SUM(total_amount) AS revenue,
    LAG(SUM(total_amount)) OVER (ORDER BY YEAR(created_at)) AS prev_year_revenue,
    (SUM(total_amount) - LAG(SUM(total_amount)) OVER (ORDER BY YEAR(created_at))) * 100.0 /
        LAG(SUM(total_amount)) OVER (ORDER BY YEAR(created_at)) AS growth_percent
FROM orders
WHERE status = 'delivered'
GROUP BY YEAR(created_at);
```

## Best Practices

✅ **DO:**
- Include all non-aggregated columns in GROUP BY
- Use meaningful aliases
- Order results for better readability
- Use HAVING for post-aggregation filters

❌ **DON'T:**
- Forget to include columns in GROUP BY
- Use WHERE with aggregates (use HAVING)
- Group by too many columns (performance)

## Common Errors

### 1. Column Not in GROUP BY

```sql
-- ❌ Error: 'name' not in GROUP BY
SELECT city, name, COUNT(*)
FROM customers
GROUP BY city;

-- ✅ Include all non-aggregated columns
SELECT city, name, COUNT(*)
FROM customers
GROUP BY city, name;

-- ✅ Or remove 'name'
SELECT city, COUNT(*)
FROM customers
GROUP BY city;
```

### 2. Using WHERE with Aggregates

```sql
-- ❌ Can't use aggregate in WHERE
SELECT city, COUNT(*) AS total
FROM customers
WHERE total > 10
GROUP BY city;

-- ✅ Use HAVING
SELECT city, COUNT(*) AS total
FROM customers
GROUP BY city
HAVING total > 10;
```

## Bài Tập

**1. Basic Aggregates**
```sql
-- Đếm tổng số products
-- Tính giá trung bình products
-- Tìm product đắt nhất và rẻ nhất
```

**2. GROUP BY**
```sql
-- Đếm orders theo status
-- Tổng doanh thu theo payment_method
-- Số customers theo city
```

**3. JOIN + GROUP BY**
```sql
-- Top 5 customers chi tiêu nhiều nhất
-- Doanh thu theo category
-- Số lượng bán theo product
```

**4. HAVING**
```sql
-- Cities có > 15 customers
-- Products có > 5 reviews
-- Categories có doanh thu > 10tr
```

## Đáp Án

<details>
<summary>Click để xem đáp án</summary>

```sql
-- 1. Basic Aggregates
SELECT COUNT(*) FROM products;
SELECT AVG(price) FROM products;
SELECT MAX(price), MIN(price) FROM products;

-- 2. GROUP BY
SELECT status, COUNT(*) FROM orders GROUP BY status;
SELECT payment_method, SUM(total_amount) FROM orders GROUP BY payment_method;
SELECT city, COUNT(*) FROM customers GROUP BY city;

-- 3. JOIN + GROUP BY
SELECT c.name, SUM(o.total_amount) AS total
FROM customers c
JOIN orders o ON c.id = o.customer_id
WHERE o.status = 'delivered'
GROUP BY c.id, c.name
ORDER BY total DESC
LIMIT 5;

SELECT cat.name, SUM(oi.subtotal) AS revenue
FROM categories cat
JOIN products p ON cat.id = p.category_id
JOIN order_items oi ON p.id = oi.product_id
GROUP BY cat.id, cat.name
ORDER BY revenue DESC;

SELECT p.name, SUM(oi.quantity) AS sold
FROM products p
JOIN order_items oi ON p.id = oi.product_id
GROUP BY p.id, p.name
ORDER BY sold DESC;

-- 4. HAVING
SELECT city, COUNT(*) AS total
FROM customers
GROUP BY city
HAVING total > 15;

SELECT product_id, COUNT(*) AS reviews
FROM reviews
GROUP BY product_id
HAVING reviews > 5;

SELECT cat.name, SUM(oi.subtotal) AS revenue
FROM categories cat
JOIN products p ON cat.id = p.category_id
JOIN order_items oi ON p.id = oi.product_id
GROUP BY cat.id, cat.name
HAVING revenue > 10000000;
```

</details>

## Tiếp Theo

➡️ [Functions (String & Date)](03-functions.md)

⬅️ [JOIN Tables](01-joins.md)
