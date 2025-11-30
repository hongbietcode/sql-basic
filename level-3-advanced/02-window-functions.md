# Window Functions - Hàm Cửa Sổ

Window Functions cho phép bạn thực hiện calculations trên một "window" (tập hợp) rows liên quan đến current row, KHÔNG group lại như GROUP BY.

## Khác Biệt: GROUP BY vs Window Functions

```sql
-- GROUP BY: Gộp rows lại
SELECT
    category_id,
    AVG(price) AS avg_price
FROM products
GROUP BY category_id;
-- Kết quả: 1 row per category

-- Window Function: Giữ nguyên rows
SELECT
    name,
    category_id,
    price,
    AVG(price) OVER (PARTITION BY category_id) AS avg_price
FROM products;
-- Kết quả: Tất cả rows, mỗi row có avg_price của category đó
```

## Syntax

```sql
function_name() OVER (
    [PARTITION BY column1, column2, ...]
    [ORDER BY column1, column2, ...]
    [ROWS/RANGE specification]
)
```

**Components:**
- `PARTITION BY`: Chia data thành partitions (như GROUP BY)
- `ORDER BY`: Sắp xếp rows trong partition
- `ROWS/RANGE`: Define window frame

## Ranking Functions

### ROW_NUMBER()

Gán số thứ tự cho mỗi row.

```sql
-- Đánh số products theo giá (cao → thấp)
SELECT
    name,
    price,
    ROW_NUMBER() OVER (ORDER BY price DESC) AS row_num
FROM products
LIMIT 10;
```

**Kết quả:**
```
+------------------+----------+---------+
| name             | price    | row_num |
+------------------+----------+---------+
| Macbook Pro M3   | 45000000 |       1 |
| iPhone 15 Pro Max| 35000000 |       2 |
| ...              |          |         |
+------------------+----------+---------+
```

### RANK()

Gán rank, SKIP ranks nếu có ties.

```sql
-- Rank products theo giá
SELECT
    name,
    price,
    RANK() OVER (ORDER BY price DESC) AS price_rank
FROM products
LIMIT 10;
```

**Ví dụ với ties:**
- Price 1000: rank 1
- Price 1000: rank 1
- Price 900: rank 3 (skipped 2!)

### DENSE_RANK()

Gán rank, KHÔNG skip ranks.

```sql
SELECT
    name,
    price,
    DENSE_RANK() OVER (ORDER BY price DESC) AS dense_rank
FROM products
LIMIT 10;
```

**Ví dụ với ties:**
- Price 1000: rank 1
- Price 1000: rank 1
- Price 900: rank 2 (không skip)

### So Sánh 3 Ranking Functions

```sql
SELECT
    name,
    price,
    ROW_NUMBER() OVER (ORDER BY price DESC) AS row_num,
    RANK() OVER (ORDER BY price DESC) AS rank,
    DENSE_RANK() OVER (ORDER BY price DESC) AS dense_rank
FROM products
ORDER BY price DESC
LIMIT 15;
```

## PARTITION BY

Chia data thành groups, apply function cho từng group.

### Top Products per Category

```sql
-- Top 3 products (theo giá) trong mỗi category
SELECT
    category_id,
    name,
    price,
    ROW_NUMBER() OVER (
        PARTITION BY category_id
        ORDER BY price DESC
    ) AS rank_in_category
FROM products;
```

### Filter Top N per Group

```sql
-- Lấy top 3 per category
SELECT * FROM (
    SELECT
        cat.name AS category,
        p.name AS product,
        p.price,
        ROW_NUMBER() OVER (
            PARTITION BY p.category_id
            ORDER BY p.price DESC
        ) AS rn
    FROM products p
    JOIN categories cat ON p.category_id = cat.id
) AS ranked
WHERE rn <= 3
ORDER BY category, rn;
```

### Top Customers per City

