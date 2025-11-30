# CASE WHEN & UNION

## CASE WHEN - Conditional Logic

CASE WHEN giống như if-else trong programming, cho phép bạn tạo conditional values.

### Simple CASE

```sql
-- Phân loại products theo giá
SELECT
    name,
    price,
    CASE
        WHEN price < 500000 THEN 'Giá rẻ'
        WHEN price BETWEEN 500000 AND 2000000 THEN 'Trung bình'
        WHEN price BETWEEN 2000000 AND 10000000 THEN 'Cao'
        ELSE 'Rất cao'
    END AS price_category
FROM products
ORDER BY price;
```

### CASE trong SELECT

```sql
-- Tạo nhiều cột với CASE
SELECT
    name,
    stock,
    CASE
        WHEN stock = 0 THEN 'Hết hàng'
        WHEN stock < 10 THEN 'Sắp hết'
        WHEN stock < 50 THEN 'Ổn định'
        ELSE 'Dư thừa'
    END AS stock_status,
    CASE
        WHEN stock = 0 THEN '🔴'
        WHEN stock < 10 THEN '🟡'
        ELSE '🟢'
    END AS indicator
FROM products
ORDER BY stock;
```

### CASE trong WHERE

```sql
-- Flexible filtering
SELECT name, price, stock
FROM products
WHERE
    CASE
        WHEN category_id = 1 THEN price > 1000000
        WHEN category_id = 2 THEN price > 500000
        ELSE price > 100000
    END
ORDER BY price DESC;
```

### CASE trong ORDER BY

```sql
-- Custom sorting
SELECT name, status, created_at
FROM orders
ORDER BY
    CASE status
        WHEN 'pending' THEN 1
        WHEN 'processing' THEN 2
        WHEN 'shipped' THEN 3
        WHEN 'delivered' THEN 4
        WHEN 'cancelled' THEN 5
    END,
    created_at DESC;
```

## CASE với Aggregates

### Count với Conditions

```sql
-- Đếm orders theo status
SELECT
    DATE_FORMAT(created_at, '%Y-%m') AS month,
    COUNT(*) AS total_orders,
    COUNT(CASE WHEN status = 'delivered' THEN 1 END) AS delivered,
    COUNT(CASE WHEN status = 'cancelled' THEN 1 END) AS cancelled,
    COUNT(CASE WHEN status = 'pending' THEN 1 END) AS pending
FROM orders
GROUP BY month
ORDER BY month DESC;
```

**Tương đương với:**
```sql
-- Dùng SUM với 0/1
SELECT
    DATE_FORMAT(created_at, '%Y-%m') AS month,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN status = 'delivered' THEN 1 ELSE 0 END) AS delivered,
    SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END) AS cancelled,
    SUM(status = 'pending') AS pending  -- MySQL shortcut
FROM orders
GROUP BY month;
```

### Conditional Sums

```sql
-- Revenue theo payment method
SELECT
    DATE_FORMAT(created_at, '%Y-%m') AS month,
    SUM(CASE WHEN payment_method = 'credit_card' THEN total_amount ELSE 0 END) AS credit_card_revenue,
    SUM(CASE WHEN payment_method = 'bank_transfer' THEN total_amount ELSE 0 END) AS bank_transfer_revenue,
    SUM(CASE WHEN payment_method = 'cash' THEN total_amount ELSE 0 END) AS cash_revenue,
    SUM(total_amount) AS total_revenue
FROM orders
WHERE status = 'delivered'
  AND created_at >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
GROUP BY month
ORDER BY month DESC;
```

### Pivot Table Style

```sql
-- Orders by day of week và status
SELECT
    DAYNAME(created_at) AS day_of_week,
    SUM(status = 'delivered') AS delivered,
    SUM(status = 'cancelled') AS cancelled,
    SUM(status = 'pending') AS pending,
    COUNT(*) AS total
FROM orders
WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY day_of_week, DAYOFWEEK(created_at)
ORDER BY DAYOFWEEK(created_at);
```

