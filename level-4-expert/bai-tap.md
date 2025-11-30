# Bài Tập Level 4 - Expert

15 bài tập tổng hợp Indexes, Transactions, Stored Procedures, và Views.

## Part 1: Indexes & Optimization (5 bài)

### Bài 1: Analyze Slow Query
Phân tích query sau và đề xuất indexes tối ưu:

```sql
SELECT
    c.name AS customer_name,
    o.created_at,
    o.total_amount,
    p.name AS product_name,
    oi.quantity
FROM customers c
JOIN orders o ON c.id = o.customer_id
JOIN order_items oi ON o.id = oi.order_id
JOIN products p ON oi.product_id = p.id
WHERE o.status = 'delivered'
  AND o.created_at >= '2024-01-01'
  AND c.city = 'Hà Nội'
ORDER BY o.created_at DESC
LIMIT 100;
```

**Tasks:**
- Dùng EXPLAIN để phân tích
- Tạo indexes phù hợp
- So sánh performance trước/sau

<details>
<summary>Đáp án</summary>

```sql
-- 1. Analyze current performance
EXPLAIN SELECT
    c.name AS customer_name,
    o.created_at,
    o.total_amount,
    p.name AS product_name,
    oi.quantity
FROM customers c
JOIN orders o ON c.id = o.customer_id
JOIN order_items oi ON o.id = oi.order_id
JOIN products p ON oi.product_id = p.id
WHERE o.status = 'delivered'
  AND o.created_at >= '2024-01-01'
  AND c.city = 'Hà Nội'
ORDER BY o.created_at DESC
LIMIT 100;

-- 2. Create optimal indexes
-- Foreign keys first
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);

-- Composite index for WHERE and ORDER BY
CREATE INDEX idx_orders_status_created ON orders(status, created_at);

-- Index for customer city filter
CREATE INDEX idx_customers_city ON customers(city);

-- 3. Alternative: Covering index for orders
CREATE INDEX idx_orders_covering
ON orders(status, created_at, customer_id, total_amount);

-- 4. Re-analyze
EXPLAIN SELECT ...;
-- Should see type: ref, much fewer rows scanned
```

</details>

---

### Bài 2: Identify Missing Indexes
Tìm tables thiếu indexes cho foreign keys.

**Output:** table_name, column_name, referenced_table

<details>
<summary>Đáp án</summary>

```sql
SELECT
    TABLE_NAME,
    COLUMN_NAME,
    REFERENCED_TABLE_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE REFERENCED_TABLE_SCHEMA = 'ecommerce_db'
  AND CONSTRAINT_NAME != 'PRIMARY'
  AND CONCAT(TABLE_NAME, '.', COLUMN_NAME) NOT IN (
      SELECT CONCAT(TABLE_NAME, '.', COLUMN_NAME)
      FROM information_schema.STATISTICS
      WHERE TABLE_SCHEMA = 'ecommerce_db'
        AND INDEX_NAME != 'PRIMARY'
  )
ORDER BY TABLE_NAME, COLUMN_NAME;

-- Create missing indexes
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
CREATE INDEX idx_products_category_id ON products(category_id);
CREATE INDEX idx_reviews_product_id ON reviews(product_id);
CREATE INDEX idx_reviews_customer_id ON reviews(customer_id);
```

</details>

---

### Bài 3: Composite Index Strategy
Design composite indexes cho các queries thường dùng:

```sql
-- Query 1: Customer orders by status
SELECT * FROM orders
WHERE customer_id = ? AND status = 'pending'
ORDER BY created_at DESC;

-- Query 2: Products by category and price range
SELECT * FROM products
WHERE category_id = ? AND price BETWEEN ? AND ?
ORDER BY price;

-- Query 3: Recent delivered orders
SELECT * FROM orders
WHERE status = 'delivered'
  AND created_at >= ?
ORDER BY created_at DESC;
```

<details>
<summary>Đáp án</summary>

```sql
-- Query 1: customer_id most selective, then status, then created_at for ORDER BY
CREATE INDEX idx_orders_customer_status_created
ON orders(customer_id, status, created_at);

-- Query 2: category_id first, then price for range
CREATE INDEX idx_products_category_price
ON products(category_id, price);

-- Query 3: status first (for WHERE), then created_at (for WHERE and ORDER BY)
CREATE INDEX idx_orders_status_created
ON orders(status, created_at);

-- Verify with EXPLAIN
EXPLAIN SELECT * FROM orders
WHERE customer_id = 1 AND status = 'pending'
ORDER BY created_at DESC;
-- Should use idx_orders_customer_status_created

EXPLAIN SELECT * FROM products
WHERE category_id = 1 AND price BETWEEN 100000 AND 500000
ORDER BY price;
-- Should use idx_products_category_price

EXPLAIN SELECT * FROM orders
WHERE status = 'delivered'
  AND created_at >= '2024-01-01'
ORDER BY created_at DESC;
-- Should use idx_orders_status_created
```

