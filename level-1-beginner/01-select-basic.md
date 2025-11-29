# SELECT Cơ Bản

SELECT là câu lệnh quan trọng nhất trong SQL, dùng để truy vấn (đọc) dữ liệu từ database.

## Cú Pháp Cơ Bản

```sql
SELECT column1, column2, ...
FROM table_name;
```

## SELECT Tất Cả Columns

Sử dụng `*` (asterisk/wildcard) để lấy tất cả columns:

```sql
-- Lấy tất cả columns và rows từ bảng products
SELECT * FROM products;

-- Lấy tất cả từ bảng customers
SELECT * FROM customers;
```

**Kết quả:** Tất cả columns và rows trong bảng

⚠️ **Lưu ý:** Chỉ dùng `SELECT *` khi thật sự cần. Trong production, nên chỉ định columns cụ thể.

## SELECT Specific Columns

Chỉ lấy các columns bạn cần:

```sql
-- Lấy name và price từ products
SELECT name, price FROM products;

-- Lấy name, email, city từ customers
SELECT name, email, city FROM customers;
```

**Ưu điểm:**
- ✅ Tăng performance (ít data transfer)
- ✅ Dễ đọc và maintain
- ✅ Chỉ lấy data cần thiết

## Thực Hành

### Ví Dụ 1: Products Table

```sql
-- Lấy tất cả products
SELECT * FROM products;

-- Chỉ lấy tên và giá
SELECT name, price FROM products;

-- Lấy tên, giá, và stock
SELECT name, price, stock FROM products;
```

**Kết quả:**
```
+------------------------+--------+-------+
| name                   | price  | stock |
+------------------------+--------+-------+
| Áo thun nam cotton     | 150000 |   100 |
| Quần jean nam slim fit | 450000 |    80 |
| Áo sơ mi nam công sở   | 250000 |    60 |
+------------------------+--------+-------+
```

### Ví Dụ 2: Customers Table

```sql
-- Lấy tên và email customers
SELECT name, email FROM customers;

-- Lấy tên và thành phố
SELECT name, city FROM customers;
```

### Ví Dụ 3: Orders Table

```sql
-- Lấy customer_id, total_amount, status
SELECT customer_id, total_amount, status FROM orders;

-- Lấy order id và created date
SELECT id, created_at FROM orders;
```

## Column Aliases (AS)

Đổi tên column trong kết quả hiển thị:

```sql
-- Sử dụng AS để đặt alias
SELECT
    name AS ten_san_pham,
    price AS gia_ban,
    stock AS ton_kho
FROM products;

-- AS có thể bỏ qua (optional)
SELECT
    name ten_san_pham,
    price gia_ban
FROM products;

-- Alias có khoảng trắng (dùng backticks hoặc quotes)
SELECT
    name AS `Tên Sản Phẩm`,
    price AS "Giá Bán"
FROM products;
```

**Kết quả:**
```
+------------------------+---------+---------+
| ten_san_pham           | gia_ban | ton_kho |
+------------------------+---------+---------+
| Áo thun nam cotton     |  150000 |     100 |
| Quần jean nam slim fit |  450000 |      80 |
+------------------------+---------+---------+
```

**Khi nào dùng aliases:**
- 📊 Khi tên column dài hoặc khó đọc
- 🇻🇳 Muốn hiển thị Tiếng Việt
- 🔢 Khi tính toán (sẽ học ở Level 2)
- 📈 Khi tạo reports

## DISTINCT - Loại Bỏ Duplicates

Lấy các giá trị duy nhất (unique):

```sql
-- Lấy danh sách các thành phố (không trùng)
SELECT DISTINCT city FROM customers;

-- Lấy các trạng thái đơn hàng
SELECT DISTINCT status FROM orders;

-- Lấy các payment methods
SELECT DISTINCT payment_method FROM orders;
```

### Ví Dụ: Cities

**Không dùng DISTINCT:**
```sql
SELECT city FROM customers;
```
Kết quả: Hà Nội, Hồ Chí Minh, Hà Nội, Đà Nẵng, Hà Nội... (có trùng)

**Dùng DISTINCT:**
```sql
SELECT DISTINCT city FROM customers;
```
Kết quả: Hà Nội, Hồ Chí Minh, Đà Nẵng, Hải Phòng... (không trùng)

### DISTINCT với Multiple Columns

```sql
-- Lấy các cặp city + created_date duy nhất
SELECT DISTINCT city, DATE(created_at) FROM customers;
```

## Literals và Expressions

### String Literals

```sql
SELECT 'Hello World' AS greeting;
SELECT name, 'VND' AS currency FROM products;
```

### Numeric Calculations

```sql
SELECT
    name,
    price,
    price * 1.1 AS price_with_vat,
    price * 0.9 AS discounted_price
FROM products;
```

### Concatenation

```sql
-- MySQL sử dụng CONCAT()
SELECT CONCAT(name, ' - ', city) AS customer_info
FROM customers;

-- Hoặc CONCAT_WS (with separator)
SELECT CONCAT_WS(' | ', name, email, city) AS full_info
FROM customers;
```

## Best Practices

✅ **DO:**
- Chỉ định columns cụ thể thay vì `SELECT *`
- Sử dụng aliases có ý nghĩa
- Format SQL để dễ đọc (xuống dòng, indent)
- Viết HOA keywords (SELECT, FROM)

❌ **DON'T:**
- Lạm dụng `SELECT *` trong production
- Đặt alias trùng tên reserved keywords
- Viết SQL thành 1 dòng dài

## Bài Tập Thực Hành

Hãy thử viết queries sau đây:

**1. Basic SELECT**
```sql
-- Lấy tất cả products
-- Lấy tên và giá của products
-- Lấy tên, email, city của customers
```

**2. Aliases**
```sql
-- Lấy product name (alias: san_pham) và price (alias: gia)
-- Lấy customer name và email với aliases Tiếng Việt
```

**3. DISTINCT**
```sql
-- Lấy danh sách cities duy nhất từ customers
-- Lấy danh sách order statuses duy nhất
-- Lấy danh sách payment methods duy nhất
```

**4. Calculations**
```sql
-- Hiển thị price và price_with_10_percent_discount
-- Hiển thị name và total_value (price * stock)
```

## Đáp Án

<details>
<summary>Click để xem đáp án</summary>

```sql
-- 1. Basic SELECT
SELECT * FROM products;
SELECT name, price FROM products;
SELECT name, email, city FROM customers;

-- 2. Aliases
SELECT name AS san_pham, price AS gia FROM products;
SELECT name AS `Tên Khách Hàng`, email AS `Email` FROM customers;

-- 3. DISTINCT
SELECT DISTINCT city FROM customers;
SELECT DISTINCT status FROM orders;
SELECT DISTINCT payment_method FROM orders;

-- 4. Calculations
SELECT name, price, price * 0.9 AS price_with_10_percent_discount FROM products;
SELECT name, price, stock, price * stock AS total_value FROM products;
```

</details>

## Tổng Kết

Bạn đã học:
- ✅ SELECT cơ bản với `*` và specific columns
- ✅ Column aliases với AS
- ✅ DISTINCT để loại duplicates
- ✅ Simple calculations và concatenation

## Tiếp Theo

➡️ [WHERE & Filters](02-where-filters.md) - Học cách lọc dữ liệu

⬅️ [Level 1 Overview](README.md)
