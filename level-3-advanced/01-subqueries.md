# Subqueries - Truy Vấn Con

Subquery là một SELECT query nằm bên trong query khác. Subqueries giúp giải quyết các vấn đề phức tạp bằng cách chia nhỏ thành các bước đơn giản hơn.

## Subquery Basics

### Subquery trong WHERE

```sql
-- Tìm products có giá > giá trung bình
SELECT name, price
FROM products
WHERE price > (
    SELECT AVG(price)
    FROM products
)
ORDER BY price DESC;
```

**Giải thích:**
1. Subquery `(SELECT AVG(price) FROM products)` chạy trước, tính giá trung bình
2. Main query so sánh price với kết quả đó

### Subquery với IN

```sql
-- Tìm customers đã đặt order
SELECT name, email
FROM customers
WHERE id IN (
    SELECT DISTINCT customer_id
    FROM orders
);

-- Tương đương với JOIN:
SELECT DISTINCT c.name, c.email
FROM customers c
JOIN orders o ON c.id = o.customer_id;
```

### Subquery với NOT IN

```sql
-- Tìm customers CHƯA đặt order
SELECT name, email, city
FROM customers
WHERE id NOT IN (
    SELECT DISTINCT customer_id
    FROM orders
    WHERE customer_id IS NOT NULL
);
```

**Lưu ý:** Luôn kiểm tra NULL khi dùng NOT IN!

### Subquery với EXISTS

```sql
-- Tìm customers có ít nhất 1 order
SELECT c.name, c.email
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.id
);

-- Tìm customers CHƯA có order
SELECT c.name, c.email
FROM customers c
WHERE NOT EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.id
);
```

**EXISTS vs IN:**
- EXISTS: Nhanh hơn với large datasets
- EXISTS: An toàn hơn với NULL values
- IN: Dễ đọc hơn với small subquery results

## Subquery trong SELECT

```sql
-- Thêm cột calculated từ subquery
SELECT
    p.name,
    p.price,
    (SELECT AVG(price) FROM products) AS avg_price,
    p.price - (SELECT AVG(price) FROM products) AS diff_from_avg
FROM products
ORDER BY diff_from_avg DESC
LIMIT 10;
```

### Correlated Subquery

```sql
-- Với mỗi product, đếm số reviews
SELECT
    p.name,
    p.price,
    (SELECT COUNT(*)
     FROM reviews r
     WHERE r.product_id = p.id) AS review_count
FROM products p
ORDER BY review_count DESC
LIMIT 10;
```

**Correlated subquery:** Subquery tham chiếu đến table trong outer query (`p.id`).

### Multiple Subqueries

```sql
-- Customer info với order stats
SELECT
    c.name,
    c.email,
    (SELECT COUNT(*)
     FROM orders o
     WHERE o.customer_id = c.id) AS order_count,
    (SELECT COALESCE(SUM(total_amount), 0)
     FROM orders o
     WHERE o.customer_id = c.id
     AND o.status = 'delivered') AS total_spent,
    (SELECT MAX(created_at)
     FROM orders o
     WHERE o.customer_id = c.id) AS last_order_date
FROM customers c
ORDER BY total_spent DESC
LIMIT 20;
```

## Subquery trong FROM

Subquery trong FROM tạo ra "derived table" (bảng tạm).

```sql
-- Revenue theo tháng với ranking
SELECT
    month,
    revenue,
    order_count
FROM (
    SELECT
        DATE_FORMAT(created_at, '%Y-%m') AS month,
        SUM(total_amount) AS revenue,
        COUNT(*) AS order_count
    FROM orders
    WHERE status = 'delivered'
    GROUP BY month
) AS monthly_stats
ORDER BY revenue DESC;
```

**Lưu ý:** Derived table PHẢI có alias (`AS monthly_stats`).

### Complex Example

```sql
-- Top 10 customers với details
SELECT
    customer_name,
    total_orders,
    total_spent,
    avg_order_value,
    CONCAT(FORMAT(total_spent, 0), ' đ') AS formatted_total
FROM (
    SELECT
        c.name AS customer_name,
        COUNT(o.id) AS total_orders,
        SUM(o.total_amount) AS total_spent,
        AVG(o.total_amount) AS avg_order_value
    FROM customers c
    JOIN orders o ON c.id = o.customer_id
    WHERE o.status = 'delivered'
    GROUP BY c.id, c.name
) AS customer_stats
WHERE total_orders >= 3
ORDER BY total_spent DESC
LIMIT 10;
```