## Nested CASE

```sql
-- Customer segmentation phức tạp
SELECT
    c.name,
    COUNT(o.id) AS order_count,
    SUM(o.total_amount) AS total_spent,
    CASE
        WHEN SUM(o.total_amount) >= 10000000 THEN
            CASE
                WHEN COUNT(o.id) >= 20 THEN 'VIP Platinum'
                WHEN COUNT(o.id) >= 10 THEN 'VIP Gold'
                ELSE 'VIP Silver'
            END
        WHEN SUM(o.total_amount) >= 5000000 THEN 'Premium'
        WHEN SUM(o.total_amount) >= 1000000 THEN 'Regular'
        ELSE 'New'
    END AS customer_tier
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
  AND o.status = 'delivered'
GROUP BY c.id, c.name
ORDER BY total_spent DESC;
```

## CASE với JOIN

```sql
-- Dynamic JOIN condition
SELECT
    o.id,
    o.created_at,
    o.total_amount,
    CASE o.status
        WHEN 'delivered' THEN c_delivered.name
        WHEN 'cancelled' THEN c_cancelled.name
        ELSE c_other.name
    END AS customer_name
FROM orders o
LEFT JOIN customers c_delivered
    ON o.customer_id = c_delivered.id AND o.status = 'delivered'
LEFT JOIN customers c_cancelled
    ON o.customer_id = c_cancelled.id AND o.status = 'cancelled'
LEFT JOIN customers c_other
    ON o.customer_id = c_other.id
    AND o.status NOT IN ('delivered', 'cancelled');
```

## Practical CASE Examples

### 1. Order Priority

```sql
-- Ưu tiên xử lý orders
SELECT
    id,
    customer_id,
    total_amount,
    created_at,
    DATEDIFF(CURDATE(), created_at) AS days_old,
    CASE
        WHEN status = 'pending' AND DATEDIFF(CURDATE(), created_at) > 7 THEN 'URGENT'
        WHEN status = 'pending' AND total_amount > 5000000 THEN 'HIGH'
        WHEN status = 'pending' THEN 'NORMAL'
        ELSE 'COMPLETED'
    END AS priority
FROM orders
ORDER BY
    CASE
        WHEN status = 'pending' AND DATEDIFF(CURDATE(), created_at) > 7 THEN 1
        WHEN status = 'pending' AND total_amount > 5000000 THEN 2
        WHEN status = 'pending' THEN 3
        ELSE 4
    END,
    created_at;
```

### 2. Product Recommendation

```sql
-- Gợi ý dựa trên stock và performance
SELECT
    p.name,
    p.stock,
    p.price,
    COALESCE(SUM(oi.quantity), 0) AS sold_quantity,
    CASE
        WHEN p.stock = 0 AND COALESCE(SUM(oi.quantity), 0) > 50 THEN 'Nhập thêm ngay'
        WHEN p.stock < 10 AND COALESCE(SUM(oi.quantity), 0) > 20 THEN 'Nhập thêm'
        WHEN p.stock > 100 AND COALESCE(SUM(oi.quantity), 0) < 5 THEN 'Giảm giá'
        WHEN COALESCE(SUM(oi.quantity), 0) = 0 THEN 'Xem xét ngừng bán'
        ELSE 'OK'
    END AS recommendation
FROM products p
LEFT JOIN order_items oi ON p.id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.id
  AND o.status = 'delivered'
  AND o.created_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY p.id, p.name, p.stock, p.price
ORDER BY
    CASE
        WHEN p.stock = 0 AND COALESCE(SUM(oi.quantity), 0) > 50 THEN 1
        WHEN p.stock < 10 AND COALESCE(SUM(oi.quantity), 0) > 20 THEN 2
        ELSE 3
    END;
```

### 3. Customer Lifecycle Stage

