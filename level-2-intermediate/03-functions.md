# Functions - String & Date

SQL functions giúp bạn manipulate và transform data.

## String Functions

### CONCAT - Nối Chuỗi

```sql
-- Nối name và email
SELECT
    CONCAT(name, ' - ', email) AS customer_info
FROM customers
LIMIT 5;

-- Tạo full name
SELECT
    CONCAT(first_name, ' ', last_name) AS full_name
FROM customers;
```

**Kết quả:**
```
+----------------------------------+
| customer_info                    |
+----------------------------------+
| Nguyễn Văn An - an.nv@email.com |
| Trần Thị Bình - binh.tt@email.com|
+----------------------------------+
```

### CONCAT_WS - Nối Với Separator

```sql
-- Separator tự động giữa các phần
SELECT
    CONCAT_WS(' | ', name, city, phone) AS customer_summary
FROM customers
LIMIT 5;
```

### UPPER & LOWER - Chuyển Hoa/Thường

```sql
-- Chuyển thành CHỮ HOA
SELECT
    UPPER(name) AS name_upper,
    UPPER(email) AS email_upper
FROM customers
LIMIT 5;

-- Chuyển thành chữ thường
SELECT LOWER(name) FROM customers;
```

### LENGTH - Độ Dài Chuỗi

```sql
-- Độ dài tên customer
SELECT
    name,
    LENGTH(name) AS name_length
FROM customers
ORDER BY name_length DESC
LIMIT 5;

-- Tìm emails dài nhất
SELECT email, LENGTH(email) AS len
FROM customers
ORDER BY len DESC
LIMIT 3;
```

### SUBSTRING - Cắt Chuỗi

```sql
-- Lấy 3 ký tự đầu
SELECT
    name,
    SUBSTRING(name, 1, 3) AS short_name
FROM customers
LIMIT 5;

-- Lấy năm từ created_at
SELECT
    name,
    SUBSTRING(created_at, 1, 4) AS year
FROM customers;

-- Tương đương với YEAR()
SELECT name, YEAR(created_at) AS year
FROM customers;
```

### LEFT & RIGHT - Lấy Đầu/Cuối

```sql
-- 5 ký tự đầu
SELECT
    name,
    LEFT(name, 5) AS prefix
FROM products
LIMIT 10;

-- 10 ký tự cuối
SELECT
    name,
    RIGHT(name, 10) AS suffix
FROM products;
```

### TRIM, LTRIM, RTRIM - Xóa Khoảng Trắng

```sql
-- Xóa khoảng trắng 2 đầu
SELECT TRIM('  Hà Nội  ') AS city;  -- 'Hà Nội'

-- Xóa khoảng trắng bên trái
SELECT LTRIM('  Hà Nội  ') AS city;  -- 'Hà Nội  '

-- Xóa khoảng trắng bên phải
SELECT RTRIM('  Hà Nội  ') AS city;  -- '  Hà Nội'

-- Practical use
SELECT
    name,
    TRIM(city) AS clean_city
FROM customers
WHERE TRIM(city) = 'Hà Nội';
```

### REPLACE - Thay Thế

```sql
-- Thay thế text
SELECT
    name,
    REPLACE(name, 'Nguyễn', 'Ng.') AS short_name
FROM customers
WHERE name LIKE 'Nguyễn%'
LIMIT 5;

-- Ẩn phần email
SELECT
    name,
    CONCAT(
        SUBSTRING(email, 1, 3),
        '***@',
        SUBSTRING_INDEX(email, '@', -1)
    ) AS masked_email
FROM customers
LIMIT 5;
```

### SUBSTRING_INDEX - Tách Chuỗi

```sql
-- Lấy domain từ email
SELECT
    email,
    SUBSTRING_INDEX(email, '@', -1) AS domain
FROM customers
LIMIT 5;

-- Lấy phần trước @
SELECT
    email,
    SUBSTRING_INDEX(email, '@', 1) AS username
FROM customers
LIMIT 5;
```

