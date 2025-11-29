# Bài Tập Level 1 - Beginner

15 bài tập thực hành để củng cố kiến thức Level 1.

## Hướng Dẫn

1. **Tự làm trước** - Đừng nhìn đáp án ngay
2. **Chạy query** trên database thực tế
3. **Kiểm tra kết quả** - Có hợp lý không?
4. **Xem đáp án** sau khi đã thử

## Bài Tập Cơ Bản (1-5)

### Bài 1: Lấy Danh Sách Products
Lấy tên và giá của tất cả sản phẩm, sắp xếp theo giá tăng dần.

**Kết quả mong đợi:** ~50 rows

---

### Bài 2: Customers ở Hà Nội
Lấy tên, email và số điện thoại của khách hàng ở Hà Nội, sắp xếp theo tên A-Z.

**Gợi ý:** WHERE + ORDER BY

---

### Bài 3: Products Giá Cao
Lấy top 10 sản phẩm đắt nhất (hiển thị tên, giá, category_id).

**Gợi ý:** ORDER BY DESC + LIMIT

---

### Bài 4: Orders Pending
Lấy tất cả đơn hàng có trạng thái 'pending' hoặc 'processing'.

**Gợi ý:** WHERE với IN hoặc OR

---

### Bài 5: Unique Cities
Lấy danh sách các thành phố duy nhất từ bảng customers, sắp xếp A-Z.

**Gợi ý:** DISTINCT + ORDER BY

---

## Bài Tập Trung Bình (6-10)

### Bài 6: Products Trong Tầm Giá
Lấy các sản phẩm có giá từ 200,000 đến 1,000,000 VNĐ, còn hàng (stock > 0), sắp xếp theo giá giảm dần.

**Gợi ý:** BETWEEN + AND + ORDER BY DESC

---

### Bài 7: Gmail Customers
Lấy 20 khách hàng mới nhất có email @gmail.com.

**Gợi ý:** LIKE + ORDER BY created_at DESC + LIMIT

---

### Bài 8: Large Orders
Lấy các đơn hàng có tổng giá trị > 5,000,000 VNĐ và đã giao hàng (delivered).

**Gợi ý:** WHERE với AND

---

### Bài 9: Products Tên Chứa "Áo"
Lấy tất cả sản phẩm có tên chứa chữ "áo" (không phân biệt HOA/thường).

**Gợi ý:** LIKE với %

---

### Bài 10: Pagination
Lấy products từ vị trí 21-30 (page 3, mỗi trang 10 items), sắp xếp theo id.

**Gợi ý:** LIMIT + OFFSET

---

## Bài Tập Nâng Cao (11-15)

### Bài 11: Top Customers by Orders
Lấy 5 khách hàng có nhiều đơn hàng nhất (cần đếm số orders của mỗi customer).

**Gợi ý:** Sử dụng subquery hoặc JOIN (có thể khó, thử sức!)

---

### Bài 12: Products Out of Stock
Lấy các sản phẩm hết hàng (stock = 0) thuộc category 1, 2, hoặc 3.

**Gợi ý:** WHERE stock = 0 AND category_id IN (...)

---

### Bài 13: Recent High-Value Orders
Lấy 10 đơn hàng có giá trị cao nhất (> 1,000,000) được tạo trong tháng 3/2024.

**Gợi ý:** WHERE với DATE, AND, ORDER BY, LIMIT

---

### Bài 14: Customers Without Orders
Lấy các khách hàng chưa có đơn hàng nào.

**Gợi ý:** LEFT JOIN hoặc NOT EXISTS (Level 2 content, thử thách!)

---

### Bài 15: Products by Price Range
Đếm số lượng products trong các tầm giá:
- < 100k
- 100k - 500k
- 500k - 1tr
- > 1tr

**Gợi ý:** CASE WHEN hoặc multiple queries

---

## Đáp Án

<details>
<summary>Bài 1-5: Cơ Bản</summary>

```sql
-- Bài 1
SELECT name, price
FROM products
ORDER BY price ASC;

-- Bài 2
SELECT name, email, phone
FROM customers
WHERE city = 'Hà Nội'
ORDER BY name ASC;

-- Bài 3
SELECT name, price, category_id
FROM products
ORDER BY price DESC
LIMIT 10;

-- Bài 4
SELECT *
FROM orders
WHERE status IN ('pending', 'processing');
-- Hoặc: WHERE status = 'pending' OR status = 'processing';

-- Bài 5
SELECT DISTINCT city
FROM customers
ORDER BY city ASC;
```