</details>

---

### Bài 4: Index Maintenance
Viết procedure để analyze và optimize tables.

<details>
<summary>Đáp án</summary>

```sql
DELIMITER $$

CREATE PROCEDURE maintain_database_indexes()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_table_name VARCHAR(64);

    -- Cursor for all tables
    DECLARE table_cursor CURSOR FOR
        SELECT TABLE_NAME
        FROM information_schema.TABLES
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_TYPE = 'BASE TABLE';

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Create log table if not exists
    CREATE TABLE IF NOT EXISTS maintenance_log (
        id INT AUTO_INCREMENT PRIMARY KEY,
        table_name VARCHAR(64),
        action VARCHAR(50),
        executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

    OPEN table_cursor;

    maintenance_loop: LOOP
        FETCH table_cursor INTO v_table_name;

        IF done THEN
            LEAVE maintenance_loop;
        END IF;

        -- Analyze table
        SET @sql = CONCAT('ANALYZE TABLE ', v_table_name);
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        INSERT INTO maintenance_log (table_name, action)
        VALUES (v_table_name, 'ANALYZE');

        -- Optimize table (skip during peak hours)
        IF HOUR(NOW()) BETWEEN 2 AND 5 THEN
            SET @sql = CONCAT('OPTIMIZE TABLE ', v_table_name);
            PREPARE stmt FROM @sql;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;

            INSERT INTO maintenance_log (table_name, action)
            VALUES (v_table_name, 'OPTIMIZE');
        END IF;

    END LOOP;

    CLOSE table_cursor;

    -- Summary
    SELECT
        action,
        COUNT(*) AS count,
        MAX(executed_at) AS last_executed
    FROM maintenance_log
    WHERE DATE(executed_at) = CURDATE()
    GROUP BY action;
END$$

DELIMITER ;

-- Run maintenance
CALL maintain_database_indexes();
```

</details>

---

### Bài 5: Query Performance Report
Tạo view để monitor query performance metrics.

<details>
<summary>Đáp án</summary>

```sql
-- Create view for index usage
CREATE OR REPLACE VIEW index_usage_stats AS
SELECT
    OBJECT_SCHEMA AS database_name,
    OBJECT_NAME AS table_name,
    INDEX_NAME AS index_name,
    COUNT_STAR AS total_access,
    COUNT_READ AS read_operations,
    COUNT_WRITE AS write_operations,
    COUNT_FETCH AS fetch_operations,
    COUNT_INSERT AS insert_operations,
    COUNT_UPDATE AS update_operations,
    COUNT_DELETE AS delete_operations
FROM performance_schema.table_io_waits_summary_by_index_usage
WHERE OBJECT_SCHEMA = 'ecommerce_db'
  AND INDEX_NAME IS NOT NULL
ORDER BY COUNT_STAR DESC;

-- Unused indexes
CREATE OR REPLACE VIEW unused_indexes AS
SELECT
    OBJECT_SCHEMA AS database_name,
    OBJECT_NAME AS table_name,
    INDEX_NAME AS index_name
FROM performance_schema.table_io_waits_summary_by_index_usage
WHERE OBJECT_SCHEMA = 'ecommerce_db'
  AND INDEX_NAME IS NOT NULL
  AND INDEX_NAME != 'PRIMARY'
  AND COUNT_STAR = 0
ORDER BY OBJECT_NAME, INDEX_NAME;

-- Table size statistics
CREATE OR REPLACE VIEW table_size_stats AS
SELECT
    TABLE_NAME AS table_name,
    ROUND(DATA_LENGTH / 1024 / 1024, 2) AS data_size_mb,
    ROUND(INDEX_LENGTH / 1024 / 1024, 2) AS index_size_mb,
    ROUND((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024, 2) AS total_size_mb,
    TABLE_ROWS AS row_count
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'ecommerce_db'
  AND TABLE_TYPE = 'BASE TABLE'
ORDER BY (DATA_LENGTH + INDEX_LENGTH) DESC;

-- Query these views
SELECT * FROM index_usage_stats LIMIT 20;
SELECT * FROM unused_indexes;
SELECT * FROM table_size_stats;
```

</details>

---

## Part 2: Transactions (5 bài)

### Bài 6: Order Processing Transaction
Tạo procedure xử lý order với proper transaction handling.

**Requirements:**
1. Validate stock availability
2. Create order và order_items
3. Update product stock
4. Handle errors và rollback
5. Return order_id hoặc error message

<details>
<summary>Đáp án</summary>