## Date & Time Functions

### NOW, CURDATE, CURTIME

```sql
-- Thời gian hiện tại (datetime)
SELECT NOW();  -- 2024-12-20 14:30:45

-- Ngày hiện tại (date)
SELECT CURDATE();  -- 2024-12-20

-- Giờ hiện tại (time)
SELECT CURTIME();  -- 14:30:45

-- Practical: Orders hôm nay
SELECT COUNT(*) AS today_orders
FROM orders
WHERE DATE(created_at) = CURDATE();
```

### DATE_FORMAT - Format Ngày

```sql
-- Format theo style
SELECT
    created_at,
    DATE_FORMAT(created_at, '%d/%m/%Y') AS vn_date,
    DATE_FORMAT(created_at, '%Y-%m-%d') AS iso_date,
    DATE_FORMAT(created_at, '%W, %M %d, %Y') AS full_date
FROM orders
LIMIT 5;
```

**Format codes:**
- `%Y` - Năm 4 chữ số (2024)
- `%y` - Năm 2 chữ số (24)
- `%m` - Tháng số (01-12)
- `%M` - Tên tháng (January)
- `%d` - Ngày (01-31)
- `%W` - Tên thứ (Monday)
- `%H` - Giờ 24h (00-23)
- `%i` - Phút (00-59)
- `%s` - Giây (00-59)

### YEAR, MONTH, DAY, HOUR

```sql
-- Extract year, month, day
SELECT
    created_at,
    YEAR(created_at) AS year,
    MONTH(created_at) AS month,
    DAY(created_at) AS day,
    HOUR(created_at) AS hour
FROM orders
LIMIT 5;

-- Orders theo năm
SELECT
    YEAR(created_at) AS year,
    COUNT(*) AS order_count,
    SUM(total_amount) AS revenue
FROM orders
WHERE status = 'delivered'
GROUP BY YEAR(created_at)
ORDER BY year DESC;
```

### DAYNAME, MONTHNAME

```sql
-- Tên ngày và tháng
SELECT
    created_at,
    DAYNAME(created_at) AS day_name,
    MONTHNAME(created_at) AS month_name
FROM orders
LIMIT 5;

-- Orders theo thứ
SELECT
    DAYNAME(created_at) AS day_of_week,
    COUNT(*) AS order_count
FROM orders
GROUP BY day_of_week
ORDER BY order_count DESC;
```

### DATEDIFF - Khoảng Cách Ngày

```sql
-- Số ngày giữa 2 dates
SELECT DATEDIFF('2024-12-31', '2024-01-01') AS days;  -- 365

-- Customers đã đăng ký bao lâu
SELECT
    name,
    created_at,
    DATEDIFF(CURDATE(), created_at) AS days_since_signup
FROM customers
ORDER BY days_since_signup DESC
LIMIT 10;

-- Orders pending quá lâu
SELECT
    id,
    created_at,
    DATEDIFF(CURDATE(), created_at) AS days_pending
FROM orders
WHERE status = 'pending'
  AND DATEDIFF(CURDATE(), created_at) > 7
ORDER BY days_pending DESC;
```

### DATE_ADD & DATE_SUB - Cộng/Trừ Ngày

```sql
-- Thêm 7 ngày
SELECT DATE_ADD(CURDATE(), INTERVAL 7 DAY) AS next_week;

-- Trừ 30 ngày
SELECT DATE_SUB(CURDATE(), INTERVAL 30 DAY) AS last_month;

-- Orders trong 30 ngày qua
SELECT COUNT(*) AS recent_orders
FROM orders
WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY);

-- Estimated delivery date (7 days from order)
SELECT
    id,
    created_at,
    DATE_ADD(created_at, INTERVAL 7 DAY) AS estimated_delivery
FROM orders
WHERE status = 'shipped';
```