```sql
-- Xác định stage của customer
SELECT
    c.name,
    c.created_at AS signup_date,
    COALESCE(MAX(o.created_at), c.created_at) AS last_activity,
    COUNT(o.id) AS order_count,
    COALESCE(SUM(o.total_amount), 0) AS total_spent,
    CASE
        WHEN COUNT(o.id) = 0 THEN 'Never Purchased'
        WHEN DATEDIFF(CURDATE(), MAX(o.created_at)) > 180 THEN 'Churned'
        WHEN DATEDIFF(CURDATE(), MAX(o.created_at)) > 90 THEN 'At Risk'
        WHEN COUNT(o.id) >= 10 AND SUM(o.total_amount) > 5000000 THEN 'Champion'
        WHEN COUNT(o.id) >= 5 THEN 'Loyal'
        WHEN COUNT(o.id) >= 2 THEN 'Repeat Customer'
        ELSE 'New Customer'
    END AS lifecycle_stage
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id AND o.status = 'delivered'
GROUP BY c.id, c.name, c.created_at
ORDER BY total_spent DESC;
```

---

## UNION - Kết Hợp Kết Quả

UNION kết hợp kết quả từ nhiều SELECT queries.

### Basic UNION

```sql
-- Tất cả customers và tên products
SELECT name, 'Customer' AS type FROM customers
UNION
SELECT name, 'Product' AS type FROM products;
```

**Rules:**
- Số columns phải giống nhau
- Data types phải tương thích
- Column names lấy từ query đầu tiên

### UNION vs UNION ALL

```sql
-- UNION: Loại bỏ duplicates (chậm hơn)
SELECT city FROM customers
UNION
SELECT city FROM customers;  -- Chỉ unique cities

-- UNION ALL: Giữ duplicates (nhanh hơn)
SELECT city FROM customers
UNION ALL
SELECT city FROM customers;  -- Tất cả, kể cả duplicates
```

**Best Practice:** Dùng UNION ALL nếu bạn chắc chắn không có duplicates hoặc muốn giữ duplicates.

### UNION với ORDER BY

```sql
-- Order toàn bộ kết quả
(SELECT name, price, 'Expensive' AS category
 FROM products
 WHERE price > 2000000)
UNION ALL
(SELECT name, price, 'Cheap' AS category
 FROM products
 WHERE price <= 2000000)
ORDER BY price DESC;
```

**Lưu ý:** ORDER BY chỉ dùng ở cuối, áp dụng cho toàn bộ kết quả.

## UNION Practical Examples

### 1. Combine Different Entities

```sql
-- Activity feed: Orders và Reviews
SELECT
    'Order' AS activity_type,
    o.id AS activity_id,
    c.name AS user_name,
    CONCAT('Đặt order #', o.id, ' - ', FORMAT(o.total_amount, 0), ' đ') AS description,
    o.created_at AS activity_date
FROM orders o
JOIN customers c ON o.customer_id = c.id

UNION ALL

SELECT
    'Review' AS activity_type,
    r.id AS activity_id,
    c.name AS user_name,
    CONCAT('Review cho ', p.name, ' - ', r.rating, ' sao') AS description,
    r.created_at AS activity_date
FROM reviews r
JOIN customers c ON r.customer_id = c.id
JOIN products p ON r.product_id = p.id

ORDER BY activity_date DESC
LIMIT 50;
```

### 2. Report Aggregation

```sql
-- Tổng hợp revenue từ nhiều nguồn
SELECT
    'Products' AS source,
    SUM(oi.subtotal) AS revenue
FROM order_items oi
JOIN orders o ON oi.order_id = o.id
WHERE o.status = 'delivered'

UNION ALL

SELECT
    'Shipping Fees' AS source,
    SUM(shipping_fee) AS revenue
FROM orders
WHERE status = 'delivered'

UNION ALL

SELECT
    'Adjustments' AS source,
    0 AS revenue  -- Placeholder

ORDER BY revenue DESC;
```

