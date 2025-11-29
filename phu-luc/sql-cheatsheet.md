# SQL Cheatsheet - Tra Cứu Nhanh

## SELECT Basics

```sql
-- Lấy tất cả
SELECT * FROM table_name;

-- Lấy columns cụ thể
SELECT col1, col2 FROM table_name;

-- DISTINCT
SELECT DISTINCT column FROM table_name;

-- Aliases
SELECT col AS alias_name FROM table_name;
```

## WHERE - Filtering

```sql
-- Comparison
WHERE price > 100000
WHERE name = 'Product'
WHERE status != 'cancelled'

-- Logical
WHERE price > 100 AND stock > 0
WHERE city = 'Hà Nội' OR city = 'HCM'
WHERE NOT status = 'delivered'

-- IN
WHERE id IN (1, 2, 3)

-- BETWEEN
WHERE price BETWEEN 100 AND 500

-- LIKE
WHERE name LIKE '%áo%'      -- Chứa "áo"
WHERE name LIKE 'Áo%'       -- Bắt đầu bằng "Áo"
WHERE name LIKE '%nam'      -- Kết thúc bằng "nam"

-- NULL
WHERE description IS NULL
WHERE phone IS NOT NULL
```

## ORDER BY & LIMIT

```sql
-- Sort tăng dần
ORDER BY price ASC

-- Sort giảm dần
ORDER BY price DESC

-- Multiple columns
ORDER BY category ASC, price DESC

-- LIMIT
LIMIT 10

-- LIMIT với OFFSET (pagination)
LIMIT 10 OFFSET 20
```

## JOIN

```sql
-- INNER JOIN
SELECT * FROM orders o
INNER JOIN customers c ON o.customer_id = c.id;

-- LEFT JOIN
SELECT * FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id;

-- RIGHT JOIN
SELECT * FROM orders o
RIGHT JOIN customers c ON o.customer_id = c.id;

-- Multiple JOINs
SELECT * FROM orders o
JOIN customers c ON o.customer_id = c.id
JOIN order_items oi ON o.id = oi.order_id
JOIN products p ON oi.product_id = p.id;
```

## GROUP BY & Aggregates

```sql
-- GROUP BY
SELECT city, COUNT(*) FROM customers GROUP BY city;

-- Aggregate Functions
COUNT(*)              -- Đếm rows
COUNT(DISTINCT city)  -- Đếm unique values
SUM(price)            -- Tổng
AVG(price)            -- Trung bình
MAX(price)            -- Giá trị lớn nhất
MIN(price)            -- Giá trị nhỏ nhất

-- HAVING (filter after GROUP BY)
SELECT city, COUNT(*) as total
FROM customers
GROUP BY city
HAVING total > 10;
```

## String Functions

```sql
CONCAT('Hello', ' ', 'World')        -- 'Hello World'
CONCAT_WS(', ', 'A', 'B', 'C')      -- 'A, B, C'
UPPER('hello')                       -- 'HELLO'
LOWER('HELLO')                       -- 'hello'
LENGTH('Hello')                      -- 5
SUBSTRING('Hello', 1, 3)             -- 'Hel'
TRIM('  hello  ')                    -- 'hello'
REPLACE('Hello', 'l', 'L')           -- 'HeLLo'
```

## Date Functions

```sql
NOW()                                -- Current datetime
CURDATE()                            -- Current date
CURTIME()                            -- Current time
DATE(datetime_column)                -- Extract date
YEAR(date_column)                    -- Extract year
MONTH(date_column)                   -- Extract month
DAY(date_column)                     -- Extract day
DATEDIFF('2024-12-31', '2024-01-01') -- Days between
DATE_ADD(date, INTERVAL 7 DAY)       -- Add 7 days
DATE_FORMAT(date, '%Y-%m-%d')        -- Format date
```

## Subqueries

```sql
-- In WHERE
SELECT * FROM products
WHERE price > (SELECT AVG(price) FROM products);

-- In FROM
SELECT * FROM (
    SELECT customer_id, COUNT(*) as order_count
    FROM orders
    GROUP BY customer_id
) AS customer_orders
WHERE order_count > 5;

-- IN/EXISTS
SELECT * FROM customers
WHERE id IN (SELECT customer_id FROM orders);
```

## Window Functions

```sql
-- ROW_NUMBER
ROW_NUMBER() OVER (ORDER BY price DESC)

-- RANK
RANK() OVER (PARTITION BY category_id ORDER BY price DESC)

-- LAG/LEAD
LAG(price, 1) OVER (ORDER BY created_at)
LEAD(price, 1) OVER (ORDER BY created_at)
```

## CASE WHEN

```sql
SELECT name,
    CASE
        WHEN price < 100000 THEN 'Rẻ'
        WHEN price BETWEEN 100000 AND 500000 THEN 'Trung bình'
        ELSE 'Đắt'
    END AS price_range
FROM products;
```

## UNION

```sql
SELECT name FROM customers WHERE city = 'Hà Nội'
UNION
SELECT name FROM customers WHERE city = 'HCM';

-- UNION ALL (giữ duplicates)
SELECT name FROM customers WHERE city = 'Hà Nội'
UNION ALL
SELECT name FROM customers WHERE city = 'HCM';
```

## Indexes

```sql
-- Tạo index
CREATE INDEX idx_price ON products(price);
CREATE INDEX idx_name_city ON customers(name, city);

-- Xóa index
DROP INDEX idx_price ON products;

-- Xem indexes
SHOW INDEX FROM products;
```

## Transactions

```sql
-- Bắt đầu transaction
START TRANSACTION;

-- Các operations
INSERT INTO ...;
UPDATE ...;
DELETE FROM ...;

-- Commit hoặc Rollback
COMMIT;     -- Lưu changes
ROLLBACK;   -- Hủy changes
```

## Common Patterns

### Top N per Group
```sql
SELECT * FROM (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as rn
    FROM products
) ranked
WHERE rn <= 3;
```

### Pagination
```sql
-- Page 1
SELECT * FROM products ORDER BY id LIMIT 20 OFFSET 0;
-- Page 2
SELECT * FROM products ORDER BY id LIMIT 20 OFFSET 20;
```

### Running Total
```sql
SELECT created_at, total_amount,
    SUM(total_amount) OVER (ORDER BY created_at) as running_total
FROM orders;
```

---

⬅️ [Quay lại Phụ Lục](README.md)