```sql
DELIMITER $$

CREATE PROCEDURE process_new_order(
    IN p_customer_id INT,
    IN p_products JSON,  -- [{"product_id": 1, "quantity": 2}, ...]
    IN p_payment_method VARCHAR(50),
    OUT p_order_id INT,
    OUT p_success BOOLEAN,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE v_total_amount DECIMAL(10,2) DEFAULT 0;
    DECLARE v_product_id INT;
    DECLARE v_quantity INT;
    DECLARE v_price DECIMAL(10,2);
    DECLARE v_stock INT;
    DECLARE v_idx INT DEFAULT 0;
    DECLARE v_count INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_success = FALSE;
        SET p_message = 'Transaction failed - database error';
        SET p_order_id = NULL;
    END;

    START TRANSACTION;

    -- Get product count from JSON
    SET v_count = JSON_LENGTH(p_products);

    -- Validate all products first
    WHILE v_idx < v_count DO
        SET v_product_id = JSON_EXTRACT(p_products, CONCAT('$[', v_idx, '].product_id'));
        SET v_quantity = JSON_EXTRACT(p_products, CONCAT('$[', v_idx, '].quantity'));

        -- Check stock
        SELECT stock, price
        INTO v_stock, v_price
        FROM products
        WHERE id = v_product_id
        FOR UPDATE;

        IF v_stock < v_quantity THEN
            ROLLBACK;
            SET p_success = FALSE;
            SET p_message = CONCAT('Insufficient stock for product ID ', v_product_id);
            SET p_order_id = NULL;
            LEAVE;
        END IF;

        SET v_total_amount = v_total_amount + (v_price * v_quantity);
        SET v_idx = v_idx + 1;
    END WHILE;

    -- If validation passed
    IF p_success IS NULL THEN
        -- Create order
        INSERT INTO orders (customer_id, total_amount, status, payment_method)
        VALUES (p_customer_id, v_total_amount, 'pending', p_payment_method);

        SET p_order_id = LAST_INSERT_ID();

        -- Reset counter
        SET v_idx = 0;

        -- Create order items and update stock
        WHILE v_idx < v_count DO
            SET v_product_id = JSON_EXTRACT(p_products, CONCAT('$[', v_idx, '].product_id'));
            SET v_quantity = JSON_EXTRACT(p_products, CONCAT('$[', v_idx, '].quantity'));

            SELECT price INTO v_price
            FROM products
            WHERE id = v_product_id;

            -- Insert order item
            INSERT INTO order_items (order_id, product_id, quantity, price, subtotal)
            VALUES (p_order_id, v_product_id, v_quantity, v_price, v_price * v_quantity);

            -- Update stock
            UPDATE products
            SET stock = stock - v_quantity
            WHERE id = v_product_id;

            SET v_idx = v_idx + 1;
        END WHILE;

        SET p_success = TRUE;
        SET p_message = 'Order created successfully';
        COMMIT;
    END IF;
END$$

DELIMITER ;

-- Test
SET @products = '[{"product_id": 1, "quantity": 2}, {"product_id": 2, "quantity": 1}]';
CALL process_new_order(1, @products, 'credit_card', @order_id, @success, @message);
SELECT @order_id, @success, @message;
```

</details>

---

### Bài 7: Inventory Transfer
Tạo procedure để transfer stock giữa 2 warehouses với transaction safety.

<details>
<summary>Đáp án</summary>

```sql
DELIMITER $$

CREATE PROCEDURE transfer_inventory(
    IN p_product_id INT,
    IN p_from_warehouse_id INT,
    IN p_to_warehouse_id INT,
    IN p_quantity INT,
    OUT p_success BOOLEAN,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE v_from_stock INT;
    DECLARE v_transfer_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_success = FALSE;
        SET p_message = 'Transfer failed';
    END;

    START TRANSACTION;

    -- Lock and check source stock
    SELECT stock INTO v_from_stock
    FROM warehouse_inventory
    WHERE product_id = p_product_id
      AND warehouse_id = p_from_warehouse_id
    FOR UPDATE;

    -- Validate
    IF v_from_stock IS NULL THEN
        ROLLBACK;
        SET p_success = FALSE;
        SET p_message = 'Product not found in source warehouse';
    ELSEIF v_from_stock < p_quantity THEN
        ROLLBACK;
        SET p_success = FALSE;
        SET p_message = 'Insufficient stock in source warehouse';
    ELSE
        -- Deduct from source
        UPDATE warehouse_inventory
        SET stock = stock - p_quantity
        WHERE product_id = p_product_id
          AND warehouse_id = p_from_warehouse_id;

        -- Add to destination
        INSERT INTO warehouse_inventory (warehouse_id, product_id, stock)
        VALUES (p_to_warehouse_id, p_product_id, p_quantity)
        ON DUPLICATE KEY UPDATE stock = stock + p_quantity;

        -- Log transfer
        INSERT INTO inventory_transfers
            (product_id, from_warehouse_id, to_warehouse_id, quantity, created_at)
        VALUES
            (p_product_id, p_from_warehouse_id, p_to_warehouse_id, p_quantity, NOW());

        SET p_success = TRUE;
        SET p_message = 'Transfer completed successfully';
        COMMIT;
    END IF;
END$$

DELIMITER ;
```

