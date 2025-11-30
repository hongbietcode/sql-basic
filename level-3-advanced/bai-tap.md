# Bài Tập Level 3 - Advanced

20 bài tập tổng hợp Subqueries, Window Functions, CASE WHEN, và UNION.

## Part 1: Subqueries (5 bài)

### Bài 1: Products Above Category Average
Tìm tất cả products có giá cao hơn giá trung bình của category đó.

**Output:** product_name, category, price, category_avg_price, difference

<details>
<summary>Đáp án</summary>

```sql
SELECT
    p.name AS product_name,
    cat.name AS category,
    p.price,
    (SELECT AVG(price)
     FROM products p2
     WHERE p2.category_id = p.category_id) AS category_avg_price,
    p.price - (SELECT AVG(price)
               FROM products p2
               WHERE p2.category_id = p.category_id) AS difference
FROM products p
JOIN categories cat ON p.category_id = cat.id
WHERE p.price > (
    SELECT AVG(price)
    FROM products p2
    WHERE p2.category_id = p.category_id
)
ORDER BY category, difference DESC;
```

</details>

---

### Bài 2: Top 3 Customers per City
Với mỗi city, tìm top 3 customers có total spending cao nhất.

**Output:** city, customer_name, total_spent, rank_in_city

<details>
<summary>Đáp án</summary>

```sql
SELECT city, customer_name, total_spent, rank_in_city
FROM (
    SELECT
        c.city,
        c.name AS customer_name,
        SUM(o.total_amount) AS total_spent,
        (SELECT COUNT(DISTINCT c2.id) + 1
         FROM customers c2
         JOIN orders o2 ON c2.id = o2.customer_id
         WHERE c2.city = c.city
           AND o2.status = 'delivered'
         GROUP BY c2.id
         HAVING SUM(o2.total_amount) > SUM(o.total_amount)) AS rank_in_city
    FROM customers c
    JOIN orders o ON c.id = o.customer_id
    WHERE o.status = 'delivered'
    GROUP BY c.id, c.city, c.name
) AS ranked
WHERE rank_in_city <= 3
ORDER BY city, rank_in_city;
```

</details>

---

### Bài 3: Orders Above Customer Average
Tìm orders có giá trị cao hơn giá trị trung bình của chính customer đó.

**Output:** order_id, customer_name, order_amount, customer_avg, difference

<details>
<summary>Đáp án</summary>

```sql
SELECT
    o.id AS order_id,
    c.name AS customer_name,
    o.total_amount AS order_amount,
    (SELECT AVG(total_amount)
     FROM orders o2
     WHERE o2.customer_id = o.customer_id) AS customer_avg,
    o.total_amount - (SELECT AVG(total_amount)
                      FROM orders o2
                      WHERE o2.customer_id = o.customer_id) AS difference
FROM orders o
JOIN customers c ON o.customer_id = c.id
WHERE o.total_amount > (
    SELECT AVG(total_amount)
    FROM orders o2
    WHERE o2.customer_id = o.customer_id
)
ORDER BY difference DESC;
```

</details>

---

### Bài 4: Products Never Sold in Last 30 Days
Tìm products chưa được bán trong 30 ngày qua.

**Output:** product_name, category, price, stock, last_sold_date

<details>
<summary>Đáp án</summary>

```sql
SELECT
    p.name AS product_name,
    cat.name AS category,
    p.price,
    p.stock,
    (SELECT MAX(o.created_at)
     FROM orders o
     JOIN order_items oi ON o.id = oi.order_id
     WHERE oi.product_id = p.id
       AND o.status = 'delivered') AS last_sold_date
FROM products p
JOIN categories cat ON p.category_id = cat.id
WHERE p.id NOT IN (
    SELECT DISTINCT oi.product_id
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.id
    WHERE o.status = 'delivered'
      AND o.created_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
      AND oi.product_id IS NOT NULL
)
ORDER BY last_sold_date DESC NULLS FIRST;
```

</details>

---

### Bài 5: Categories Performance Comparison
So sánh revenue của mỗi category với overall average category revenue.

**Output:** category, revenue, avg_category_revenue, performance (above/below)

<details>
<summary>Đáp án</summary>

