# ORDER BY & LIMIT

Học cách sắp xếp và giới hạn kết quả truy vấn.

## ORDER BY - Sắp Xếp Dữ Liệu

### Cú Pháp

```sql
SELECT column1, column2
FROM table_name
ORDER BY column1 [ASC|DESC];
```

- `ASC` - Ascending (tăng dần) - **mặc định**
- `DESC` - Descending (giảm dần)

### Sort Ascending (Tăng Dần)

```sql
-- Products sắp xếp theo giá tăng dần
SELECT name, price
FROM products
ORDER BY price ASC;

-- ASC có thể bỏ qua (default)
SELECT name, price
FROM products
ORDER BY price;

-- Customers sắp xếp theo tên A-Z
SELECT name, city
FROM customers
ORDER BY name;
```

### Sort Descending (Giảm Dần)

```sql
-- Products theo giá giảm dần (đắt nhất trước)
SELECT name, price
FROM products
ORDER BY price DESC;

-- Orders theo total_amount giảm dần
SELECT id, customer_id, total_amount
FROM orders
ORDER BY total_amount DESC;

-- Customers mới nhất trước
SELECT name, created_at
FROM customers
ORDER BY created_at DESC;
```

### Sort by Multiple Columns

```sql
-- Sắp xếp theo city (A-Z), trong mỗi city sắp theo name (A-Z)
SELECT name, city
FROM customers
ORDER BY city ASC, name ASC;

-- Products: category tăng, price giảm
SELECT name, category_id, price
FROM products
ORDER BY category_id ASC, price DESC;

-- Orders: status A-Z, total giảm dần
SELECT id, status, total_amount
FROM orders
ORDER BY status ASC, total_amount DESC;
```

**Giải thích:**
- Column đầu tiên được sort trước
- Nếu có giá trị bằng nhau, sort theo column thứ 2
- Và cứ thế tiếp tục...

### Sort by Column Position

```sql
-- Sắp xếp theo column thứ 2 (price)
SELECT name, price
FROM products
ORDER BY 2 DESC;

-- Sort by column 3, then column 1
SELECT name, price, stock
FROM products
ORDER BY 3 ASC, 1 ASC;
```

⚠️ **Không khuyến khích** - Khó đọc và dễ lỗi khi thay đổi query

### Sort with NULL Values

```sql
-- Products có description, NULL values cuối cùng
SELECT name, description
FROM products
ORDER BY description IS NULL, description;

-- Hoặc dùng IFNULL/COALESCE
SELECT name, IFNULL(description, 'No description') as desc
FROM products
ORDER BY description;
```

## LIMIT - Giới Hạn Số Rows

### Basic LIMIT

```sql
-- Lấy 10 products đầu tiên
SELECT * FROM products LIMIT 10;

-- Top 5 products đắt nhất
SELECT name, price
FROM products
ORDER BY price DESC
LIMIT 5;

-- 3 customers mới nhất
SELECT name, created_at
FROM customers
ORDER BY created_at DESC
LIMIT 3;
```

### LIMIT với OFFSET

```sql
-- Bỏ qua 10 rows đầu, lấy 5 rows tiếp theo
SELECT name, price
FROM products
ORDER BY price DESC
LIMIT 5 OFFSET 10;

-- Tương đương:
LIMIT 10, 5;  -- (offset, limit)
```

**Use Case:** Pagination (phân trang)

```sql
-- Page 1: rows 1-10
SELECT * FROM products LIMIT 10 OFFSET 0;

-- Page 2: rows 11-20
SELECT * FROM products LIMIT 10 OFFSET 10;

-- Page 3: rows 21-30
SELECT * FROM products LIMIT 10 OFFSET 20;

-- Formula: OFFSET = (page - 1) * page_size
```

## Kết Hợp WHERE + ORDER BY + LIMIT

```sql
-- Top 10 products rẻ nhất có stock > 0
SELECT name, price, stock
FROM products
WHERE stock > 0
ORDER BY price ASC
LIMIT 10;

-- 5 orders lớn nhất status = delivered
SELECT id, customer_id, total_amount
FROM orders
WHERE status = 'delivered'
ORDER BY total_amount DESC
LIMIT 5;

-- Customers ở Hà Nội, mới nhất trước, lấy 20
SELECT name, city, created_at
FROM customers
WHERE city = 'Hà Nội'
ORDER BY created_at DESC
LIMIT 20;
```

## Thứ Tự Thực Thi

SQL thực thi theo thứ tự logic:

```sql
SELECT name, price          -- 3. Chọn columns
FROM products               -- 1. Từ bảng nào
WHERE price > 100000        -- 2. Lọc rows
ORDER BY price DESC         -- 4. Sắp xếp
LIMIT 10;                   -- 5. Giới hạn
```

1. **FROM** - Xác định table
2. **WHERE** - Lọc rows
3. **SELECT** - Chọn columns
4. **ORDER BY** - Sắp xếp
5. **LIMIT** - Giới hạn số lượng

## Practical Examples

### Top Products

```sql
-- Top 10 sản phẩm đắt nhất
SELECT name, price
FROM products
ORDER BY price DESC
LIMIT 10;

-- Top 10 sản phẩm rẻ nhất còn hàng
SELECT name, price, stock
FROM products
WHERE stock > 0
ORDER BY price ASC
LIMIT 10;

-- Sản phẩm bán chạy (có nhiều reviews nhất)
SELECT p.name, COUNT(r.id) as review_count
FROM products p
LEFT JOIN reviews r ON p.id = r.product_id
GROUP BY p.id
ORDER BY review_count DESC
LIMIT 10;
```

