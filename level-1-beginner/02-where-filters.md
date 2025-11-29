# WHERE & Filters

WHERE clause cho phép bạn lọc rows dựa trên điều kiện cụ thể.

## Cú Pháp

```sql
SELECT column1, column2
FROM table_name
WHERE condition;
```

## Comparison Operators

### Equal (=)

```sql
-- Lấy product có id = 1
SELECT * FROM products WHERE id = 1;

-- Lấy customers ở Hà Nội
SELECT * FROM customers WHERE city = 'Hà Nội';

-- Lấy orders với status delivered
SELECT * FROM orders WHERE status = 'delivered';
```

### Not Equal (!= hoặc <>)

```sql
-- Products không phải category 1
SELECT * FROM products WHERE category_id != 1;

-- Orders không phải delivered
SELECT * FROM orders WHERE status <> 'delivered';
```

### Greater Than (>)

```sql
-- Products có giá > 500,000
SELECT name, price FROM products WHERE price > 500000;

-- Orders có total > 1,000,000
SELECT * FROM orders WHERE total_amount > 1000000;
```

### Less Than (<)

```sql
-- Products có giá < 200,000
SELECT name, price FROM products WHERE price < 200000;

-- Products có stock < 50
SELECT name, stock FROM products WHERE stock < 50;
```

### Greater Than or Equal (>=)

```sql
-- Products có giá >= 1,000,000
SELECT * FROM products WHERE price >= 1000000;
```

### Less Than or Equal (<=)

```sql
-- Products có stock <= 100
SELECT * FROM products WHERE stock <= 100;
```

## Logical Operators

### AND - Tất cả điều kiện phải đúng

```sql
-- Products giá từ 100k đến 500k
SELECT name, price
FROM products
WHERE price >= 100000 AND price <= 500000;

-- Customers ở Hà Nội và tạo sau ngày 2024-02-01
SELECT name, city, created_at
FROM customers
WHERE city = 'Hà Nội' AND created_at > '2024-02-01';

-- Orders delivered và payment = credit_card
SELECT *
FROM orders
WHERE status = 'delivered' AND payment_method = 'credit_card';
```

### OR - Ít nhất 1 điều kiện đúng

```sql
-- Customers ở Hà Nội HOẶC Hồ Chí Minh
SELECT name, city
FROM customers
WHERE city = 'Hà Nội' OR city = 'Hồ Chí Minh';

-- Orders với status shipped HOẶC delivered
SELECT *
FROM orders
WHERE status = 'shipped' OR status = 'delivered';
```

### NOT - Phủ định điều kiện

```sql
-- Customers KHÔNG ở Hà Nội
SELECT name, city
FROM customers
WHERE NOT city = 'Hà Nội';

-- Products KHÔNG thuộc category 1
SELECT *
FROM products
WHERE NOT category_id = 1;
```

### Kết Hợp AND, OR, NOT

```sql
-- Products giá 100k-500k VÀ stock > 50
SELECT name, price, stock
FROM products
WHERE (price >= 100000 AND price <= 500000)
  AND stock > 50;

-- Customers ở Hà Nội/HCM VÀ tạo sau 2024-02-01
SELECT name, city, created_at
FROM customers
WHERE (city = 'Hà Nội' OR city = 'Hồ Chí Minh')
  AND created_at > '2024-02-01';
```

⚠️ **Lưu ý:** Sử dụng `()` để nhóm điều kiện rõ ràng!

## IN Operator

Kiểm tra giá trị có trong danh sách:

```sql
-- Customers ở 3 thành phố
SELECT name, city
FROM customers
WHERE city IN ('Hà Nội', 'Hồ Chí Minh', 'Đà Nẵng');

-- Orders với status trong list
SELECT *
FROM orders
WHERE status IN ('pending', 'processing', 'shipped');

-- Products thuộc category 1, 3, 5
SELECT *
FROM products
WHERE category_id IN (1, 3, 5);
```

**NOT IN:**
```sql
-- Customers KHÔNG ở Hà Nội, HCM
SELECT name, city
FROM customers
WHERE city NOT IN ('Hà Nội', 'Hồ Chí Minh');
```

## BETWEEN Operator

Kiểm tra giá trị trong khoảng (inclusive):

```sql
-- Products có giá từ 100k đến 500k
SELECT name, price
FROM products
WHERE price BETWEEN 100000 AND 500000;

-- Tương đương:
WHERE price >= 100000 AND price <= 500000;

-- Orders từ tháng 2 đến tháng 4
SELECT *
FROM orders
WHERE created_at BETWEEN '2024-02-01' AND '2024-04-30';
```

**NOT BETWEEN:**
```sql
-- Products NGOÀI khoảng 100k-500k
SELECT name, price
FROM products
WHERE price NOT BETWEEN 100000 AND 500000;
```

## LIKE Operator

Pattern matching với strings:

### Wildcards

- `%` - 0 hoặc nhiều ký tự
- `_` - Đúng 1 ký tự