```sql
SELECT
    cat.name AS category,
    COALESCE(SUM(oi.subtotal), 0) AS revenue,
    (SELECT AVG(cat_revenue)
     FROM (
         SELECT SUM(oi2.subtotal) AS cat_revenue
         FROM categories cat2
         JOIN products p2 ON cat2.id = p2.category_id
         JOIN order_items oi2 ON p2.id = oi2.product_id
         JOIN orders o2 ON oi2.order_id = o2.id
         WHERE o2.status = 'delivered'
         GROUP BY cat2.id
     ) AS all_cats) AS avg_category_revenue,
    CASE
        WHEN COALESCE(SUM(oi.subtotal), 0) > (
            SELECT AVG(cat_revenue)
            FROM (
                SELECT SUM(oi2.subtotal) AS cat_revenue
                FROM categories cat2
                JOIN products p2 ON cat2.id = p2.category_id
                JOIN order_items oi2 ON p2.id = oi2.product_id
                JOIN orders o2 ON oi2.order_id = o2.id
                WHERE o2.status = 'delivered'
                GROUP BY cat2.id
            ) AS all_cats
        ) THEN 'Above Average'
        ELSE 'Below Average'
    END AS performance
FROM categories cat
LEFT JOIN products p ON cat.id = p.category_id
LEFT JOIN order_items oi ON p.id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.id AND o.status = 'delivered'
GROUP BY cat.id, cat.name
ORDER BY revenue DESC;
```

</details>

---

## Part 2: Window Functions (5 bài)

### Bài 6: Product Ranking by Category
Rank products theo số lượng đã bán trong mỗi category. Hiển thị top 5 per category.

**Output:** category, product_name, quantity_sold, rank_in_category

<details>
<summary>Đáp án</summary>

```sql
SELECT * FROM (
    SELECT
        cat.name AS category,
        p.name AS product_name,
        COALESCE(SUM(oi.quantity), 0) AS quantity_sold,
        ROW_NUMBER() OVER (
            PARTITION BY cat.id
            ORDER BY COALESCE(SUM(oi.quantity), 0) DESC
        ) AS rank_in_category
    FROM categories cat
    JOIN products p ON cat.id = p.category_id
    LEFT JOIN order_items oi ON p.id = oi.product_id
    LEFT JOIN orders o ON oi.order_id = o.id AND o.status = 'delivered'
    GROUP BY cat.id, cat.name, p.id, p.name
) AS ranked
WHERE rank_in_category <= 5
ORDER BY category, rank_in_category;
```

</details>

---

### Bài 7: Running Total Revenue
Tính running total revenue theo ngày trong 30 ngày qua.

**Output:** date, daily_revenue, cumulative_revenue

<details>
<summary>Đáp án</summary>

```sql
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

</details>

---

### Bài 8: Month-over-Month Growth
Tính revenue growth rate (%) giữa các tháng.

**Output:** month, revenue, prev_month_revenue, growth_rate

<details>
<summary>Đáp án</summary>

```sql
SELECT
    month,
    revenue,
    prev_month_revenue,
    CASE
        WHEN prev_month_revenue IS NULL THEN NULL
        WHEN prev_month_revenue = 0 THEN NULL
        ELSE ROUND(
            (revenue - prev_month_revenue) * 100.0 / prev_month_revenue,
            2
        )
    END AS growth_rate
FROM (
    SELECT
        DATE_FORMAT(created_at, '%Y-%m') AS month,
        SUM(total_amount) AS revenue,
        LAG(SUM(total_amount)) OVER (ORDER BY DATE_FORMAT(created_at, '%Y-%m')) AS prev_month_revenue
    FROM orders
    WHERE status = 'delivered'
      AND created_at >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
    GROUP BY month
) AS monthly_data
ORDER BY month DESC;
```

</details>

---

### Bài 9: Customer Quartiles by Spending
Chia customers thành 4 quartiles dựa trên total spending.

**Output:** customer_name, total_spent, quartile

<details>
<summary>Đáp án</summary>

```sql
SELECT
    customer_name,
    total_spent,
    quartile,
    CASE quartile
        WHEN 1 THEN 'Top 25%'
        WHEN 2 THEN '25-50%'
        WHEN 3 THEN '50-75%'
        WHEN 4 THEN 'Bottom 25%'
    END AS quartile_label
