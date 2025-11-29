# Giới Thiệu SQL

## SQL là gì?

**SQL (Structured Query Language)** là ngôn ngữ lập trình được thiết kế để quản lý và truy vấn dữ liệu trong các hệ quản trị cơ sở dữ liệu quan hệ (RDBMS).

### Tại Sao Phải Học SQL?

📊 **Universal** - Được sử dụng bởi hầu hết các công ty tech
💼 **High Demand** - Kỹ năng SQL luôn được tìm kiếm
🚀 **Career Growth** - Mở ra nhiều cơ hội nghề nghiệp
💰 **High Salary** - Lương cao cho các vị trí liên quan database
🔧 **Practical** - Ứng dụng thực tế trong mọi dự án

### SQL Được Dùng Ở Đâu?

- **Web Development** - Backend, API, user management
- **Data Analysis** - Business intelligence, reporting
- **Mobile Apps** - User data, offline storage
- **E-commerce** - Orders, products, customers
- **Social Media** - Posts, comments, likes
- **IoT** - Sensor data, device management

## Database Là Gì?

**Database** (cơ sở dữ liệu) là một tập hợp dữ liệu có tổ chức, được lưu trữ và truy xuất từ hệ thống máy tính.

### Relational Database

Database quan hệ lưu trữ dữ liệu trong các **bảng (tables)** với:
- **Rows (Hàng)** - Mỗi row là một record/bản ghi
- **Columns (Cột)** - Mỗi column là một thuộc tính/field

**Ví dụ:** Bảng `customers`

| id | name | email | city |
|----|------|-------|------|
| 1 | Nguyễn Văn An | an@gmail.com | Hà Nội |
| 2 | Trần Thị Bình | binh@gmail.com | Hồ Chí Minh |

### Popular Database Systems

- **MySQL** ⭐ - Phổ biến nhất, open-source
- **PostgreSQL** - Mạnh mẽ, nhiều tính năng
- **SQLite** - Nhẹ, embedded
- **SQL Server** - Microsoft
- **Oracle** - Enterprise

Trong khóa học này, chúng ta sử dụng **MySQL 8.0**.

## Các Khái Niệm Cơ Bản

### 1. Database (Cơ sở dữ liệu)
Container chứa toàn bộ tables và data.

**Ví dụ:** `ecommerce_db`

### 2. Table (Bảng)
Tập hợp dữ liệu có cấu trúc, gồm rows và columns.

**Ví dụ:** `products`, `customers`, `orders`

### 3. Column (Cột)
Thuộc tính/field của table, mỗi column có kiểu dữ liệu cụ thể.

**Ví dụ:** `id`, `name`, `email`, `price`

### 4. Row (Hàng)
Một bản ghi/record trong table.

**Ví dụ:** 1 customer, 1 product, 1 order

### 5. Primary Key
Column hoặc tập hợp columns duy nhất để định danh mỗi row.

**Ví dụ:** `id` column (auto-increment)

### 6. Foreign Key
Column tham chiếu đến primary key của table khác, tạo mối quan hệ.

**Ví dụ:** `customer_id` trong bảng `orders` tham chiếu đến `id` trong `customers`

### 7. Index
Cấu trúc dữ liệu giúp tăng tốc độ truy vấn.

**Ví dụ:** Index trên `email` để tìm kiếm nhanh

## SQL Commands Categories

SQL được chia thành 4 nhóm lệnh chính:

### 1. DQL (Data Query Language) - Truy Vấn Dữ Liệu
```sql
SELECT * FROM customers;
```
📖 **Mục đích:** Đọc/truy vấn dữ liệu

### 2. DML (Data Manipulation Language) - Thao Tác Dữ Liệu
```sql
INSERT INTO customers (name, email) VALUES ('John', 'john@email.com');
UPDATE customers SET city = 'Hà Nội' WHERE id = 1;
DELETE FROM customers WHERE id = 5;
```
📝 **Mục đích:** Thêm, sửa, xóa dữ liệu

### 3. DDL (Data Definition Language) - Định Nghĩa Cấu Trúc
```sql
CREATE TABLE products (...);
ALTER TABLE products ADD COLUMN stock INT;
DROP TABLE old_table;
```
🏗️ **Mục đích:** Tạo, sửa, xóa cấu trúc database

### 4. DCL (Data Control Language) - Kiểm Soát Truy Cập
```sql
GRANT SELECT ON database.* TO 'user'@'localhost';
REVOKE INSERT ON database.* FROM 'user'@'localhost';
```
🔐 **Mục đích:** Phân quyền user

