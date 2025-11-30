# Bài Tập Level 2 - Intermediate

20 bài tập tổng hợp JOIN, GROUP BY, và Functions.

## Part 1: JOIN Exercises (5 bài)

### Bài 1: Customer Orders Summary
Lấy thông tin tất cả customers với số lượng orders và tổng chi tiêu của họ. Bao gồm cả customers chưa có order nào.

**Output mong đợi:** name, email, order_count, total_spent

<details>
<summary>Đáp án</summary>

```sql
SELECT
    c.name,
    c.email,
    COUNT(o.id) AS order_count,
    COALESCE(SUM(o.total_amount), 0) AS total_spent
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.name, c.email
ORDER BY total_spent DESC;
```

</details>

---

### Bài 2: Product Sales Report
Tìm top 10 products bán chạy nhất (theo số lượng đã bán), kèm theo tên category và tổng doanh thu.

**Output:** product_name, category_name, quantity_sold, revenue

<details>
<summary>Đáp án</summary>

```sql
SELECT
    p.name AS product_name,
    cat.name AS category_name,
    SUM(oi.quantity) AS quantity_sold,
    SUM(oi.subtotal) AS revenue
FROM products p
JOIN categories cat ON p.category_id = cat.id
JOIN order_items oi ON p.id = oi.product_id
JOIN orders o ON oi.order_id = o.id
WHERE o.status = 'delivered'
GROUP BY p.id, p.name, cat.name
ORDER BY quantity_sold DESC
LIMIT 10;
```

</details>

---

### Bài 3: Customers Without Orders
Tìm tất cả customers chưa đặt order nào, hiển thị name, email, city, và số ngày kể từ khi đăng ký.

**Output:** name, email, city, days_since_signup

<details>
<summary>Đáp án</summary>

```sql
SELECT
    c.name,
    c.email,
    c.city,
    DATEDIFF(CURDATE(), c.created_at) AS days_since_signup
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
WHERE o.id IS NULL
ORDER BY days_since_signup DESC;
```

</details>

---

### Bài 4: Order Details Report
Lấy chi tiết đầy đủ của order_id = 1, bao gồm: order info, customer info, từng product trong order với quantity và price.

**Output:** order_id, customer_name, product_name, quantity, price, subtotal

<details>
<summary>Đáp án</summary>

```sql
SELECT
    o.id AS order_id,
    c.name AS customer_name,
    p.name AS product_name,
    oi.quantity,
    oi.price,
    oi.subtotal
FROM orders o
JOIN customers c ON o.customer_id = c.id
JOIN order_items oi ON o.id = oi.order_id
JOIN products p ON oi.product_id = p.id
WHERE o.id = 1
ORDER BY oi.id;
```

</details>

---

### Bài 5: Products Never Reviewed
Tìm products chưa có review nào, hiển thị name, price, stock, và tên category.

**Output:** product_name, category, price, stock

<details>
<summary>Đáp án</summary>

```sql
SELECT
    p.name AS product_name,
    cat.name AS category,
    p.price,
    p.stock
FROM products p
JOIN categories cat ON p.category_id = cat.id
LEFT JOIN reviews r ON p.id = r.product_id
WHERE r.id IS NULL
ORDER BY p.price DESC;
```

</details>

---

## Part 2: GROUP BY & Aggregates (5 bài)

### Bài 6: Revenue by City
Tính tổng doanh thu, số lượng orders, và giá trị trung bình mỗi order theo từng thành phố.

**Output:** city, total_orders, total_revenue, avg_order_value

<details>
<summary>Đáp án</summary>

```sql
SELECT
    c.city,
    COUNT(o.id) AS total_orders,
    SUM(o.total_amount) AS total_revenue,
    AVG(o.total_amount) AS avg_order_value
FROM customers c
JOIN orders o ON c.id = o.customer_id
WHERE o.status = 'delivered'
GROUP BY c.city
ORDER BY total_revenue DESC;
```

</details>

---

### Bài 7: Category Performance
Với mỗi category, tính: số lượng products, tổng số lượng đã bán, tổng doanh thu, và average rating.

**Output:** category, product_count, total_sold, revenue, avg_rating

<details>
<summary>Đáp án</summary>