</details>

---

### Bài 8: Handle Concurrent Orders
Test và fix race condition khi 2 customers order cùng 1 product với stock = 1.

<details>
<summary>Đáp án</summary>

```sql
DELIMITER $$

-- WRONG: Race condition possible
CREATE PROCEDURE order_product_unsafe(
    IN p_customer_id INT,
    IN p_product_id INT,
    IN p_quantity INT
)
BEGIN
    DECLARE v_stock INT;

    -- Check stock
    SELECT stock INTO v_stock
    FROM products
    WHERE id = p_product_id;

    IF v_stock >= p_quantity THEN
        -- ⚠️ Race condition here! Another transaction can execute between SELECT and UPDATE

        INSERT INTO orders (customer_id, total_amount)
        SELECT p_customer_id, price * p_quantity
        FROM products WHERE id = p_product_id;

        UPDATE products
        SET stock = stock - p_quantity
        WHERE id = p_product_id;
    END IF;
END$$

-- CORRECT: Use FOR UPDATE lock
CREATE PROCEDURE order_product_safe(
    IN p_customer_id INT,
    IN p_product_id INT,
    IN p_quantity INT,
    OUT p_success BOOLEAN,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE v_stock INT;
    DECLARE v_price DECIMAL(10,2);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_success = FALSE;
        SET p_message = 'Order failed';
    END;

    START TRANSACTION;

    -- Lock row atomically
    SELECT stock, price
    INTO v_stock, v_price
    FROM products
    WHERE id = p_product_id
    FOR UPDATE;  -- 🔒 Lock prevents concurrent access

    IF v_stock < p_quantity THEN
        ROLLBACK;
        SET p_success = FALSE;
        SET p_message = 'Insufficient stock';
    ELSE
        INSERT INTO orders (customer_id, total_amount, status)
        VALUES (p_customer_id, v_price * p_quantity, 'pending');

        INSERT INTO order_items (order_id, product_id, quantity, price, subtotal)
        VALUES (LAST_INSERT_ID(), p_product_id, p_quantity, v_price, v_price * p_quantity);

        UPDATE products
        SET stock = stock - p_quantity
        WHERE id = p_product_id;

        SET p_success = TRUE;
        SET p_message = 'Order created';
        COMMIT;
    END IF;
END$$

DELIMITER ;

-- Test concurrently in 2 terminals
-- Terminal 1:
CALL order_product_safe(1, 1, 1, @s1, @m1);

-- Terminal 2 (simultaneously):
CALL order_product_safe(2, 1, 1, @s2, @m2);

-- Only one should succeed
SELECT @s1, @m1;  -- TRUE, 'Order created'
SELECT @s2, @m2;  -- FALSE, 'Insufficient stock'
```

</details>

---

### Bài 9: Deadlock Prevention
Fix deadlock trong procedure update multiple products.

<details>
<summary>Đáp án</summary>

```sql
DELIMITER $$

-- WRONG: Can cause deadlock
CREATE PROCEDURE update_products_wrong(IN p_product_ids JSON)
BEGIN
    DECLARE v_idx INT DEFAULT 0;
    DECLARE v_count INT;
    DECLARE v_product_id INT;

    START TRANSACTION;

    SET v_count = JSON_LENGTH(p_product_ids);

    WHILE v_idx < v_count DO
        SET v_product_id = JSON_EXTRACT(p_product_ids, CONCAT('$[', v_idx, ']'));

        -- ⚠️ Random order can cause deadlock
        UPDATE products
        SET stock = stock - 1
        WHERE id = v_product_id;

        SET v_idx = v_idx + 1;
    END WHILE;

    COMMIT;
END$$

-- CORRECT: Lock in consistent order
CREATE PROCEDURE update_products_safe(IN p_product_ids JSON)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- Lock all products in ID order (prevents deadlock)
    UPDATE products
    SET stock = stock - 1
    WHERE id IN (
        SELECT product_id
        FROM (
            SELECT JSON_EXTRACT(p_product_ids, CONCAT('$[', idx, ']')) AS product_id
            FROM (
                SELECT 0 AS idx UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4
                UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9
            ) AS numbers
            WHERE idx < JSON_LENGTH(p_product_ids)
        ) AS temp
    )
    ORDER BY id;  -- 🔑 Consistent order prevents deadlock

    COMMIT;
END$$

DELIMITER ;
```

</details>

---

### Bài 10: Retry Logic for Deadlocks
Implement retry mechanism khi gặp deadlock.

<details>
<summary>Đáp án</summary>