**Interval units:**
- `DAY`, `WEEK`, `MONTH`, `YEAR`
- `HOUR`, `MINUTE`, `SECOND`

### TIMESTAMPDIFF - Khoảng Cách Linh Hoạt

```sql
-- Số tháng giữa 2 dates
SELECT TIMESTAMPDIFF(MONTH, '2024-01-01', '2024-12-31') AS months;

-- Số giờ
SELECT TIMESTAMPDIFF(HOUR, '2024-01-01 00:00:00', '2024-01-01 14:30:00') AS hours;

-- Customer age (months since signup)
SELECT
    name,
    TIMESTAMPDIFF(MONTH, created_at, CURDATE()) AS months_active
FROM customers
ORDER BY months_active DESC
LIMIT 10;
```

## Practical Examples

### 1. Format Order Summary

```sql
SELECT
    id,
    CONCAT('#', LPAD(id, 6, '0')) AS order_code,
    DATE_FORMAT(created_at, '%d/%m/%Y %H:%i') AS order_time,
    CONCAT(FORMAT(total_amount, 0), ' VNĐ') AS amount,
    UPPER(status) AS status
FROM orders
ORDER BY id DESC
LIMIT 10;
```

**Kết quả:**
```
+----+------------+------------------+--------------+----------+
| id | order_code | order_time       | amount       | status   |
+----+------------+------------------+--------------+----------+
|  1 | #000001    | 20/12/2024 14:30 | 1,350,000 VNĐ| DELIVERED|
+----+------------+------------------+--------------+----------+
```

### 2. Email Domain Analysis

```sql
SELECT
    SUBSTRING_INDEX(email, '@', -1) AS domain,
    COUNT(*) AS customer_count
FROM customers
GROUP BY domain
ORDER BY customer_count DESC;
```

### 3. Customer Name Formatting

```sql
SELECT
    UPPER(LEFT(name, 1)) AS initial,
    name,
    CONCAT(
        UPPER(LEFT(name, 1)),
        LOWER(SUBSTRING(name, 2))
    ) AS formatted_name
FROM customers
LIMIT 5;
```

### 4. Monthly Revenue Report

```sql
SELECT
    DATE_FORMAT(created_at, '%Y-%m') AS month,
    DATE_FORMAT(created_at, '%M %Y') AS month_name,
    COUNT(*) AS orders,
    FORMAT(SUM(total_amount), 0) AS revenue
FROM orders
WHERE status = 'delivered'
  AND created_at >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
GROUP BY month, month_name
ORDER BY month DESC;
```

### 5. Product Name Search

```sql
-- Tìm products có từ "Áo"
SELECT
    name,
    price,
    CASE
        WHEN LOWER(name) LIKE '%áo thun%' THEN 'T-Shirt'
        WHEN LOWER(name) LIKE '%áo sơ mi%' THEN 'Shirt'
        WHEN LOWER(name) LIKE '%áo khoác%' THEN 'Jacket'
        ELSE 'Other'
    END AS category
FROM products
WHERE name LIKE '%Áo%'
ORDER BY price DESC;
```

### 6. Order Age Analysis

```sql
SELECT
    id,
    status,
    created_at,
    DATEDIFF(CURDATE(), created_at) AS days_old,
    CASE
        WHEN DATEDIFF(CURDATE(), created_at) < 7 THEN 'New'
        WHEN DATEDIFF(CURDATE(), created_at) < 30 THEN 'Recent'
        WHEN DATEDIFF(CURDATE(), created_at) < 90 THEN 'Old'
        ELSE 'Very Old'
    END AS age_category
FROM orders
ORDER BY days_old DESC
LIMIT 20;
```

### 7. Customer Activity Timeline

```sql
SELECT
    c.name,
    c.created_at AS signup_date,
    TIMESTAMPDIFF(MONTH, c.created_at, CURDATE()) AS months_member,
    COUNT(o.id) AS total_orders,
    MAX(o.created_at) AS last_order_date,
    DATEDIFF(CURDATE(), MAX(o.created_at)) AS days_since_last_order
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.name, c.created_at
HAVING total_orders > 0
ORDER BY days_since_last_order DESC
LIMIT 20;
```