```sql
-- Top 3 customers (theo total spent) trong mỗi city
SELECT * FROM (
    SELECT
        c.city,
        c.name,
        SUM(o.total_amount) AS total_spent,
        RANK() OVER (
            PARTITION BY c.city
            ORDER BY SUM(o.total_amount) DESC
        ) AS rank_in_city
    FROM customers c
    JOIN orders o ON c.id = o.customer_id
    WHERE o.status = 'delivered'
    GROUP BY c.id, c.city, c.name
) AS ranked
WHERE rank_in_city <= 3
ORDER BY city, rank_in_city;
```

## Aggregate Window Functions

### Running Total (Cumulative Sum)

```sql
-- Tổng doanh thu tích lũy theo ngày
SELECT
    DATE(created_at) AS date,
    SUM(total_amount) AS daily_revenue,
    SUM(SUM(total_amount)) OVER (
        ORDER BY DATE(created_at)
    ) AS cumulative_revenue
FROM orders
WHERE status = 'delivered'
  AND created_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY DATE(created_at)
ORDER BY date;
```

**Kết quả:**
```
+------------+---------------+--------------------+
| date       | daily_revenue | cumulative_revenue |
+------------+---------------+--------------------+
| 2024-11-01 |    5,000,000  |         5,000,000  |
| 2024-11-02 |    3,500,000  |         8,500,000  |
| 2024-11-03 |    6,200,000  |        14,700,000  |
+------------+---------------+--------------------+
```

### Moving Average

```sql
-- Moving average (3 ngày)
SELECT
    DATE(created_at) AS date,
    SUM(total_amount) AS daily_revenue,
    AVG(SUM(total_amount)) OVER (
        ORDER BY DATE(created_at)
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS moving_avg_3days
FROM orders
WHERE status = 'delivered'
  AND created_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY DATE(created_at)
ORDER BY date;
```

**ROWS BETWEEN:**
- `2 PRECEDING`: 2 rows trước
- `CURRENT ROW`: Row hiện tại
- `1 FOLLOWING`: 1 row sau
- `UNBOUNDED PRECEDING`: Tất cả rows trước
- `UNBOUNDED FOLLOWING`: Tất cả rows sau

### Percentage of Total

```sql
-- Phần trăm doanh thu của mỗi category
SELECT
    cat.name AS category,
    SUM(oi.subtotal) AS revenue,
    SUM(SUM(oi.subtotal)) OVER () AS total_revenue,
    ROUND(
        SUM(oi.subtotal) * 100.0 / SUM(SUM(oi.subtotal)) OVER (),
        2
    ) AS percentage
FROM categories cat
JOIN products p ON cat.id = p.category_id
JOIN order_items oi ON p.id = oi.product_id
JOIN orders o ON oi.order_id = o.id
WHERE o.status = 'delivered'
GROUP BY cat.id, cat.name
ORDER BY percentage DESC;
```

## Value Window Functions

### LAG() - Giá Trị Row Trước

```sql
-- So sánh doanh thu hôm nay với hôm qua
SELECT
    DATE(created_at) AS date,
    SUM(total_amount) AS revenue,
    LAG(SUM(total_amount)) OVER (ORDER BY DATE(created_at)) AS prev_day_revenue,
    SUM(total_amount) - LAG(SUM(total_amount)) OVER (ORDER BY DATE(created_at)) AS change
FROM orders
WHERE status = 'delivered'
  AND created_at >= DATE_SUB(CURDATE(), INTERVAL 10 DAY)
GROUP BY DATE(created_at)
ORDER BY date;
```

### LEAD() - Giá Trị Row Sau

```sql
-- Xem revenue ngày mai (nếu có data)
SELECT
    DATE(created_at) AS date,
    SUM(total_amount) AS revenue,
    LEAD(SUM(total_amount)) OVER (ORDER BY DATE(created_at)) AS next_day_revenue
FROM orders
WHERE status = 'delivered'
GROUP BY DATE(created_at)
ORDER BY date;
```

### FIRST_VALUE() & LAST_VALUE()

```sql
-- So sánh price với highest/lowest trong category
SELECT
    cat.name AS category,
    p.name AS product,
    p.price,
    FIRST_VALUE(p.price) OVER (
        PARTITION BY p.category_id
        ORDER BY p.price DESC
    ) AS highest_price,
    LAST_VALUE(p.price) OVER (
        PARTITION BY p.category_id
        ORDER BY p.price DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS lowest_price
FROM products p
JOIN categories cat ON p.category_id = cat.id
ORDER BY category, p.price DESC;
```

