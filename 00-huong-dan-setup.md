# Hướng Dẫn Setup MySQL với Docker

Chúng ta sẽ sử dụng **Docker** để chạy MySQL, giúp setup nhanh chóng và không ảnh hưởng đến hệ thống.

## Bước 1: Cài Đặt Docker Desktop

### macOS
1. Download Docker Desktop: https://www.docker.com/products/docker-desktop
2. Mở file `.dmg` và kéo Docker vào Applications
3. Khởi động Docker Desktop từ Applications
4. Chờ Docker khởi động (biểu tượng cá voi trên menu bar)

### Windows
1. Download Docker Desktop: https://www.docker.com/products/docker-desktop
2. Chạy installer và làm theo hướng dẫn
3. Restart máy nếu được yêu cầu
4. Khởi động Docker Desktop
5. Enable WSL 2 nếu được nhắc

### Linux
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install docker.io docker-compose
sudo systemctl start docker
sudo systemctl enable docker
```

### Verify Docker
```bash
docker --version
# Output: Docker version 24.x.x

docker-compose --version
# Output: Docker Compose version v2.x.x
```

## Bước 2: Download Dự Án

### Option 1: Git Clone (Recommended)
```bash
git clone <repository-url>
cd sql-basic
```

### Option 2: Download ZIP
1. Download ZIP từ GitHub
2. Giải nén vào thư mục bạn muốn
3. Mở terminal/cmd tại thư mục đó

## Bước 3: Khởi Động MySQL Container

```bash
# Di chuyển vào thư mục dự án
cd sql-basic

# Khởi động MySQL container (chạy background)
docker-compose up -d
```

**Output mong đợi:**
```
[+] Running 2/2
 ✔ Network sql-basic_default  Created
 ✔ Container sql-learning-mysql  Started
```

### Giải Thích Lệnh
- `docker-compose` - Công cụ quản lý multi-container
- `up` - Khởi động services
- `-d` - Detached mode (chạy background)

### Kiểm Tra Container
```bash
# Xem containers đang chạy
docker ps

# Output:
# CONTAINER ID   IMAGE       STATUS         PORTS                    NAMES
# abc123...      mysql:8.0   Up 2 minutes   0.0.0.0:3306->3306/tcp   sql-learning-mysql
```

### Xem Logs
```bash
# Xem logs của MySQL container
docker-compose logs -f

# Thoát: Ctrl + C
```

Chờ đến khi thấy:
```
[Server] /usr/sbin/mysqld: ready for connections
```

## Bước 4: Kết Nối với MySQL

### Thông Tin Kết Nối

| Field | Value |
|-------|-------|
| **Host** | localhost (hoặc 127.0.0.1) |
| **Port** | 3306 |
| **Database** | ecommerce_db |
| **Username** | sqllearner |
| **Password** | learner_password_123 |
| **Root Password** | root_password_123 |

### Option 1: MySQL Workbench (Recommended)

1. Mở MySQL Workbench
2. Click **"+"** để tạo connection mới
3. Điền thông tin:
   - Connection Name: `SQL Learning - Ecommerce`
   - Hostname: `localhost`
   - Port: `3306`
   - Username: `sqllearner`
4. Click **"Store in Keychain"** và nhập password: `learner_password_123`
5. Click **"Test Connection"** → Should show "Successfully connected"
6. Click **"OK"**
7. Double-click connection để kết nối

### Option 2: DBeaver

1. Mở DBeaver
2. Click **"New Database Connection"** (plug icon)
3. Chọn **MySQL**
4. Điền thông tin:
   - Server Host: `localhost`
   - Port: `3306`
   - Database: `ecommerce_db`
   - Username: `sqllearner`
   - Password: `learner_password_123`
5. Click **"Test Connection"**
6. Download driver nếu được yêu cầu
7. Click **"Finish"**

### Option 3: TablePlus

1. Mở TablePlus
2. Click **"Create a new connection"**
3. Chọn **MySQL**
4. Điền thông tin như trên
5. Click **"Test"** → Thành công
6. Click **"Connect"**

### Option 4: Command Line

```bash
# Kết nối với MySQL
mysql -h localhost -P 3306 -u sqllearner -p ecommerce_db