### 8. Phone Number Formatting

```sql
-- Format phone: 0123456789 → 0123-456-789
SELECT
    name,
    phone,
    CONCAT(
        SUBSTRING(phone, 1, 4), '-',
        SUBSTRING(phone, 5, 3), '-',
        SUBSTRING(phone, 8, 3)
    ) AS formatted_phone
FROM customers
WHERE phone IS NOT NULL
LIMIT 10;
```

### 9. Quarter Analysis

```sql
SELECT
    YEAR(created_at) AS year,
    QUARTER(created_at) AS quarter,
    CONCAT('Q', QUARTER(created_at), ' ', YEAR(created_at)) AS period,
    COUNT(*) AS orders,
    SUM(total_amount) AS revenue
FROM orders
WHERE status = 'delivered'
GROUP BY year, quarter, period
ORDER BY year DESC, quarter DESC;
```

### 10. Week Analysis

```sql
-- Orders theo ngày trong tuần
SELECT
    DAYNAME(created_at) AS day_of_week,
    DAYOFWEEK(created_at) AS day_number,
    COUNT(*) AS order_count,
    AVG(total_amount) AS avg_order_value
FROM orders
WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY day_of_week, day_number
ORDER BY day_number;
```

## Combining Functions

### 1. Customer Profile

```sql
SELECT
    CONCAT(
        UPPER(LEFT(name, 1)),
        LOWER(SUBSTRING(name, 2))
    ) AS name,
    SUBSTRING_INDEX(email, '@', -1) AS email_domain,
    city,
    DATE_FORMAT(created_at, '%d/%m/%Y') AS signup_date,
    TIMESTAMPDIFF(MONTH, created_at, CURDATE()) AS months_active,
    CONCAT(
        SUBSTRING(phone, 1, 4), '-',
        SUBSTRING(phone, 5, 3), '-',
        SUBSTRING(phone, 8)
    ) AS formatted_phone
FROM customers
ORDER BY created_at DESC
LIMIT 10;
```

### 2. Product Catalog

```sql
SELECT
    CONCAT('#P', LPAD(id, 4, '0')) AS product_code,
    UPPER(LEFT(name, 30)) AS product_name,
    CONCAT(FORMAT(price, 0), ' đ') AS price_formatted,
    stock,
    CASE
        WHEN stock = 0 THEN 'Hết hàng'
        WHEN stock < 10 THEN 'Sắp hết'
        ELSE 'Còn hàng'
    END AS availability
FROM products
ORDER BY stock ASC
LIMIT 20;
```

## COALESCE & IFNULL

```sql
-- COALESCE - Trả về giá trị đầu tiên NOT NULL
SELECT
    name,
    COALESCE(phone, email, 'No contact') AS contact_info
FROM customers
LIMIT 10;

-- IFNULL - Thay thế NULL
SELECT
    name,
    IFNULL(phone, 'Chưa cập nhật') AS phone
FROM customers
LIMIT 10;

-- Practical: Default values
SELECT
    p.name,
    IFNULL(AVG(r.rating), 0) AS avg_rating,
    COALESCE(COUNT(r.id), 0) AS review_count
FROM products p
LEFT JOIN reviews r ON p.id = r.product_id
GROUP BY p.id, p.name
ORDER BY avg_rating DESC
LIMIT 20;
```

## CAST & CONVERT

```sql
-- Convert types
SELECT
    id,
    CAST(created_at AS DATE) AS order_date,
    CAST(total_amount AS UNSIGNED) AS amount_integer
FROM orders
LIMIT 5;

-- CONVERT
SELECT
    name,
    CONVERT(price, CHAR) AS price_string
FROM products
LIMIT 5;
```

## Bài Tập