```sql
SELECT
    cat.name AS category,
    COUNT(DISTINCT p.id) AS product_count,
    COALESCE(SUM(oi.quantity), 0) AS total_sold,
    COALESCE(SUM(oi.subtotal), 0) AS revenue,
    COALESCE(AVG(r.rating), 0) AS avg_rating
FROM categories cat
LEFT JOIN products p ON cat.id = p.category_id
LEFT JOIN order_items oi ON p.id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.id AND o.status = 'delivered'
LEFT JOIN reviews r ON p.id = r.product_id
GROUP BY cat.id, cat.name
ORDER BY revenue DESC;
```

</details>

---

### Bài 8: Monthly Revenue Trend
Tính doanh thu theo tháng trong 6 tháng gần nhất, chỉ tính orders đã delivered.

**Output:** month, order_count, revenue

<details>
<summary>Đáp án</summary>

```sql
SELECT
    DATE_FORMAT(created_at, '%Y-%m') AS month,
    COUNT(*) AS order_count,
    SUM(total_amount) AS revenue
FROM orders
WHERE status = 'delivered'
  AND created_at >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
GROUP BY month
ORDER BY month DESC;
```

</details>

---

### Bài 9: High-Value Customers
Tìm customers có tổng chi tiêu > 5,000,000 VNĐ, sắp xếp theo tổng chi tiêu giảm dần.

**Output:** name, email, order_count, total_spent

<details>
<summary>Đáp án</summary>

```sql
SELECT
    c.name,
    c.email,
    COUNT(o.id) AS order_count,
    SUM(o.total_amount) AS total_spent
FROM customers c
JOIN orders o ON c.id = o.customer_id
WHERE o.status = 'delivered'
GROUP BY c.id, c.name, c.email
HAVING total_spent > 5000000
ORDER BY total_spent DESC;
```

</details>

---

### Bài 10: Popular Products
Tìm products có > 10 reviews, hiển thị name, average rating, và số lượng reviews.

**Output:** product_name, avg_rating, review_count

<details>
<summary>Đáp án</summary>

```sql
SELECT
    p.name AS product_name,
    AVG(r.rating) AS avg_rating,
    COUNT(r.id) AS review_count
FROM products p
JOIN reviews r ON p.id = r.product_id
GROUP BY p.id, p.name
HAVING review_count > 10
ORDER BY avg_rating DESC, review_count DESC;
```

</details>

---

## Part 3: Functions (5 bài)

### Bài 11: Format Customer List
Tạo danh sách customers với format:
- Name: Title Case
- Email domain
- Phone: formatted (0123-456-789)
- Signup date: DD/MM/YYYY

**Output:** formatted_name, email_domain, formatted_phone, signup_date

<details>
<summary>Đáp án</summary>

```sql
SELECT
    CONCAT(
        UPPER(LEFT(name, 1)),
        LOWER(SUBSTRING(name, 2))
    ) AS formatted_name,
    SUBSTRING_INDEX(email, '@', -1) AS email_domain,
    CONCAT(
        SUBSTRING(phone, 1, 4), '-',
        SUBSTRING(phone, 5, 3), '-',
        SUBSTRING(phone, 8)
    ) AS formatted_phone,
    DATE_FORMAT(created_at, '%d/%m/%Y') AS signup_date
FROM customers
ORDER BY created_at DESC
LIMIT 20;
```

</details>

---

### Bài 12: Order Age Analysis
Với mỗi order, tính số ngày kể từ khi order được tạo, và phân loại:
- < 7 ngày: "New"
- 7-30 ngày: "Recent"
- 30-90 ngày: "Old"
- > 90 ngày: "Very Old"

**Output:** order_id, created_at, days_old, age_category

<details>
<summary>Đáp án</summary>

```sql
SELECT
    id AS order_id,
    created_at,
    DATEDIFF(CURDATE(), created_at) AS days_old,
    CASE
        WHEN DATEDIFF(CURDATE(), created_at) < 7 THEN 'New'
        WHEN DATEDIFF(CURDATE(), created_at) < 30 THEN 'Recent'
        WHEN DATEDIFF(CURDATE(), created_at) < 90 THEN 'Old'
        ELSE 'Very Old'
    END AS age_category
FROM orders
ORDER BY days_old DESC;
```

</details>

---

### Bài 13: Product Catalog
Tạo product catalog với:
- Product code: #P0001 format
- Name: UPPERCASE (max 40 chars)
- Price: formatted với dấu phẩy và "đ"
- Stock status: "Hết hàng", "Sắp hết" (< 10), "Còn hàng"

