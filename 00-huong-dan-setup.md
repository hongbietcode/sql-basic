# Hướng Dẫn Setup MySQL Workbench

Để học SQL, bạn cần một công cụ để kết nối và thực hành với database. **MySQL Workbench** là công cụ chính thức từ MySQL, miễn phí và mạnh mẽ.

## Bước 1: Download MySQL Workbench

### Link Download Chính Thức
**🔗 https://dev.mysql.com/downloads/workbench/**

### Chọn Phiên Bản Phù Hợp

#### macOS
1. Truy cập: https://dev.mysql.com/downloads/workbench/
2. Chọn **"macOS"** trong Select Operating System
3. Chọn phiên bản phù hợp:
   - **macOS (ARM, 64-bit), DMG Archive** - Cho Mac M1/M2/M3
   - **macOS (x86, 64-bit), DMG Archive** - Cho Mac Intel
4. Click **"Download"**
5. Có thể bỏ qua đăng nhập bằng cách click **"No thanks, just start my download"**

#### Windows
1. Truy cập: https://dev.mysql.com/downloads/workbench/
2. Chọn **"Microsoft Windows"**
3. Download file `.msi` installer
4. Click **"Download"**
5. Bỏ qua đăng nhập nếu không muốn

#### Linux (Ubuntu/Debian)
```bash
# Thêm repository
sudo apt update
sudo apt install mysql-workbench
```

#### Linux (Fedora/RedHat)
```bash
sudo dnf install mysql-workbench
```

## Bước 2: Cài Đặt MySQL Workbench

### macOS
1. Mở file `.dmg` đã download
2. Kéo **MySQL Workbench** vào thư mục **Applications**
3. Mở MySQL Workbench từ Applications
4. Nếu gặp cảnh báo security:
   - Mở **System Settings** → **Privacy & Security**
   - Click **"Open Anyway"** bên cạnh MySQL Workbench

### Windows
1. Double-click file `.msi` installer
2. Click **"Next"** để tiếp tục
3. Chọn **"Complete"** installation
4. Click **"Install"**
5. Chờ quá trình cài đặt hoàn tất
6. Click **"Finish"**
7. Khởi động MySQL Workbench

### Linux
Sau khi cài đặt qua package manager, mở MySQL Workbench từ Applications menu.

## Bước 3: Kết Nối Với Database Server

Database đã được deploy sẵn trên server để bạn có thể thực hành.

### Thông Tin Kết Nối

**Lưu ý:** Admin sẽ cung cấp thông tin kết nối chính xác. Dưới đây là template:

| Field | Value |
|-------|-------|
| **Connection Name** | SQL Learning - Ecommerce |
| **Hostname** | `<server-ip-hoặc-domain>` |
| **Port** | 3306 (hoặc port khác nếu được chỉ định) |
| **Username** | `sqllearner` |
| **Password** | `<sẽ-được-cung-cấp>` |
| **Default Schema** | `ecommerce_db` |

### Tạo Connection Mới

1. **Mở MySQL Workbench**

2. **Tạo Connection Mới:**
   - Click biểu tượng **"+"** bên cạnh "MySQL Connections"
   - Hoặc menu: **Database** → **Manage Connections** → **New**

3. **Điền Thông Tin:**
   - **Connection Name:** `SQL Learning - Ecommerce` (hoặc tên bạn muốn)
   - **Connection Method:** `Standard (TCP/IP)`
   - **Hostname:** Nhập IP hoặc domain của server (sẽ được cung cấp)
   - **Port:** `3306` (mặc định, hoặc theo hướng dẫn)
   - **Username:** `sqllearner`
   - **Default Schema:** `ecommerce_db`

4. **Lưu Password:**
   - Click **"Store in Keychain..."** (macOS) hoặc **"Store in Vault..."** (Windows/Linux)
   - Nhập password đã được cung cấp
   - Click **"OK"**

5. **Test Connection:**
   - Click nút **"Test Connection"**
   - Nếu thành công, sẽ thấy: "Successfully made the MySQL connection"
   - Nếu thất bại, xem phần Troubleshooting bên dưới

6. **Lưu Connection:**
   - Click **"OK"** để lưu connection

7. **Kết Nối:**
   - Double-click vào connection vừa tạo
   - MySQL Workbench sẽ mở SQL Editor

## Bước 4: Verify Database

Sau khi kết nối thành công, chạy các câu SQL sau để kiểm tra:

### Kiểm Tra Các Bảng
```sql
-- Xem tất cả bảng trong database
SHOW TABLES;
```

**Output mong đợi:**
```
+------------------------+
| Tables_in_ecommerce_db |
+------------------------+
| cart                   |
| categories             |
| customers              |
| order_items            |
| orders                 |
| products               |
| reviews                |
+------------------------+
7 rows in set
```

### Đếm Records
```sql
-- Đếm số lượng records trong mỗi bảng
SELECT
    'customers' as table_name, COUNT(*) as total FROM customers
UNION ALL
SELECT 'categories', COUNT(*) FROM categories
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'reviews', COUNT(*) FROM reviews
UNION ALL
SELECT 'cart', COUNT(*) FROM cart;
```

**Output mong đợi:**
```
+-------------+-------+
| table_name  | total |
+-------------+-------+
| customers   |   100 |
| categories  |    10 |
| products    |    50 |
| orders      |   200 |
| order_items |   500+|
| reviews     |   150 |
| cart        |    50 |
+-------------+-------+
```

### Xem Dữ Liệu Mẫu
```sql
-- Lấy 5 products đầu tiên
SELECT * FROM products LIMIT 5;

-- Lấy 5 customers đầu tiên
SELECT * FROM customers LIMIT 5;

-- Lấy 5 orders gần nhất
SELECT * FROM orders
ORDER BY created_at DESC
LIMIT 5;
```

**Nếu bạn thấy dữ liệu → Setup thành công!** 🎉

## Sử Dụng MySQL Workbench

### Chạy SQL Queries

1. **Mở SQL Editor:**
   - Double-click vào connection đã tạo
   - Hoặc click icon "SQL Editor" ở toolbar

2. **Viết Query:**
   - Gõ SQL query vào editor
   - Ví dụ: `SELECT * FROM products LIMIT 10;`

3. **Chạy Query:**
   - **Chạy toàn bộ:** Click icon ⚡ (lightning bolt) hoặc `Ctrl+Shift+Enter`
   - **Chạy query hiện tại:** Click icon ⚡ (1 lightning) hoặc `Ctrl+Enter`
   - Kết quả sẽ hiển thị ở phần dưới

4. **Xem Kết Quả:**
   - Tab **Result Grid** hiển thị dữ liệu dạng bảng
   - Tab **Output** hiển thị messages và errors
   - Tab **Execution Plan** hiển thị query performance

### Tính Năng Hữu Ích

#### 1. Schema Navigator
- Panel bên trái hiển thị:
  - Databases
  - Tables
  - Views
  - Stored Procedures
- Right-click vào table → **Select Rows** để xem data nhanh

#### 2. Query History
- Menu: **Query** → **History**
- Xem lại các queries đã chạy
- Double-click để load lại query

#### 3. Auto-Complete
- Gõ tên table/column và nhấn `Ctrl+Space`
- MySQL Workbench sẽ suggest

#### 4. Format Query
- Select query text
- Menu: **Query** → **Beautify Query**
- Hoặc `Ctrl+B`

#### 5. Export Results
- Right-click vào Result Grid
- Chọn **Export** → Format (CSV, JSON, XML, HTML, etc.)

#### 6. Multiple Query Tabs
- `Ctrl+T` để mở tab mới
- Có thể có nhiều queries đang chạy song song

## Alternative Tools (Tùy Chọn)

Nếu bạn muốn thử công cụ khác:

### DBeaver (Free, Cross-platform)
- Download: https://dbeaver.io/download/
- Universal database tool
- Support nhiều databases

### TablePlus (Paid, Mac/Windows/Linux)
- Download: https://tableplus.com/
- Modern, fast UI
- Free trial 14 ngày

### HeidiSQL (Free, Windows only)
- Download: https://www.heidisql.com/download.php
- Lightweight, đơn giản

### Command Line (Advanced)
```bash
# Cài MySQL Client
# macOS
brew install mysql-client

# Ubuntu/Debian
sudo apt install mysql-client

# Kết nối
mysql -h <hostname> -P 3306 -u sqllearner -p ecommerce_db
```

## Troubleshooting

### Không Kết Nối Được Server

**Lỗi:** "Can't connect to MySQL server"

**Kiểm tra:**
1. ✅ Hostname/IP đúng chưa?
2. ✅ Port đúng chưa? (thường là 3306)
3. ✅ Username/Password đúng chưa?
4. ✅ Có internet connection?
5. ✅ Firewall có block port 3306?