**1. String Functions**
```sql
-- Tạo username từ email (phần trước @)
-- Format tên customers thành "Title Case"
-- Tìm products có tên dài nhất
```

**2. Date Functions**
```sql
-- Đếm orders theo tháng (6 tháng gần nhất)
-- Tìm customers đăng ký > 1 năm
-- Orders pending > 7 ngày
```

**3. Combining Functions**
```sql
-- Format order report: code, date, customer, amount
-- Customer activity: name, signup date, months active, last order
-- Product report: code, name, price formatted, stock status
```

**4. Advanced**
```sql
-- Revenue theo quarter
-- Top 10 customers (format: name, email domain, total spent)
-- Products chưa bán được trong 30 ngày
```

## Đáp Án

<details>
<summary>Click để xem đáp án</summary>

```sql
-- 1. String Functions
SELECT
    email,
    SUBSTRING_INDEX(email, '@', 1) AS username
FROM customers
LIMIT 10;

SELECT
    name,
    CONCAT(
        UPPER(LEFT(name, 1)),
        LOWER(SUBSTRING(name, 2))
    ) AS title_case
FROM customers
LIMIT 10;

SELECT name, LENGTH(name) AS len
FROM products
ORDER BY len DESC
LIMIT 1;

-- 2. Date Functions
SELECT
    DATE_FORMAT(created_at, '%Y-%m') AS month,
    COUNT(*) AS orders
FROM orders
WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
GROUP BY month
ORDER BY month DESC;

SELECT name, created_at
FROM customers
WHERE created_at <= DATE_SUB(CURDATE(), INTERVAL 1 YEAR);

SELECT id, created_at, DATEDIFF(CURDATE(), created_at) AS days
FROM orders
WHERE status = 'pending'
  AND DATEDIFF(CURDATE(), created_at) > 7;

-- 3. Combining Functions
SELECT
    CONCAT('#', LPAD(id, 6, '0')) AS code,
    DATE_FORMAT(created_at, '%d/%m/%Y') AS date,
    (SELECT name FROM customers WHERE id = orders.customer_id) AS customer,
    CONCAT(FORMAT(total_amount, 0), ' đ') AS amount
FROM orders
ORDER BY id DESC
LIMIT 10;

SELECT
    c.name,
    DATE_FORMAT(c.created_at, '%d/%m/%Y') AS signup,
    TIMESTAMPDIFF(MONTH, c.created_at, CURDATE()) AS months,
    MAX(o.created_at) AS last_order
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.name, c.created_at
LIMIT 10;

SELECT
    CONCAT('#P', LPAD(id, 4, '0')) AS code,
    name,
    CONCAT(FORMAT(price, 0), ' đ') AS price,
    CASE
        WHEN stock = 0 THEN 'Hết hàng'
        WHEN stock < 10 THEN 'Sắp hết'
        ELSE 'Còn hàng'
    END AS status
FROM products;

-- 4. Advanced
SELECT
    CONCAT('Q', QUARTER(created_at), ' ', YEAR(created_at)) AS quarter,
    SUM(total_amount) AS revenue
FROM orders
WHERE status = 'delivered'
GROUP BY quarter
ORDER BY quarter DESC;

SELECT
    c.name,
    SUBSTRING_INDEX(c.email, '@', -1) AS domain,
    CONCAT(FORMAT(SUM(o.total_amount), 0), ' đ') AS total
FROM customers c
JOIN orders o ON c.id = o.customer_id
WHERE o.status = 'delivered'
GROUP BY c.id, c.name, domain
ORDER BY SUM(o.total_amount) DESC
LIMIT 10;

SELECT p.name, p.stock
FROM products p
LEFT JOIN order_items oi ON p.id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.id
  AND o.created_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
WHERE o.id IS NULL;
```

</details>

## Tiếp Theo

➡️ [Bài Tập Level 2](bai-tap.md)

⬅️ [GROUP BY & Aggregates](02-group-by.md)