### 3. Multi-Table Search

```sql
-- Search trong nhiều tables
SELECT
    'Customer' AS type,
    id,
    name,
    email AS contact
FROM customers
WHERE name LIKE '%Nguyễn%'

UNION ALL

SELECT
    'Product' AS type,
    id,
    name,
    NULL AS contact
FROM products
WHERE name LIKE '%Nguyễn%'

ORDER BY type, name;
```

### 4. Time Series with Gaps

```sql
-- Fill missing dates với UNION
WITH RECURSIVE date_range AS (
    SELECT DATE_SUB(CURDATE(), INTERVAL 29 DAY) AS date
    UNION ALL
    SELECT DATE_ADD(date, INTERVAL 1 DAY)
    FROM date_range
    WHERE date < CURDATE()
)
SELECT
    dr.date,
    COALESCE(daily.order_count, 0) AS order_count,
    COALESCE(daily.revenue, 0) AS revenue
FROM date_range dr
LEFT JOIN (
    SELECT
        DATE(created_at) AS date,
        COUNT(*) AS order_count,
        SUM(total_amount) AS revenue
    FROM orders
    WHERE status = 'delivered'
    GROUP BY DATE(created_at)
) AS daily ON dr.date = daily.date
ORDER BY dr.date;
```

### 5. Category Comparison

```sql
-- So sánh performance categories
(SELECT
    'Electronics' AS category,
    COUNT(DISTINCT o.id) AS orders,
    SUM(oi.subtotal) AS revenue
FROM categories cat
JOIN products p ON cat.id = p.category_id
JOIN order_items oi ON p.id = oi.product_id
JOIN orders o ON oi.order_id = o.id
WHERE cat.name = 'Điện tử' AND o.status = 'delivered')

UNION ALL

(SELECT
    'Fashion' AS category,
    COUNT(DISTINCT o.id) AS orders,
    SUM(oi.subtotal) AS revenue
FROM categories cat
JOIN products p ON cat.id = p.category_id
JOIN order_items oi ON p.id = oi.product_id
JOIN orders o ON oi.order_id = o.id
WHERE cat.name = 'Thời trang' AND o.status = 'delivered')

UNION ALL

(SELECT
    'All Categories' AS category,
    COUNT(DISTINCT o.id) AS orders,
    SUM(oi.subtotal) AS revenue
FROM order_items oi
JOIN orders o ON oi.order_id = o.id
WHERE o.status = 'delivered');
```

## Combining CASE and UNION

### 1. Complex Report

```sql
-- Báo cáo tổng hợp với nhiều sections
SELECT 'Revenue by Status' AS report_section, NULL AS category, NULL AS value
UNION ALL
SELECT
    '',
    status,
    SUM(total_amount)
FROM orders
GROUP BY status

UNION ALL
SELECT '', '', NULL

UNION ALL
SELECT 'Revenue by Payment Method', NULL, NULL
UNION ALL
SELECT
    '',
    payment_method,
    SUM(total_amount)
FROM orders
WHERE status = 'delivered'
GROUP BY payment_method

ORDER BY report_section, category;
```

### 2. Dashboard Summary

```sql
-- Key metrics
SELECT
    'Total Customers' AS metric,
    COUNT(*) AS value,
    NULL AS category
FROM customers

UNION ALL

SELECT
    'Total Orders',
    COUNT(*),
    NULL
FROM orders

UNION ALL

SELECT
    'Total Revenue',
    SUM(total_amount),
    NULL
FROM orders
WHERE status = 'delivered'

UNION ALL

SELECT
    'Avg Order Value',
    AVG(total_amount),
    NULL
FROM orders
WHERE status = 'delivered'

UNION ALL

SELECT
    'Orders by Status',
    COUNT(*),
    status
FROM orders
GROUP BY status;
```

## Performance Tips

### 1. Use UNION ALL When Possible