</details>

<details>
<summary>Bài 6-10: Trung Bình</summary>

```sql
-- Bài 6
SELECT name, price, stock
FROM products
WHERE price BETWEEN 200000 AND 1000000
  AND stock > 0
ORDER BY price DESC;

-- Bài 7
SELECT name, email, created_at
FROM customers
WHERE email LIKE '%@gmail.com'
ORDER BY created_at DESC
LIMIT 20;

-- Bài 8
SELECT id, customer_id, total_amount, status
FROM orders
WHERE total_amount > 5000000
  AND status = 'delivered';

-- Bài 9
SELECT name, price
FROM products
WHERE name LIKE '%áo%' OR name LIKE '%Áo%';
-- Hoặc (MySQL default case-insensitive):
WHERE name LIKE '%áo%';

-- Bài 10
SELECT *
FROM products
ORDER BY id
LIMIT 10 OFFSET 20;
-- Hoặc: LIMIT 20, 10;
```

</details>

<details>
<summary>Bài 11-15: Nâng Cao</summary>

```sql
-- Bài 11 (cách đơn giản với Level 1)
SELECT customer_id, COUNT(*) as order_count
FROM orders
GROUP BY customer_id
ORDER BY order_count DESC
LIMIT 5;

-- Bài 12
SELECT name, stock, category_id
FROM products
WHERE stock = 0
  AND category_id IN (1, 2, 3);

-- Bài 13
SELECT id, total_amount, created_at
FROM orders
WHERE total_amount > 1000000
  AND created_at >= '2024-03-01'
  AND created_at < '2024-04-01'
ORDER BY total_amount DESC
LIMIT 10;

-- Bài 14 (Level 2 - JOIN)
SELECT c.id, c.name, c.email
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
WHERE o.id IS NULL;

-- Bài 15 (multiple queries)
SELECT
    '< 100k' as price_range,
    COUNT(*) as count
FROM products
WHERE price < 100000
UNION ALL
SELECT
    '100k - 500k',
    COUNT(*)
FROM products
WHERE price BETWEEN 100000 AND 500000
UNION ALL
SELECT
    '500k - 1tr',
    COUNT(*)
FROM products
WHERE price BETWEEN 500000 AND 1000000
UNION ALL
SELECT
    '> 1tr',
    COUNT(*)
FROM products
WHERE price > 1000000;

-- Hoặc dùng CASE (Level 2)
SELECT
    CASE
        WHEN price < 100000 THEN '< 100k'
        WHEN price BETWEEN 100000 AND 500000 THEN '100k - 500k'
        WHEN price BETWEEN 500000 AND 1000000 THEN '500k - 1tr'
        ELSE '> 1tr'
    END as price_range,
    COUNT(*) as count
FROM products
GROUP BY price_range;
```

</details>

## Bonus Exercises

Muốn thử thách hơn? Thử các bài sau:

**Bonus 1:** Lấy products có tên dài nhất (hint: LENGTH())
**Bonus 2:** Tính tổng giá trị tồn kho của mỗi category (hint: price * stock)
**Bonus 3:** Lấy orders có notes, sắp xếp theo độ dài notes giảm dần

## Tự Kiểm Tra

Sau khi hoàn thành:

- [ ] Làm được 5/5 bài cơ bản
- [ ] Làm được 4/5 bài trung bình
- [ ] Làm được 2/5 bài nâng cao
- [ ] Hiểu rõ SELECT, WHERE, ORDER BY, LIMIT
- [ ] Tự tin viết queries cơ bản

**Nếu chưa:** Xem lại lý thuyết và thử lại!

**Nếu rồi:** Chúc mừng! Bạn đã hoàn thành Level 1! 🎉

## Tiếp Theo

Sẵn sàng cho Level 2?

➡️ [Level 2: Intermediate](../level-2-intermediate/README.md) - JOIN, GROUP BY, Functions

⬅️ [ORDER BY & LIMIT](03-order-limit.md)