**Lưu ý:** LAST_VALUE cần `ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING` để lấy đúng giá trị cuối.

### NTH_VALUE()

```sql
-- Lấy giá của product thứ 3 (theo price DESC) trong mỗi category
SELECT
    cat.name AS category,
    p.name AS product,
    p.price,
    NTH_VALUE(p.price, 3) OVER (
        PARTITION BY p.category_id
        ORDER BY p.price DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS third_highest_price
FROM products p
JOIN categories cat ON p.category_id = cat.id
ORDER BY category, p.price DESC;
```

## NTILE() - Chia Thành N Groups

```sql
-- Chia customers thành 4 quartiles theo total spent
SELECT
    customer_name,
    total_spent,
    NTILE(4) OVER (ORDER BY total_spent DESC) AS quartile
FROM (
    SELECT
        c.name AS customer_name,
        SUM(o.total_amount) AS total_spent
    FROM customers c
    JOIN orders o ON c.id = o.customer_id
    WHERE o.status = 'delivered'
    GROUP BY c.id, c.name
) AS customer_totals
ORDER BY total_spent DESC;
```

**Quartiles:**
- 1: Top 25%
- 2: 25-50%
- 3: 50-75%
- 4: Bottom 25%

## Practical Examples

### 1. Product Performance Dashboard

```sql
SELECT
    p.name,
    cat.name AS category,
    p.price,
    p.stock,
    COUNT(oi.id) AS times_ordered,
    SUM(oi.quantity) AS total_quantity_sold,

    -- Rank trong tất cả products
    RANK() OVER (ORDER BY SUM(oi.quantity) DESC) AS overall_rank,

    -- Rank trong category
    RANK() OVER (
        PARTITION BY cat.id
        ORDER BY SUM(oi.quantity) DESC
    ) AS category_rank,

    -- Phần trăm của total sales
    ROUND(
        SUM(oi.quantity) * 100.0 / SUM(SUM(oi.quantity)) OVER (),
        2
    ) AS pct_of_total_sales
FROM products p
JOIN categories cat ON p.category_id = cat.id
LEFT JOIN order_items oi ON p.id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.id AND o.status = 'delivered'
GROUP BY p.id, p.name, cat.id, cat.name, p.price, p.stock
ORDER BY total_quantity_sold DESC;
```

### 2. Customer Segmentation with RFM

```sql
-- RFM Analysis: Recency, Frequency, Monetary
SELECT
    customer_name,
    days_since_last_order AS recency,
    order_count AS frequency,
    total_spent AS monetary,

    NTILE(5) OVER (ORDER BY days_since_last_order) AS recency_score,
    NTILE(5) OVER (ORDER BY order_count DESC) AS frequency_score,
    NTILE(5) OVER (ORDER BY total_spent DESC) AS monetary_score
FROM (
    SELECT
        c.name AS customer_name,
        DATEDIFF(CURDATE(), MAX(o.created_at)) AS days_since_last_order,
        COUNT(o.id) AS order_count,
        SUM(o.total_amount) AS total_spent
    FROM customers c
    JOIN orders o ON c.id = o.customer_id
    WHERE o.status = 'delivered'
    GROUP BY c.id, c.name
) AS customer_metrics
ORDER BY monetary_score DESC, frequency_score DESC, recency_score;
```

### 3. Monthly Revenue with Growth Rate

```sql
SELECT
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month) AS prev_month_revenue,
    revenue - LAG(revenue) OVER (ORDER BY month) AS absolute_change,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY month)) * 100.0
        / LAG(revenue) OVER (ORDER BY month),
        2
    ) AS growth_rate_pct
FROM (
    SELECT
        DATE_FORMAT(created_at, '%Y-%m') AS month,
        SUM(total_amount) AS revenue
    FROM orders
    WHERE status = 'delivered'
      AND created_at >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
    GROUP BY month
) AS monthly_revenue
ORDER BY month;
```

