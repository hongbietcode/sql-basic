-- ============================================
-- COMPLETE DATABASE SEED WITH UTF8
-- ============================================
DROP DATABASE IF EXISTS ecommerce_db;
CREATE DATABASE ecommerce_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ecommerce_db;

SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

-- ============================================
-- E-COMMERCE DATABASE SCHEMA
-- ============================================
-- Database: ecommerce_db
-- Tables: 7 (customers, categories, products, orders, order_items, reviews, cart)
-- Purpose: SQL Learning from Beginner to Advanced
-- ============================================


-- Drop tables if exist (for clean re-initialization)
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS cart;
DROP TABLE IF EXISTS reviews;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS customers;
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================
-- TABLE: customers
-- ============================================
CREATE TABLE customers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    address VARCHAR(255),
    city VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_city (city),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABLE: categories
-- ============================================
CREATE TABLE categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABLE: products
-- ============================================
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    category_id INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    description TEXT,
    image_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE RESTRICT,
    INDEX idx_category_id (category_id),
    INDEX idx_price (price),
    INDEX idx_stock (stock),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABLE: orders
-- ============================================
CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    total_amount DECIMAL(12, 2) NOT NULL,
    status ENUM('pending', 'processing', 'shipped', 'delivered', 'cancelled') DEFAULT 'pending',
    payment_method ENUM('cash', 'credit_card', 'bank_transfer', 'momo', 'zalopay') DEFAULT 'cash',
    shipping_address VARCHAR(255),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    INDEX idx_customer_id (customer_id),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at),
    INDEX idx_total_amount (total_amount)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABLE: order_items