```sql
DELIMITER $$

CREATE PROCEDURE create_order_with_retry(
    IN p_customer_id INT,
    IN p_product_id INT,
    IN p_quantity INT,
    OUT p_order_id INT,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE v_retry_count INT DEFAULT 0;
    DECLARE v_max_retries INT DEFAULT 3;
    DECLARE v_deadlock INT DEFAULT 0;
    DECLARE v_price DECIMAL(10,2);

    retry_loop: LOOP
        BEGIN
            -- Deadlock handler
            DECLARE CONTINUE HANDLER FOR 1213  -- Deadlock error code
            BEGIN
                SET v_deadlock = 1;
            END;

            DECLARE EXIT HANDLER FOR SQLEXCEPTION
            BEGIN
                ROLLBACK;
                IF v_deadlock = 0 THEN
                    SET p_message = 'Database error';
                    LEAVE retry_loop;
                END IF;
            END;

            SET v_deadlock = 0;
            START TRANSACTION;

            -- Lock product
            SELECT price INTO v_price
            FROM products
            WHERE id = p_product_id
            FOR UPDATE;

            -- Create order
            INSERT INTO orders (customer_id, total_amount, status)
            VALUES (p_customer_id, v_price * p_quantity, 'pending');

            SET p_order_id = LAST_INSERT_ID();

            -- Update stock
            UPDATE products
            SET stock = stock - p_quantity
            WHERE id = p_product_id
              AND stock >= p_quantity;

            IF ROW_COUNT() = 0 THEN
                ROLLBACK;
                SET p_message = 'Insufficient stock';
                LEAVE retry_loop;
            END IF;

            COMMIT;
            SET p_message = 'Order created successfully';
            LEAVE retry_loop;
        END;

        -- Handle deadlock
        IF v_deadlock = 1 THEN
            SET v_retry_count = v_retry_count + 1;

            IF v_retry_count >= v_max_retries THEN
                SET p_message = 'Failed after retries due to deadlock';
                SET p_order_id = NULL;
                LEAVE retry_loop;
            END IF;

            -- Wait before retry (exponential backoff)
            DO SLEEP(v_retry_count * 0.1);
        END IF;
    END LOOP;
END$$

DELIMITER ;
```

</details>

---

## Part 3: Stored Procedures & Views (5 bài)

### Bài 11: Comprehensive Analytics View
Tạo view phân tích toàn diện về sales performance.

<details>
<summary>Đáp án</summary>

```sql
CREATE OR REPLACE VIEW sales_analytics AS
SELECT
    DATE_FORMAT(o.created_at, '%Y-%m') AS month,
    DATE_FORMAT(o.created_at, '%Y-%m-%d') AS date,
    cat.name AS category,
    c.city,

    -- Order metrics
    COUNT(DISTINCT o.id) AS order_count,
    COUNT(DISTINCT o.customer_id) AS unique_customers,
    AVG(o.total_amount) AS avg_order_value,

    -- Product metrics
    SUM(oi.quantity) AS units_sold,
    COUNT(DISTINCT oi.product_id) AS unique_products,

    -- Revenue metrics
    SUM(oi.subtotal) AS gross_revenue,
    SUM(o.total_amount) AS total_revenue,

    -- Customer segments
    SUM(CASE WHEN o.total_amount < 500000 THEN 1 ELSE 0 END) AS small_orders,
    SUM(CASE WHEN o.total_amount BETWEEN 500000 AND 2000000 THEN 1 ELSE 0 END) AS medium_orders,
    SUM(CASE WHEN o.total_amount > 2000000 THEN 1 ELSE 0 END) AS large_orders,

    -- Payment methods
    SUM(CASE WHEN o.payment_method = 'credit_card' THEN o.total_amount ELSE 0 END) AS credit_card_revenue,
    SUM(CASE WHEN o.payment_method = 'bank_transfer' THEN o.total_amount ELSE 0 END) AS bank_transfer_revenue,
    SUM(CASE WHEN o.payment_method = 'cash' THEN o.total_amount ELSE 0 END) AS cash_revenue

FROM orders o
JOIN customers c ON o.customer_id = c.id
JOIN order_items oi ON o.id = oi.order_id
JOIN products p ON oi.product_id = p.id
JOIN categories cat ON p.category_id = cat.id
WHERE o.status = 'delivered'
GROUP BY month, date, cat.name, c.city
WITH CHECK OPTION;

-- Usage examples
SELECT * FROM sales_analytics
WHERE month = DATE_FORMAT(CURDATE(), '%Y-%m')
ORDER BY gross_revenue DESC;

SELECT
    category,
    SUM(gross_revenue) AS total_revenue,
    SUM(units_sold) AS total_units
FROM sales_analytics
WHERE month >= DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 6 MONTH), '%Y-%m')
GROUP BY category
ORDER BY total_revenue DESC;
```

</details>