## Subquery với Comparison Operators

### ANY / SOME

```sql
-- Products có giá cao hơn BẤT KỲ product nào trong category 1
SELECT name, price, category_id
FROM products
WHERE price > ANY (
    SELECT price
    FROM products
    WHERE category_id = 1
)
AND category_id != 1;
```

### ALL

```sql
-- Products có giá cao hơn TẤT CẢ products trong category 1
SELECT name, price, category_id
FROM products
WHERE price > ALL (
    SELECT price
    FROM products
    WHERE category_id = 1
)
ORDER BY price DESC;

-- Tương đương với:
SELECT name, price, category_id
FROM products
WHERE price > (
    SELECT MAX(price)
    FROM products
    WHERE category_id = 1
);
```

## Practical Examples

### 1. Products Above Average Rating

```sql
-- Products có rating > rating trung bình
SELECT
    p.name,
    p.price,
    AVG(r.rating) AS avg_rating,
    COUNT(r.id) AS review_count
FROM products p
JOIN reviews r ON p.id = r.product_id
GROUP BY p.id, p.name, p.price
HAVING avg_rating > (
    SELECT AVG(rating)
    FROM reviews
)
ORDER BY avg_rating DESC;
```

### 2. Top Customers per City

```sql
-- Với mỗi city, tìm customer chi tiêu nhiều nhất
SELECT
    c.city,
    c.name,
    c.email,
    total_spent
FROM customers c
JOIN (
    SELECT
        customer_id,
        SUM(total_amount) AS total_spent
    FROM orders
    WHERE status = 'delivered'
    GROUP BY customer_id
) AS customer_totals ON c.id = customer_totals.customer_id
WHERE total_spent = (
    SELECT MAX(total_spent)
    FROM (
        SELECT
            c2.city,
            SUM(o2.total_amount) AS total_spent
        FROM customers c2
        JOIN orders o2 ON c2.id = o2.customer_id
        WHERE o2.status = 'delivered'
          AND c2.city = c.city
        GROUP BY c2.id, c2.city
    ) AS city_stats
)
ORDER BY c.city, total_spent DESC;
```

### 3. Products Never Ordered

```sql
-- Products chưa được order lần nào
SELECT
    p.name,
    p.price,
    p.stock,
    cat.name AS category
FROM products p
JOIN categories cat ON p.category_id = cat.id
WHERE p.id NOT IN (
    SELECT DISTINCT product_id
    FROM order_items
    WHERE product_id IS NOT NULL
)
ORDER BY p.price DESC;
```

### 4. Customers Who Only Order from One Category

```sql
-- Customers chỉ mua products từ 1 category duy nhất
SELECT
    c.name,
    c.email,
    COUNT(DISTINCT p.category_id) AS category_count
FROM customers c
JOIN orders o ON c.id = o.customer_id
JOIN order_items oi ON o.id = oi.order_id
JOIN products p ON oi.product_id = p.id
GROUP BY c.id, c.name, c.email
HAVING category_count = 1;
```

### 5. Orders Above Average for Customer

```sql
-- Tìm orders có giá trị > giá trị trung bình của customer đó
SELECT
    o.id,
    o.customer_id,
    c.name,
    o.total_amount,
    (SELECT AVG(total_amount)
     FROM orders o2
     WHERE o2.customer_id = o.customer_id) AS customer_avg
FROM orders o
JOIN customers c ON o.customer_id = c.id
WHERE o.total_amount > (
    SELECT AVG(total_amount)
    FROM orders o2
    WHERE o2.customer_id = o.customer_id
)
ORDER BY o.customer_id, o.total_amount DESC;
```

### 6. Category Performance vs Average