**Giải pháp:**
```bash
# Test kết nối với telnet
telnet <hostname> 3306

# Hoặc với netcat
nc -zv <hostname> 3306
```

Nếu không kết nối được → Liên hệ admin để kiểm tra:
- Server có đang chạy?
- Firewall có cho phép remote connections?
- User có quyền remote access?

### SSL Connection Error

**Lỗi:** "SSL connection error"

**Giải pháp:**
1. Trong connection settings
2. Tab **"SSL"**
3. Set **"Use SSL"** = **"No"** (nếu server không require SSL)
4. Hoặc **"Require"** nếu server yêu cầu SSL

### Authentication Failed

**Lỗi:** "Access denied for user 'sqllearner'@'%'"

**Nguyên nhân:**
- Password sai
- User chưa được tạo trên server
- User không có quyền remote access

**Giải pháp:**
- Kiểm tra lại password
- Liên hệ admin để verify user permissions

### Slow Connection

Nếu kết nối chậm:
1. Kiểm tra internet speed
2. Thử đổi connection method → **Standard TCP/IP over SSH** (nếu có SSH access)
3. Liên hệ admin kiểm tra server load

### Port is Blocked

**Lỗi:** "Can't connect" hoặc timeout

**Kiểm tra firewall:**

**macOS:**
```bash
# Check if port is open
nc -zv <hostname> 3306
```

**Windows:**
```bash
# Test with PowerShell
Test-NetConnection -ComputerName <hostname> -Port 3306
```

Nếu blocked → Liên hệ admin hoặc IT department.

### Database Not Found

**Lỗi:** "Unknown database 'ecommerce_db'"

**Giải pháp:**
1. Bỏ trống **"Default Schema"** khi tạo connection
2. Sau khi kết nối, chạy:
```sql
SHOW DATABASES;
```
3. Kiểm tra tên database chính xác
4. Chọn database:
```sql
USE ecommerce_db;
```

## Tips & Best Practices

### 💡 Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+Enter` | Execute current statement |
| `Ctrl+Shift+Enter` | Execute all statements |
| `Ctrl+T` | New query tab |
| `Ctrl+/` | Comment/uncomment line |
| `Ctrl+B` | Beautify/format query |
| `Ctrl+Space` | Auto-complete |
| `Ctrl+L` | Delete current line |

### 💡 Query Tips

```sql
-- Always limit results khi test
SELECT * FROM products LIMIT 10;

-- Dùng comments để ghi chú
-- Đây là comment 1 line

/*
Đây là comment
nhiều lines
*/

-- Format queries cho dễ đọc
SELECT
    p.name,
    p.price,
    c.name AS category
FROM products p
JOIN categories c ON p.category_id = c.id
WHERE p.price > 100000
ORDER BY p.price DESC
LIMIT 10;
```

### 💡 Safety Tips

⚠️ **Cẩn thận với UPDATE/DELETE:**
```sql
-- ❌ NGUY HIỂM: Xóa tất cả data
DELETE FROM products;

-- ✅ AN TOÀN: Có WHERE clause
DELETE FROM products
WHERE id = 123;

-- ✅ TỐT NHẤT: Test với SELECT trước
SELECT * FROM products
WHERE id = 123;
-- Nếu OK → Đổi SELECT thành DELETE
```

⚠️ **Always backup trước khi UPDATE/DELETE nhiều rows**

⚠️ **Không share password lên internet**

## Tổng Kết

Sau khi hoàn thành setup:

✅ MySQL Workbench đã cài đặt
✅ Connection đến server thành công
✅ Database có đầy đủ 7 bảng và data
✅ Đã test chạy queries cơ bản

**Bạn đã sẵn sàng bắt đầu học SQL!** 🚀

## Tiếp Theo

➡️ [Level 1: Beginner](level-1-beginner/README.md) - Bắt đầu học SELECT cơ bản

Hoặc xem lại:

⬅️ [Giới Thiệu SQL](00-gioi-thieu.md) - Tổng quan về SQL

## Lấy Thông Tin Kết Nối

**Lưu ý quan trọng:** Thông tin kết nối database (hostname, username, password) sẽ được cung cấp riêng.

Nếu bạn chưa có thông tin kết nối, vui lòng liên hệ để nhận:
- Server hostname/IP
- Database username
- Password
- Port (nếu khác 3306)

---

**Có thắc mắc?**
- Tham khảo [Lỗi Thường Gặp](phu-luc/loi-thuong-gap.md)
- Hoặc liên hệ support
