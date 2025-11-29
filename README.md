# SQL Cơ Bản đến Nâng Cao 🚀

Chào mừng bạn đến với khóa học SQL toàn diện! Từ cơ bản đến nâng cao với database E-commerce thực tế.

## 📚 Giới Thiệu

Khóa học này được thiết kế để giúp bạn:
- **Học SQL từ con số 0** - Không cần kiến thức nền tảng
- **Thực hành với database thực tế** - E-commerce với 1000+ records
- **Tiến bộ theo lộ trình rõ ràng** - 4 levels từ Beginner đến Expert
- **70+ bài tập thực hành** - Kèm đáp án chi tiết

## 🎯 Ai Nên Học Khóa Này?

✅ **Newbie** muốn học SQL từ đầu
✅ **Web Developers** cần làm việc với database
✅ **Data Analysts** muốn nâng cao kỹ năng SQL
✅ **Students** cần học SQL cho môn học/đồ án
✅ **Anyone** muốn hiểu cách database hoạt động

## 🗺️ Lộ Trình Học (4 Levels)

### Level 1: Beginner (Cơ Bản) 🌱
**Thời gian:** 2-3 tuần
**Nội dung:**
- SELECT, WHERE, DISTINCT
- ORDER BY, LIMIT
- Operators (AND, OR, IN, BETWEEN, LIKE)
- NULL handling

**Bài tập:** 15 exercises

### Level 2: Intermediate (Trung Cấp) 📈
**Thời gian:** 3-4 tuần
**Nội dung:**
- JOIN (INNER, LEFT, RIGHT)
- GROUP BY, HAVING
- Aggregate Functions (COUNT, SUM, AVG, MAX, MIN)
- String & Date Functions

**Bài tập:** 20 exercises

### Level 3: Advanced (Nâng Cao) 🎓
**Thời gian:** 4-5 tuần
**Nội dung:**
- Subqueries
- UNION, CASE WHEN
- Window Functions (ROW_NUMBER, RANK, LAG, LEAD)
- CTEs (Common Table Expressions)

**Bài tập:** 20 exercises

### Level 4: Expert (Chuyên Gia) 🏆
**Thời gian:** 3-4 tuần
**Nội dung:**
- Indexes & Performance Optimization
- Transactions (ACID)
- Stored Procedures & Functions
- Views & Database Design

**Bài tập:** 15 exercises

## 🐳 Database E-commerce

Bạn sẽ làm việc với một database E-commerce hoàn chỉnh:

**7 Tables:**
- `customers` - 100 khách hàng
- `categories` - 10 danh mục sản phẩm
- `products` - 50 sản phẩm (Tiếng Việt)
- `orders` - 200 đơn hàng
- `order_items` - 500+ chi tiết đơn hàng
- `reviews` - 150 đánh giá sản phẩm
- `cart` - 50 giỏ hàng đang hoạt động

**Tổng cộng:** 1000+ records dữ liệu thực tế!

## 🚀 Quick Start

### Bước 1: Cài đặt Docker Desktop
```bash
# Download tại: https://www.docker.com/products/docker-desktop
```

### Bước 2: Clone repo (nếu có) hoặc download files
```bash
git clone <repository-url>
cd sql-basic
```

### Bước 3: Khởi động MySQL Database
```bash
docker-compose up -d
```

### Bước 4: Kết nối với Database

**Thông tin kết nối:**
- **Host:** localhost
- **Port:** 3306
- **Database:** ecommerce_db
- **Username:** sqllearner
- **Password:** learner_password_123

**Tools để connect:**
- MySQL Workbench (recommended)
- DBeaver
- TablePlus
- phpMyAdmin
- Command line: `mysql -h localhost -u sqllearner -p ecommerce_db`

### Bước 5: Verify Database

```sql
-- Kiểm tra các bảng
SHOW TABLES;

-- Đếm số records
SELECT
    (SELECT COUNT(*) FROM customers) as customers,
    (SELECT COUNT(*) FROM products) as products,
    (SELECT COUNT(*) FROM orders) as orders,
    (SELECT COUNT(*) FROM reviews) as reviews;
```

## 📖 Cách Sử Dụng

1. **Đọc lý thuyết** từng level theo thứ tự
2. **Thực hành** với bài tập kèm theo
3. **Tự làm trước** khi xem đáp án
4. **Thử nghiệm** các biến thể của câu query
5. **Lặp lại** cho đến khi thuộc

## 📂 Cấu Trúc Dự Án

```
sql-basic/
├── docker-compose.yml          # MySQL container
├── .env                        # Database config
├── docker/
│   └── init/
│       ├── 01-schema.sql       # Database structure
│       └── 02-seed-data.sql    # Mock data
├── sql/
│   ├── solutions/              # Đáp án bài tập
│   └── practice/               # File để bạn viết SQL
└── [Documentation files]       # Bạn đang đọc
```

## 💡 Tips Học Tập

✅ **Thực hành hàng ngày** - 30-60 phút/ngày
✅ **Tự viết query** - Đừng copy/paste
✅ **Thử nghiệm** - Thay đổi query để hiểu rõ hơn
✅ **Đọc lỗi** - Học từ error messages
✅ **Tham khảo docs** - MySQL official documentation
✅ **Join community** - Hỏi đáp khi gặp khó khăn

## 🎓 Sau Khóa Học Này

Bạn sẽ có thể:
- ✅ Viết SQL queries phức tạp tự tin
- ✅ Tối ưu hóa performance của queries
- ✅ Thiết kế database schemas hiệu quả
- ✅ Phân tích dữ liệu với SQL
- ✅ Chuẩn bị tốt cho các vai trò:
  - Backend Developer
  - Data Analyst
  - Database Administrator
  - Full-stack Developer

## 📚 Resources Bổ Sung

- [MySQL Official Docs](https://dev.mysql.com/doc/)
- [SQL Style Guide](https://www.sqlstyle.guide/)
- [W3Schools SQL](https://www.w3schools.com/sql/)
- [LeetCode Database Problems](https://leetcode.com/problemset/database/)

## 🤝 Contributing

Nếu bạn tìm thấy lỗi hoặc muốn đóng góp:
1. Open an issue
2. Submit a pull request
3. Share your feedback

## 📝 License

MIT License - Feel free to use for learning!

---

**Bắt đầu ngay:** [Giới Thiệu SQL](00-gioi-thieu.md) | [Hướng Dẫn Setup](00-huong-dan-setup.md)

**Happy Learning!** 🎉
