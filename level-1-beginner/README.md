# Level 1: Beginner - Cơ Bản

Chào mừng đến với Level 1! Đây là nơi bạn bắt đầu hành trình học SQL.

## 🎯 Mục Tiêu

Sau khi hoàn thành Level 1, bạn sẽ có thể:
- ✅ Viết câu SELECT cơ bản để lấy dữ liệu
- ✅ Lọc dữ liệu với WHERE và các operators
- ✅ Sắp xếp dữ liệu với ORDER BY
- ✅ Giới hạn số lượng kết quả với LIMIT
- ✅ Xử lý NULL values
- ✅ Sử dụng DISTINCT để loại bỏ duplicates

## 📚 Nội Dung

### [1. SELECT Cơ Bản](01-select-basic.md)
- SELECT và FROM
- SELECT specific columns
- SELECT * (all columns)
- DISTINCT
- Column aliases với AS

**Ví dụ:**
```sql
SELECT name, price FROM products;
SELECT DISTINCT city FROM customers;
SELECT name AS product_name, price AS gia_ban FROM products;
```

### [2. WHERE & Filters](02-where-filters.md)
- WHERE clause
- Comparison operators (=, !=, >, <, >=, <=)
- Logical operators (AND, OR, NOT)
- IN, BETWEEN, LIKE
- NULL handling (IS NULL, IS NOT NULL)

**Ví dụ:**
```sql
SELECT * FROM products WHERE price > 500000;
SELECT * FROM customers WHERE city IN ('Hà Nội', 'Hồ Chí Minh');
SELECT * FROM products WHERE name LIKE '%áo%';
```

### [3. ORDER BY & LIMIT](03-order-limit.md)
- ORDER BY (ASC, DESC)
- Sorting by multiple columns
- LIMIT
- OFFSET
- Combining ORDER BY and LIMIT

**Ví dụ:**
```sql
SELECT * FROM products ORDER BY price DESC;
SELECT * FROM customers ORDER BY created_at DESC LIMIT 10;
SELECT * FROM orders ORDER BY total_amount DESC LIMIT 5 OFFSET 10;
```

### [4. Bài Tập Thực Hành](bai-tap.md)
**15 bài tập** từ dễ đến khó với đáp án chi tiết

## ⏱️ Thời Gian Học

- **Tổng thời gian:** 2-3 tuần
- **Khuyến nghị:** 30-60 phút/ngày
- **Breakdown:**
  - Week 1: SELECT basic + WHERE
  - Week 2: ORDER BY + LIMIT + Practice
  - Week 3: Review + Exercises

## 📖 Cách Học Hiệu Quả

1. **Đọc lý thuyết** - Hiểu concepts trước khi code
2. **Viết SQL** - Tự tay viết, không copy/paste
3. **Chạy queries** - Xem kết quả thực tế
4. **Thử nghiệm** - Thay đổi queries để hiểu sâu hơn
5. **Làm bài tập** - Tự làm trước khi xem đáp án

## 🗂️ Database E-commerce

Bạn sẽ thực hành với các bảng sau:

**customers** - Khách hàng
```sql
SELECT * FROM customers LIMIT 3;
```
| id | name | email | city | created_at |
|----|------|-------|------|------------|
| 1 | Nguyễn Văn An | an@gmail.com | Hà Nội | 2024-01-15 |
| 2 | Trần Thị Bình | binh@gmail.com | Hồ Chí Minh | 2024-01-16 |

**products** - Sản phẩm
```sql
SELECT * FROM products LIMIT 3;
```
| id | name | category_id | price | stock |
|----|------|-------------|-------|-------|
| 1 | Áo thun nam cotton | 1 | 150000 | 100 |
| 2 | Quần jean nam slim fit | 1 | 450000 | 80 |

**orders** - Đơn hàng
```sql
SELECT * FROM orders LIMIT 3;
```
| id | customer_id | total_amount | status | created_at |
|----|-------------|--------------|--------|------------|
| 1 | 1 | 1350000 | delivered | 2024-01-20 |
| 2 | 2 | 850000 | delivered | 2024-01-21 |

## ✅ Checklist Hoàn Thành Level 1

- [ ] Đọc xong 3 bài lý thuyết
- [ ] Viết ít nhất 20 câu SELECT queries
- [ ] Hoàn thành 15 bài tập
- [ ] Tự tin với SELECT, WHERE, ORDER BY, LIMIT
- [ ] Hiểu cách filter và sort data

## 💡 Tips

✅ **Practice daily** - 30 phút mỗi ngày tốt hơn 3 giờ cuối tuần
✅ **Type, don't copy** - Gõ bằng tay để nhớ lâu hơn
✅ **Read errors** - Error messages giúp bạn học nhanh
✅ **Experiment** - Thử các biến thể của queries
✅ **Take notes** - Ghi chú những điều mới học

## 🚀 Bắt Đầu

Sẵn sàng chưa? Bắt đầu với bài đầu tiên:

➡️ [SELECT Cơ Bản](01-select-basic.md)

Hoặc quay lại:

⬅️ [Hướng Dẫn Setup](../00-huong-dan-setup.md)