```sql
-- Products có tên chứa "áo"
SELECT name FROM products WHERE name LIKE '%áo%';

-- Products tên BẮT ĐẦU bằng "Áo"
SELECT name FROM products WHERE name LIKE 'Áo%';

-- Products tên KẾT THÚC bằng "nam"
SELECT name FROM products WHERE name LIKE '%nam';

-- Customers có email domain @gmail.com
SELECT name, email FROM customers WHERE email LIKE '%@gmail.com';

-- Products tên có đúng 1 ký tự trước "hăn"
SELECT name FROM products WHERE name LIKE '_hăn%';
```

**NOT LIKE:**
```sql
-- Products KHÔNG chứa "áo"
SELECT name FROM products WHERE name NOT LIKE '%áo%';
```

**Case Sensitivity:**
- MySQL: Mặc định KHÔNG phân biệt HOA/thường
- Để phân biệt: `WHERE name LIKE BINARY 'Áo%'`

## NULL Values

NULL = không có giá trị (khác với empty string '' và 0)

### IS NULL

```sql
-- Products không có description
SELECT name FROM products WHERE description IS NULL;

-- Customers không có phone
SELECT name, phone FROM customers WHERE phone IS NULL;
```

### IS NOT NULL

```sql
-- Products CÓ description
SELECT name, description FROM products WHERE description IS NOT NULL;

-- Orders CÓ notes
SELECT id, notes FROM orders WHERE notes IS NOT NULL;
```

⚠️ **Không thể dùng = hoặc != với NULL:**
```sql
-- ❌ SAI
WHERE description = NULL

-- ✅ ĐÚNG
WHERE description IS NULL
```

## Combining Everything

```sql
-- Products:
-- - Giá từ 100k-1tr
-- - Thuộc category 1 hoặc 2
-- - Có stock > 0
-- - Tên chứa "áo"
SELECT name, price, category_id, stock
FROM products
WHERE price BETWEEN 100000 AND 1000000
  AND category_id IN (1, 2)
  AND stock > 0
  AND name LIKE '%áo%';

-- Orders:
-- - Delivered hoặc Shipped
-- - Tổng tiền > 500k
-- - Payment = credit_card hoặc momo
-- - Có notes
SELECT *
FROM orders
WHERE status IN ('delivered', 'shipped')
  AND total_amount > 500000
  AND payment_method IN ('credit_card', 'momo')
  AND notes IS NOT NULL;
```

## Best Practices

✅ **DO:**
- Sử dụng `()` để nhóm điều kiện logic
- Dùng IN thay vì nhiều OR
- Dùng BETWEEN cho ranges
- Dùng IS NULL/IS NOT NULL (không dùng = NULL)

❌ **DON'T:**
- Quên dấu ngoặc khi mix AND/OR
- Dùng = NULL hoặc != NULL
- Viết quá nhiều OR liên tiếp (dùng IN)

## Bài Tập

**1. Comparison Operators**
```sql
-- Lấy products có giá > 1,000,000
-- Lấy customers tạo trước 2024-02-01
-- Lấy orders có total < 100,000
```

**2. Logical Operators**
```sql
-- Products giá 200k-800k VÀ stock > 50
-- Customers ở Hà Nội HOẶC Đà Nẵng
-- Orders KHÔNG phải status cancelled
```

**3. IN & BETWEEN**
```sql
-- Products thuộc category 1, 3, 5, 7
-- Orders có total từ 500k-2tr
-- Customers ở 5 thành phố bất kỳ
```

**4. LIKE**
```sql
-- Products tên chứa "giày"
-- Customers có email @gmail.com
-- Products tên bắt đầu bằng "Laptop"
```

**5. NULL**
```sql
-- Orders có notes
-- Products không có description
```

## Đáp Án

<details>
<summary>Click để xem đáp án</summary>

```sql
-- 1. Comparison
SELECT * FROM products WHERE price > 1000000;
SELECT * FROM customers WHERE created_at < '2024-02-01';
SELECT * FROM orders WHERE total_amount < 100000;

-- 2. Logical Operators
SELECT * FROM products WHERE price BETWEEN 200000 AND 800000 AND stock > 50;
SELECT * FROM customers WHERE city IN ('Hà Nội', 'Đà Nẵng');
SELECT * FROM orders WHERE status != 'cancelled';

-- 3. IN & BETWEEN
SELECT * FROM products WHERE category_id IN (1, 3, 5, 7);
SELECT * FROM orders WHERE total_amount BETWEEN 500000 AND 2000000;
SELECT * FROM customers WHERE city IN ('Hà Nội', 'Hồ Chí Minh', 'Đà Nẵng', 'Hải Phòng', 'Cần Thơ');

-- 4. LIKE
SELECT * FROM products WHERE name LIKE '%giày%';
SELECT * FROM customers WHERE email LIKE '%@gmail.com';
SELECT * FROM products WHERE name LIKE 'Laptop%';

-- 5. NULL
SELECT * FROM orders WHERE notes IS NOT NULL;
SELECT * FROM products WHERE description IS NULL;
```

</details>

## Tiếp Theo

➡️ [ORDER BY & LIMIT](03-order-limit.md)

⬅️ [SELECT Cơ Bản](01-select-basic.md)