### 4. Top 3 Products per Category (Complete)

```sql
-- Top 3 best-selling products trong mỗi category
SELECT
    category,
    product_name,
    quantity_sold,
    revenue,
    rank_in_category
FROM (
    SELECT
        cat.name AS category,
        p.name AS product_name,
        SUM(oi.quantity) AS quantity_sold,
        SUM(oi.subtotal) AS revenue,
        ROW_NUMBER() OVER (
            PARTITION BY cat.id
            ORDER BY SUM(oi.quantity) DESC
        ) AS rank_in_category
    FROM categories cat
    JOIN products p ON cat.id = p.category_id
    JOIN order_items oi ON p.id = oi.product_id
    JOIN orders o ON oi.order_id = o.id
    WHERE o.status = 'delivered'
    GROUP BY cat.id, cat.name, p.id, p.name
) AS ranked
WHERE rank_in_category <= 3
ORDER BY category, rank_in_category;
```

### 5. Running Total Inventory Value

```sql
SELECT
    p.name,
    p.price,
    p.stock,
    p.price * p.stock AS inventory_value,
    SUM(p.price * p.stock) OVER (
        ORDER BY p.price * p.stock DESC
    ) AS cumulative_inventory_value,
    ROUND(
        SUM(p.price * p.stock) OVER (
            ORDER BY p.price * p.stock DESC
        ) * 100.0 / SUM(p.price * p.stock) OVER (),
        2
    ) AS cumulative_percentage
FROM products p
ORDER BY inventory_value DESC;
```

### 6. Customer Lifetime Value Ranking

```sql
SELECT
    customer_name,
    first_order_date,
    last_order_date,
    days_active,
    order_count,
    total_spent,
    avg_order_value,

    -- Overall rank
    RANK() OVER (ORDER BY total_spent DESC) AS value_rank,

    -- Quartile
    NTILE(4) OVER (ORDER BY total_spent DESC) AS value_quartile,

    -- Percentile
    PERCENT_RANK() OVER (ORDER BY total_spent DESC) AS percentile
FROM (
    SELECT
        c.name AS customer_name,
        MIN(o.created_at) AS first_order_date,
        MAX(o.created_at) AS last_order_date,
        DATEDIFF(MAX(o.created_at), MIN(o.created_at)) AS days_active,
        COUNT(o.id) AS order_count,
        SUM(o.total_amount) AS total_spent,
        AVG(o.total_amount) AS avg_order_value
    FROM customers c
    JOIN orders o ON c.id = o.customer_id
    WHERE o.status = 'delivered'
    GROUP BY c.id, c.name
) AS customer_stats
ORDER BY total_spent DESC;
```

### 7. Product Price Comparison

```sql
-- So sánh giá product với trung bình, max, min trong category
SELECT
    cat.name AS category,
    p.name AS product,
    p.price,

    AVG(p.price) OVER (PARTITION BY cat.id) AS category_avg_price,
    MAX(p.price) OVER (PARTITION BY cat.id) AS category_max_price,
    MIN(p.price) OVER (PARTITION BY cat.id) AS category_min_price,

    p.price - AVG(p.price) OVER (PARTITION BY cat.id) AS diff_from_avg,

    ROUND(
        (p.price - AVG(p.price) OVER (PARTITION BY cat.id)) * 100.0
        / AVG(p.price) OVER (PARTITION BY cat.id),
        2
    ) AS pct_diff_from_avg
FROM products p
JOIN categories cat ON p.category_id = cat.id
ORDER BY category, pct_diff_from_avg DESC;
```

### 8. Daily Order Analysis with Moving Averages

```sql
SELECT
    date,
    order_count,
    revenue,

    -- 7-day moving average
    AVG(revenue) OVER (
        ORDER BY date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS moving_avg_7d,

    -- Compare với yesterday
    LAG(revenue) OVER (ORDER BY date) AS yesterday_revenue,
    revenue - LAG(revenue) OVER (ORDER BY date) AS daily_change,

    -- Running total
    SUM(revenue) OVER (ORDER BY date) AS cumulative_revenue
FROM (
    SELECT
        DATE(created_at) AS date,
        COUNT(*) AS order_count,
        SUM(total_amount) AS revenue
    FROM orders
    WHERE status = 'delivered'
      AND created_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
    GROUP BY DATE(created_at)
) AS daily_stats
ORDER BY date;
```