```sql
-- So sánh revenue của mỗi category với average
SELECT
    cat.name AS category,
    cat_revenue.revenue,
    cat_revenue.order_count,
    (SELECT AVG(revenue)
     FROM (
         SELECT
             p2.category_id,
             SUM(oi2.subtotal) AS revenue
         FROM products p2
         JOIN order_items oi2 ON p2.id = oi2.product_id
         JOIN orders o2 ON oi2.order_id = o2.id
         WHERE o2.status = 'delivered'
         GROUP BY p2.category_id
     ) AS all_cats
    ) AS avg_category_revenue,
    cat_revenue.revenue - (
        SELECT AVG(revenue)
        FROM (
            SELECT
                p2.category_id,
                SUM(oi2.subtotal) AS revenue
            FROM products p2
            JOIN order_items oi2 ON p2.id = oi2.product_id
            JOIN orders o2 ON oi2.order_id = o2.id
            WHERE o2.status = 'delivered'
            GROUP BY p2.category_id
        ) AS all_cats
    ) AS diff_from_avg
FROM categories cat
JOIN (
    SELECT
        p.category_id,
        SUM(oi.subtotal) AS revenue,
        COUNT(DISTINCT o.id) AS order_count
    FROM products p
    JOIN order_items oi ON p.id = oi.product_id
    JOIN orders o ON oi.order_id = o.id
    WHERE o.status = 'delivered'
    GROUP BY p.category_id
) AS cat_revenue ON cat.id = cat_revenue.category_id
ORDER BY diff_from_avg DESC;
```

### 7. Second Highest Price

```sql
-- Product có giá cao thứ 2
SELECT name, price
FROM products
WHERE price = (
    SELECT MAX(price)
    FROM products
    WHERE price < (SELECT MAX(price) FROM products)
);
```

### 8. Customers with Above-Average Order Frequency

```sql
-- Customers có số orders > trung bình
SELECT
    c.name,
    c.email,
    COUNT(o.id) AS order_count,
    (SELECT AVG(order_count)
     FROM (
         SELECT customer_id, COUNT(*) AS order_count
         FROM orders
         GROUP BY customer_id
     ) AS counts
    ) AS avg_orders
FROM customers c
JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.name, c.email
HAVING order_count > (
    SELECT AVG(order_count)
    FROM (
        SELECT customer_id, COUNT(*) AS order_count
        FROM orders
        GROUP BY customer_id
    ) AS counts
)
ORDER BY order_count DESC;
```

### 9. Products Cheaper Than Category Average

```sql
-- Trong mỗi category, products có giá < giá trung bình category đó
SELECT
    p.name,
    cat.name AS category,
    p.price,
    (SELECT AVG(price)
     FROM products p2
     WHERE p2.category_id = p.category_id) AS category_avg_price,
    p.price - (
        SELECT AVG(price)
        FROM products p2
        WHERE p2.category_id = p.category_id
    ) AS diff_from_avg
FROM products p
JOIN categories cat ON p.category_id = cat.id
WHERE p.price < (
    SELECT AVG(price)
    FROM products p2
    WHERE p2.category_id = p.category_id
)
ORDER BY category, diff_from_avg;
```

### 10. Latest Order per Customer

```sql
-- Order mới nhất của mỗi customer
SELECT
    c.name,
    o.id AS order_id,
    o.created_at,
    o.total_amount
FROM customers c
JOIN orders o ON c.id = o.customer_id
WHERE o.created_at = (
    SELECT MAX(created_at)
    FROM orders o2
    WHERE o2.customer_id = c.id
)
ORDER BY o.created_at DESC
LIMIT 20;
```

## Performance Tips

### 1. Avoid Correlated Subqueries When Possible

```sql
-- SLOW - Correlated subquery
SELECT
    p.name,
    (SELECT COUNT(*)
     FROM reviews r
     WHERE r.product_id = p.id) AS review_count
FROM products p;

-- FAST - JOIN
SELECT
    p.name,
    COUNT(r.id) AS review_count
FROM products p
LEFT JOIN reviews r ON p.id = r.product_id
GROUP BY p.id, p.name;
```

### 2. Use EXISTS Instead of IN for Large Tables

```sql
-- Slower với large tables
SELECT name FROM customers
WHERE id IN (SELECT customer_id FROM orders);

-- Faster
SELECT name FROM customers c
WHERE EXISTS (
    SELECT 1 FROM orders o WHERE o.customer_id = c.id
);
```

### 3. Index Foreign Keys

Đảm bảo foreign key columns có indexes:
```sql
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
```

## Common Mistakes

### 1. Subquery Returning Multiple Rows