FROM (
    SELECT
        c.name AS customer_name,
        SUM(o.total_amount) AS total_spent,
        NTILE(4) OVER (ORDER BY SUM(o.total_amount) DESC) AS quartile
    FROM customers c
    JOIN orders o ON c.id = o.customer_id
    WHERE o.status = 'delivered'
    GROUP BY c.id, c.name
) AS customer_quartiles
ORDER BY total_spent DESC;
```

</details>

---

### Bài 10: Moving Average (7 days)
Tính 7-day moving average của daily revenue.

**Output:** date, daily_revenue, moving_avg_7d

<details>
<summary>Đáp án</summary>

```sql
SELECT
    date,
    daily_revenue,
    ROUND(AVG(daily_revenue) OVER (
        ORDER BY date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ), 0) AS moving_avg_7d
FROM (
    SELECT
        DATE(created_at) AS date,
        SUM(total_amount) AS daily_revenue
    FROM orders
    WHERE status = 'delivered'
      AND created_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
    GROUP BY DATE(created_at)
) AS daily_stats
ORDER BY date;
```

</details>

---

## Part 3: CASE WHEN (5 bài)

### Bài 11: Customer Lifecycle Stage
Phân loại customers theo lifecycle stage dựa trên order count và recency.

**Output:** customer_name, order_count, days_since_last_order, lifecycle_stage

<details>
<summary>Đáp án</summary>

```sql
SELECT
    c.name AS customer_name,
    COUNT(o.id) AS order_count,
    COALESCE(DATEDIFF(CURDATE(), MAX(o.created_at)), 999) AS days_since_last_order,
    CASE
        WHEN COUNT(o.id) = 0 THEN 'Never Purchased'
        WHEN DATEDIFF(CURDATE(), MAX(o.created_at)) > 180 THEN 'Churned'
        WHEN DATEDIFF(CURDATE(), MAX(o.created_at)) > 90 THEN 'At Risk'
        WHEN COUNT(o.id) >= 10 THEN 'Champion'
        WHEN COUNT(o.id) >= 5 THEN 'Loyal'
        WHEN COUNT(o.id) >= 2 THEN 'Repeat'
        ELSE 'New'
    END AS lifecycle_stage
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id AND o.status = 'delivered'
GROUP BY c.id, c.name
ORDER BY order_count DESC;
```

</details>

---

### Bài 12: Order Priority System
Tạo priority cho orders dựa trên status, age, và amount.

**Output:** order_id, status, days_old, total_amount, priority, priority_score

<details>
<summary>Đáp án</summary>

```sql
SELECT
    id AS order_id,
    status,
    DATEDIFF(CURDATE(), created_at) AS days_old,
    total_amount,
    CASE
        WHEN status = 'pending' AND DATEDIFF(CURDATE(), created_at) > 7 THEN 'CRITICAL'
        WHEN status = 'pending' AND total_amount > 5000000 THEN 'HIGH'
        WHEN status = 'processing' AND DATEDIFF(CURDATE(), created_at) > 3 THEN 'HIGH'
        WHEN status = 'pending' OR status = 'processing' THEN 'NORMAL'
        ELSE 'LOW'
    END AS priority,
    CASE
        WHEN status = 'pending' AND DATEDIFF(CURDATE(), created_at) > 7 THEN 100
        WHEN status = 'pending' AND total_amount > 5000000 THEN 80
        WHEN status = 'processing' AND DATEDIFF(CURDATE(), created_at) > 3 THEN 70
        WHEN status = 'pending' OR status = 'processing' THEN 50
        ELSE 10
    END AS priority_score
FROM orders
ORDER BY priority_score DESC, created_at;
```

</details>

---

### Bài 13: Revenue Pivot by Payment Method
Tạo pivot table: revenue theo tháng và payment method.

**Output:** month, credit_card, bank_transfer, cash, total

<details>
<summary>Đáp án</summary>

```sql
SELECT
    DATE_FORMAT(created_at, '%Y-%m') AS month,
    SUM(CASE WHEN payment_method = 'credit_card' THEN total_amount ELSE 0 END) AS credit_card,
    SUM(CASE WHEN payment_method = 'bank_transfer' THEN total_amount ELSE 0 END) AS bank_transfer,
    SUM(CASE WHEN payment_method = 'cash' THEN total_amount ELSE 0 END) AS cash,
    SUM(total_amount) AS total