---

### Bài 12: Data Cleanup Procedure
Tạo procedure tự động cleanup old data.

<details>
<summary>Đáp án</summary>

```sql
DELIMITER $$

CREATE PROCEDURE cleanup_old_data(
    IN p_days_old INT,
    IN p_dry_run BOOLEAN,
    OUT p_deleted_count INT
)
BEGIN
    DECLARE v_cart_deleted INT DEFAULT 0;
    DECLARE v_logs_deleted INT DEFAULT 0;
    DECLARE v_sessions_deleted INT DEFAULT 0;

    -- Create log table if not exists
    CREATE TABLE IF NOT EXISTS cleanup_log (
        id INT AUTO_INCREMENT PRIMARY KEY,
        table_name VARCHAR(64),
        rows_deleted INT,
        cleanup_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

    IF p_dry_run THEN
        -- Dry run: Show what would be deleted
        SELECT 'cart' AS table_name, COUNT(*) AS would_delete
        FROM cart
        WHERE created_at < DATE_SUB(CURDATE(), INTERVAL p_days_old DAY)

        UNION ALL

        SELECT 'activity_logs', COUNT(*)
        FROM activity_logs
        WHERE created_at < DATE_SUB(CURDATE(), INTERVAL p_days_old DAY)

        UNION ALL

        SELECT 'sessions', COUNT(*)
        FROM sessions
        WHERE last_activity < DATE_SUB(CURDATE(), INTERVAL p_days_old DAY);

        SET p_deleted_count = 0;
    ELSE
        -- Actually delete
        START TRANSACTION;

        -- Delete old cart items
        DELETE FROM cart
        WHERE created_at < DATE_SUB(CURDATE(), INTERVAL p_days_old DAY);
        SET v_cart_deleted = ROW_COUNT();

        -- Delete old logs
        DELETE FROM activity_logs
        WHERE created_at < DATE_SUB(CURDATE(), INTERVAL p_days_old DAY)
        LIMIT 10000;  -- Batch delete to avoid locking
        SET v_logs_deleted = ROW_COUNT();

        -- Delete expired sessions
        DELETE FROM sessions
        WHERE last_activity < DATE_SUB(CURDATE(), INTERVAL p_days_old DAY);
        SET v_sessions_deleted = ROW_COUNT();

        -- Log cleanup
        INSERT INTO cleanup_log (table_name, rows_deleted) VALUES
            ('cart', v_cart_deleted),
            ('activity_logs', v_logs_deleted),
            ('sessions', v_sessions_deleted);

        SET p_deleted_count = v_cart_deleted + v_logs_deleted + v_sessions_deleted;

        COMMIT;

        -- Summary
        SELECT
            table_name,
            rows_deleted,
            cleanup_date
        FROM cleanup_log
        ORDER BY cleanup_date DESC
        LIMIT 10;
    END IF;
END$$

DELIMITER ;

-- Usage
CALL cleanup_old_data(90, TRUE, @count);  -- Dry run
CALL cleanup_old_data(90, FALSE, @count);  -- Actually delete
SELECT @count AS total_deleted;
```

</details>

---

### Bài 13: Dynamic Report Generator
Tạo procedure sinh báo cáo linh hoạt theo tham số.

<details>
<summary>Đáp án</summary>

```sql
DELIMITER $$

CREATE PROCEDURE generate_report(
    IN p_report_type VARCHAR(50),  -- 'daily', 'monthly', 'category', 'customer'
    IN p_start_date DATE,
    IN p_end_date DATE
)
BEGIN
    IF p_report_type = 'daily' THEN
        SELECT
            DATE(created_at) AS date,
            COUNT(*) AS orders,
            SUM(total_amount) AS revenue,
            AVG(total_amount) AS avg_order_value,
            COUNT(DISTINCT customer_id) AS unique_customers
        FROM orders
        WHERE created_at BETWEEN p_start_date AND p_end_date
          AND status = 'delivered'
        GROUP BY DATE(created_at)
        ORDER BY date;

    ELSEIF p_report_type = 'monthly' THEN
        SELECT
            DATE_FORMAT(created_at, '%Y-%m') AS month,
            COUNT(*) AS orders,
            SUM(total_amount) AS revenue,
            COUNT(DISTINCT customer_id) AS unique_customers
        FROM orders
        WHERE created_at BETWEEN p_start_date AND p_end_date
          AND status = 'delivered'
        GROUP BY month
        ORDER BY month;

    ELSEIF p_report_type = 'category' THEN
        SELECT
            cat.name AS category,
            COUNT(DISTINCT o.id) AS orders,
            SUM(oi.quantity) AS units_sold,
            SUM(oi.subtotal) AS revenue,
            AVG(oi.price) AS avg_price
        FROM categories cat
        JOIN products p ON cat.id = p.category_id
        JOIN order_items oi ON p.id = oi.product_id
        JOIN orders o ON oi.order_id = o.id
        WHERE o.created_at BETWEEN p_start_date AND p_end_date
          AND o.status = 'delivered'
        GROUP BY cat.id, cat.name
        ORDER BY revenue DESC;

    ELSEIF p_report_type = 'customer' THEN
        SELECT
            c.name,
            c.email,
            c.city,
            COUNT(o.id) AS orders,
            SUM(o.total_amount) AS total_spent,
            AVG(o.total_amount) AS avg_order_value,
            MIN(o.created_at) AS first_order,
            MAX(o.created_at) AS last_order
        FROM customers c
        JOIN orders o ON c.id = o.customer_id
        WHERE o.created_at BETWEEN p_start_date AND p_end_date
          AND o.status = 'delivered'
        GROUP BY c.id, c.name, c.email, c.city
        ORDER BY total_spent DESC
        LIMIT 100;

    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid report type';
    END IF;
END$$

DELIMITER ;

-- Usage
CALL generate_report('daily', '2024-01-01', '2024-01-31');
CALL generate_report('category', '2024-01-01', '2024-12-31');
```