# Nhập password: learner_password_123
```

Hoặc qua Docker:
```bash
docker exec -it sql-learning-mysql mysql -u sqllearner -p ecommerce_db
```

### Option 5: VS Code Extension

1. Install extension: **MySQL** (by Jun Han)
2. Click MySQL icon ở sidebar
3. Click **"+"** để add connection
4. Điền thông tin như trên
5. Kết nối và bắt đầu query

## Bước 5: Verify Database

Sau khi kết nối, chạy các câu SQL sau để verify:

### Kiểm Tra Các Bảng
```sql
-- Xem tất cả bảng
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
```

### Đếm Records
```sql
-- Đếm số lượng records mỗi bảng
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
| order_items |   500+ |
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
SELECT * FROM orders ORDER BY created_at DESC LIMIT 5;
```

Nếu bạn thấy dữ liệu → **Setup thành công!** 🎉

## Các Lệnh Docker Hữu Ích

### Quản Lý Container

```bash
# Dừng MySQL container
docker-compose stop

# Khởi động lại
docker-compose start

# Restart
docker-compose restart

# Xem logs
docker-compose logs -f mysql

# Dừng và xóa container
docker-compose down

# Dừng và xóa cả volumes (xóa data)
docker-compose down -v
```

### Truy Cập MySQL Shell

```bash
# Truy cập MySQL shell với user root
docker exec -it sql-learning-mysql mysql -u root -p
# Password: root_password_123

# Hoặc với user sqllearner
docker exec -it sql-learning-mysql mysql -u sqllearner -p ecommerce_db
# Password: learner_password_123
```

### Backup Database

```bash
# Backup toàn bộ database
docker exec sql-learning-mysql mysqldump -u sqllearner -plearner_password_123 ecommerce_db > backup.sql

# Restore database
docker exec -i sql-learning-mysql mysql -u sqllearner -plearner_password_123 ecommerce_db < backup.sql
```

### Reset Database

Nếu muốn reset database về trạng thái ban đầu:

```bash
# Dừng và xóa container + volumes
docker-compose down -v

# Khởi động lại (sẽ tự động chạy lại init scripts)
docker-compose up -d
```

## Troubleshooting

### Port 3306 Đã Được Sử Dụng

**Lỗi:**
```
Error: Port 3306 is already in use
```

**Giải pháp 1:** Dừng MySQL đang chạy trên hệ thống
```bash
# macOS
brew services stop mysql

# Windows
# Dừng MySQL service trong Services

# Linux
sudo systemctl stop mysql
```

**Giải pháp 2:** Đổi port trong `.env`
```bash
# Mở file .env và sửa
MYSQL_PORT=3307  # Thay vì 3306
```

Sau đó restart container:
```bash
docker-compose down
docker-compose up -d
```

Kết nối với port mới: `localhost:3307`

### Container Không Khởi Động

```bash
# Xem logs để debug
docker-compose logs mysql

# Kiểm tra container
docker ps -a

# Restart Docker Desktop
```

### Permission Denied (Linux)

```bash
# Thêm user vào docker group
sudo usermod -aG docker $USER

# Logout và login lại
```

### MySQL Client Không Kết Nối Được

1. Kiểm tra container đang chạy: `docker ps`
2. Kiểm tra port: `netstat -an | grep 3306`
3. Ping localhost: `ping localhost`
4. Thử kết nối qua command line trước
5. Check firewall settings

## Lưu Ý Quan Trọng

⚠️ **Password trong .env**
- File `.env` chứa passwords
- Không commit file này lên Git public repo
- Đã thêm `.env` vào `.gitignore`

⚠️ **Data Persistence**
- Data được lưu trong Docker volumes
- Chạy `docker-compose down -v` sẽ **XÓA DATA**
- Backup trước khi xóa volumes

⚠️ **RAM Usage**
- MySQL container dùng ~400MB RAM
- Đóng Docker Desktop khi không dùng để tiết kiệm RAM

## Tổng Kết

Sau khi hoàn thành setup:

✅ Docker Desktop đã cài và chạy
✅ MySQL container đã khởi động
✅ Database client đã kết nối thành công
✅ Database có đầy đủ 7 bảng và 1000+ records

**Bạn đã sẵn sàng bắt đầu học SQL!** 🚀

## Tiếp Theo

➡️ [Level 1: Beginner](level-1-beginner/README.md) - Bắt đầu học SELECT cơ bản

Hoặc xem lại:

⬅️ [Giới Thiệu SQL](00-gioi-thieu.md) - Tổng quan về SQL