```sql
-- ERROR: Subquery returns more than 1 row
SELECT name, price
FROM products
WHERE price > (
    SELECT price  -- Trả về nhiều rows!
    FROM products
    WHERE category_id = 1
);

-- FIX: Dùng aggregate hoặc ANY/ALL
WHERE price > (SELECT MAX(price) FROM products WHERE category_id = 1);
-- HOẶC
WHERE price > ANY (SELECT price FROM products WHERE category_id = 1);
```

### 2. NULL in NOT IN

```sql
-- Có thể trả về unexpected results nếu có NULL
SELECT name FROM customers
WHERE id NOT IN (
    SELECT customer_id FROM orders  -- Có thể chứa NULL
);

-- SAFE: Loại bỏ NULL
WHERE id NOT IN (
    SELECT customer_id FROM orders WHERE customer_id IS NOT NULL
);

-- HOẶC dùng NOT EXISTS
WHERE NOT EXISTS (
    SELECT 1 FROM orders o WHERE o.customer_id = customers.id
);
```

### 3. Missing Alias for Derived Table

```sql
-- ERROR: Derived table must have alias
SELECT * FROM (
    SELECT name, price FROM products
);

-- CORRECT
SELECT * FROM (
    SELECT name, price FROM products
) AS product_list;
```

## Bài Tập

**1. Basic Subqueries**
```sql
-- Tìm products có stock > stock trung bình
-- Customers có total_spent > average total_spent
-- Products chưa có review nào
```

**2. Correlated Subqueries**
```sql
-- Với mỗi category, products có giá cao nhất
-- Orders có giá trị lớn nhất của mỗi customer
-- Products có nhiều reviews nhất trong category
```

**3. Derived Tables**
```sql
-- Top 5 categories theo revenue
-- Monthly revenue với growth rate
-- Customer segments (based on total_spent)
```

**4. Advanced**
```sql
-- Customers đã mua tất cả products trong category X
-- Products có rating cao hơn 80% products khác
-- Orders có > 5 items và total_amount > average
```

## Đáp Án

<details>
<summary>Click để xem đáp án</summary>

```sql
-- 1. Basic
SELECT name, stock
FROM products
WHERE stock > (SELECT AVG(stock) FROM products);

SELECT c.name, SUM(o.total_amount) AS total
FROM customers c
JOIN orders o ON c.id = o.customer_id
WHERE o.status = 'delivered'
GROUP BY c.id, c.name
HAVING total > (
    SELECT AVG(total)
    FROM (
        SELECT SUM(total_amount) AS total
        FROM orders
        WHERE status = 'delivered'
        GROUP BY customer_id
    ) AS totals
);

SELECT p.name
FROM products p
WHERE NOT EXISTS (
    SELECT 1 FROM reviews r WHERE r.product_id = p.id
);

-- 2. Correlated
SELECT p.name, cat.name, p.price
FROM products p
JOIN categories cat ON p.category_id = cat.id
WHERE p.price = (
    SELECT MAX(price)
    FROM products p2
    WHERE p2.category_id = p.category_id
);

SELECT c.name, o.id, o.total_amount
FROM customers c
JOIN orders o ON c.id = o.customer_id
WHERE o.total_amount = (
    SELECT MAX(total_amount)
    FROM orders o2
    WHERE o2.customer_id = c.id
);

-- 3. Derived Tables
SELECT category, revenue, order_count
FROM (
    SELECT
        cat.name AS category,
        SUM(oi.subtotal) AS revenue,
        COUNT(DISTINCT o.id) AS order_count
    FROM categories cat
    JOIN products p ON cat.id = p.category_id
    JOIN order_items oi ON p.id = oi.product_id
    JOIN orders o ON oi.order_id = o.id
    WHERE o.status = 'delivered'
    GROUP BY cat.id, cat.name
) AS cat_stats
ORDER BY revenue DESC
LIMIT 5;

-- 4. Advanced
SELECT o.id, o.total_amount, item_count
FROM orders o
JOIN (
    SELECT order_id, COUNT(*) AS item_count
    FROM order_items
    GROUP BY order_id
) AS counts ON o.id = counts.order_id
WHERE item_count > 5
  AND o.total_amount > (SELECT AVG(total_amount) FROM orders);
```

</details>

## Tiếp Theo

➡️ [Window Functions](02-window-functions.md)

⬅️ [Level 2: Intermediate](../level-2-intermediate/README.md)