</details>

---

### Bài 14: Automated Customer Tier Update
Tạo procedure tự động cập nhật customer tiers và gửi notifications.

<details>
<summary>Đáp án</summary>

```sql
DELIMITER $$

CREATE PROCEDURE update_customer_tiers()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_customer_id INT;
    DECLARE v_customer_name VARCHAR(255);
    DECLARE v_old_tier VARCHAR(20);
    DECLARE v_new_tier VARCHAR(20);
    DECLARE v_total_spent DECIMAL(10,2);
    DECLARE v_order_count INT;

    -- Cursor for customers with tier changes
    DECLARE tier_cursor CURSOR FOR
        SELECT
            c.id,
            c.name,
            c.tier AS old_tier,
            CASE
                WHEN stats.total_spent >= 10000000 AND stats.order_count >= 20 THEN 'Platinum'
                WHEN stats.total_spent >= 10000000 OR stats.order_count >= 15 THEN 'Gold'
                WHEN stats.total_spent >= 5000000 OR stats.order_count >= 10 THEN 'Silver'
                WHEN stats.total_spent >= 1000000 OR stats.order_count >= 3 THEN 'Bronze'
                ELSE 'Standard'
            END AS new_tier,
            stats.total_spent,
            stats.order_count
        FROM customers c
        LEFT JOIN (
            SELECT
                customer_id,
                SUM(total_amount) AS total_spent,
                COUNT(*) AS order_count
            FROM orders
            WHERE status = 'delivered'
            GROUP BY customer_id
        ) stats ON c.id = stats.customer_id
        HAVING old_tier != new_tier OR old_tier IS NULL;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Create notifications table if not exists
    CREATE TABLE IF NOT EXISTS tier_change_notifications (
        id INT AUTO_INCREMENT PRIMARY KEY,
        customer_id INT,
        customer_name VARCHAR(255),
        old_tier VARCHAR(20),
        new_tier VARCHAR(20),
        total_spent DECIMAL(10,2),
        order_count INT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        sent BOOLEAN DEFAULT FALSE
    );

    OPEN tier_cursor;

    update_loop: LOOP
        FETCH tier_cursor INTO
            v_customer_id,
            v_customer_name,
            v_old_tier,
            v_new_tier,
            v_total_spent,
            v_order_count;

        IF done THEN
            LEAVE update_loop;
        END IF;

        -- Update customer tier
        UPDATE customers
        SET tier = v_new_tier,
            tier_updated_at = NOW()
        WHERE id = v_customer_id;

        -- Create notification
        INSERT INTO tier_change_notifications
            (customer_id, customer_name, old_tier, new_tier, total_spent, order_count)
        VALUES
            (v_customer_id, v_customer_name, v_old_tier, v_new_tier, v_total_spent, v_order_count);

    END LOOP;

    CLOSE tier_cursor;

    -- Return summary
    SELECT
        new_tier,
        COUNT(*) AS customer_count,
        AVG(total_spent) AS avg_spending,
        AVG(order_count) AS avg_orders
    FROM tier_change_notifications
    WHERE DATE(created_at) = CURDATE()
      AND sent = FALSE
    GROUP BY new_tier
    ORDER BY
        CASE new_tier
            WHEN 'Platinum' THEN 1
            WHEN 'Gold' THEN 2
            WHEN 'Silver' THEN 3
            WHEN 'Bronze' THEN 4
            ELSE 5
        END;
END$$

DELIMITER ;

-- Schedule to run daily
-- CREATE EVENT update_tiers_daily
-- ON SCHEDULE EVERY 1 DAY
-- STARTS '2024-01-01 02:00:00'
-- DO CALL update_customer_tiers();
```