**Output:** product_code, name, price_formatted, stock_status

<details>
<summary>Đáp án</summary>

```sql
SELECT
    CONCAT('#P', LPAD(id, 4, '0')) AS product_code,
    UPPER(LEFT(name, 40)) AS name,
    CONCAT(FORMAT(price, 0), ' đ') AS price_formatted,
    CASE
        WHEN stock = 0 THEN 'Hết hàng'
        WHEN stock < 10 THEN 'Sắp hết'
        ELSE 'Còn hàng'
    END AS stock_status
FROM products
ORDER BY stock ASC;
```

</details>

---

### Bài 14: Customer Activity
Tìm customers inactive (không order) > 60 ngày, hiển thị last_order_date và days_inactive.

**Output:** name, email, last_order_date, days_inactive

<details>
<summary>Đáp án</summary>

```sql
SELECT
    c.name,
    c.email,
    MAX(o.created_at) AS last_order_date,
    DATEDIFF(CURDATE(), MAX(o.created_at)) AS days_inactive
FROM customers c
JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.name, c.email
HAVING days_inactive > 60
ORDER BY days_inactive DESC;
```

</details>

---

### Bài 15: Weekly Order Pattern
Phân tích orders theo ngày trong tuần, tính tổng orders và average order value cho mỗi ngày.

**Output:** day_of_week, order_count, avg_order_value

<details>
<summary>Đáp án</summary>

```sql
SELECT
    DAYNAME(created_at) AS day_of_week,
    COUNT(*) AS order_count,
    AVG(total_amount) AS avg_order_value
FROM orders
WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY day_of_week, DAYOFWEEK(created_at)
ORDER BY DAYOFWEEK(created_at);
```

</details>

---

## Part 4: Complex Queries (5 bài)

### Bài 16: Customer Segmentation
Phân loại customers thành segments dựa trên tổng chi tiêu:
- < 500,000: "Bronze"
- 500,000 - 2,000,000: "Silver"
- 2,000,000 - 5,000,000: "Gold"
- > 5,000,000: "Platinum"

Tính số lượng customers và average spending mỗi segment.

**Output:** segment, customer_count, avg_spending

<details>
<summary>Đáp án</summary>

```sql
SELECT
    CASE
        WHEN total_spent < 500000 THEN 'Bronze'
        WHEN total_spent BETWEEN 500000 AND 2000000 THEN 'Silver'
        WHEN total_spent BETWEEN 2000000 AND 5000000 THEN 'Gold'
        ELSE 'Platinum'
    END AS segment,
    COUNT(*) AS customer_count,
    AVG(total_spent) AS avg_spending
FROM (
    SELECT
        c.id,
        COALESCE(SUM(o.total_amount), 0) AS total_spent
    FROM customers c
    LEFT JOIN orders o ON c.id = o.customer_id
    WHERE o.status = 'delivered' OR o.status IS NULL
    GROUP BY c.id
) AS customer_totals
GROUP BY segment
ORDER BY avg_spending DESC;
```

</details>

---

### Bài 17: Payment Method Analysis
Phân tích theo payment method: tổng orders, revenue, average order value, min/max order value.

**Output:** payment_method, order_count, revenue, avg_value, min_order, max_order

<details>
<summary>Đáp án</summary>

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

</details>

---

### Bài 18: Top Products by Category
Với mỗi category, tìm top 3 products bán chạy nhất (theo số lượng đã bán).

**Output:** category, product_name, quantity_sold, revenue

<details>
<summary>Đáp án</summary>

```sql
SELECT
    cat.name AS category,
    p.name AS product_name,
    SUM(oi.quantity) AS quantity_sold,
    SUM(oi.subtotal) AS revenue
FROM categories cat
JOIN products p ON cat.id = p.category_id
JOIN order_items oi ON p.id = oi.product_id
JOIN orders o ON oi.order_id = o.id
WHERE o.status = 'delivered'
GROUP BY cat.id, cat.name, p.id, p.name
ORDER BY cat.name, quantity_sold DESC;
```

**Note:** Để lấy top 3 mỗi category, cần dùng window functions (Level 3) hoặc subqueries.

</details>

---

### Bài 19: Hourly Sales Pattern
Phân tích orders theo giờ trong ngày (0-23), tính order count và revenue cho mỗi giờ.

**Output:** hour, order_count, revenue

<details>
<summary>Đáp án</summary>