FROM orders
WHERE status = 'delivered'
  AND created_at >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
GROUP BY month
ORDER BY month DESC;
```

</details>

---

### Bài 14: Product Stock Status
Phân loại products theo stock level và sales performance.

**Output:** product_name, stock, monthly_sales, status, recommendation

<details>
<summary>Đáp án</summary>

```sql
SELECT
    p.name AS product_name,
    p.stock,
    COALESCE(SUM(oi.quantity), 0) AS monthly_sales,
    CASE
        WHEN p.stock = 0 THEN 'Out of Stock'
        WHEN p.stock < 10 THEN 'Low Stock'
        WHEN p.stock < 50 THEN 'Normal'
        ELSE 'High Stock'
    END AS status,
    CASE
        WHEN p.stock = 0 AND COALESCE(SUM(oi.quantity), 0) > 20 THEN 'Urgent Restock'
        WHEN p.stock < 10 AND COALESCE(SUM(oi.quantity), 0) > 10 THEN 'Restock Soon'
        WHEN p.stock > 100 AND COALESCE(SUM(oi.quantity), 0) < 5 THEN 'Consider Discount'
        WHEN COALESCE(SUM(oi.quantity), 0) = 0 THEN 'Review Product'
        ELSE 'OK'
    END AS recommendation
FROM products p
LEFT JOIN order_items oi ON p.id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.id
  AND o.status = 'delivered'
  AND o.created_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY p.id, p.name, p.stock
ORDER BY
    CASE
        WHEN p.stock = 0 AND COALESCE(SUM(oi.quantity), 0) > 20 THEN 1
        WHEN p.stock < 10 AND COALESCE(SUM(oi.quantity), 0) > 10 THEN 2
        ELSE 3
    END,
    monthly_sales DESC;
```

</details>

---

### Bài 15: Customer Value Tiers
Tạo customer tiers dựa trên spending và frequency.

**Output:** customer_name, total_spent, order_count, tier, benefits

<details>
<summary>Đáp án</summary>

```sql
SELECT
    c.name AS customer_name,
    COALESCE(SUM(o.total_amount), 0) AS total_spent,
    COUNT(o.id) AS order_count,
    CASE
        WHEN COALESCE(SUM(o.total_amount), 0) >= 10000000 AND COUNT(o.id) >= 20 THEN 'Platinum'
        WHEN COALESCE(SUM(o.total_amount), 0) >= 10000000 OR COUNT(o.id) >= 15 THEN 'Gold'
        WHEN COALESCE(SUM(o.total_amount), 0) >= 5000000 OR COUNT(o.id) >= 10 THEN 'Silver'
        WHEN COALESCE(SUM(o.total_amount), 0) >= 1000000 OR COUNT(o.id) >= 3 THEN 'Bronze'
        ELSE 'Standard'
    END AS tier,
    CASE
        WHEN COALESCE(SUM(o.total_amount), 0) >= 10000000 AND COUNT(o.id) >= 20 THEN 'Free shipping + 20% discount'
        WHEN COALESCE(SUM(o.total_amount), 0) >= 10000000 OR COUNT(o.id) >= 15 THEN 'Free shipping + 15% discount'
        WHEN COALESCE(SUM(o.total_amount), 0) >= 5000000 OR COUNT(o.id) >= 10 THEN 'Free shipping + 10% discount'
        WHEN COALESCE(SUM(o.total_amount), 0) >= 1000000 OR COUNT(o.id) >= 3 THEN '5% discount'
        ELSE 'None'
    END AS benefits
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id AND o.status = 'delivered'
GROUP BY c.id, c.name
ORDER BY total_spent DESC;
```

</details>

---

## Part 4: UNION & Combined (5 bài)

### Bài 16: Activity Feed
Tạo activity feed kết hợp orders và reviews, sắp xếp theo thời gian.

**Output:** activity_type, activity_id, user_name, description, activity_date

<details>
<summary>Đáp án</summary>

```sql
SELECT
    'Order' AS activity_type,
    o.id AS activity_id,
    c.name AS user_name,
    CONCAT('Order #', o.id, ' - ', o.status, ' - ', FORMAT(o.total_amount, 0), ' đ') AS description,
    o.created_at AS activity_date