</details>

---

### Bài 15: Complete E-commerce Dashboard
Tạo comprehensive dashboard view với tất cả metrics quan trọng.

<details>
<summary>Đáp án</summary>

```sql
-- Main dashboard view
CREATE OR REPLACE VIEW dashboard_overview AS
SELECT
    -- Today
    (SELECT COUNT(*) FROM orders WHERE DATE(created_at) = CURDATE()) AS today_orders,
    (SELECT SUM(total_amount) FROM orders WHERE DATE(created_at) = CURDATE() AND status != 'cancelled') AS today_revenue,
    (SELECT COUNT(DISTINCT customer_id) FROM orders WHERE DATE(created_at) = CURDATE()) AS today_customers,

    -- This month
    (SELECT COUNT(*) FROM orders WHERE DATE_FORMAT(created_at, '%Y-%m') = DATE_FORMAT(CURDATE(), '%Y-%m')) AS month_orders,
    (SELECT SUM(total_amount) FROM orders WHERE DATE_FORMAT(created_at, '%Y-%m') = DATE_FORMAT(CURDATE(), '%Y-%m') AND status = 'delivered') AS month_revenue,

    -- Total
    (SELECT COUNT(*) FROM customers) AS total_customers,
    (SELECT COUNT(*) FROM products) AS total_products,
    (SELECT COUNT(*) FROM orders) AS total_orders,

    -- Pending
    (SELECT COUNT(*) FROM orders WHERE status = 'pending') AS pending_orders,
    (SELECT COUNT(*) FROM products WHERE stock < 10) AS low_stock_products,
    (SELECT COUNT(*) FROM products WHERE stock = 0) AS out_of_stock_products,

    -- Averages
    (SELECT AVG(total_amount) FROM orders WHERE status = 'delivered') AS avg_order_value,
    (SELECT AVG(order_count) FROM (SELECT customer_id, COUNT(*) AS order_count FROM orders WHERE status = 'delivered' GROUP BY customer_id) AS t) AS avg_orders_per_customer;

-- Top products view
CREATE OR REPLACE VIEW dashboard_top_products AS
SELECT
    p.id,
    p.name,
    cat.name AS category,
    p.stock,
    COUNT(DISTINCT o.id) AS order_count,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.subtotal) AS revenue,
    AVG(r.rating) AS avg_rating
FROM products p
JOIN categories cat ON p.category_id = cat.id
LEFT JOIN order_items oi ON p.id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.id AND o.status = 'delivered'
    AND o.created_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
LEFT JOIN reviews r ON p.id = r.product_id
GROUP BY p.id, p.name, cat.name, p.stock
ORDER BY revenue DESC
LIMIT 10;

-- Top customers view
CREATE OR REPLACE VIEW dashboard_top_customers AS
SELECT
    c.id,
    c.name,
    c.email,
    c.city,
    c.tier,
    COUNT(o.id) AS order_count,
    SUM(o.total_amount) AS total_spent,
    AVG(o.total_amount) AS avg_order_value,
    MAX(o.created_at) AS last_order_date,
    DATEDIFF(CURDATE(), MAX(o.created_at)) AS days_since_last_order
FROM customers c
JOIN orders o ON c.id = o.customer_id
WHERE o.status = 'delivered'
GROUP BY c.id, c.name, c.email, c.city, c.tier
ORDER BY total_spent DESC
LIMIT 10;

-- Sales trend view
CREATE OR REPLACE VIEW dashboard_sales_trend AS
SELECT
    DATE(created_at) AS date,
    COUNT(*) AS orders,
    SUM(total_amount) AS revenue,
    AVG(total_amount) AS avg_order_value,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM orders
WHERE status = 'delivered'
  AND created_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY DATE(created_at)
ORDER BY date;

-- Usage: Get complete dashboard
SELECT * FROM dashboard_overview;
SELECT * FROM dashboard_top_products;
SELECT * FROM dashboard_top_customers;
SELECT * FROM dashboard_sales_trend;
```

</details>

---

## Tổng Kết

Hoàn thành 15 bài tập Level 4, bạn đã master:

- ✅ Index design và optimization strategies
- ✅ Transaction management với ACID guarantees
- ✅ Deadlock prevention và handling
- ✅ Complex stored procedures
- ✅ Views for reporting và analytics
- ✅ Error handling và retry logic
- ✅ Performance monitoring
- ✅ Production-ready database code

## Chúc Mừng!

Bạn đã hoàn thành toàn bộ SQL Learning Roadmap! 🎉

**Next Steps:**
- Practice với real projects
- Learn about database sharding và replication
- Explore NoSQL databases
- Study database security
- Master query optimization

➡️ [Phụ Lục: Tài Liệu Tham Khảo](../phu-luc/README.md)

⬅️ [Stored Procedures & Views](03-procedures-views.md)