```sql
SELECT
    HOUR(created_at) AS hour,
    COUNT(*) AS order_count,
    SUM(total_amount) AS revenue
FROM orders
WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY hour
ORDER BY hour;
```

</details>

---

### Bài 20: Complete Sales Report
Tạo báo cáo tổng hợp với:
- Customer info (name, email, city)
- Order info (order_id, order_date formatted)
- Product details (product_name, category)
- Order metrics (quantity, price, subtotal)

Chỉ lấy orders trong 3 tháng gần nhất, status = 'delivered'.

**Output:** customer_name, city, order_id, order_date, product_name, category, quantity, price, subtotal

<details>
<summary>Đáp án</summary>

```sql
SELECT
    c.name AS customer_name,
    c.city,
    o.id AS order_id,
    DATE_FORMAT(o.created_at, '%d/%m/%Y') AS order_date,
    p.name AS product_name,
    cat.name AS category,
    oi.quantity,
    CONCAT(FORMAT(oi.price, 0), ' đ') AS price,
    CONCAT(FORMAT(oi.subtotal, 0), ' đ') AS subtotal
FROM customers c
JOIN orders o ON c.id = o.customer_id
JOIN order_items oi ON o.id = oi.order_id
JOIN products p ON oi.product_id = p.id
JOIN categories cat ON p.category_id = cat.id
WHERE o.status = 'delivered'
  AND o.created_at >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
ORDER BY o.created_at DESC, o.id, oi.id
LIMIT 100;
```

</details>

---

## Bonus Challenges

### Challenge 1: Revenue Comparison
So sánh doanh thu tháng này với tháng trước (absolute difference và percentage change).

<details>
<summary>Đáp án</summary>

```sql
SELECT
    DATE_FORMAT(CURDATE(), '%Y-%m') AS current_month,
    (SELECT SUM(total_amount) FROM orders
     WHERE DATE_FORMAT(created_at, '%Y-%m') = DATE_FORMAT(CURDATE(), '%Y-%m')
     AND status = 'delivered') AS current_revenue,
    (SELECT SUM(total_amount) FROM orders
     WHERE DATE_FORMAT(created_at, '%Y-%m') = DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 1 MONTH), '%Y-%m')
     AND status = 'delivered') AS last_month_revenue,
    (SELECT SUM(total_amount) FROM orders
     WHERE DATE_FORMAT(created_at, '%Y-%m') = DATE_FORMAT(CURDATE(), '%Y-%m')
     AND status = 'delivered') -
    (SELECT SUM(total_amount) FROM orders
     WHERE DATE_FORMAT(created_at, '%Y-%m') = DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 1 MONTH), '%Y-%m')
     AND status = 'delivered') AS difference;
```

</details>

---

### Challenge 2: Customer Lifetime Value
Tính Customer Lifetime Value (CLV) cho mỗi customer:
- Total spent
- Number of orders
- Average order value
- First order date
- Last order date
- Customer lifetime (days)

<details>
<summary>Đáp án</summary>

```sql
SELECT
    c.name,
    c.email,
    COUNT(o.id) AS total_orders,
    SUM(o.total_amount) AS total_spent,
    AVG(o.total_amount) AS avg_order_value,
    MIN(o.created_at) AS first_order_date,
    MAX(o.created_at) AS last_order_date,
    DATEDIFF(MAX(o.created_at), MIN(o.created_at)) AS customer_lifetime_days
FROM customers c
JOIN orders o ON c.id = o.customer_id
WHERE o.status = 'delivered'
GROUP BY c.id, c.name, c.email
ORDER BY total_spent DESC
LIMIT 20;
```

</details>

---

## Tổng Kết

Hoàn thành 20 bài tập trên, bạn đã nắm vững:
- ✅ JOIN tables (INNER, LEFT, RIGHT, multiple JOINs)
- ✅ GROUP BY với aggregates (COUNT, SUM, AVG, MAX, MIN)
- ✅ HAVING clause
- ✅ String functions (CONCAT, SUBSTRING, UPPER, LOWER, etc.)
- ✅ Date functions (DATE_FORMAT, DATEDIFF, DATE_ADD, etc.)
- ✅ CASE WHEN
- ✅ Combining multiple concepts

## Tiếp Theo

➡️ [Level 3: Advanced](../level-3-advanced/README.md)

⬅️ [Functions](03-functions.md)