### Latest/Oldest Records

```sql
-- 10 customers mới nhất
SELECT name, created_at
FROM customers
ORDER BY created_at DESC
LIMIT 10;

-- 5 customers cũ nhất
SELECT name, created_at
FROM customers
ORDER BY created_at ASC
LIMIT 5;

-- 20 orders gần nhất
SELECT id, customer_id, created_at
FROM orders
ORDER BY created_at DESC
LIMIT 20;
```

### Pagination

```sql
-- Products per page = 20
-- Page 1
SELECT * FROM products ORDER BY id LIMIT 20 OFFSET 0;

-- Page 2
SELECT * FROM products ORDER BY id LIMIT 20 OFFSET 20;

-- Page 3
SELECT * FROM products ORDER BY id LIMIT 20 OFFSET 40;
```

### Random Selection

```sql
-- Lấy 5 products ngẫu nhiên
SELECT * FROM products ORDER BY RAND() LIMIT 5;

-- 10 customers ngẫu nhiên
SELECT * FROM customers ORDER BY RAND() LIMIT 10;
```

⚠️ **Lưu ý:** `RAND()` chậm với tables lớn!

## Best Practices

✅ **DO:**
- Luôn dùng ORDER BY khi dùng LIMIT
- Dùng indexes cho columns trong ORDER BY
- Dùng LIMIT để tránh trả về quá nhiều rows
- Test pagination với data thực tế

❌ **DON'T:**
- Dùng LIMIT không có ORDER BY (kết quả không nhất quán)
- Sort by column position (khó đọc)
- Lạm dụng RAND() cho tables lớn
- Quên tính OFFSET cho pagination

## Performance Tips

```sql
-- ❌ CHẬM: Full table scan
SELECT * FROM products ORDER BY price DESC LIMIT 10;

-- ✅ NHANH HƠN: Có index trên price
CREATE INDEX idx_price ON products(price);
SELECT * FROM products ORDER BY price DESC LIMIT 10;

-- ✅ NHANH HƠN: Chỉ lấy columns cần thiết
SELECT id, name, price FROM products ORDER BY price DESC LIMIT 10;
```

## Bài Tập

**1. Basic ORDER BY**
```sql
-- Lấy tất cả products sắp xếp theo name A-Z
-- Lấy customers sắp xếp theo city A-Z, name A-Z
-- Lấy orders sắp xếp theo created_at mới nhất trước
```

**2. ORDER BY DESC**
```sql
-- Top 10 products đắt nhất
-- Top 5 orders giá trị cao nhất
-- 10 reviews mới nhất
```

**3. LIMIT**
```sql
-- Lấy 15 products đầu tiên
-- Top 5 customers mới nhất
-- 20 orders đầu tiên
```

**4. LIMIT với OFFSET**
```sql
-- Products page 2 (items 11-20)
-- Customers page 3 (items 21-30, mỗi page 10)
```

**5. Kết Hợp**
```sql
-- Top 10 products rẻ nhất category = 1
-- 5 orders lớn nhất status = delivered từ Hà Nội
-- 15 customers mới nhất có email @gmail.com
```

## Đáp Án

<details>
<summary>Click để xem đáp án</summary>

```sql
-- 1. Basic ORDER BY
SELECT * FROM products ORDER BY name ASC;
SELECT * FROM customers ORDER BY city ASC, name ASC;
SELECT * FROM orders ORDER BY created_at DESC;

-- 2. ORDER BY DESC
SELECT name, price FROM products ORDER BY price DESC LIMIT 10;
SELECT id, total_amount FROM orders ORDER BY total_amount DESC LIMIT 5;
SELECT * FROM reviews ORDER BY created_at DESC LIMIT 10;

-- 3. LIMIT
SELECT * FROM products LIMIT 15;
SELECT * FROM customers ORDER BY created_at DESC LIMIT 5;
SELECT * FROM orders LIMIT 20;

-- 4. LIMIT với OFFSET
SELECT * FROM products LIMIT 10 OFFSET 10;
SELECT * FROM customers LIMIT 10 OFFSET 20;

-- 5. Kết Hợp
SELECT name, price FROM products WHERE category_id = 1 ORDER BY price ASC LIMIT 10;

SELECT o.id, o.total_amount, c.city
FROM orders o
JOIN customers c ON o.customer_id = c.id
WHERE o.status = 'delivered' AND c.city = 'Hà Nội'
ORDER BY o.total_amount DESC
LIMIT 5;

SELECT name, email, created_at
FROM customers
WHERE email LIKE '%@gmail.com'
ORDER BY created_at DESC
LIMIT 15;
```

</details>

## Tổng Kết

Bạn đã học:
- ✅ ORDER BY (ASC/DESC) để sắp xếp
- ✅ Sort by multiple columns
- ✅ LIMIT để giới hạn rows
- ✅ OFFSET cho pagination
- ✅ Kết hợp WHERE + ORDER BY + LIMIT

## Tiếp Theo

➡️ [Bài Tập Level 1](bai-tap.md) - Thực hành tổng hợp

⬅️ [WHERE & Filters](02-where-filters.md)
