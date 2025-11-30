# JOIN Tables - Kết Hợp Dữ Liệu

JOIN là một trong những tính năng mạnh nhất của SQL, cho phép bạn kết hợp data từ nhiều tables.

## Tại Sao Cần JOIN?

Trong database quan hệ, data được chia thành nhiều tables để:
- Tránh duplicate data
- Dễ maintain
- Tăng performance

**Ví dụ:** Thay vì lưu tên customer trong mỗi order, chúng ta lưu `customer_id` và JOIN với bảng `customers` khi cần.

## INNER JOIN - Giao Điểm

Lấy rows có matching values ở CẢ HAI tables.

### Cú Pháp

```sql
SELECT columns
FROM table1
INNER JOIN table2 ON table1.column = table2.column;
```

### Basic Example

```sql
-- Lấy orders với tên customer
SELECT
    o.id,
    c.name AS customer_name,
    o.total_amount,
    o.status
FROM orders o
INNER JOIN customers c ON o.customer_id = c.id;
```

**Kết quả:**
```
+----+----------------+--------------+-----------+
| id | customer_name  | total_amount | status    |
+----+----------------+--------------+-----------+
|  1 | Nguyễn Văn An  |      1350000 | delivered |
|  2 | Trần Thị Bình  |       850000 | delivered |
+----+----------------+--------------+-----------+
```

### Multiple Columns

```sql
-- Lấy nhiều columns từ cả 2 tables
SELECT
    c.name,
    c.email,
    c.city,
    o.id AS order_id,
    o.total_amount,
    o.created_at AS order_date
FROM customers c
INNER JOIN orders o ON c.id = o.customer_id
ORDER BY o.created_at DESC
LIMIT 10;
```

### Implicit vs Explicit JOIN

```sql
-- ❌ Implicit (old style - không khuyến khích)
SELECT * FROM orders, customers
WHERE orders.customer_id = customers.id;

-- ✅ Explicit (modern, recommended)
SELECT * FROM orders
INNER JOIN customers ON orders.customer_id = customers.id;
```

## LEFT JOIN - Lấy Tất Cả Bên Trái

Lấy TẤT CẢ rows từ left table, và matching rows từ right table. Nếu không match → NULL.

### Cú Pháp

```sql
SELECT columns
FROM left_table
LEFT JOIN right_table ON left_table.column = right_table.column;
```

### Example

```sql
-- Lấy TẤT CẢ customers, kể cả những người chưa mua hàng
SELECT
    c.id,
    c.name,
    c.email,
    COUNT(o.id) AS order_count,
    COALESCE(SUM(o.total_amount), 0) AS total_spent
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.name, c.email
ORDER BY order_count DESC;
```

**Use Case:** Tìm customers chưa có orders

```sql
SELECT
    c.id,
    c.name,
    c.email
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
WHERE o.id IS NULL;
```

## RIGHT JOIN - Lấy Tất Cả Bên Phải

Lấy TẤT CẢ rows từ right table, và matching rows từ left table.

```sql
-- Tương đương với LEFT JOIN nhưng đảo ngược
SELECT
    c.name,
    o.id,
    o.total_amount
FROM orders o
RIGHT JOIN customers c ON o.customer_id = c.id;

-- Tương đương với:
SELECT
    c.name,
    o.id,
    o.total_amount
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id;
```

⚠️ **Note:** RIGHT JOIN ít dùng hơn LEFT JOIN. Thường thì chỉ cần LEFT JOIN.

## Multiple JOINs

Kết hợp nhiều hơn 2 tables:

```sql
-- Orders với Customer info và Order Items
SELECT
    o.id AS order_id,
    c.name AS customer_name,
    c.city,
    oi.quantity,
    p.name AS product_name,
    oi.price
FROM orders o
INNER JOIN customers c ON o.customer_id = c.id
INNER JOIN order_items oi ON o.id = oi.order_id
INNER JOIN products p ON oi.product_id = p.id
WHERE o.status = 'delivered'
ORDER BY o.id
LIMIT 20;
```

### Example: Complete Order Details