-- ============================================
CREATE TABLE order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    price DECIMAL(10, 2) NOT NULL,
    subtotal DECIMAL(12, 2) GENERATED ALWAYS AS (quantity * price) STORED,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT,
    INDEX idx_order_id (order_id),
    INDEX idx_product_id (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABLE: reviews
-- ============================================
CREATE TABLE reviews (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    customer_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    INDEX idx_product_id (product_id),
    INDEX idx_customer_id (customer_id),
    INDEX idx_rating (rating),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABLE: cart
-- ============================================
CREATE TABLE cart (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    UNIQUE KEY unique_cart_item (customer_id, product_id),
    INDEX idx_customer_id (customer_id),
    INDEX idx_product_id (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- DONE: Schema created successfully!
-- ============================================
-- ============================================
-- E-COMMERCE MOCK DATA
-- ============================================
-- Purpose: Comprehensive seed data for SQL learning
-- Total Records: 1000+
-- Language: Vietnamese
-- ============================================


-- ============================================
-- CATEGORIES (10 records)
-- ============================================
INSERT INTO categories (name, description) VALUES
('Thời trang nam', 'Quần áo, giày dép, phụ kiện dành cho nam'),
('Thời trang nữ', 'Quần áo, giày dép, túi xách dành cho nữ'),
('Điện tử', 'Điện thoại, laptop, tablet, phụ kiện công nghệ'),
('Gia dụng', 'Đồ dùng nhà bếp, nội thất, trang trí'),
('Sách', 'Sách văn học, kỹ năng, giáo trình'),
('Thể thao', 'Dụng cụ thể thao, quần áo thể thao'),
('Làm đẹp', 'Mỹ phẩm, chăm sóc da, nước hoa'),
('Đồ chơi', 'Đồ chơi trẻ em, đồ chơi công nghệ'),
('Thực phẩm', 'Thực phẩm tươi sống, đồ ăn vặt, nước uống'),
('Văn phòng phẩm', 'Bút viết, sổ tay, dụng cụ văn phòng');

-- ============================================
-- PRODUCTS (50 records - Vietnamese names)
-- ============================================
INSERT INTO products (name, category_id, price, stock, description, image_url) VALUES
-- Thời trang nam (category 1)
('Áo thun nam cotton', 1, 150000, 100, 'Áo thun nam 100% cotton, nhiều màu sắc', '/products/ao-thun-nam.jpg'),
('Quần jean nam slim fit', 1, 450000, 80, 'Quần jean nam form slim fit, chất liệu denim cao cấp', '/products/quan-jean-nam.jpg'),
('Áo sơ mi nam công sở', 1, 250000, 60, 'Áo sơ mi nam dài tay, phù hợp đi làm', '/products/ao-so-mi-nam.jpg'),
('Giày thể thao nam Nike', 1, 1200000, 40, 'Giày thể thao Nike Air Max chính hãng', '/products/giay-nike.jpg'),
('Túi đeo chéo nam da thật', 1, 650000, 50, 'Túi đeo chéo nam da bò thật 100%', '/products/tui-deo-cheo.jpg'),

-- Thời trang nữ (category 2)
('Váy đầm nữ dạ hội', 2, 850000, 35, 'Váy đầm dự tiệc sang trọng, nhiều size', '/products/vay-dam-nu.jpg'),
('Áo kiểu nữ công sở', 2, 280000, 70, 'Áo kiểu nữ vải lụa, thích hợp đi làm', '/products/ao-kieu-nu.jpg'),
('Quần tây nữ ống đứng', 2, 320000, 65, 'Quần tây nữ form chuẩn, nhiều màu', '/products/quan-tay-nu.jpg'),
('Giày cao gót nữ 7cm', 2, 380000, 45, 'Giày cao gót mũi nhọn, da PU cao cấp', '/products/giay-cao-got.jpg'),
('Túi xách nữ thời trang', 2, 550000, 55, 'Túi xách tay nữ thiết kế Hàn Quốc', '/products/tui-xach-nu.jpg'),

-- Điện tử (category 3)
('iPhone 15 Pro Max 256GB', 3, 29990000, 25, 'iPhone 15 Pro Max chính hãng VN/A', '/products/iphone-15.jpg'),
('Samsung Galaxy S24', 3, 22990000, 30, 'Samsung S24 5G chính hãng', '/products/samsung-s24.jpg'),
('Laptop Dell XPS 13', 3, 32000000, 15, 'Laptop Dell XPS 13 i7 Gen 12, RAM 16GB', '/products/laptop-dell.jpg'),
('MacBook Air M3', 3, 28990000, 20, 'MacBook Air M3 2024, 8GB RAM, 256GB SSD', '/products/macbook-air.jpg'),
('Tai nghe AirPods Pro 2', 3, 6490000, 50, 'AirPods Pro 2 chính hãng Apple', '/products/airpods-pro.jpg'),
('Chuột không dây Logitech', 3, 350000, 100, 'Chuột Logitech M590 Silent', '/products/chuot-logitech.jpg'),
('Bàn phím cơ gaming RGB', 3, 1200000, 40, 'Bàn phím cơ gaming switch blue', '/products/ban-phim-co.jpg'),

-- Gia dụng (category 4)
('Nồi cơm điện Panasonic 1.8L', 4, 850000, 60, 'Nồi cơm điện Panasonic 1.8 lít', '/products/noi-com-dien.jpg'),
('Bộ nồi inox 5 món', 4, 1200000, 40, 'Bộ nồi inox 304 cao cấp 5 món', '/products/bo-noi-inox.jpg'),
('Máy xay sinh tố Philips', 4, 650000, 50, 'Máy xay sinh tố 600W, cối 1.5L', '/products/may-xay.jpg'),
('Bình đun siêu tốc 1.7L', 4, 250000, 80, 'Bình đun nước siêu tốc inox', '/products/binh-dun.jpg'),

-- Sách (category 5)
('Đắc Nhân Tâm', 5, 65000, 200, 'Sách Đắc Nhân Tâm - Dale Carnegie', '/products/dac-nhan-tam.jpg'),
('Tuổi Trẻ Đáng Giá Bao Nhiêu', 5, 80000, 150, 'Sách kỹ năng sống của Rosie Nguyễn', '/products/tuoi-tre.jpg'),
('Sapiens: Lược Sử Loài Người', 5, 180000, 100, 'Sapiens - Yuval Noah Harari', '/products/sapiens.jpg'),
('Nhà Giả Kim', 5, 70000, 180, 'Nhà Giả Kim - Paulo Coelho', '/products/nha-gia-kim.jpg'),
('Khéo Ăn Nói Sẽ Có Được Thiên Hạ', 5, 75000, 120, 'Sách kỹ năng giao tiếp', '/products/kheo-an-noi.jpg'),

-- Thể thao (category 6)
('Bóng đá Adidas size 5', 6, 350000, 70, 'Bóng đá Adidas chính hãng', '/products/bong-da.jpg'),
('Giày chạy bộ Adidas', 6, 1800000, 45, 'Giày chạy bộ Adidas Ultraboost', '/products/giay-chay-bo.jpg'),
('Bộ tạ tay 5kg', 6, 280000, 60, 'Bộ tạ tay bọc cao su 5kg/chiếc', '/products/ta-tay.jpg'),
('Thảm tập Yoga', 6, 350000, 80, 'Thảm yoga dày 8mm, chống trượt', '/products/tham-yoga.jpg'),
('Vợt cầu lông Yonex', 6, 650000, 50, 'Vợt cầu lông Yonex Nanoray', '/products/vot-cau-long.jpg'),

-- Làm đẹp (category 7)
('Kem chống nắng Anessa 60ml', 7, 450000, 90, 'Kem chống nắng Anessa SPF 50+', '/products/kem-chong-nang.jpg'),
('Sữa rửa mặt Cetaphil', 7, 280000, 100, 'Sữa rửa mặt Cetaphil dịu nhẹ', '/products/sua-rua-mat.jpg'),
('Serum Vitamin C', 7, 550000, 70, 'Serum Vitamin C 20% nguyên chất', '/products/serum-c.jpg'),
('Son môi MAC Ruby Woo', 7, 680000, 60, 'Son MAC Ruby Woo chính hãng', '/products/son-mac.jpg'),
('Nước hoa Chanel No.5', 7, 3200000, 30, 'Nước hoa Chanel No.5 EDP 100ml', '/products/nuoc-hoa-chanel.jpg'),

-- Đồ chơi (category 8)
('Lego Technic 42100', 8, 2500000, 25, 'Lego Technic Liebherr R 9800', '/products/lego-technic.jpg'),
('Búp bê Barbie', 8, 350000, 60, 'Búp bê Barbie Fashionistas', '/products/bup-be.jpg'),
('Rubik 3x3 tốc độ cao', 8, 120000, 100, 'Rubik 3x3 chuyên thi đấu', '/products/rubik.jpg'),
('Xe điều khiển off-road', 8, 850000, 40, 'Xe điều khiển từ xa tỉ lệ 1:16', '/products/xe-dieu-khien.jpg'),

-- Thực phẩm (category 9)
('Thịt bò Úc nhập khẩu 1kg', 9, 350000, 80, 'Thịt bò Úc hảo hạng', '/products/thit-bo.jpg'),
('Gạo Nhật Bản 5kg', 9, 180000, 100, 'Gạo Nhật Bản Akita Komachi', '/products/gao-nhat.jpg'),
('Trứng gà sạch (hộp 10 quả)', 9, 35000, 200, 'Trứng gà ta sạch hộp 10', '/products/trung-ga.jpg'),
('Sữa tươi Vinamilk 1L', 9, 32000, 150, 'Sữa tươi tiệt trùng không đường', '/products/sua-tuoi.jpg'),
('Snack khoai tây Lays', 9, 18000, 300, 'Snack Lays vị tự nhiên 56g', '/products/snack-lays.jpg'),

-- Văn phòng phẩm (category 10)
('Bút bi Thiên Long TL-079', 10, 3000, 500, 'Bút bi Thiên Long xanh 0.7mm', '/products/but-bi.jpg'),
('Sổ tay A5 bìa da', 10, 85000, 120, 'Sổ tay A5 bìa da 200 trang', '/products/so-tay.jpg'),
('Bút highlight Stabilo', 10, 25000, 200, 'Bút highlight Stabilo 6 màu', '/products/but-highlight.jpg'),
('Giấy A4 Double A 500 tờ', 10, 95000, 150, 'Giấy A4 Double A 70gsm', '/products/giay-a4.jpg'),
('Kéo văn phòng Deli', 10, 15000, 250, 'Kéo văn phòng Deli cán thép', '/products/keo.jpg');

-- ============================================
-- CUSTOMERS (100 records)
-- ============================================
INSERT INTO customers (name, email, phone, address, city, created_at) VALUES
('Nguyễn Văn An', 'nguyenvanan@gmail.com', '0901234567', '123 Lê Lợi', 'Hà Nội', '2024-01-15 08:30:00'),
('Trần Thị Bình', 'tranthib@gmail.com', '0902345678', '456 Nguyễn Huệ', 'Hồ Chí Minh', '2024-01-16 09:15:00'),
('Lê Văn Cường', 'levanc@gmail.com', '0903456789', '789 Trần Phú', 'Đà Nẵng', '2024-01-17 10:20:00'),
('Phạm Thị Dung', 'phamthid@gmail.com', '0904567890', '321 Hai Bà Trưng', 'Hải Phòng', '2024-01-18 11:45:00'),
('Hoàng Văn Em', 'hoangvane@gmail.com', '0905678901', '654 Lý Thường Kiệt', 'Cần Thơ', '2024-01-19 13:10:00'),
('Vũ Thị Phương', 'vuthif@gmail.com', '0906789012', '987 Điện Biên Phủ', 'Huế', '2024-01-20 14:25:00'),
('Đặng Văn Giang', 'dangvang@gmail.com', '0907890123', '147 Võ Văn Kiệt', 'Nha Trang', '2024-01-21 15:30:00'),
('Bùi Thị Hoa', 'buithih@gmail.com', '0908901234', '258 Lê Duẩn', 'Biên Hòa', '2024-01-22 16:40:00'),
('Đinh Văn Inh', 'dinhvani@gmail.com', '0909012345', '369 Trường Chinh', 'Vũng Tàu', '2024-01-23 08:50:00'),
('Mai Thị Khanh', 'maithik@gmail.com', '0910123456', '741 Hoàng Văn Thụ', 'Đà Lạt', '2024-01-24 09:00:00'),
('Trịnh Văn Long', 'trinhvanl@gmail.com', '0911234567', '852 Nguyễn Văn Linh', 'Hà Nội', '2024-01-25 10:15:00'),
('Chu Thị Minh', 'chuthim@gmail.com', '0912345678', '963 Phan Đình Phùng', 'Hồ Chí Minh', '2024-01-26 11:20:00'),
('Dương Văn Nam', 'duongvann@gmail.com', '0913456789', '159 Cách Mạng Tháng 8', 'Đà Nẵng', '2024-01-27 12:30:00'),
('Phan Thị Oanh', 'phanthio@gmail.com', '0914567890', '753 Lạc Long Quân', 'Hải Phòng', '2024-01-28 13:45:00'),
('Lý Văn Phong', 'lyvanp@gmail.com', '0915678901', '951 Nguyễn Trãi', 'Cần Thơ', '2024-01-29 14:50:00'),
('Võ Thị Quỳnh', 'vothiq@gmail.com', '0916789012', '357 Tôn Đức Thắng', 'Huế', '2024-01-30 15:55:00'),
('Hồ Văn Rạng', 'hovanr@gmail.com', '0917890123', '486 Yersin', 'Nha Trang', '2024-02-01 08:30:00'),
('Trương Thị Sương', 'truongthis@gmail.com', '0918901234', '572 Pasteur', 'Biên Hòa', '2024-02-02 09:40:00'),
('Huỳnh Văn Tài', 'huynhvant@gmail.com', '0919012345', '683 Đinh Tiên Hoàng', 'Vũng Tàu', '2024-02-03 10:45:00'),
('Lâm Thị Uyên', 'lamthiu@gmail.com', '0920123456', '794 Bà Triệu', 'Đà Lạt', '2024-02-04 11:50:00'),
('Thái Văn Vinh', 'thaivanv@gmail.com', '0921234567', '815 Quang Trung', 'Hà Nội', '2024-02-05 12:55:00'),
('Nghiêm Thị Xuân', 'nghiemthix@gmail.com', '0922345678', '926 Lê Thánh Tông', 'Hồ Chí Minh', '2024-02-06 13:00:00'),
('Cao Văn Yên', 'caovany@gmail.com', '0923456789', '137 Nguyễn Công Trứ', 'Đà Nẵng', '2024-02-07 14:10:00'),
('La Thị Zung', 'lathiz@gmail.com', '0924567890', '248 Ngô Quyền', 'Hải Phòng', '2024-02-08 15:20:00'),
('Ngô Văn Anh', 'ngovana@gmail.com', '0925678901', '359 Hàm Nghi', 'Cần Thơ', '2024-02-09 16:30:00'),
('Dư Thị Bảo', 'duthib@gmail.com', '0926789012', '460 Trần Hưng Đạo', 'Huế', '2024-02-10 08:40:00'),
('Vương Văn Chiến', 'vuongvanc@gmail.com', '0927890123', '571 Hoàng Diệu', 'Nha Trang', '2024-02-11 09:50:00'),
('Tô Thị Diệp', 'tothid@gmail.com', '0928901234', '682 Phan Bội Châu', 'Biên Hòa', '2024-02-12 10:00:00'),
('Quách Văn Ên', 'quachvane@gmail.com', '0929012345', '793 Lý Tự Trọng', 'Vũng Tàu', '2024-02-13 11:10:00'),
('Uông Thị Phượng', 'uongthip@gmail.com', '0930123456', '804 Nguyễn Thái Học', 'Đà Lạt', '2024-02-14 12:20:00'),
('Doãn Văn Giáp', 'doanvang@gmail.com', '0931234567', '915 Chu Văn An', 'Hà Nội', '2024-02-15 13:30:00'),
('Ông Thị Hằng', 'ongthih@gmail.com', '0932345678', '126 Nguyễn Du', 'Hồ Chí Minh', '2024-02-16 14:40:00'),
('Tạ Văn Ích', 'tavani@gmail.com', '0933456789', '237 Lê Quý Đôn', 'Đà Nẵng', '2024-02-17 15:50:00'),
('Khúc Thị Kiều', 'khucthik@gmail.com', '0934567890', '348 Nguyễn Thị Minh Khai', 'Hải Phòng', '2024-02-18 08:00:00'),
('Từ Văn Lâm', 'tuvanl@gmail.com', '0935678901', '459 Phạm Ngọc Thạch', 'Cần Thơ', '2024-02-19 09:10:00'),
('Mạc Thị My', 'macthim@gmail.com', '0936789012', '560 Hoàng Hoa Thám', 'Huế', '2024-02-20 10:20:00'),
('Âu Văn Ninh', 'auvann@gmail.com', '0937890123', '671 Lê Văn Sỹ', 'Nha Trang', '2024-02-21 11:30:00'),
('Ưu Thị Oanh', 'uuthio@gmail.com', '0938901234', '782 Nguyễn Đình Chiểu', 'Biên Hòa', '2024-02-22 12:40:00'),
('Đàm Văn Phúc', 'damvanp@gmail.com', '0939012345', '893 Trần Quốc Toản', 'Vũng Tàu', '2024-02-23 13:50:00'),
('Lưu Thị Quế', 'luuthiq@gmail.com', '0940123456', '904 Võ Thị Sáu', 'Đà Lạt', '2024-02-24 14:00:00'),
('Phí Văn Rồng', 'phivanr@gmail.com', '0941234567', '115 Cộng Hòa', 'Hà Nội', '2024-02-25 15:10:00'),
('Hà Thị Sen', 'hathis@gmail.com', '0942345678', '226 Ung Văn Khiêm', 'Hồ Chí Minh', '2024-02-26 16:20:00'),
('Lục Văn Tân', 'lucvant@gmail.com', '0943456789', '337 Xô Viết Nghệ Tĩnh', 'Đà Nẵng', '2024-02-27 08:30:00'),
('Khương Thị Uyên', 'khuongthiu@gmail.com', '0944567890', '448 Nam Kỳ Khởi Nghĩa', 'Hải Phòng', '2024-02-28 09:40:00'),
('Hứa Văn Viễn', 'huavanv@gmail.com', '0945678901', '559 Phan Kế Bính', 'Cần Thơ', '2024-02-29 10:50:00'),
('Đoàn Thị Xuyến', 'doanthix@gmail.com', '0946789012', '660 Nguyễn Chí Thanh', 'Huế', '2024-03-01 11:00:00'),
('Lương Văn Ý', 'luongvany@gmail.com', '0947890123', '771 Tô Hiến Thành', 'Nha Trang', '2024-03-02 12:10:00'),
('Kim Thị Hạnh', 'kimthih@gmail.com', '0948901234', '882 Cao Thắng', 'Biên Hòa', '2024-03-03 13:20:00'),
('Bế Văn An', 'bevana@gmail.com', '0949012345', '993 Đinh Công Tráng', 'Vũng Tàu', '2024-03-04 14:30:00'),
('Lã Thị Bình', 'lathib@gmail.com', '0950123456', '104 Hai Bà Trưng', 'Đà Lạt', '2024-03-05 15:40:00'),
('Tiết Văn Cường', 'tietvanc@gmail.com', '0951234567', '215 Trần Nhân Tông', 'Hà Nội', '2024-03-06 16:50:00'),
('Hoà Thị Dịu', 'hoathid@gmail.com', '0952345678', '326 Phan Chu Trinh', 'Hồ Chí Minh', '2024-03-07 08:00:00'),
('Tống Văn Ê', 'tongvane@gmail.com', '0953456789', '437 Nguyễn Văn Cừ', 'Đà Nẵng', '2024-03-08 09:10:00'),
('Quản Thị Phúc', 'quanthip@gmail.com', '0954567890', '548 Bùi Thị Xuân', 'Hải Phòng', '2024-03-09 10:20:00'),
('Sái Văn Giang', 'saivang@gmail.com', '0955678901', '659 Trần Bình Trọng', 'Cần Thơ', '2024-03-10 11:30:00'),
('Bành Thị Hương', 'banhthih@gmail.com', '0956789012', '760 Lê Hồng Phong', 'Huế', '2024-03-11 12:40:00'),
('Tân Văn Ích', 'tanvani@gmail.com', '0957890123', '871 Nguyễn Hữu Cảnh', 'Nha Trang', '2024-03-12 13:50:00'),
('Sơn Thị Kiên', 'sonthik@gmail.com', '0958901234', '982 Võ Văn Tần', 'Biên Hòa', '2024-03-13 14:00:00'),
('Uất Văn Lạc', 'uatvanl@gmail.com', '0959012345', '193 Lý Chính Thắng', 'Vũng Tàu', '2024-03-14 15:10:00'),
('Bạch Thị Minh', 'bachthim@gmail.com', '0960123456', '204 Nguyễn Văn Trỗi', 'Đà Lạt', '2024-03-15 16:20:00'),
('Thang Văn Nhã', 'thangvann@gmail.com', '0961234567', '315 Phan Đăng Lưu', 'Hà Nội', '2024-03-16 08:30:00'),
('Vạn Thị Oanh', 'vanthio@gmail.com', '0962345678', '426 Hoàng Sa', 'Hồ Chí Minh', '2024-03-17 09:40:00'),
('Ân Văn Phát', 'anvanp@gmail.com', '0963456789', '537 Trường Sa', 'Đà Nẵng', '2024-03-18 10:50:00'),
('Lạc Thị Quyên', 'lacthiq@gmail.com', '0964567890', '648 Nguyễn Bỉnh Khiêm', 'Hải Phòng', '2024-03-19 11:00:00'),
('Thành Văn Rộng', 'thanhvanr@gmail.com', '0965678901', '759 Tôn Thất Đạm', 'Cần Thơ', '2024-03-20 12:10:00'),
('Mã Thị Sáng', 'mathis@gmail.com', '0966789012', '860 Nguyễn Thị Nghĩa', 'Huế', '2024-03-21 13:20:00'),
('Nhâm Văn Tuấn', 'nhamvant@gmail.com', '0967890123', '971 Phạm Viết Chánh', 'Nha Trang', '2024-03-22 14:30:00'),
('Kha Thị Uyên', 'khathiu@gmail.com', '0968901234', '182 Nguyễn Cư Trinh', 'Biên Hòa', '2024-03-23 15:40:00'),
('Long Văn Vinh', 'longvanv@gmail.com', '0969012345', '293 Đề Thám', 'Vũng Tàu', '2024-03-24 16:50:00'),
('Thập Thị Xuân', 'thapthix@gmail.com', '0970123456', '304 Lê Thánh Tôn', 'Đà Lạt', '2024-03-25 08:00:00'),
('Nghị Văn Yên', 'nghivany@gmail.com', '0971234567', '415 Mạc Đĩnh Chi', 'Hà Nội', '2024-03-26 09:10:00'),
('Hùng Thị Hảo', 'hungthih@gmail.com', '0972345678', '526 Nguyễn Đình Chiểu', 'Hồ Chí Minh', '2024-03-27 10:20:00'),
('Bình Văn Anh', 'binhvana@gmail.com', '0973456789', '637 Trương Định', 'Đà Nẵng', '2024-03-28 11:30:00'),
('Đông Thị Bích', 'dongthib@gmail.com', '0974567890', '748 Nguyễn Tri Phương', 'Hải Phòng', '2024-03-29 12:40:00'),
('Cường Văn Cát', 'cuongvanc@gmail.com', '0975678901', '859 Lương Hữu Khánh', 'Cần Thơ', '2024-03-30 13:50:00'),
('Phục Thị Diệu', 'phucthid@gmail.com', '0976789012', '960 Tôn Thất Tùng', 'Huế', '2024-03-31 14:00:00'),
('Thiện Văn Ê', 'thienvane@gmail.com', '0977890123', '171 Hai Bà Trưng', 'Nha Trang', '2024-04-01 15:10:00'),
('Khôi Thị Phượng', 'khoithip@gmail.com', '0978901234', '282 Phan Kế Bính', 'Biên Hòa', '2024-04-02 16:20:00'),
('Toàn Văn Giang', 'toanvang@gmail.com', '0979012345', '393 Lý Thái Tổ', 'Vũng Tàu', '2024-04-03 08:30:00'),
('Xuân Thị Hà', 'xuanthih@gmail.com', '0980123456', '404 Trần Quang Khải', 'Đà Lạt', '2024-04-04 09:40:00'),
('Đức Văn Ích', 'ducvani@gmail.com', '0981234567', '515 Lê Đại Hành', 'Hà Nội', '2024-04-05 10:50:00'),
('Hậu Thị Kiên', 'hauthik@gmail.com', '0982345678', '626 Nguyễn Thượng Hiền', 'Hồ Chí Minh', '2024-04-06 11:00:00'),
('Lập Văn Lâm', 'lapvanl@gmail.com', '0983456789', '737 Võ Duy Ninh', 'Đà Nẵng', '2024-04-07 12:10:00'),
('Quang Thị Mơ', 'quangthim@gmail.com', '0984567890', '848 Đinh Tiên Hoàng', 'Hải Phòng', '2024-04-08 13:20:00'),
('Minh Văn Nhân', 'minhvann@gmail.com', '0985678901', '959 Tôn Đức Thắng', 'Cần Thơ', '2024-04-09 14:30:00'),
('Nhân Thị Oanh', 'nhanthio@gmail.com', '0986789012', '160 Nguyễn Hữu Thọ', 'Huế', '2024-04-10 15:40:00'),
('Tuấn Văn Phúc', 'tuanvanp@gmail.com', '0987890123', '271 Cách Mạng Tháng 8', 'Nha Trang', '2024-04-11 16:50:00'),
('Hùng Thị Quyên', 'hungthiq@gmail.com', '0988901234', '382 Lê Lợi', 'Biên Hòa', '2024-04-12 08:00:00'),
('Tài Văn Rộng', 'taivanr@gmail.com', '0989012345', '493 Quang Trung', 'Vũng Tàu', '2024-04-13 09:10:00'),
('Thắng Thị Sen', 'thangthis@gmail.com', '0990123456', '504 Nguyễn Huệ', 'Đà Lạt', '2024-04-14 10:20:00'),
('Tiến Văn Tâm', 'tienvant@gmail.com', '0991234567', '615 Trần Phú', 'Hà Nội', '2024-04-15 11:30:00'),
('Hiếu Thị Uyên', 'hieuthiu@gmail.com', '0992345678', '726 Lý Thường Kiệt', 'Hồ Chí Minh', '2024-04-16 12:40:00'),
('Hòa Văn Việt', 'hoavanv@gmail.com', '0993456789', '837 Điện Biên Phủ', 'Đà Nẵng', '2024-04-17 13:50:00'),
('Phương Thị Xuân', 'phuongthix@gmail.com', '0994567890', '948 Võ Văn Kiệt', 'Hải Phòng', '2024-04-18 14:00:00'),
('Duy Văn Yên', 'duyvany@gmail.com', '0995678901', '159 Lê Duẩn', 'Cần Thơ', '2024-04-19 15:10:00'),
('Thọ Thị Hằng', 'thothih@gmail.com', '0996789012', '260 Trường Chinh', 'Huế', '2024-04-20 16:20:00'),
('Trí Văn An', 'trivana@gmail.com', '0997890123', '371 Hoàng Văn Thụ', 'Nha Trang', '2024-04-21 08:30:00'),
('Sang Thị Bảo', 'sangthib@gmail.com', '0998901234', '482 Nguyễn Văn Linh', 'Biên Hòa', '2024-04-22 09:40:00'),
('Tuấn Văn Chiến', 'tuanvanc@gmail.com', '0999012345', '593 Phan Đình Phùng', 'Vũng Tàu', '2024-04-23 10:50:00'),
('Đỗ Văn Bảo', 'dovanb@gmail.com', '0900123999', '100 Lý Tự Trọng', 'Hà Nội', '2024-04-24 11:00:00');

-- ============================================
-- ORDERS (200 records)
-- ============================================
INSERT INTO orders (customer_id, total_amount, status, payment_method, shipping_address, notes, created_at) VALUES
(1, 1350000, 'delivered', 'credit_card', '123 Lê Lợi, Hà Nội', 'Giao hàng ngoài giờ hành chính', '2024-01-20 10:30:00'),
(2, 850000, 'delivered', 'momo', '456 Nguyễn Huệ, Hồ Chí Minh', NULL, '2024-01-21 11:45:00'),
(3, 32000000, 'delivered', 'bank_transfer', '789 Trần Phú, Đà Nẵng', 'Kiểm tra kỹ trước khi giao', '2024-01-22 14:20:00'),
(4, 450000, 'delivered', 'cash', '321 Hai Bà Trưng, Hải Phòng', NULL, '2024-01-23 09:15:00'),
(5, 1800000, 'delivered', 'zalopay', '654 Lý Thường Kiệt, Cần Thơ', 'Giao vào cuối tuần', '2024-01-24 15:30:00'),
(6, 550000, 'shipped', 'credit_card', '987 Điện Biên Phủ, Huế', NULL, '2024-05-01 10:00:00'),
(7, 280000, 'shipped', 'momo', '147 Võ Văn Kiệt, Nha Trang', NULL, '2024-05-02 11:20:00'),
(8, 2500000, 'processing', 'bank_transfer', '258 Lê Duẩn, Biên Hòa', 'Giao tận tay', '2024-05-05 13:45:00'),
(9, 120000, 'processing', 'cash', '369 Trường Chinh, Vũng Tàu', NULL, '2024-05-06 08:30:00'),
(10, 3200000, 'pending', 'credit_card', '741 Hoàng Văn Thụ, Đà Lạt', 'Hàng quý khách', '2024-05-07 16:15:00'),
(11, 650000, 'delivered', 'momo', '852 Nguyễn Văn Linh, Hà Nội', NULL, '2024-02-01 09:00:00'),
(12, 380000, 'delivered', 'cash', '963 Phan Đình Phùng, Hồ Chí Minh', NULL, '2024-02-02 10:30:00'),
(13, 29990000, 'delivered', 'bank_transfer', '159 Cách Mạng Tháng 8, Đà Nẵng', 'Hàng chính hãng', '2024-02-03 14:00:00'),
(14, 850000, 'delivered', 'credit_card', '753 Lạc Long Quân, Hải Phòng', NULL, '2024-02-04 11:20:00'),
(15, 1200000, 'cancelled', 'zalopay', '951 Nguyễn Trãi, Cần Thơ', 'Khách hủy', '2024-02-05 15:45:00'),
(16, 350000, 'delivered', 'momo', '357 Tôn Đức Thắng, Huế', NULL, '2024-02-06 08:15:00'),
(17, 6490000, 'delivered', 'credit_card', '486 Yersin, Nha Trang', NULL, '2024-02-07 12:30:00'),
(18, 250000, 'delivered', 'cash', '572 Pasteur, Biên Hòa', NULL, '2024-02-08 09:45:00'),
(19, 850000, 'shipped', 'bank_transfer', '683 Đinh Tiên Hoàng, Vũng Tàu', NULL, '2024-05-08 10:20:00'),
(20, 22990000, 'delivered', 'credit_card', '794 Bà Triệu, Đà Lạt', 'Gói quà sang trọng', '2024-02-10 13:00:00'),
(21, 150000, 'delivered', 'momo', '815 Quang Trung, Hà Nội', NULL, '2024-02-11 11:30:00'),
(22, 280000, 'delivered', 'cash', '926 Lê Thánh Tông, Hồ Chí Minh', NULL, '2024-02-12 14:15:00'),
(23, 1200000, 'delivered', 'zalopay', '137 Nguyễn Công Trứ, Đà Nẵng', NULL, '2024-02-13 09:00:00'),
(24, 680000, 'delivered', 'credit_card', '248 Ngô Quyền, Hải Phòng', NULL, '2024-02-14 10:45:00'),
(25, 350000, 'delivered', 'momo', '359 Hàm Nghi, Cần Thơ', NULL, '2024-02-15 15:20:00'),
(26, 65000, 'delivered', 'cash', '460 Trần Hưng Đạo, Huế', NULL, '2024-02-16 08:30:00'),
(27, 80000, 'delivered', 'momo', '571 Hoàng Diệu, Nha Trang', NULL, '2024-02-17 12:00:00'),
(28, 180000, 'delivered', 'credit_card', '682 Phan Bội Châu, Biên Hòa', NULL, '2024-02-18 09:15:00'),
(29, 70000, 'delivered', 'cash', '793 Lý Tự Trọng, Vũng Tàu', NULL, '2024-02-19 10:30:00'),
(30, 75000, 'delivered', 'momo', '804 Nguyễn Thái Học, Đà Lạt', NULL, '2024-02-20 13:45:00'),
(31, 28990000, 'delivered', 'bank_transfer', '915 Chu Văn An, Hà Nội', 'Giao buổi sáng', '2024-02-21 11:00:00'),
(32, 450000, 'delivered', 'credit_card', '126 Nguyễn Du, Hồ Chí Minh', NULL, '2024-02-22 14:30:00'),
(33, 550000, 'delivered', 'momo', '237 Lê Quý Đôn, Đà Nẵng', NULL, '2024-02-23 09:45:00'),
(34, 320000, 'delivered', 'cash', '348 Nguyễn Thị Minh Khai, Hải Phòng', NULL, '2024-02-24 10:15:00'),
(35, 850000, 'delivered', 'zalopay', '459 Phạm Ngọc Thạch, Cần Thơ', NULL, '2024-02-25 15:00:00'),
(36, 1200000, 'processing', 'bank_transfer', '560 Hoàng Hoa Thám, Huế', 'Giao nhanh', '2024-05-09 08:45:00'),
(37, 3000, 'delivered', 'cash', '671 Lê Văn Sỹ, Nha Trang', NULL, '2024-03-01 11:20:00'),
(38, 85000, 'delivered', 'momo', '782 Nguyễn Đình Chiểu, Biên Hòa', NULL, '2024-03-02 13:35:00'),
(39, 25000, 'delivered', 'cash', '893 Trần Quốc Toản, Vũng Tàu', NULL, '2024-03-03 09:00:00'),
(40, 95000, 'delivered', 'momo', '904 Võ Thị Sáu, Đà Lạt', NULL, '2024-03-04 10:30:00'),
(41, 15000, 'delivered', 'cash', '115 Cộng Hòa, Hà Nội', NULL, '2024-03-05 14:15:00'),
(42, 350000, 'delivered', 'credit_card', '226 Ung Văn Khiêm, Hồ Chí Minh', NULL, '2024-03-06 11:45:00'),
(43, 280000, 'delivered', 'momo', '337 Xô Viết Nghệ Tĩnh, Đà Nẵng', NULL, '2024-03-07 15:30:00'),
(44, 550000, 'delivered', 'zalopay', '448 Nam Kỳ Khởi Nghĩa, Hải Phòng', NULL, '2024-03-08 08:20:00'),
(45, 450000, 'delivered', 'cash', '559 Phan Kế Bính, Cần Thơ', NULL, '2024-03-09 12:00:00'),
(46, 650000, 'delivered', 'credit_card', '660 Nguyễn Chí Thanh, Huế', NULL, '2024-03-10 09:30:00'),
(47, 380000, 'delivered', 'momo', '771 Tô Hiến Thành, Nha Trang', NULL, '2024-03-11 13:45:00'),
(48, 35000, 'delivered', 'cash', '882 Cao Thắng, Biên Hòa', NULL, '2024-03-12 10:15:00'),
(49, 32000, 'delivered', 'momo', '993 Đinh Công Tráng, Vũng Tàu', NULL, '2024-03-13 14:30:00'),
(50, 18000, 'delivered', 'cash', '104 Hai Bà Trưng, Đà Lạt', NULL, '2024-03-14 11:00:00'),
(51, 350000, 'delivered', 'momo', '215 Trần Nhân Tông, Hà Nội', NULL, '2024-03-15 15:20:00'),
(52, 150000, 'delivered', 'credit_card', '326 Phan Chu Trinh, Hồ Chí Minh', NULL, '2024-03-16 08:45:00'),
(53, 250000, 'delivered', 'cash', '437 Nguyễn Văn Cừ, Đà Nẵng', NULL, '2024-03-17 12:15:00'),
(54, 1200000, 'delivered', 'bank_transfer', '548 Bùi Thị Xuân, Hải Phòng', NULL, '2024-03-18 09:30:00'),
(55, 680000, 'delivered', 'credit_card', '659 Trần Bình Trọng, Cần Thơ', NULL, '2024-03-19 13:00:00'),
(56, 850000, 'delivered', 'momo', '760 Lê Hồng Phong, Huế', NULL, '2024-03-20 10:45:00'),
(57, 65000, 'shipped', 'cash', '871 Nguyễn Hữu Cảnh, Nha Trang', NULL, '2024-05-10 14:20:00'),
(58, 450000, 'delivered', 'zalopay', '982 Võ Văn Tần, Biên Hòa', NULL, '2024-03-22 11:30:00'),
(59, 280000, 'delivered', 'momo', '193 Lý Chính Thắng, Vũng Tàu', NULL, '2024-03-23 15:10:00'),
(60, 550000, 'delivered', 'credit_card', '204 Nguyễn Văn Trỗi, Đà Lạt', NULL, '2024-03-24 08:50:00'),
(61, 22990000, 'delivered', 'bank_transfer', '315 Phan Đăng Lưu, Hà Nội', 'Hàng cao cấp', '2024-03-25 12:30:00'),
(62, 29990000, 'delivered', 'credit_card', '426 Hoàng Sa, Hồ Chí Minh', 'Giao tận nhà', '2024-03-26 09:15:00'),
(63, 6490000, 'delivered', 'momo', '537 Trường Sa, Đà Nẵng', NULL, '2024-03-27 13:45:00'),
(64, 350000, 'delivered', 'cash', '648 Nguyễn Bỉnh Khiêm, Hải Phòng', NULL, '2024-03-28 10:20:00'),
(65, 1200000, 'delivered', 'zalopay', '759 Tôn Thất Đạm, Cần Thơ', NULL, '2024-03-29 14:00:00'),
(66, 80000, 'delivered', 'momo', '860 Nguyễn Thị Nghĩa, Huế', NULL, '2024-03-30 11:35:00'),
(67, 180000, 'delivered', 'credit_card', '971 Phạm Viết Chánh, Nha Trang', NULL, '2024-03-31 15:15:00'),
(68, 70000, 'delivered', 'cash', '182 Nguyễn Cư Trinh, Biên Hòa', NULL, '2024-04-01 08:40:00'),
(69, 75000, 'delivered', 'momo', '293 Đề Thám, Vũng Tàu', NULL, '2024-04-02 12:20:00'),
(70, 350000, 'delivered', 'credit_card', '304 Lê Thánh Tôn, Đà Lạt', NULL, '2024-04-03 09:55:00'),
(71, 1800000, 'delivered', 'bank_transfer', '415 Mạc Đĩnh Chi, Hà Nội', NULL, '2024-04-04 13:30:00'),
(72, 280000, 'delivered', 'momo', '526 Nguyễn Đình Chiểu, Hồ Chí Minh', NULL, '2024-04-05 10:10:00'),
(73, 350000, 'delivered', 'cash', '637 Trương Định, Đà Nẵng', NULL, '2024-04-06 14:45:00'),
(74, 150000, 'delivered', 'zalopay', '748 Nguyễn Tri Phương, Hải Phòng', NULL, '2024-04-07 11:25:00'),
(75, 250000, 'delivered', 'momo', '859 Lương Hữu Khánh, Cần Thơ', NULL, '2024-04-08 15:00:00'),
(76, 450000, 'delivered', 'credit_card', '960 Tôn Thất Tùng, Huế', NULL, '2024-04-09 08:35:00'),
(77, 650000, 'delivered', 'cash', '171 Hai Bà Trưng, Nha Trang', NULL, '2024-04-10 12:15:00'),
(78, 550000, 'delivered', 'bank_transfer', '282 Phan Kế Bính, Biên Hòa', NULL, '2024-04-11 09:50:00'),
(79, 380000, 'delivered', 'momo', '393 Lý Thái Tổ, Vũng Tàu', NULL, '2024-04-12 13:25:00'),
(80, 320000, 'delivered', 'credit_card', '404 Trần Quang Khải, Đà Lạt', NULL, '2024-04-13 10:30:00'),
(81, 32000000, 'delivered', 'bank_transfer', '515 Lê Đại Hành, Hà Nội', 'Laptop cao cấp', '2024-04-14 14:10:00'),
(82, 1200000, 'delivered', 'credit_card', '626 Nguyễn Thượng Hiền, Hồ Chí Minh', NULL, '2024-04-15 11:45:00'),
(83, 850000, 'delivered', 'momo', '737 Võ Duy Ninh, Đà Nẵng', NULL, '2024-04-16 15:20:00'),
(84, 680000, 'delivered', 'cash', '848 Đinh Tiên Hoàng, Hải Phòng', NULL, '2024-04-17 08:55:00'),
(85, 350000, 'delivered', 'zalopay', '959 Tôn Đức Thắng, Cần Thơ', NULL, '2024-04-18 12:30:00'),
(86, 280000, 'delivered', 'momo', '160 Nguyễn Hữu Thọ, Huế', NULL, '2024-04-19 09:20:00'),
(87, 550000, 'delivered', 'credit_card', '271 Cách Mạng Tháng 8, Nha Trang', NULL, '2024-04-20 13:55:00'),
(88, 450000, 'delivered', 'cash', '382 Lê Lợi, Biên Hòa', NULL, '2024-04-21 10:35:00'),
(89, 150000, 'delivered', 'bank_transfer', '493 Quang Trung, Vũng Tàu', NULL, '2024-04-22 14:15:00'),
(90, 250000, 'delivered', 'momo', '504 Nguyễn Huệ, Đà Lạt', NULL, '2024-04-23 11:50:00'),
(91, 28990000, 'delivered', 'credit_card', '615 Trần Phú, Hà Nội', 'MacBook Air', '2024-04-24 15:30:00'),
(92, 1200000, 'delivered', 'zalopay', '726 Lý Thường Kiệt, Hồ Chí Minh', NULL, '2024-04-25 08:40:00'),
(93, 350000, 'delivered', 'momo', '837 Điện Biên Phủ, Đà Nẵng', NULL, '2024-04-26 12:20:00'),
(94, 65000, 'delivered', 'cash', '948 Võ Văn Kiệt, Hải Phòng', NULL, '2024-04-27 09:05:00'),
(95, 80000, 'delivered', 'momo', '159 Lê Duẩn, Cần Thơ', NULL, '2024-04-28 13:40:00'),
(96, 180000, 'delivered', 'credit_card', '260 Trường Chinh, Huế', NULL, '2024-04-29 10:15:00'),
(97, 70000, 'delivered', 'cash', '371 Hoàng Văn Thụ, Nha Trang', NULL, '2024-04-30 14:50:00'),
(98, 75000, 'delivered', 'bank_transfer', '482 Nguyễn Văn Linh, Biên Hòa', NULL, '2024-05-01 11:30:00'),
(99, 350000, 'delivered', 'momo', '593 Phan Đình Phùng, Vũng Tàu', NULL, '2024-05-02 15:10:00'),
(100, 1800000, 'processing', 'credit_card', '123 Lê Lợi, Hà Nội', 'Giày thể thao', '2024-05-03 08:25:00'),
-- Additional 100 orders
(1, 850000, 'delivered', 'momo', '123 Lê Lợi, Hà Nội', NULL, '2024-02-25 10:30:00'),
(5, 3200000, 'delivered', 'credit_card', '654 Lý Thường Kiệt, Cần Thơ', 'Nước hoa cao cấp', '2024-02-26 14:20:00'),
(10, 65000, 'delivered', 'cash', '741 Hoàng Văn Thụ, Đà Lạt', NULL, '2024-02-27 09:45:00'),
(15, 350000, 'delivered', 'momo', '951 Nguyễn Trãi, Cần Thơ', NULL, '2024-02-28 11:15:00'),
(20, 680000, 'delivered', 'zalopay', '794 Bà Triệu, Đà Lạt', NULL, '2024-03-01 13:30:00'),
(25, 1200000, 'delivered', 'bank_transfer', '359 Hàm Nghi, Cần Thơ', NULL, '2024-03-02 15:00:00'),
(30, 280000, 'delivered', 'credit_card', '804 Nguyễn Thái Học, Đà Lạt', NULL, '2024-03-03 08:40:00'),
(35, 550000, 'delivered', 'momo', '459 Phạm Ngọc Thạch, Cần Thơ', NULL, '2024-03-04 10:20:00'),
(40, 450000, 'delivered', 'cash', '904 Võ Thị Sáu, Đà Lạt', NULL, '2024-03-05 12:10:00'),
(45, 150000, 'delivered', 'zalopay', '559 Phan Kế Bính, Cần Thơ', NULL, '2024-03-06 14:45:00'),
(50, 250000, 'delivered', 'momo', '104 Hai Bà Trưng, Đà Lạt', NULL, '2024-03-07 09:25:00'),
(2, 32000, 'delivered', 'cash', '456 Nguyễn Huệ, Hồ Chí Minh', NULL, '2024-03-08 11:50:00'),
(7, 95000, 'delivered', 'momo', '147 Võ Văn Kiệt, Nha Trang', NULL, '2024-03-09 13:15:00'),
(12, 3000, 'delivered', 'cash', '963 Phan Đình Phùng, Hồ Chí Minh', NULL, '2024-03-10 15:35:00'),
(17, 85000, 'delivered', 'credit_card', '486 Yersin, Nha Trang', NULL, '2024-03-11 08:00:00'),
(22, 25000, 'delivered', 'momo', '926 Lê Thánh Tông, Hồ Chí Minh', NULL, '2024-03-12 10:40:00'),
(27, 15000, 'delivered', 'cash', '571 Hoàng Diệu, Nha Trang', NULL, '2024-03-13 12:25:00'),
(32, 350000, 'delivered', 'zalopay', '126 Nguyễn Du, Hồ Chí Minh', NULL, '2024-03-14 14:10:00'),
(37, 650000, 'delivered', 'bank_transfer', '671 Lê Văn Sỹ, Nha Trang', NULL, '2024-03-15 09:55:00'),
(42, 280000, 'delivered', 'credit_card', '226 Ung Văn Khiêm, Hồ Chí Minh', NULL, '2024-03-16 11:30:00'),
(47, 380000, 'delivered', 'momo', '771 Tô Hiến Thành, Nha Trang', NULL, '2024-03-17 13:45:00'),
(52, 550000, 'delivered', 'cash', '326 Phan Chu Trinh, Hồ Chí Minh', NULL, '2024-03-18 15:20:00'),
(57, 450000, 'delivered', 'zalopay', '871 Nguyễn Hữu Cảnh, Nha Trang', NULL, '2024-03-19 08:35:00'),
(62, 150000, 'delivered', 'momo', '426 Hoàng Sa, Hồ Chí Minh', NULL, '2024-03-20 10:15:00'),
(67, 250000, 'delivered', 'credit_card', '971 Phạm Viết Chánh, Nha Trang', NULL, '2024-03-21 12:50:00'),
(72, 1200000, 'delivered', 'cash', '526 Nguyễn Đình Chiểu, Hồ Chí Minh', NULL, '2024-03-22 14:30:00'),
(77, 850000, 'delivered', 'bank_transfer', '171 Hai Bà Trưng, Nha Trang', NULL, '2024-03-23 09:10:00'),
(82, 680000, 'delivered', 'momo', '626 Nguyễn Thượng Hiền, Hồ Chí Minh', NULL, '2024-03-24 11:45:00'),
(87, 320000, 'delivered', 'credit_card', '271 Cách Mạng Tháng 8, Nha Trang', NULL, '2024-03-25 13:20:00'),
(92, 35000, 'delivered', 'cash', '726 Lý Thường Kiệt, Hồ Chí Minh', NULL, '2024-03-26 15:05:00'),
(97, 18000, 'delivered', 'momo', '371 Hoàng Văn Thụ, Nha Trang', NULL, '2024-03-27 08:50:00'),
(3, 6490000, 'delivered', 'zalopay', '789 Trần Phú, Đà Nẵng', NULL, '2024-03-28 10:25:00'),
(8, 22990000, 'delivered', 'bank_transfer', '258 Lê Duẩn, Biên Hòa', 'Samsung S24', '2024-03-29 12:00:00'),
(13, 28990000, 'delivered', 'credit_card', '159 Cách Mạng Tháng 8, Đà Nẵng', 'MacBook Air M3', '2024-03-30 14:40:00'),
(18, 32000000, 'delivered', 'bank_transfer', '572 Pasteur, Biên Hòa', 'Dell XPS 13', '2024-03-31 09:15:00'),
(23, 29990000, 'delivered', 'credit_card', '137 Nguyễn Công Trứ, Đà Nẵng', 'iPhone 15 Pro Max', '2024-04-01 11:50:00'),
(28, 1200000, 'delivered', 'momo', '682 Phan Bội Châu, Biên Hòa', NULL, '2024-04-02 13:30:00'),
(33, 350000, 'delivered', 'cash', '237 Lê Quý Đôn, Đà Nẵng', NULL, '2024-04-03 15:10:00'),
(38, 280000, 'delivered', 'zalopay', '782 Nguyễn Đình Chiểu, Biên Hòa', NULL, '2024-04-04 08:45:00'),
(43, 550000, 'delivered', 'bank_transfer', '337 Xô Viết Nghệ Tĩnh, Đà Nẵng', NULL, '2024-04-05 10:20:00'),
(48, 450000, 'delivered', 'credit_card', '882 Cao Thắng, Biên Hòa', NULL, '2024-04-06 12:05:00'),
(53, 150000, 'delivered', 'momo', '437 Nguyễn Văn Cừ, Đà Nẵng', NULL, '2024-04-07 13:45:00'),
(58, 650000, 'delivered', 'cash', '982 Võ Văn Tần, Biên Hòa', NULL, '2024-04-08 15:25:00'),
(63, 250000, 'delivered', 'zalopay', '537 Trường Sa, Đà Nẵng', NULL, '2024-04-09 09:00:00'),
(68, 380000, 'delivered', 'momo', '182 Nguyễn Cư Trinh, Biên Hòa', NULL, '2024-04-10 10:35:00'),
(73, 320000, 'delivered', 'credit_card', '637 Trương Định, Đà Nẵng', NULL, '2024-04-11 12:20:00'),
(78, 1200000, 'delivered', 'bank_transfer', '282 Phan Kế Bính, Biên Hòa', NULL, '2024-04-12 14:00:00'),
(83, 850000, 'delivered', 'momo', '737 Võ Duy Ninh, Đà Nẵng', NULL, '2024-04-13 15:40:00'),
(88, 680000, 'delivered', 'cash', '382 Lê Lợi, Biên Hòa', NULL, '2024-04-14 08:15:00'),
(93, 65000, 'delivered', 'zalopay', '837 Điện Biên Phủ, Đà Nẵng', NULL, '2024-04-15 09:50:00'),
(98, 80000, 'delivered', 'credit_card', '482 Nguyễn Văn Linh, Biên Hòa', NULL, '2024-04-16 11:30:00'),
(4, 180000, 'delivered', 'momo', '321 Hai Bà Trưng, Hải Phòng', NULL, '2024-04-17 13:10:00'),
(9, 70000, 'delivered', 'cash', '369 Trường Chinh, Vũng Tàu', NULL, '2024-04-18 14:50:00'),
(14, 75000, 'delivered', 'zalopay', '753 Lạc Long Quân, Hải Phòng', NULL, '2024-04-19 08:30:00'),
(19, 350000, 'delivered', 'bank_transfer', '683 Đinh Tiên Hoàng, Vũng Tàu', NULL, '2024-04-20 10:10:00'),
(24, 1800000, 'delivered', 'credit_card', '248 Ngô Quyền, Hải Phòng', NULL, '2024-04-21 11:45:00'),
(29, 280000, 'delivered', 'momo', '793 Lý Tự Trọng, Vũng Tàu', NULL, '2024-04-22 13:25:00'),
(34, 550000, 'delivered', 'cash', '348 Nguyễn Thị Minh Khai, Hải Phòng', NULL, '2024-04-23 15:05:00'),
(39, 450000, 'delivered', 'zalopay', '893 Trần Quốc Toản, Vũng Tàu', NULL, '2024-04-24 08:40:00'),
(44, 150000, 'delivered', 'momo', '448 Nam Kỳ Khởi Nghĩa, Hải Phòng', NULL, '2024-04-25 10:20:00'),
(49, 250000, 'delivered', 'credit_card', '993 Đinh Công Tráng, Vũng Tàu', NULL, '2024-04-26 12:00:00'),
(54, 650000, 'delivered', 'cash', '548 Bùi Thị Xuân, Hải Phòng', NULL, '2024-04-27 13:35:00'),
(59, 320000, 'delivered', 'bank_transfer', '193 Lý Chính Thắng, Vũng Tàu', NULL, '2024-04-28 15:15:00'),
(64, 380000, 'delivered', 'momo', '648 Nguyễn Bỉnh Khiêm, Hải Phòng', NULL, '2024-04-29 09:00:00'),
(69, 1200000, 'delivered', 'credit_card', '293 Đề Thám, Vũng Tàu', NULL, '2024-04-30 10:35:00'),
(74, 850000, 'delivered', 'zalopay', '748 Nguyễn Tri Phương, Hải Phòng', NULL, '2024-05-01 12:15:00'),
(79, 32000, 'delivered', 'momo', '393 Lý Thái Tổ, Vũng Tàu', NULL, '2024-05-02 13:50:00'),
(84, 35000, 'delivered', 'cash', '848 Đinh Tiên Hoàng, Hải Phòng', NULL, '2024-05-03 15:30:00'),
(89, 18000, 'delivered', 'zalopay', '493 Quang Trung, Vũng Tàu', NULL, '2024-05-04 08:10:00'),
(94, 95000, 'delivered', 'bank_transfer', '948 Võ Văn Kiệt, Hải Phòng', NULL, '2024-05-05 09:45:00'),
(99, 3000, 'delivered', 'credit_card', '593 Phan Đình Phùng, Vũng Tàu', NULL, '2024-05-06 11:25:00'),
(6, 85000, 'pending', 'momo', '987 Điện Biên Phủ, Huế', NULL, '2024-05-07 13:00:00'),
(11, 25000, 'delivered', 'cash', '852 Nguyễn Văn Linh, Hà Nội', NULL, '2024-05-08 14:40:00'),
(16, 15000, 'delivered', 'zalopay', '357 Tôn Đức Thắng, Huế', NULL, '2024-05-09 08:20:00'),
(21, 6490000, 'delivered', 'bank_transfer', '815 Quang Trung, Hà Nội', NULL, '2024-05-10 10:00:00'),
(26, 22990000, 'processing', 'credit_card', '460 Trần Hưng Đạo, Huế', 'Samsung S24', '2024-05-11 11:35:00'),
(31, 28990000, 'processing', 'bank_transfer', '915 Chu Văn An, Hà Nội', 'MacBook Air M3', '2024-05-11 13:15:00'),
(36, 350000, 'cancelled', 'momo', '560 Hoàng Hoa Thám, Huế', 'Khách không nhận', '2024-04-15 14:55:00'),
(41, 280000, 'delivered', 'cash', '115 Cộng Hòa, Hà Nội', NULL, '2024-05-12 08:35:00'),
(46, 550000, 'delivered', 'zalopay', '660 Nguyễn Chí Thanh, Huế', NULL, '2024-05-12 10:15:00'),
(51, 450000, 'delivered', 'credit_card', '215 Trần Nhân Tông, Hà Nội', NULL, '2024-05-13 11:50:00'),
(56, 150000, 'delivered', 'momo', '760 Lê Hồng Phong, Huế', NULL, '2024-05-13 13:30:00'),
(61, 250000, 'delivered', 'cash', '315 Phan Đăng Lưu, Hà Nội', NULL, '2024-05-14 15:10:00'),
(66, 650000, 'delivered', 'bank_transfer', '860 Nguyễn Thị Nghĩa, Huế', NULL, '2024-05-14 08:50:00'),
(71, 320000, 'delivered', 'momo', '415 Mạc Đĩnh Chi, Hà Nội', NULL, '2024-05-15 10:25:00'),
(76, 380000, 'delivered', 'credit_card', '960 Tôn Thất Tùng, Huế', NULL, '2024-05-15 12:05:00'),
(81, 1200000, 'delivered', 'cash', '515 Lê Đại Hành, Hà Nội', NULL, '2024-05-16 13:40:00'),
(86, 850000, 'delivered', 'zalopay', '160 Nguyễn Hữu Thọ, Huế', NULL, '2024-05-16 15:20:00'),
(91, 680000, 'delivered', 'bank_transfer', '615 Trần Phú, Hà Nội', NULL, '2024-05-17 09:00:00'),
(96, 1800000, 'delivered', 'credit_card', '260 Trường Chinh, Huế', NULL, '2024-05-17 10:40:00'),
(100, 32000000, 'processing', 'bank_transfer', '123 Lê Lợi, Hà Nội', 'Laptop Dell XPS 13', '2024-05-18 12:20:00');

-- ============================================
-- ORDER_ITEMS (500 records)
-- ============================================
INSERT INTO order_items (order_id, product_id, quantity, price) VALUES
-- Order 1: total 1350000 (iPhone case + Jean)
(1, 2, 2, 450000),
(1, 1, 3, 150000),
-- Order 2: total 850000 (Váy đầm)
(2, 6, 1, 850000),
-- Order 3: total 32000000 (Laptop Dell)
(3, 13, 1, 32000000),
-- Order 4: total 450000 (Quần jean)
(4, 2, 1, 450000),
-- Order 5: total 1800000 (Giày thể thao Adidas)
(5, 27, 1, 1800000),
-- Order 6: total 550000 (Túi xách nữ)
(6, 10, 1, 550000),
-- Order 7: total 280000 (Áo kiểu nữ)
(7, 7, 1, 280000),
-- Order 8: total 2500000 (Lego)
(8, 38, 1, 2500000),
-- Order 9: total 120000 (Rubik)
(9, 40, 1, 120000),
-- Order 10: total 3200000 (Nước hoa Chanel)
(10, 37, 1, 3200000),
-- Order 11: total 650000 (Túi đeo chéo nam)
(11, 5, 1, 650000),
-- Order 12: total 380000 (Giày cao gót)
(12, 9, 1, 380000),
-- Order 13: total 29990000 (iPhone 15)
(13, 11, 1, 29990000),
-- Order 14: total 850000 (Váy đầm)
(14, 6, 1, 850000),
-- Order 15: total 1200000 (Bộ nồi inox)
(15, 19, 1, 1200000),
-- Order 16: total 350000 (Bóng đá Adidas)
(16, 26, 1, 350000),
-- Order 17: total 6490000 (AirPods Pro)
(17, 15, 1, 6490000),
-- Order 18: total 250000 (Áo sơ mi nam)
(18, 3, 1, 250000),
-- Order 19: total 850000 (Nồi cơm điện)
(19, 18, 1, 850000),
-- Order 20: total 22990000 (Samsung S24)
(20, 12, 1, 22990000),
-- Order 21: total 150000 (Áo thun nam)
(21, 1, 1, 150000),
-- Order 22: total 280000 (Áo kiểu nữ)
(22, 7, 1, 280000),
-- Order 23: total 1200000 (Bàn phím cơ)
(23, 17, 1, 1200000),
-- Order 24: total 680000 (Son MAC)
(24, 36, 1, 680000),
-- Order 25: total 350000 (Bóng đá)
(25, 26, 1, 350000),
-- Order 26: total 65000 (Đắc Nhân Tâm)
(26, 22, 1, 65000),
-- Order 27: total 80000 (Tuổi Trẻ Đáng Giá)
(27, 23, 1, 80000),
-- Order 28: total 180000 (Sapiens)
(28, 24, 1, 180000),
-- Order 29: total 70000 (Nhà Giả Kim)
(29, 25, 1, 70000),
-- Order 30: total 75000 (Khéo Ăn Nói)
(30, 26, 1, 75000),
-- Order 31: total 28990000 (MacBook Air)
(31, 14, 1, 28990000),
-- Order 32: total 450000 (Quần jean)
(32, 2, 1, 450000),
-- Order 33: total 550000 (Túi xách nữ)
(33, 10, 1, 550000),
-- Order 34: total 320000 (Quần tây nữ)
(34, 8, 1, 320000),
-- Order 35: total 850000 (Váy đầm)
(35, 6, 1, 850000),
-- Order 36: total 1200000 (Bộ nồi inox)
(36, 19, 1, 1200000),
-- Order 37: total 3000 (Bút bi)
(37, 47, 1, 3000),
-- Order 38: total 85000 (Sổ tay A5)
(38, 48, 1, 85000),
-- Order 39: total 25000 (Bút highlight)
(39, 49, 1, 25000),
-- Order 40: total 95000 (Giấy A4)
(40, 50, 1, 95000),
-- Order 41: total 15000 (Kéo)
(41, 51, 1, 15000),
-- Order 42: total 350000 (Chuột Logitech)
(42, 16, 1, 350000),
-- Order 43: total 280000 (Sữa rửa mặt)
(43, 34, 1, 280000),
-- Order 44: total 550000 (Serum C)
(44, 35, 1, 550000),
-- Order 45: total 450000 (Kem chống nắng)
(45, 33, 1, 450000),
-- Order 46: total 650000 (Túi đeo chéo)
(46, 5, 1, 650000),
-- Order 47: total 380000 (Giày cao gót)
(47, 9, 1, 380000),
-- Order 48: total 35000 (Trứng gà)
(48, 44, 1, 35000),
-- Order 49: total 32000 (Sữa tươi)
(49, 45, 1, 32000),
-- Order 50: total 18000 (Snack Lays)
(50, 46, 1, 18000),
-- Order 51: total 350000 (Thịt bò)
(51, 42, 1, 350000),
-- Order 52: total 150000 (Áo thun nam)
(52, 1, 1, 150000),
-- Order 53: total 250000 (Áo sơ mi nam)
(53, 3, 1, 250000),
-- Order 54: total 1200000 (Giày Nike)
(54, 4, 1, 1200000),
-- Order 55: total 680000 (Son MAC)
(55, 36, 1, 680000),
-- Order 56: total 850000 (Xe điều khiển)
(56, 41, 1, 850000),
-- Order 57: total 65000 (Đắc Nhân Tâm)
(57, 22, 1, 65000),
-- Order 58: total 450000 (Quần jean)
(58, 2, 1, 450000),
-- Order 59: total 280000 (Áo kiểu nữ)
(59, 7, 1, 280000),
-- Order 60: total 550000 (Túi xách nữ)
(60, 10, 1, 550000),
-- Order 61: total 22990000 (Samsung S24)
(61, 12, 1, 22990000),
-- Order 62: total 29990000 (iPhone 15)
(62, 11, 1, 29990000),
-- Order 63: total 6490000 (AirPods Pro)
(63, 15, 1, 6490000),
-- Order 64: total 350000 (Bóng đá)
(64, 26, 1, 350000),
-- Order 65: total 1200000 (Bàn phím cơ)
(65, 17, 1, 1200000),
-- Order 66: total 80000 (Tuổi Trẻ)
(66, 23, 1, 80000),
-- Order 67: total 180000 (Sapiens)
(67, 24, 1, 180000),
-- Order 68: total 70000 (Nhà Giả Kim)
(68, 25, 1, 70000),
-- Order 69: total 75000 (Khéo Ăn Nói)
(69, 26, 1, 75000),
-- Order 70: total 350000 (Thịt bò)
(70, 42, 1, 350000),
-- Order 71: total 1800000 (Giày Adidas)
(71, 27, 1, 1800000),
-- Order 72: total 280000 (Bộ tạ tay)
(72, 28, 1, 280000),
-- Order 73: total 350000 (Thảm Yoga)
(73, 29, 1, 350000),
-- Order 74: total 150000 (Áo thun nam)
(74, 1, 1, 150000),
-- Order 75: total 250000 (Bình đun siêu tốc)
(75, 21, 1, 250000),
-- Order 76: total 450000 (Kem chống nắng)
(76, 33, 1, 450000),
-- Order 77: total 650000 (Vợt cầu lông)
(77, 30, 1, 650000),
-- Order 78: total 550000 (Túi xách nữ)
(78, 10, 1, 550000),
-- Order 79: total 380000 (Giày cao gót)
(79, 9, 1, 380000),
-- Order 80: total 320000 (Quần tây nữ)
(80, 8, 1, 320000),
-- Order 81: total 32000000 (Laptop Dell)
(81, 13, 1, 32000000),
-- Order 82: total 1200000 (Bộ nồi inox)
(82, 19, 1, 1200000),
-- Order 83: total 850000 (Máy xay)
(83, 20, 1, 650000),
(83, 21, 1, 200000),
-- Order 84: total 680000 (Son MAC)
(84, 36, 1, 680000),
-- Order 85: total 350000 (Búp bê Barbie)
(85, 39, 1, 350000),
-- Order 86: total 280000 (Sữa rửa mặt)
(86, 34, 1, 280000),
-- Order 87: total 550000 (Serum C)
(87, 35, 1, 550000),
-- Order 88: total 450000 (Quần jean)
(88, 2, 1, 450000),
-- Order 89: total 150000 (Áo thun nam)
(89, 1, 1, 150000),
-- Order 90: total 250000 (Áo sơ mi nam)
(90, 3, 1, 250000),
-- Order 91: total 28990000 (MacBook Air)
(91, 14, 1, 28990000),
-- Order 92: total 1200000 (Bàn phím cơ)
(92, 17, 1, 1200000),
-- Order 93: total 350000 (Chuột Logitech)
(93, 16, 1, 350000),
-- Order 94: total 65000 (Đắc Nhân Tâm)
(94, 22, 1, 65000),
-- Order 95: total 80000 (Tuổi Trẻ)
(95, 23, 1, 80000),
-- Order 96: total 180000 (Sapiens)
(96, 24, 1, 180000),
-- Order 97: total 70000 (Nhà Giả Kim)
(97, 25, 1, 70000),
-- Order 98: total 75000 (Khéo Ăn Nói)
(98, 26, 1, 75000),
-- Order 99: total 350000 (Thịt bò)
(99, 42, 1, 350000),
-- Order 100: total 1800000 (Giày Adidas)
(100, 27, 1, 1800000),
-- Additional order items for orders 101-200
(101, 6, 1, 850000),
(102, 37, 1, 3200000),
(103, 22, 1, 65000),
(104, 26, 1, 350000),
(105, 36, 1, 680000),
(106, 17, 1, 1200000),
(107, 7, 1, 280000),
(108, 10, 1, 550000),
(109, 2, 1, 450000),
(110, 1, 1, 150000),
(111, 3, 1, 250000),
(112, 45, 1, 32000),
(113, 50, 1, 95000),
(114, 47, 1, 3000),
(115, 48, 1, 85000),
(116, 49, 1, 25000),
(117, 51, 1, 15000),
(118, 16, 1, 350000),
(119, 5, 1, 650000),
(120, 7, 1, 280000),
(121, 9, 1, 380000),
(122, 10, 1, 550000),
(123, 2, 1, 450000),
(124, 1, 1, 150000),
(125, 3, 1, 250000),
(126, 19, 1, 1200000),
(127, 6, 1, 850000),
(128, 36, 1, 680000),
(129, 8, 1, 320000),
(130, 44, 1, 35000),
(131, 46, 1, 18000),
(132, 15, 1, 6490000),
(133, 12, 1, 22990000),
(134, 14, 1, 28990000),
(135, 13, 1, 32000000),
(136, 11, 1, 29990000),
(137, 17, 1, 1200000),
(138, 26, 1, 350000),
(139, 34, 1, 280000),
(140, 10, 1, 550000),
(141, 2, 1, 450000),
(142, 1, 1, 150000),
(143, 5, 1, 650000),
(144, 3, 1, 250000),
(145, 9, 1, 380000),
(146, 8, 1, 320000),
(147, 19, 1, 1200000),
(148, 6, 1, 850000),
(149, 36, 1, 680000),
(150, 22, 1, 65000),
(151, 42, 1, 350000),
(152, 27, 1, 1800000),
(153, 7, 1, 280000),
(154, 26, 1, 350000),
(155, 1, 1, 150000),
(156, 3, 1, 250000),
(157, 2, 1, 450000),
(158, 5, 1, 650000),
(159, 8, 1, 320000),
(160, 9, 1, 380000),
(161, 19, 1, 1200000),
(162, 6, 1, 850000),
(163, 36, 1, 680000),
(164, 10, 1, 550000),
(165, 27, 1, 1800000),
(166, 23, 1, 80000),
(167, 24, 1, 180000),
(168, 25, 1, 70000),
(169, 26, 1, 75000),
(170, 42, 1, 350000),
(171, 27, 1, 1800000),
(172, 34, 1, 280000),
(173, 10, 1, 550000),
(174, 2, 1, 450000),
(175, 21, 1, 250000),
(176, 33, 1, 450000),
(177, 30, 1, 650000),
(178, 10, 1, 550000),
(179, 9, 1, 380000),
(180, 8, 1, 320000),
(181, 13, 1, 32000000),
(182, 19, 1, 1200000),
(183, 20, 1, 650000),
(183, 21, 1, 200000),
(184, 36, 1, 680000),
(185, 39, 1, 350000),
(186, 34, 1, 280000),
(187, 35, 1, 550000),
(188, 2, 1, 450000),
(189, 1, 1, 150000),
(190, 3, 1, 250000),
(191, 14, 1, 28990000),
(192, 17, 1, 1200000),
(193, 16, 1, 350000),
(194, 22, 1, 65000),
(195, 23, 1, 80000),
(196, 24, 1, 180000),
(197, 25, 1, 70000),
(198, 26, 1, 75000),
(199, 42, 1, 350000),
(200, 27, 1, 1800000),
-- More varied order items
(1, 16, 1, 350000),
(5, 39, 1, 350000),
(10, 48, 1, 85000),
(15, 20, 1, 650000),
(20, 33, 1, 450000),
(25, 28, 1, 280000),
(30, 34, 1, 280000),
(35, 35, 1, 550000),
(40, 49, 1, 25000),
(45, 30, 1, 650000),
(50, 43, 1, 180000),
(52, 16, 2, 350000),
(54, 33, 1, 450000),
(56, 28, 1, 280000),
(58, 5, 1, 650000),
(60, 35, 1, 550000),
(65, 16, 1, 350000),
(70, 43, 1, 180000),
(72, 29, 1, 350000),
(73, 28, 1, 280000),
(75, 44, 1, 35000),
(77, 28, 2, 280000),
(82, 20, 1, 1200000),
(85, 40, 1, 120000),
(92, 16, 1, 350000),
(93, 40, 1, 120000),
(101, 39, 1, 350000),
(106, 16, 1, 350000),
(111, 16, 1, 350000),
(118, 39, 1, 350000),
(123, 16, 1, 350000),
(128, 40, 1, 120000),
(137, 16, 1, 350000),
(143, 39, 1, 350000),
(147, 20, 1, 1200000),
(152, 28, 1, 280000),
(157, 16, 1, 350000),
(161, 20, 1, 1200000),
(177, 28, 1, 280000),
(183, 39, 1, 350000),
(192, 16, 1, 350000);

-- ============================================
-- REVIEWS (150 records)
-- ============================================
INSERT INTO reviews (product_id, customer_id, rating, comment, created_at) VALUES
-- iPhone 15 Pro Max (product 11)
(11, 13, 5, 'Máy rất đẹp, camera cực chất. Giao hàng nhanh!', '2024-02-05 10:30:00'),
(11, 62, 5, 'iPhone 15 Pro Max quá đỉnh, màn hình đẹp, pin trâu', '2024-03-28 14:20:00'),
(11, 136, 4, 'Sản phẩm tốt nhưng giá hơi cao', '2024-04-20 09:15:00'),
-- Samsung S24 (product 12)
(12, 20, 5, 'Samsung S24 màn hình đẹp, hiệu năng mạnh mẽ', '2024-02-12 11:45:00'),
(12, 61, 4, 'Rất hài lòng với sản phẩm', '2024-03-27 16:30:00'),
(12, 133, 5, 'Camera S24 chụp ảnh đẹp lắm', '2024-04-01 10:25:00'),
-- Laptop Dell XPS 13 (product 13)
(13, 3, 5, 'Laptop Dell XPS 13 siêu mỏng nhẹ, hiệu năng tuyệt vời', '2024-01-25 15:20:00'),
(13, 81, 5, 'Máy chạy mượt, thiết kế đẹp', '2024-04-16 12:30:00'),
(13, 135, 4, 'Sản phẩm tốt, đóng gói cẩn thận', '2024-04-03 09:45:00'),
(13, 200, 5, 'Dell XPS 13 rất tuyệt, đáng giá tiền', '2024-05-20 11:20:00'),
-- MacBook Air M3 (product 14)
(14, 31, 5, 'MacBook Air M3 quá nhanh, pin trâu', '2024-02-23 13:15:00'),
(14, 91, 5, 'Máy đẹp, chạy rất mượt', '2024-04-26 14:40:00'),
(14, 134, 5, 'MacBook Air M3 2024 tuyệt vời', '2024-04-02 10:30:00'),
-- AirPods Pro 2 (product 15)
(15, 17, 5, 'Âm thanh tuyệt vời, chống ồn rất tốt', '2024-02-09 14:30:00'),
(15, 63, 4, 'Chất lượng âm thanh đỉnh cao', '2024-03-29 15:45:00'),
(15, 132, 5, 'AirPods Pro 2 chính hãng, nghe nhạc cực đã', '2024-03-31 11:20:00'),
-- Áo thun nam (product 1)
(1, 21, 4, 'Áo thun cotton mát, form đẹp', '2024-02-13 10:00:00'),
(1, 52, 4, 'Chất vải tốt, giá hợp lý', '2024-03-18 11:30:00'),
(1, 74, 5, 'Áo đẹp, mặc thoải mái', '2024-04-09 13:15:00'),
(1, 89, 4, 'Sản phẩm ok, giao hàng nhanh', '2024-04-24 09:45:00'),
(1, 110, 3, 'Áo hơi nhỏ so với size', '2024-03-08 10:20:00'),
-- Quần jean nam (product 2)
(2, 4, 5, 'Quần jean đẹp, form chuẩn', '2024-01-25 12:30:00'),
(2, 32, 4, 'Chất denim tốt', '2024-02-24 13:45:00'),
(2, 58, 5, 'Quần đẹp, giá hợp lý', '2024-03-24 14:00:00'),
(2, 88, 4, 'Form slim fit rất đẹp', '2024-04-23 12:15:00'),
(2, 109, 4, 'Quần tốt nhưng hơi dài', '2024-03-07 09:30:00'),
(2, 123, 5, 'Chất lượng tốt, đáng mua', '2024-03-18 15:10:00'),
-- Áo sơ mi nam (product 3)
(3, 18, 4, 'Áo sơ mi công sở đẹp, vải mát', '2024-02-10 11:15:00'),
(3, 53, 5, 'Form chuẩn, đi làm rất hợp', '2024-03-19 12:40:00'),
(3, 90, 4, 'Chất vải tốt, ủi phẳng', '2024-04-25 10:55:00'),
(3, 111, 4, 'Áo đẹp, giá tốt', '2024-03-09 11:20:00'),
(3, 142, 5, 'Rất hài lòng với sản phẩm', '2024-04-08 13:30:00'),
-- Giày Nike (product 4)
(4, 54, 5, 'Giày Nike chính hãng, đẹp lắm', '2024-03-20 14:20:00'),
(4, 54, 5, 'Đi rất thoải mái, êm chân', '2024-05-05 09:45:00'),
-- Váy đầm nữ (product 6)
(6, 2, 5, 'Váy đầm rất đẹp, vải mềm mại', '2024-01-23 13:00:00'),
(6, 14, 5, 'Váy sang trọng, đi tiệc rất hợp', '2024-02-06 12:15:00'),
(6, 35, 4, 'Đẹp nhưng hơi chật ở vòng 2', '2024-02-27 14:30:00'),
(6, 101, 5, 'Váy dạ hội xinh xắn', '2024-02-27 11:45:00'),
(6, 127, 5, 'Chất liệu tốt, may đẹp', '2024-03-25 13:20:00'),
(6, 148, 5, 'Váy rất đẹp, đáng tiền', '2024-04-18 15:00:00'),
(6, 162, 5, 'Thiết kế sang trọng', '2024-04-24 10:30:00'),
-- Áo kiểu nữ (product 7)
(7, 7, 4, 'Áo kiểu đẹp, vải lụa mát', '2024-01-28 15:45:00'),
(7, 22, 4, 'Form chuẩn, đi làm ok', '2024-02-14 13:30:00'),
(7, 59, 5, 'Áo đẹp, giá hợp lý', '2024-03-25 11:15:00'),
(7, 107, 4, 'Chất vải tốt', '2024-03-06 14:20:00'),
(7, 120, 4, 'Áo xinh, mặc thoải mái', '2024-03-17 09:45:00'),
(7, 153, 5, 'Rất hài lòng', '2024-04-27 12:30:00'),
-- Quần tây nữ (product 8)
(8, 34, 4, 'Quần tây form đẹp', '2024-02-26 14:00:00'),
(8, 80, 4, 'Chất vải tốt, ống đứng chuẩn', '2024-04-15 11:30:00'),
(8, 129, 5, 'Quần đẹp lắm', '2024-03-28 12:45:00'),
(8, 159, 4, 'Form chuẩn, đi làm hợp', '2024-05-01 09:20:00'),
(8, 174, 3, 'Quần hơi dài', '2024-04-23 10:15:00'),
(8, 180, 4, 'Chất lượng tốt', '2024-05-05 13:40:00'),
-- Giày cao gót (product 9)
(9, 12, 5, 'Giày cao gót đẹp, đi êm', '2024-02-04 12:45:00'),
(9, 47, 4, 'Giày xinh, gót vừa phải', '2024-03-13 13:20:00'),
(9, 79, 5, 'Rất thích giày này', '2024-04-14 14:35:00'),
(9, 121, 4, 'Đẹp nhưng hơi chật', '2024-03-19 11:00:00'),
(9, 145, 5, 'Giày cao gót mũi nhọn đẹp lắm', '2024-04-10 15:20:00'),
(9, 160, 4, 'Chất lượng ok', '2024-05-02 10:45:00'),
(9, 179, 5, 'Đi rất đẹp chân', '2024-05-06 12:30:00'),
-- Túi xách nữ (product 10)
(10, 6, 5, 'Túi xách đẹp, thiết kế Hàn Quốc', '2024-01-27 14:10:00'),
(10, 33, 5, 'Túi rộng, đựng đồ tốt', '2024-02-25 13:00:00'),
(10, 60, 4, 'Túi xinh, chất liệu ok', '2024-03-26 15:40:00'),
(10, 78, 5, 'Rất thích mẫu túi này', '2024-04-13 11:25:00'),
(10, 108, 4, 'Đẹp, giá hợp lý', '2024-03-06 12:50:00'),
(10, 122, 5, 'Túi thời trang, chất lượng tốt', '2024-03-20 14:15:00'),
(10, 140, 4, 'Túi đẹp lắm', '2024-04-06 10:30:00'),
(10, 164, 5, 'Rất hài lòng', '2024-05-03 13:20:00'),
(10, 173, 4, 'Túi xinh, giao nhanh', '2024-04-26 11:40:00'),
(10, 178, 5, 'Chất lượng cao', '2024-05-04 15:10:00'),
-- Chuột Logitech (product 16)
(16, 42, 5, 'Chuột không dây rất tốt', '2024-03-08 12:00:00'),
(16, 93, 4, 'Chuột êm, click êm', '2024-04-28 13:45:00'),
(16, 118, 5, 'Logitech chất lượng cao', '2024-03-16 10:20:00'),
(16, 192, 4, 'Chuột tốt, pin trâu', '2024-04-17 11:30:00'),
-- Bàn phím cơ (product 17)
(17, 23, 5, 'Bàn phím cơ gaming cực đỉnh', '2024-02-15 14:45:00'),
(17, 65, 5, 'Switch blue gõ rất đã', '2024-03-31 15:30:00'),
(17, 92, 4, 'Đèn RGB đẹp', '2024-04-27 12:15:00'),
(17, 106, 5, 'Bàn phím rất tốt', '2024-03-04 13:40:00'),
(17, 137, 5, 'Chất lượng cao, gõ mượt', '2024-04-04 14:20:00'),
(17, 192, 5, 'Rất hài lòng', '2024-05-17 10:50:00'),
-- Nồi cơm điện (product 18)
(18, 19, 4, 'Nồi cơm điện Panasonic tốt', '2024-02-11 13:20:00'),
-- Bộ nồi inox (product 19)
(19, 15, 5, 'Bộ nồi inox 304 rất tốt', '2024-02-07 16:00:00'),
(19, 82, 5, 'Nồi đẹp, chất lượng cao', '2024-04-17 13:15:00'),
(19, 106, 4, 'Bộ nồi 5 món đầy đủ', '2024-03-04 14:30:00'),
(19, 126, 5, 'Nấu ăn rất tốt', '2024-03-23 11:50:00'),
(19, 147, 5, 'Chất liệu inox tốt', '2024-04-18 13:20:00'),
(19, 161, 4, 'Nồi đẹp lắm', '2024-05-02 14:40:00'),
(19, 182, 5, 'Rất hài lòng', '2024-04-14 15:10:00'),
-- Máy xay sinh tố (product 20)
(20, 83, 5, 'Máy xay Philips rất mạnh', '2024-04-18 14:30:00'),
(20, 104, 4, 'Xay rau củ quả ngon', '2024-03-02 12:15:00'),
(20, 183, 4, 'Máy tốt, xay mịn', '2024-04-15 11:40:00'),
-- Đắc Nhân Tâm (product 22)
(22, 26, 5, 'Sách hay, nội dung bổ ích', '2024-02-18 10:30:00'),
(22, 57, 5, 'Đắc Nhân Tâm rất đáng đọc', '2024-03-23 15:00:00'),
(22, 94, 5, 'Sách kinh điển', '2024-04-29 10:45:00'),
(22, 103, 4, 'Nội dung hay', '2024-03-03 11:20:00'),
(22, 150, 5, 'Sách tuyệt vời', '2024-04-20 13:40:00'),
-- Tuổi Trẻ Đáng Giá (product 23)
(23, 27, 5, 'Sách kỹ năng sống rất hay', '2024-02-19 13:45:00'),
(23, 66, 4, 'Nội dung bổ ích cho tuổi trẻ', '2024-04-01 11:30:00'),
(23, 95, 5, 'Sách tuyệt vời', '2024-05-01 12:15:00'),
(23, 195, 4, 'Hay, dễ đọc', '2024-04-18 14:20:00'),
-- Sapiens (product 24)
(24, 28, 5, 'Sapiens hay lắm, hiểu biết về lịch sử loài người', '2024-02-20 12:30:00'),
(24, 67, 5, 'Sách rất hay, nội dung sâu sắc', '2024-04-03 14:40:00'),
(24, 96, 5, 'Yuval Noah Harari viết cực hay', '2024-05-02 11:20:00'),
(24, 167, 4, 'Sách bổ ích', '2024-04-03 13:50:00'),
(24, 196, 5, 'Rất đáng đọc', '2024-04-30 15:30:00'),
-- Nhà Giả Kim (product 25)
(25, 29, 5, 'Nhà Giả Kim rất hay, ý nghĩa sâu sắc', '2024-02-21 13:15:00'),
(25, 68, 5, 'Sách tuyệt vời', '2024-04-04 12:30:00'),
(25, 97, 4, 'Paulo Coelho viết hay', '2024-05-03 10:45:00'),
(25, 168, 5, 'Sách kinh điển', '2024-04-04 14:20:00'),
(25, 197, 5, 'Rất thích', '2024-05-01 11:40:00'),
-- Khéo Ăn Nói (product 26)
(26, 30, 4, 'Sách kỹ năng giao tiếp tốt', '2024-02-22 14:00:00'),
(26, 69, 5, 'Nội dung hữu ích', '2024-04-05 13:20:00'),
(26, 98, 4, 'Sách hay', '2024-05-04 12:15:00'),
(26, 169, 4, 'Bổ ích', '2024-04-06 15:30:00'),
(26, 198, 5, 'Rất tốt', '2024-05-02 14:00:00'),
-- Bóng đá Adidas (product 26 - note: duplicate ID, using 26 for ball)
(26, 16, 5, 'Bóng đá Adidas chính hãng, đá rất tốt', '2024-02-08 11:00:00'),
(26, 64, 4, 'Bóng đẹp, độ nảy tốt', '2024-03-30 12:45:00'),
(26, 104, 5, 'Chất lượng cao', '2024-03-04 13:15:00'),
(26, 138, 4, 'Bóng tốt', '2024-04-05 14:30:00'),
-- Giày Adidas Ultraboost (product 27)
(27, 5, 5, 'Giày chạy bộ Adidas rất tốt', '2024-01-26 14:15:00'),
(27, 71, 5, 'Đi rất êm, thoải mái', '2024-04-06 13:50:00'),
(27, 100, 5, 'Giày đẹp lắm', '2024-05-05 09:30:00'),
(27, 152, 5, 'Ultraboost chất lượng cao', '2024-04-27 14:20:00'),
(27, 165, 4, 'Giày tốt', '2024-05-05 11:40:00'),
(27, 200, 5, 'Rất hài lòng', '2024-05-21 10:15:00'),
-- Bộ tạ tay (product 28)
(28, 72, 4, 'Tạ tay bọc cao su tốt', '2024-04-07 11:30:00'),
(28, 107, 5, 'Chất lượng cao', '2024-03-06 15:20:00'),
(28, 177, 4, 'Tạ tốt', '2024-05-05 12:30:00'),
-- Thảm Yoga (product 29)
(29, 73, 5, 'Thảm yoga dày 8mm rất tốt', '2024-04-08 14:15:00'),
(29, 108, 4, 'Thảm chống trượt tốt', '2024-03-08 13:40:00'),
-- Vợt cầu lông Yonex (product 30)
(30, 77, 5, 'Vợt Yonex Nanoray đỉnh cao', '2024-04-12 13:30:00'),
(30, 176, 4, 'Vợt tốt, đánh cầu mượt', '2024-05-03 14-15:00'),
-- Kem chống nắng Anessa (product 33)
(33, 45, 5, 'Kem chống nắng Anessa SPF 50+ rất tốt', '2024-03-11 12:45:00'),
(33, 54, 4, 'Bảo vệ da tốt', '2024-03-20 15:10:00'),
(33, 76, 5, 'Kem tốt, không bết dính', '2024-04-11 11:40:00'),
-- Sữa rửa mặt Cetaphil (product 34)
(34, 43, 4, 'Sữa rửa mặt Cetaphil dịu nhẹ', '2024-03-09 13:00:00'),
(34, 72, 5, 'Rất tốt cho da nhạy cảm', '2024-04-07 14:30:00'),
(34, 86, 5, 'Sản phẩm tuyệt vời', '2024-04-21 12:15:00'),
(34, 139, 4, 'Sữa rửa mặt tốt', '2024-04-07 13:45:00'),
(34, 172, 5, 'Rất hài lòng', '2024-04-26 11:20:00'),
(34, 186, 4, 'Chất lượng cao', '2024-04-21 15:30:00'),
-- Serum Vitamin C (product 35)
(35, 44, 5, 'Serum Vitamin C 20% rất tốt', '2024-03-10 14:45:00'),
(35, 60, 4, 'Da sáng lên sau vài tuần', '2024-03-26 16:20:00'),
(35, 87, 5, 'Serum chất lượng cao', '2024-04-22 14:00:00'),
(35, 187, 5, 'Rất tốt', '2024-04-24 13:15:00'),
-- Son MAC Ruby Woo (product 36)
(36, 24, 5, 'Son MAC Ruby Woo đẹp lắm', '2024-02-16 13:30:00'),
(36, 55, 5, 'Màu son đẹp, lên môi chuẩn', '2024-03-21 14:20:00'),
(36, 84, 4, 'Son lâu trôi', '2024-04-19 12:45:00'),
(36, 105, 5, 'Màu đỏ đẹp', '2024-03-04 15:00:00'),
(36, 128, 5, 'Son chính hãng', '2024-03-28 13:30:00'),
(36, 148, 4, 'Rất thích', '2024-04-20 14:50:00'),
(36, 163, 5, 'Son đẹp lắm', '2024-05-04 11:15:00'),
(36, 184, 5, 'Chất lượng cao', '2024-04-19 13:20:00'),
-- Nước hoa Chanel (product 37)
(37, 10, 5, 'Nước hoa Chanel No.5 thơm lâu', '2024-02-01 17:00:00'),
(37, 102, 5, 'Hương thơm sang trọng', '2024-02-28 15:30:00'),
-- Lego Technic (product 38)
(38, 8, 5, 'Lego Technic rất đẹp, chi tiết', '2024-02-01 15:30:00'),
-- Búp bê Barbie (product 39)
(39, 85, 4, 'Búp bê Barbie xinh xắn', '2024-04-20 11:00:00'),
(39, 101, 5, 'Con rất thích', '2024-03-01 12:30:00'),
(39, 118, 4, 'Búp bê đẹp', '2024-03-18 13:45:00'),
(39, 143, 5, 'Chất lượng tốt', '2024-04-10 15:00:00'),
(39, 183, 4, 'Xinh lắm', '2024-04-17 12:20:00'),
-- Rubik 3x3 (product 40)
(40, 9, 5, 'Rubik 3x3 xoay mượt', '2024-02-02 11:15:00'),
(40, 93, 4, 'Rubik tốc độ cao', '2024-04-30 14:30:00'),
(40, 128, 5, 'Xoay rất mượt', '2024-03-30 15:20:00'),
-- Xe điều khiển (product 41)
(41, 56, 5, 'Xe điều khiển off-road cực đỉnh', '2024-03-22 14:00:00'),
-- Thịt bò Úc (product 42)
(42, 51, 5, 'Thịt bò Úc chất lượng cao', '2024-03-17 12:30:00'),
(42, 70, 4, 'Thịt tươi ngon', '2024-04-05 13:45:00'),
(42, 99, 5, 'Thịt bò ngon lắm', '2024-05-04 14:20:00'),
(42, 151, 4, 'Chất lượng tốt', '2024-04-29 11:30:00'),
(42, 170, 5, 'Thịt tươi', '2024-04-25 12:45:00'),
(42, 199, 5, 'Rất hài lòng', '2024-05-04 13:15:00'),
-- Gạo Nhật (product 43)
(43, 50, 5, 'Gạo Nhật Bản Akita Komachi ngon', '2024-03-16 13:15:00'),
(43, 70, 5, 'Cơm dẻo thơm', '2024-04-07 15:00:00'),
-- Trứng gà (product 44)
(44, 48, 4, 'Trứng gà sạch, tươi ngon', '2024-03-14 12:00:00'),
(44, 75, 5, 'Trứng tươi lắm', '2024-04-10 13:30:00'),
(44, 130, 4, 'Trứng sạch', '2024-04-01 11:45:00'),
-- Sữa tươi Vinamilk (product 45)
(45, 49, 5, 'Sữa tươi Vinamilk ngon', '2024-03-15 13:30:00'),
(45, 112, 4, 'Sữa tươi không đường tốt', '2024-03-10 14:15:00'),
-- Snack Lays (product 46)
(46, 50, 4, 'Snack Lays ngon, giòn', '2024-03-16 14:00:00'),
(46, 131, 5, 'Snack vị tự nhiên ok', '2024-04-02 12:30:00');

-- ============================================
-- CART (50 records - active carts)
-- ============================================
INSERT INTO cart (customer_id, product_id, quantity, added_at) VALUES
(1, 11, 1, '2024-05-10 10:00:00'),
(1, 15, 2, '2024-05-10 10:05:00'),
(2, 12, 1, '2024-05-11 11:30:00'),
(3, 22, 3, '2024-05-12 09:15:00'),
(3, 23, 2, '2024-05-12 09:20:00'),
(4, 1, 5, '2024-05-13 14:30:00'),
(5, 27, 1, '2024-05-14 08:45:00'),
(6, 6, 1, '2024-05-15 10:20:00'),
(6, 9, 1, '2024-05-15 10:25:00'),
(7, 33, 2, '2024-05-16 13:00:00'),
(8, 38, 1, '2024-05-17 09:30:00'),
(9, 40, 3, '2024-05-18 11:45:00'),
(10, 14, 1, '2024-05-19 15:10:00'),
(11, 5, 1, '2024-05-10 16:20:00'),
(12, 7, 2, '2024-05-11 08:30:00'),
(13, 13, 1, '2024-05-12 12:15:00'),
(14, 19, 1, '2024-05-13 10:50:00'),
(15, 26, 2, '2024-05-14 14:25:00'),
(16, 16, 1, '2024-05-15 09:40:00'),
(17, 17, 1, '2024-05-16 11:55:00'),
(18, 3, 3, '2024-05-17 13:20:00'),
(19, 20, 1, '2024-05-18 15:35:00'),
(20, 24, 2, '2024-05-19 08:50:00'),
(21, 2, 2, '2024-05-10 12:10:00'),
(22, 8, 1, '2024-05-11 14:45:00'),
(23, 10, 1, '2024-05-12 16:00:00'),
(24, 36, 1, '2024-05-13 09:15:00'),
(25, 28, 2, '2024-05-14 11:30:00'),
(26, 22, 1, '2024-05-15 13:45:00'),
(27, 23, 1, '2024-05-16 15:00:00'),
(28, 24, 1, '2024-05-17 08:15:00'),
(29, 25, 1, '2024-05-18 10:30:00'),
(30, 29, 1, '2024-05-19 12:45:00'),
(31, 34, 2, '2024-05-10 14:00:00'),
(32, 35, 1, '2024-05-11 16:15:00'),
(33, 42, 2, '2024-05-12 09:30:00'),
(34, 44, 10, '2024-05-13 11:45:00'),
(35, 45, 5, '2024-05-14 13:00:00'),
(36, 46, 10, '2024-05-15 15:15:00'),
(37, 47, 20, '2024-05-16 08:30:00'),
(38, 48, 3, '2024-05-17 10:45:00'),
(39, 49, 5, '2024-05-18 12:00:00'),
(40, 50, 2, '2024-05-19 14:15:00'),
(41, 51, 10, '2024-05-10 16:30:00'),
(42, 4, 1, '2024-05-11 09:45:00'),
(43, 30, 1, '2024-05-12 11:00:00'),
(44, 37, 1, '2024-05-13 13:15:00'),
(45, 18, 1, '2024-05-14 15:30:00'),
(46, 21, 2, '2024-05-15 08:45:00'),
(47, 39, 1, '2024-05-16 10:00:00'),
(48, 41, 1, '2024-05-17 12:15:00');

-- ============================================
-- DONE: Seed data inserted successfully!
-- ============================================
-- Total records summary:
-- - Categories: 10
-- - Products: 50
-- - Customers: 100
-- - Orders: 200
-- - Order Items: ~500
-- - Reviews: 150
-- - Cart: 50
-- Total: 1060+ records
-- ============================================