## Performance Tips

### 1. Index Columns Used in PARTITION BY and ORDER BY

```sql
CREATE INDEX idx_products_category_price ON products(category_id, price);
CREATE INDEX idx_orders_status_created ON orders(status, created_at);
```

### 2. Use CTEs for Complex Window Queries

```sql
-- Easier to read and maintain
WITH customer_stats AS (
    SELECT
        c.id,
        c.name,
        SUM(o.total_amount) AS total_spent
    FROM customers c
    JOIN orders o ON c.id = o.customer_id
    WHERE o.status = 'delivered'
    GROUP BY c.id, c.name
)
SELECT
    name,
    total_spent,
    RANK() OVER (ORDER BY total_spent DESC) AS rank
FROM customer_stats;
```

### 3. Filter After Window Functions

```sql
-- Correct: Filter trong outer query
SELECT * FROM (
    SELECT
        name,
        price,
        ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) AS rn
    FROM products
) AS ranked
WHERE rn <= 3;  -- Filter SAU khi đã có window function result
```

## Bài Tập

**1. Ranking**
```sql
-- Top 5 customers theo total spent
-- Top 3 products per category (theo revenue)
-- Rank orders theo total_amount trong từng tháng
```

**2. Aggregates**
```sql
-- Running total revenue theo ngày
-- Moving average 7 ngày của orders
-- Phần trăm contribution của mỗi category
```

**3. Value Functions**
```sql
-- So sánh doanh thu mỗi tháng với tháng trước
-- First và last order của mỗi customer
-- Product có giá cao thứ 2 trong mỗi category
```

**4. Advanced**
```sql
-- Customer segmentation (NTILE 5)
-- RFM analysis
-- Products chiếm 80% total revenue (Pareto)
```

## Đáp Án

<details>
<summary>Click để xem đáp án</summary>

```sql
-- 1. Ranking
SELECT
    name,
    email,
    total_spent,
    RANK() OVER (ORDER BY total_spent DESC) AS rank
FROM (
    SELECT c.name, c.email, SUM(o.total_amount) AS total_spent
    FROM customers c
    JOIN orders o ON c.id = o.customer_id
    WHERE o.status = 'delivered'
    GROUP BY c.id, c.name, c.email
) AS stats
LIMIT 5;

-- 2. Aggregates
SELECT
    DATE(created_at) AS date,
    SUM(total_amount) AS revenue,
    SUM(SUM(total_amount)) OVER (ORDER BY DATE(created_at)) AS running_total
FROM orders
WHERE status = 'delivered'
GROUP BY DATE(created_at)
ORDER BY date;

-- 3. Value Functions
SELECT
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month) AS prev_month,
    revenue - LAG(revenue) OVER (ORDER BY month) AS change
FROM (
    SELECT
        DATE_FORMAT(created_at, '%Y-%m') AS month,
        SUM(total_amount) AS revenue
    FROM orders
    WHERE status = 'delivered'
    GROUP BY month
) AS monthly;

-- 4. Advanced - Pareto 80/20
SELECT
    name,
    revenue,
    cumulative_pct
FROM (
    SELECT
        p.name,
        SUM(oi.subtotal) AS revenue,
        SUM(SUM(oi.subtotal)) OVER (ORDER BY SUM(oi.subtotal) DESC) * 100.0
        / SUM(SUM(oi.subtotal)) OVER () AS cumulative_pct
    FROM products p
    JOIN order_items oi ON p.id = oi.product_id
    JOIN orders o ON oi.order_id = o.id
    WHERE o.status = 'delivered'
    GROUP BY p.id, p.name
) AS stats
WHERE cumulative_pct <= 80
ORDER BY revenue DESC;
```

</details>

## Tiếp Theo

➡️ [CASE WHEN & UNION](03-case-union.md)

⬅️ [Subqueries](01-subqueries.md)