```sql
-- Thông tin đầy đủ của 1 order
SELECT
    o.id,
    o.created_at,
    c.name AS customer,
    c.email,
    c.phone,
    p.name AS product,
    cat.name AS category,
    oi.quantity,
    oi.price,
    oi.subtotal,
    o.total_amount,
    o.status
FROM orders o
JOIN customers c ON o.customer_id = c.id
JOIN order_items oi ON o.id = oi.order_id
JOIN products p ON oi.product_id = p.id
JOIN categories cat ON p.category_id = cat.id
WHERE o.id = 1;
```

## Self JOIN

JOIN table với chính nó:

```sql
-- Tìm customers cùng thành phố
SELECT
    c1.name AS customer1,
    c2.name AS customer2,
    c1.city
FROM customers c1
INNER JOIN customers c2 ON c1.city = c2.city AND c1.id < c2.id
WHERE c1.city = 'Hà Nội'
LIMIT 10;
```

## JOIN với WHERE

```sql
-- JOIN + filter
SELECT
    c.name,
    o.total_amount,
    o.created_at
FROM customers c
INNER JOIN orders o ON c.id = o.customer_id
WHERE c.city = 'Hà Nội'
  AND o.total_amount > 1000000
  AND o.status = 'delivered'
ORDER BY o.total_amount DESC;
```

## USING Clause

Khi columns có tên giống nhau:

```sql
-- Thay vì
SELECT * FROM orders o
JOIN customers c ON o.customer_id = c.id;

-- Có thể dùng USING (nếu column tên giống)
SELECT * FROM orders
JOIN customers USING (customer_id);  -- ❌ Không work vì tên khác

-- Ví dụ work với bảng có tên giống:
-- JOIN order_items USING (order_id)
```

## Practical Examples

### 1. Top Customers by Revenue

```sql
SELECT
    c.name,
    c.email,
    COUNT(o.id) AS order_count,
    SUM(o.total_amount) AS total_revenue
FROM customers c
INNER JOIN orders o ON c.id = o.customer_id
WHERE o.status = 'delivered'
GROUP BY c.id, c.name, c.email
ORDER BY total_revenue DESC
LIMIT 10;
```

### 2. Products Never Ordered

```sql
SELECT
    p.id,
    p.name,
    p.price,
    p.stock
FROM products p
LEFT JOIN order_items oi ON p.id = oi.product_id
WHERE oi.id IS NULL;
```

### 3. Orders by City

```sql
SELECT
    c.city,
    COUNT(o.id) AS order_count,
    SUM(o.total_amount) AS total_revenue,
    AVG(o.total_amount) AS avg_order_value
FROM customers c
INNER JOIN orders o ON c.id = o.customer_id
WHERE o.status = 'delivered'
GROUP BY c.city
ORDER BY total_revenue DESC;
```

### 4. Products with Reviews

```sql
SELECT
    p.name,
    p.price,
    AVG(r.rating) AS avg_rating,
    COUNT(r.id) AS review_count
FROM products p
INNER JOIN reviews r ON p.id = r.product_id
GROUP BY p.id, p.name, p.price
HAVING review_count >= 3
ORDER BY avg_rating DESC;
```

### 5. Monthly Revenue by Category

```sql
SELECT
    cat.name AS category,
    DATE_FORMAT(o.created_at, '%Y-%m') AS month,
    SUM(oi.subtotal) AS revenue
FROM categories cat
JOIN products p ON cat.id = p.category_id
JOIN order_items oi ON p.id = oi.product_id
JOIN orders o ON oi.order_id = o.id
WHERE o.status = 'delivered'
GROUP BY cat.id, cat.name, month
ORDER BY month DESC, revenue DESC;
```

## JOIN Performance Tips

### 1. Index Foreign Keys

```sql
-- Luôn có index trên FK columns
CREATE INDEX idx_customer_id ON orders(customer_id);
CREATE INDEX idx_product_id ON order_items(product_id);
```

### 2. Select Only Needed Columns

```sql
-- ❌ SLOW
SELECT * FROM orders o
JOIN customers c ON o.customer_id = c.id;

-- ✅ FAST
SELECT o.id, c.name, o.total_amount
FROM orders o
JOIN customers c ON o.customer_id = c.id;
```

### 3. Use WHERE to Filter Early