```sql
-- Faster: Không cần check duplicates
SELECT id FROM customers WHERE city = 'Hà Nội'
UNION ALL
SELECT id FROM customers WHERE city = 'Sài Gòn';

-- Slower: Check duplicates (dù không có)
SELECT id FROM customers WHERE city = 'Hà Nội'
UNION
SELECT id FROM customers WHERE city = 'Sài Gòn';
```

### 2. Index Columns in CASE Conditions

```sql
-- Index status và created_at
CREATE INDEX idx_orders_status_created ON orders(status, created_at);

SELECT
    COUNT(CASE WHEN status = 'delivered' THEN 1 END) AS delivered
FROM orders
WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY);
```

### 3. Simplify Complex CASE

```sql
-- Instead of nested CASE
SELECT
    name,
    price,
    CASE
        WHEN price < 100000 THEN 'A'
        WHEN price < 500000 THEN 'B'
        WHEN price < 1000000 THEN 'C'
        ELSE 'D'
    END AS price_tier
FROM products;

-- Consider lookup table for complex logic
```

## Bài Tập

**1. CASE Basic**
```sql
-- Phân loại customers theo số orders
-- Tính commission rate theo total_amount (tiered)
-- Stock status với emoji indicators
```

**2. CASE với Aggregates**
```sql
-- Pivot: Revenue by month và payment method
-- Count orders by status và city
-- Daily sales với weekend/weekday flag
```

**3. UNION**
```sql
-- Activity feed: Customers + Products mới
-- Search results từ nhiều tables
-- Top 5 per category với UNION
```

**4. Combined**
```sql
-- Customer segmentation report với CASE
-- Revenue comparison (current vs last year) với UNION
-- Complete dashboard summary
```

## Đáp Án

<details>
<summary>Click để xem đáp án</summary>

```sql
-- 1. CASE Basic
SELECT
    name,
    email,
    COUNT(o.id) AS order_count,
    CASE
        WHEN COUNT(o.id) = 0 THEN 'No Orders'
        WHEN COUNT(o.id) < 3 THEN 'New'
        WHEN COUNT(o.id) < 10 THEN 'Regular'
        ELSE 'VIP'
    END AS customer_level
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.name, c.email;

-- 2. Pivot
SELECT
    DATE_FORMAT(created_at, '%Y-%m') AS month,
    SUM(CASE WHEN payment_method = 'credit_card' THEN total_amount ELSE 0 END) AS credit_card,
    SUM(CASE WHEN payment_method = 'bank_transfer' THEN total_amount ELSE 0 END) AS bank,
    SUM(CASE WHEN payment_method = 'cash' THEN total_amount ELSE 0 END) AS cash
FROM orders
WHERE status = 'delivered'
GROUP BY month
ORDER BY month DESC;

-- 3. UNION
SELECT name, created_at, 'Customer' AS type
FROM customers
WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
UNION ALL
SELECT name, created_at, 'Product' AS type
FROM products
WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
ORDER BY created_at DESC;

-- 4. Combined
SELECT
    segment,
    COUNT(*) AS customer_count,
    AVG(total_spent) AS avg_spending
FROM (
    SELECT
        c.name,
        COALESCE(SUM(o.total_amount), 0) AS total_spent,
        CASE
            WHEN COALESCE(SUM(o.total_amount), 0) >= 10000000 THEN 'VIP'
            WHEN COALESCE(SUM(o.total_amount), 0) >= 5000000 THEN 'Premium'
            WHEN COALESCE(SUM(o.total_amount), 0) >= 1000000 THEN 'Regular'
            ELSE 'New'
        END AS segment
    FROM customers c
    LEFT JOIN orders o ON c.id = o.customer_id AND o.status = 'delivered'
    GROUP BY c.id, c.name
) AS segments
GROUP BY segment;
```

</details>

## Tiếp Theo

➡️ [Bài Tập Level 3](bai-tap.md)

⬅️ [Window Functions](02-window-functions.md)
