# Database Schema - E-commerce

## Tổng Quan

Database **ecommerce_db** gồm 7 bảng chính với 1000+ records.

## Entity Relationship Diagram (ERD)

```
┌─────────────┐       ┌──────────────┐       ┌─────────────┐
│  customers  │──────<│    orders    │>──────│ order_items │
└─────────────┘       └──────────────┘       └─────────────┘
      │                                              │
      │                                              │
      │                                              ▼
      │                                       ┌─────────────┐
      │                                       │  products   │
      │                                       └─────────────┘
      │                                              │
      │                                              │
      ▼                                              ▼
┌─────────────┐                              ┌─────────────┐
│   reviews   │                              │ categories  │
└─────────────┘                              └─────────────┘
      │
      ▼
┌─────────────┐
│    cart     │
└─────────────┘
```

## Tables Chi Tiết

### 1. customers (100 records)
Thông tin khách hàng

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary Key, Auto Increment |
| name | VARCHAR(100) | Tên khách hàng |
| email | VARCHAR(100) | Email (UNIQUE) |
| phone | VARCHAR(20) | Số điện thoại |
| address | VARCHAR(255) | Địa chỉ |
| city | VARCHAR(50) | Thành phố |
| created_at | TIMESTAMP | Ngày tạo |
| updated_at | TIMESTAMP | Ngày cập nhật |

**Indexes:** email, city, created_at

---

### 2. categories (10 records)
Danh mục sản phẩm

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary Key |
| name | VARCHAR(100) | Tên danh mục |
| description | TEXT | Mô tả |
| created_at | TIMESTAMP | Ngày tạo |

**Examples:** Thời trang nam, Thời trang nữ, Điện tử, Gia dụng, Sách...

---

### 3. products (50 records)
Sản phẩm

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary Key |
| name | VARCHAR(200) | Tên sản phẩm (Tiếng Việt) |
| category_id | INT | FK → categories.id |
| price | DECIMAL(10,2) | Giá (VNĐ) |
| stock | INT | Số lượng tồn kho |
| description | TEXT | Mô tả sản phẩm |
| image_url | VARCHAR(255) | URL hình ảnh |
| created_at | TIMESTAMP | Ngày tạo |
| updated_at | TIMESTAMP | Ngày cập nhật |

**Indexes:** category_id, price, stock, created_at

**Price Range:** 3,000 - 32,000,000 VNĐ

---

### 4. orders (200 records)
Đơn hàng

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary Key |
| customer_id | INT | FK → customers.id |
| total_amount | DECIMAL(12,2) | Tổng giá trị đơn |
| status | ENUM | pending, processing, shipped, delivered, cancelled |
| payment_method | ENUM | cash, credit_card, bank_transfer, momo, zalopay |
| shipping_address | VARCHAR(255) | Địa chỉ giao hàng |
| notes | TEXT | Ghi chú |
| created_at | TIMESTAMP | Ngày tạo |
| updated_at | TIMESTAMP | Ngày cập nhật |

**Indexes:** customer_id, status, created_at, total_amount

**Status Distribution:**
- delivered: ~170 orders
- shipped: ~10 orders
- processing: ~15 orders
- pending: ~3 orders
- cancelled: ~2 orders

---

### 5. order_items (500+ records)
Chi tiết đơn hàng

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary Key |
| order_id | INT | FK → orders.id |
| product_id | INT | FK → products.id |
| quantity | INT | Số lượng |
| price | DECIMAL(10,2) | Giá tại thời điểm mua |
| subtotal | DECIMAL(12,2) | Tự động: quantity * price |
| created_at | TIMESTAMP | Ngày tạo |

**Indexes:** order_id, product_id

---

### 6. reviews (150 records)
Đánh giá sản phẩm

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary Key |
| product_id | INT | FK → products.id |
| customer_id | INT | FK → customers.id |
| rating | INT | Đánh giá 1-5 sao |
| comment | TEXT | Bình luận |
| created_at | TIMESTAMP | Ngày tạo |

**Indexes:** product_id, customer_id, rating, created_at

**Constraint:** rating BETWEEN 1 AND 5

---

### 7. cart (50 records)
Giỏ hàng

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary Key |
| customer_id | INT | FK → customers.id |
| product_id | INT | FK → products.id |
| quantity | INT | Số lượng |
| added_at | TIMESTAMP | Thời gian thêm vào giỏ |

**Indexes:** customer_id, product_id

**Unique:** (customer_id, product_id) - 1 customer chỉ có 1 cart item cho 1 product

---

## Relationships

### One-to-Many

1. **customers → orders**
   - 1 customer có nhiều orders
   - `orders.customer_id` → `customers.id`

2. **orders → order_items**
   - 1 order có nhiều items
   - `order_items.order_id` → `orders.id`

3. **products → order_items**
   - 1 product xuất hiện trong nhiều order items
   - `order_items.product_id` → `products.id`

4. **categories → products**
   - 1 category có nhiều products
   - `products.category_id` → `categories.id`

5. **products → reviews**
   - 1 product có nhiều reviews
   - `reviews.product_id` → `products.id`

6. **customers → reviews**
   - 1 customer có nhiều reviews
   - `reviews.customer_id` → `customers.id`

### Many-to-Many

**customers ↔ products** (through cart)
- Customer có thể có nhiều products trong cart
- Product có thể trong cart của nhiều customers

**customers ↔ products** (through orders/order_items)
- Customer đã mua nhiều products
- Product đã được mua bởi nhiều customers

---

## Sample Queries

### Lấy Orders với Customer Info
```sql
SELECT o.id, c.name, o.total_amount, o.status
FROM orders o
JOIN customers c ON o.customer_id = c.id;
```

### Lấy Order Items với Product Info
```sql
SELECT oi.*, p.name, p.price
FROM order_items oi
JOIN products p ON oi.product_id = p.id
WHERE oi.order_id = 1;
```

### Products với Category Name
```sql
SELECT p.name, c.name as category, p.price
FROM products p
JOIN categories c ON p.category_id = c.id;
```

### Products với Average Rating
```sql
SELECT p.name, AVG(r.rating) as avg_rating, COUNT(r.id) as review_count
FROM products p
LEFT JOIN reviews r ON p.id = r.product_id
GROUP BY p.id;
```

---

⬅️ [Quay lại Phụ Lục](README.md)