```sql
-- ✅ Filter BEFORE JOIN
SELECT o.id, c.name
FROM orders o
JOIN customers c ON o.customer_id = c.id
WHERE o.created_at > '2024-01-01';  -- Filter early
```

## Common Mistakes

### 1. Cartesian Product

```sql
-- ❌ Quên ON condition → N × M rows!
SELECT * FROM orders, customers;

-- ✅ Always use ON
SELECT * FROM orders o
JOIN customers c ON o.customer_id = c.id;
```

### 2. Ambiguous Columns

```sql
-- ❌ Lỗi: Column 'id' is ambiguous
SELECT id, name FROM orders
JOIN customers ON orders.customer_id = customers.id;

-- ✅ Specify table
SELECT orders.id, customers.name FROM orders
JOIN customers ON orders.customer_id = customers.id;

-- ✅ Better: Use aliases
SELECT o.id, c.name FROM orders o
JOIN customers c ON o.customer_id = c.id;
```

### 3. Wrong JOIN Type

```sql
-- ❌ INNER JOIN → mất customers không có orders
SELECT c.name, COUNT(o.id) FROM customers c
INNER JOIN orders o ON c.id = o.customer_id
GROUP BY c.id;

-- ✅ LEFT JOIN → giữ tất cả customers
SELECT c.name, COUNT(o.id) FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
GROUP BY c.id;
```

## Bài Tập

**1. Basic JOIN**
```sql
-- Lấy tất cả orders với tên customer và email
-- Lấy products với tên category
```

**2. LEFT JOIN**
```sql
-- Tìm customers chưa có order nào
-- Tìm products chưa có review nào
```

**3. Multiple JOINs**
```sql
-- Lấy order details: customer, products, quantities
-- Top 10 products bán chạy nhất (theo số lượng đã bán)
```

**4. Aggregation với JOIN**
```sql
-- Tổng doanh thu theo thành phố
-- Trung bình rating mỗi category
```

## Đáp Án

<details>
<summary>Click để xem đáp án</summary>

```sql
-- 1. Basic JOIN
SELECT o.id, c.name, c.email, o.total_amount
FROM orders o
JOIN customers c ON o.customer_id = c.id;

SELECT p.name, cat.name AS category, p.price
FROM products p
JOIN categories cat ON p.category_id = cat.id;

-- 2. LEFT JOIN
SELECT c.id, c.name, c.email
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
WHERE o.id IS NULL;

SELECT p.id, p.name
FROM products p
LEFT JOIN reviews r ON p.id = r.product_id
WHERE r.id IS NULL;

-- 3. Multiple JOINs
SELECT
    o.id,
    c.name AS customer,
    p.name AS product,
    oi.quantity,
    oi.price
FROM orders o
JOIN customers c ON o.customer_id = c.id
JOIN order_items oi ON o.id = oi.order_id
JOIN products p ON oi.product_id = p.id;

SELECT
    p.name,
    SUM(oi.quantity) AS total_sold
FROM products p
JOIN order_items oi ON p.id = oi.product_id
JOIN orders o ON oi.order_id = o.id
WHERE o.status = 'delivered'
GROUP BY p.id, p.name
ORDER BY total_sold DESC
LIMIT 10;

-- 4. Aggregation
SELECT
    c.city,
    SUM(o.total_amount) AS revenue
FROM customers c
JOIN orders o ON c.id = o.customer_id
WHERE o.status = 'delivered'
GROUP BY c.city
ORDER BY revenue DESC;

SELECT
    cat.name,
    AVG(r.rating) AS avg_rating
FROM categories cat
JOIN products p ON cat.id = p.category_id
JOIN reviews r ON p.id = r.product_id
GROUP BY cat.id, cat.name;
```

</details>

## Tổng Kết

- ✅ INNER JOIN - matching rows từ cả 2 tables
- ✅ LEFT JOIN - tất cả left + matching right
- ✅ RIGHT JOIN - tất cả right + matching left
- ✅ Multiple JOINs - kết hợp > 2 tables
- ✅ Self JOIN - join table với chính nó

## Tiếp Theo

➡️ [GROUP BY & Aggregates](02-group-by.md)

⬅️ [Level 2 Overview](README.md)