FROM orders o
JOIN customers c ON o.customer_id = c.id

UNION ALL

SELECT
    'Review' AS activity_type,
    r.id AS activity_id,
    c.name AS user_name,
    CONCAT(r.rating, ' stars for ', p.name) AS description,
    r.created_at AS activity_date
FROM reviews r
JOIN customers c ON r.customer_id = c.id
JOIN products p ON r.product_id = p.id

UNION ALL

SELECT
    'Customer Signup' AS activity_type,
    c.id AS activity_id,
    c.name AS user_name,
    CONCAT('New customer from ', c.city) AS description,
    c.created_at AS activity_date
FROM customers c
WHERE c.created_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)

ORDER BY activity_date DESC
LIMIT 100;
```

</details>

---

### Bài 17: Top Performers Report
Kết hợp top customers, top products, và top categories.

**Output:** category (Customer/Product/Category), name, metric_value

<details>
<summary>Đáp án</summary>

```sql
(SELECT
    'Top Customer' AS category,
    c.name AS name,
    SUM(o.total_amount) AS metric_value
FROM customers c
JOIN orders o ON c.id = o.customer_id
WHERE o.status = 'delivered'
GROUP BY c.id, c.name
ORDER BY metric_value DESC
LIMIT 5)

UNION ALL

(SELECT
    'Top Product' AS category,
    p.name AS name,
    SUM(oi.subtotal) AS metric_value
FROM products p
JOIN order_items oi ON p.id = oi.product_id
JOIN orders o ON oi.order_id = o.id
WHERE o.status = 'delivered'
GROUP BY p.id, p.name
ORDER BY metric_value DESC
LIMIT 5)

UNION ALL

(SELECT
    'Top Category' AS category,
    cat.name AS name,
    SUM(oi.subtotal) AS metric_value
FROM categories cat
JOIN products p ON cat.id = p.category_id
JOIN order_items oi ON p.id = oi.product_id
JOIN orders o ON oi.order_id = o.id
WHERE o.status = 'delivered'
GROUP BY cat.id, cat.name
ORDER BY metric_value DESC
LIMIT 5)

ORDER BY category, metric_value DESC;
```

</details>

---

### Bài 18: Comprehensive Dashboard
Tạo dashboard summary với key metrics.

**Output:** metric_category, metric_name, metric_value

<details>
<summary>Đáp án</summary>

```sql
SELECT 'Overview' AS metric_category, 'Total Customers' AS metric_name, COUNT(*) AS metric_value
FROM customers

UNION ALL
SELECT 'Overview', 'Total Products', COUNT(*) FROM products

UNION ALL
SELECT 'Overview', 'Total Orders', COUNT(*) FROM orders

UNION ALL
SELECT 'Revenue', 'Total Revenue', SUM(total_amount)
FROM orders WHERE status = 'delivered'

UNION ALL
SELECT 'Revenue', 'Average Order Value', AVG(total_amount)
FROM orders WHERE status = 'delivered'

UNION ALL
SELECT 'Orders', 'Pending Orders', COUNT(*)
FROM orders WHERE status = 'pending'

UNION ALL
SELECT 'Orders', 'Delivered Orders', COUNT(*)
FROM orders WHERE status = 'delivered'

UNION ALL
SELECT 'Orders', 'Cancelled Orders', COUNT(*)
FROM orders WHERE status = 'cancelled'

UNION ALL
SELECT 'Products', 'Out of Stock', COUNT(*)
FROM products WHERE stock = 0

UNION ALL
SELECT 'Products', 'Low Stock (<10)', COUNT(*)
FROM products WHERE stock < 10 AND stock > 0