**Trong khóa học này, chúng ta tập trung vào DQL (SELECT) và một phần DML.**

## Cú Pháp SQL Cơ Bản

### Case Sensitivity
- **Keywords:** Không phân biệt HOA/thường (`SELECT` = `select`)
- **Table/Column names:** Tùy database (MySQL: không phân biệt)
- **String values:** Phân biệt HOA/thường (`'Hà Nội'` ≠ `'hà nội'`)

**Best Practice:** Viết HOA keywords, thường table/column names
```sql
SELECT name, email FROM customers;  -- ✅ Recommended
```

### Comments
```sql
-- Đây là comment 1 dòng

/* Đây là comment
   nhiều dòng */

SELECT name -- Inline comment
FROM customers;
```

### Semicolon (;)
Kết thúc mỗi câu SQL statement:
```sql
SELECT * FROM products;
SELECT * FROM customers;
```

### String Values
Sử dụng single quotes (`'`) hoặc double quotes (`"`):
```sql
SELECT * FROM customers WHERE name = 'Nguyễn Văn An';
SELECT * FROM products WHERE name = "Áo thun nam";
```

## Câu SELECT Đầu Tiên

```sql
-- Lấy tất cả columns từ bảng products
SELECT * FROM products;

-- Lấy các columns cụ thể
SELECT name, price FROM products;

-- Lấy 5 products đầu tiên
SELECT * FROM products LIMIT 5;
```

### Giải Thích:
- `SELECT` - Keyword để truy vấn
- `*` - Tất cả columns (wildcard)
- `FROM products` - Từ bảng products
- `LIMIT 5` - Giới hạn 5 rows

## Lộ Trình Học

```
Level 1: Beginner
└── SELECT, WHERE, ORDER BY, LIMIT
    (3-4 tuần)

Level 2: Intermediate
└── JOIN, GROUP BY, Aggregates, Functions
    (4-5 tuần)

Level 3: Advanced
└── Subqueries, Window Functions, CTEs
    (5-6 tuần)

Level 4: Expert
└── Indexes, Transactions, Stored Procedures
    (4-5 tuần)
```

**Tổng thời gian:** 16-20 tuần (4-5 tháng)
**Thời gian học khuyến nghị:** 30-60 phút/ngày

## E-commerce Database Schema

Trong khóa học, bạn sẽ làm việc với database **ecommerce_db**:

**7 Bảng chính:**
1. `customers` - Khách hàng (100 records)
2. `categories` - Danh mục sản phẩm (10 records)
3. `products` - Sản phẩm (50 records)
4. `orders` - Đơn hàng (200 records)
5. `order_items` - Chi tiết đơn hàng (500+ records)
6. `reviews` - Đánh giá sản phẩm (150 records)
7. `cart` - Giỏ hàng (50 records)

**Relationships (Quan hệ):**
- Customers → Orders (1-to-many)
- Orders → Order Items (1-to-many)
- Products → Order Items (1-to-many)
- Products → Reviews (1-to-many)
- Customers → Reviews (1-to-many)

Chi tiết schema: [Database Schema](phu-luc/database-schema.md)

## Công Cụ Cần Thiết

### 1. Docker Desktop ⭐ (Required)
Để chạy MySQL container
- Download: https://www.docker.com/products/docker-desktop

### 2. Database Client (Chọn 1)
Để kết nối và viết SQL:

**MySQL Workbench** (Recommended)
- Free, official MySQL tool
- Download: https://dev.mysql.com/downloads/workbench/

**DBeaver**
- Free, cross-platform
- Download: https://dbeaver.io/

**TablePlus**
- Beautiful UI (có phí)
- Download: https://tableplus.com/

**VS Code Extension**
- MySQL (by Jun Han)
- SQLTools

### 3. Optional
- **Git** - Để clone repository
- **Text Editor** - VS Code, Sublime Text

## Tips Trước Khi Bắt Đầu

✅ **Cài đặt Docker Desktop** trước khi học Level 1
✅ **Chọn database client** mà bạn thích
✅ **Chuẩn bị sẵn notebook** để ghi chú
✅ **Join SQL communities** để hỏi đáp:
   - Stack Overflow
   - Reddit r/SQL
   - Discord SQL servers

## Tiếp Theo

Bạn đã sẵn sàng? 🚀

➡️ [Hướng Dẫn Setup](00-huong-dan-setup.md) - Cài đặt MySQL với Docker

Hoặc nhảy thẳng vào:

➡️ [Level 1: Beginner](level-1-beginner/README.md) - Bắt đầu học SQL