ORDER BY metric_category, metric_name;
```

</details>

---

### Bài 19: Year-over-Year Comparison (với Window Functions + CASE)
So sánh revenue từng tháng với cùng tháng năm trước.

**Output:** month, current_year_revenue, last_year_revenue, yoy_growth

<details>
<summary>Đáp án</summary>

```sql
SELECT
    MONTH(created_at) AS month,
    MONTHNAME(created_at) AS month_name,
    SUM(CASE WHEN YEAR(created_at) = YEAR(CURDATE()) THEN total_amount ELSE 0 END) AS current_year_revenue,
    SUM(CASE WHEN YEAR(created_at) = YEAR(CURDATE()) - 1 THEN total_amount ELSE 0 END) AS last_year_revenue,
    CASE
        WHEN SUM(CASE WHEN YEAR(created_at) = YEAR(CURDATE()) - 1 THEN total_amount ELSE 0 END) = 0 THEN NULL
        ELSE ROUND(
            (SUM(CASE WHEN YEAR(created_at) = YEAR(CURDATE()) THEN total_amount ELSE 0 END) -
             SUM(CASE WHEN YEAR(created_at) = YEAR(CURDATE()) - 1 THEN total_amount ELSE 0 END)) * 100.0 /
            SUM(CASE WHEN YEAR(created_at) = YEAR(CURDATE()) - 1 THEN total_amount ELSE 0 END),
            2
        )
    END AS yoy_growth_pct
FROM orders
WHERE status = 'delivered'
  AND YEAR(created_at) IN (YEAR(CURDATE()), YEAR(CURDATE()) - 1)
GROUP BY MONTH(created_at), month_name
ORDER BY month;
```

</details>

---

### Bài 20: RFM Analysis Complete
Tạo RFM (Recency, Frequency, Monetary) analysis hoàn chỉnh với segmentation.

**Output:** customer_name, recency, frequency, monetary, rfm_score, segment

<details>
<summary>Đáp án</summary>

```sql
SELECT
    customer_name,
    recency,
    frequency,
    monetary,
    CONCAT(recency_score, frequency_score, monetary_score) AS rfm_score,
    CASE
        WHEN recency_score >= 4 AND frequency_score >= 4 AND monetary_score >= 4 THEN 'Champions'
        WHEN recency_score >= 3 AND frequency_score >= 3 AND monetary_score >= 4 THEN 'Loyal Customers'
        WHEN recency_score >= 4 AND frequency_score <= 2 THEN 'New Customers'
        WHEN recency_score >= 3 AND frequency_score >= 2 AND monetary_score >= 3 THEN 'Potential Loyalists'
        WHEN recency_score <= 2 AND frequency_score >= 4 AND monetary_score >= 4 THEN 'At Risk'
        WHEN recency_score <= 2 AND frequency_score >= 2 AND monetary_score >= 3 THEN 'Cant Lose Them'
        WHEN recency_score <= 2 THEN 'Hibernating'
        ELSE 'Others'
    END AS segment
FROM (
    SELECT
        customer_name,
        recency,
        frequency,
        monetary,
        NTILE(5) OVER (ORDER BY recency) AS recency_score,
        NTILE(5) OVER (ORDER BY frequency DESC) AS frequency_score,
        NTILE(5) OVER (ORDER BY monetary DESC) AS monetary_score
    FROM (
        SELECT
            c.name AS customer_name,
            DATEDIFF(CURDATE(), MAX(o.created_at)) AS recency,
            COUNT(o.id) AS frequency,
            SUM(o.total_amount) AS monetary
        FROM customers c
        JOIN orders o ON c.id = o.customer_id
        WHERE o.status = 'delivered'
        GROUP BY c.id, c.name
    ) AS customer_metrics
) AS rfm_scores
ORDER BY monetary DESC;
```

</details>

---

## Tổng Kết

Hoàn thành 20 bài tập trên, bạn đã master:
- ✅ Subqueries (scalar, correlated, derived tables)
- ✅ Window Functions (ROW_NUMBER, RANK, NTILE, LAG, LEAD)
- ✅ Aggregate window functions (SUM, AVG, running totals)
- ✅ CASE WHEN (simple, nested, với aggregates)
- ✅ UNION / UNION ALL
- ✅ Kết hợp nhiều concepts phức tạp

## Tiếp Theo

➡️ [Level 4: Expert](../level-4-expert/README.md)

⬅️ [CASE WHEN & UNION](03-case-union.md)
