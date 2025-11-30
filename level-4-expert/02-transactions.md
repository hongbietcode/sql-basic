# Transactions - ACID & Data Integrity

Transaction là một nhóm SQL statements được thực thi như một đơn vị duy nhất. Tất cả thành công hoặc tất cả thất bại.

## Why Transactions?

```sql
-- Không có transaction: Nguy hiểm!
UPDATE accounts SET balance = balance - 1000 WHERE id = 1;  -- Success
-- ⚠️ Power outage here!
UPDATE accounts SET balance = balance + 1000 WHERE id = 2;  -- Never executed!
-- 1000 VNĐ biến mất!

-- Với transaction: An toàn
START TRANSACTION;
UPDATE accounts SET balance = balance - 1000 WHERE id = 1;
UPDATE accounts SET balance = balance + 1000 WHERE id = 2;
COMMIT;  -- Cả 2 thành công
-- HOẶC
ROLLBACK;  -- Cả 2 thất bại, data không thay đổi
```

## ACID Properties

Transactions đảm bảo 4 properties:

### A - Atomicity (Tính nguyên tử)
Tất cả hoặc không có gì.

```sql
START TRANSACTION;
INSERT INTO orders (customer_id, total_amount) VALUES (1, 1000000);
INSERT INTO order_items (order_id, product_id, quantity) VALUES (LAST_INSERT_ID(), 1, 2);
INSERT INTO order_items (order_id, product_id, quantity) VALUES (LAST_INSERT_ID(), 2, 1);
COMMIT;

-- Nếu bất kỳ statement nào fail → tất cả bị rollback
```

### C - Consistency (Tính nhất quán)
Data luôn hợp lệ, constraints được enforce.

```sql
START TRANSACTION;
-- This will fail if violates constraints
INSERT INTO orders (customer_id, total_amount) VALUES (999999, -1000);  -- Invalid!
ROLLBACK;
```

### I - Isolation (Tính cô lập)
Transactions không can thiệp vào nhau.

```sql
-- Transaction 1
START TRANSACTION;
UPDATE products SET stock = stock - 1 WHERE id = 1;
-- ... doing work ...
COMMIT;

-- Transaction 2 (concurrent)
START TRANSACTION;
SELECT stock FROM products WHERE id = 1;  -- Sees correct value
COMMIT;
```

### D - Durability (Tính bền vững)
Sau khi COMMIT, data được lưu vĩnh viễn.

```sql
START TRANSACTION;
INSERT INTO orders (customer_id, total_amount) VALUES (1, 1000000);
COMMIT;  -- Data được ghi vào disk, không mất ngay cả khi server crash
```

## Basic Transaction Commands

### START TRANSACTION / BEGIN

```sql
-- Cả 2 đều OK
START TRANSACTION;
-- hoặc
BEGIN;
```

### COMMIT

```sql
START TRANSACTION;
UPDATE products SET stock = stock - 1 WHERE id = 1;
COMMIT;  -- Lưu thay đổi
```

### ROLLBACK

```sql
START TRANSACTION;
UPDATE products SET stock = stock - 1 WHERE id = 1;
ROLLBACK;  -- Hủy thay đổi
```

## Practical Examples

### 1. Create Order with Items

```sql
START TRANSACTION;

-- 1. Tạo order
INSERT INTO orders (customer_id, total_amount, status, payment_method)
VALUES (1, 1500000, 'pending', 'credit_card');

SET @order_id = LAST_INSERT_ID();

-- 2. Thêm order items
INSERT INTO order_items (order_id, product_id, quantity, price, subtotal)
VALUES
    (@order_id, 1, 2, 500000, 1000000),
    (@order_id, 2, 1, 500000, 500000);

-- 3. Giảm stock
UPDATE products SET stock = stock - 2 WHERE id = 1;
UPDATE products SET stock = stock - 1 WHERE id = 2;

-- 4. Kiểm tra stock không âm
SELECT id, stock FROM products WHERE id IN (1, 2) AND stock < 0;

-- Nếu OK: COMMIT, nếu không: ROLLBACK
COMMIT;
```

### 2. Transfer Money

```sql
START TRANSACTION;

-- Kiểm tra balance
SELECT balance FROM accounts WHERE id = 1 FOR UPDATE;  -- Lock row

-- Transfer
UPDATE accounts SET balance = balance - 1000000 WHERE id = 1;
UPDATE accounts SET balance = balance + 1000000 WHERE id = 2;

-- Verify
SELECT
    (SELECT balance FROM accounts WHERE id = 1) AS from_balance,
    (SELECT balance FROM accounts WHERE id = 2) AS to_balance;

-- Check constraints
SELECT * FROM accounts WHERE id = 1 AND balance < 0;

IF found_negative THEN
    ROLLBACK;
ELSE
    COMMIT;
END IF;
```

### 3. Cancel Order & Restore Stock

```sql
START TRANSACTION;

-- 1. Lấy order items
SELECT product_id, quantity
FROM order_items
WHERE order_id = 123;

-- 2. Restore stock
UPDATE products p
JOIN order_items oi ON p.id = oi.product_id
SET p.stock = p.stock + oi.quantity
WHERE oi.order_id = 123;

-- 3. Update order status
UPDATE orders
SET status = 'cancelled'
WHERE id = 123;

-- 4. Log cancellation
INSERT INTO order_logs (order_id, action, created_at)
VALUES (123, 'cancelled', NOW());

COMMIT;
```

## Savepoints

Savepoints cho phép partial rollback.

```sql
START TRANSACTION;

-- Step 1
INSERT INTO orders (customer_id, total_amount) VALUES (1, 1000000);
SAVEPOINT order_created;

-- Step 2
INSERT INTO order_items (order_id, product_id, quantity) VALUES (LAST_INSERT_ID(), 1, 2);
SAVEPOINT items_added;

-- Step 3
UPDATE products SET stock = stock - 2 WHERE id = 1;

-- Oops, lỗi! Rollback về savepoint
ROLLBACK TO items_added;

-- Thử lại step 3
UPDATE products SET stock = stock - 2 WHERE id = 1;

-- OK, commit tất cả
COMMIT;
```

**Commands:**
- `SAVEPOINT name` - Tạo savepoint
- `ROLLBACK TO name` - Rollback về savepoint
- `RELEASE SAVEPOINT name` - Xóa savepoint

## Isolation Levels

Isolation levels control how transactions see changes from other transactions.

### 1. READ UNCOMMITTED (Lowest isolation)

```sql
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
START TRANSACTION;
SELECT * FROM products WHERE id = 1;  -- Có thể thấy uncommitted changes!
COMMIT;
```

**Problems:**
- Dirty reads: Đọc data chưa commit
- Non-repeatable reads
- Phantom reads

### 2. READ COMMITTED

```sql
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;
SELECT * FROM products WHERE id = 1;  -- Chỉ thấy committed data
COMMIT;
```

**Problems:**
- Non-repeatable reads: 2 lần SELECT khác nhau
- Phantom reads

### 3. REPEATABLE READ (MySQL default)

```sql
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;
SELECT * FROM products WHERE id = 1;  -- Row snapshot
-- ... time passes ...
SELECT * FROM products WHERE id = 1;  -- Same result!
COMMIT;
```

**Problems:**
- Phantom reads: New rows từ INSERT

### 4. SERIALIZABLE (Highest isolation)

```sql
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
START TRANSACTION;
SELECT * FROM products WHERE price > 1000000;
-- Other transactions cannot INSERT/UPDATE/DELETE trong range này
COMMIT;
```

**Đặc điểm:**
- Hoàn toàn isolated
- Chậm nhất
- Có thể deadlock

### Comparison Table

| Level | Dirty Read | Non-Repeatable Read | Phantom Read | Performance |
|-------|-----------|-------------------|--------------|-------------|
| READ UNCOMMITTED | ✅ Yes | ✅ Yes | ✅ Yes | Fastest |
| READ COMMITTED | ❌ No | ✅ Yes | ✅ Yes | Fast |
| REPEATABLE READ | ❌ No | ❌ No | ✅ Yes | Medium |
| SERIALIZABLE | ❌ No | ❌ No | ❌ No | Slowest |

## Locking

### Row-Level Locks

#### SELECT ... FOR UPDATE

```sql
START TRANSACTION;

-- Lock row for update
SELECT * FROM products
WHERE id = 1
FOR UPDATE;

-- Other transactions phải wait
UPDATE products SET stock = stock - 1 WHERE id = 1;

COMMIT;  -- Release lock
```

#### SELECT ... LOCK IN SHARE MODE

```sql
START TRANSACTION;

-- Shared lock: Cho phép read, block write
SELECT * FROM products
WHERE id = 1
LOCK IN SHARE MODE;

-- Other transactions có thể SELECT
-- Nhưng UPDATE/DELETE phải wait

COMMIT;
```

### Table-Level Locks

```sql
-- Lock entire table
LOCK TABLES products WRITE;
UPDATE products SET stock = stock - 1;
UNLOCK TABLES;

-- Read lock
LOCK TABLES products READ;
SELECT * FROM products;
UNLOCK TABLES;
```

**Note:** Tránh table locks, dùng row locks thay vì.

## Deadlocks

Deadlock xảy ra khi 2 transactions đợi nhau.

### Example Deadlock

```sql
-- Transaction 1
START TRANSACTION;
UPDATE products SET stock = stock - 1 WHERE id = 1;  -- Lock product 1
-- ... waiting ...
UPDATE products SET stock = stock - 1 WHERE id = 2;  -- Wait for lock on product 2

-- Transaction 2 (concurrent)
START TRANSACTION;
UPDATE products SET stock = stock - 1 WHERE id = 2;  -- Lock product 2
-- ... waiting ...
UPDATE products SET stock = stock - 1 WHERE id = 1;  -- Wait for lock on product 1

-- DEADLOCK! MySQL will rollback one transaction
```

### Detecting Deadlocks

```sql
-- Show last deadlock
SHOW ENGINE INNODB STATUS;
-- Look for "LATEST DETECTED DEADLOCK" section
```

### Preventing Deadlocks

**1. Lock resources trong cùng thứ tự**
```sql
-- GOOD: Luôn lock theo id tăng dần
UPDATE products SET stock = stock - 1 WHERE id IN (1, 2, 3) ORDER BY id;

-- BAD: Lock random order
UPDATE products SET stock = stock - 1 WHERE id = 2;
UPDATE products SET stock = stock - 1 WHERE id = 1;
```

**2. Keep transactions short**
```sql
-- BAD: Long transaction
START TRANSACTION;
SELECT * FROM orders;  -- Large query
-- ... complex processing ...
UPDATE orders SET status = 'processed';
COMMIT;

-- GOOD: Short transaction
-- Do processing outside transaction
START TRANSACTION;
UPDATE orders SET status = 'processed' WHERE id = 123;
COMMIT;
```

**3. Use lower isolation levels**
```sql
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
```

**4. Handle deadlock errors**
```sql
-- Retry on deadlock
DECLARE deadlock_detected BOOLEAN DEFAULT FALSE;

REPEAT
    BEGIN
        DECLARE EXIT HANDLER FOR 1213  -- Deadlock error code
        BEGIN
            SET deadlock_detected = TRUE;
        END;

        START TRANSACTION;
        -- ... your operations ...
        COMMIT;
        SET deadlock_detected = FALSE;
    END;
UNTIL NOT deadlock_detected END REPEAT;
```

## Auto-commit Mode

MySQL mặc định bật auto-commit.

```sql
-- Check auto-commit
SELECT @@autocommit;  -- 1 = ON

-- Disable auto-commit
SET autocommit = 0;

-- Now every statement needs explicit COMMIT
UPDATE products SET stock = stock - 1 WHERE id = 1;
-- ... changes not saved yet ...
COMMIT;  -- Now saved

-- Re-enable
SET autocommit = 1;
```

## Transaction Best Practices

### 1. Keep Transactions Short

```sql
-- BAD: Long transaction
START TRANSACTION;
SELECT * FROM orders WHERE created_at > '2024-01-01';  -- Large dataset
-- ... processing 10,000 rows ...
UPDATE orders SET processed = 1;
COMMIT;

-- GOOD: Process in batches
REPEAT
    START TRANSACTION;
    UPDATE orders
    SET processed = 1
    WHERE created_at > '2024-01-01'
      AND processed = 0
    LIMIT 1000;
    COMMIT;
UNTIL ROW_COUNT() = 0 END REPEAT;
```

### 2. Avoid User Interaction in Transactions

```sql
-- BAD
START TRANSACTION;
SELECT * FROM cart WHERE customer_id = 1;
-- ... wait for user to confirm ...  ⚠️ Lock held!
UPDATE cart SET status = 'checked_out';
COMMIT;

-- GOOD
-- Get data first
SELECT * FROM cart WHERE customer_id = 1;
-- ... user confirms ...
START TRANSACTION;
UPDATE cart SET status = 'checked_out' WHERE customer_id = 1;
COMMIT;
```

### 3. Handle Errors Properly

```sql
DELIMITER $$

CREATE PROCEDURE create_order(
    IN p_customer_id INT,
    IN p_product_id INT,
    IN p_quantity INT
)
BEGIN
    DECLARE exit handler FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;  -- Re-throw error
    END;

    START TRANSACTION;

    -- Create order
    INSERT INTO orders (customer_id, total_amount)
    SELECT p_customer_id, price * p_quantity
    FROM products
    WHERE id = p_product_id;

    -- Add item
    INSERT INTO order_items (order_id, product_id, quantity)
    VALUES (LAST_INSERT_ID(), p_product_id, p_quantity);

    -- Update stock
    UPDATE products
    SET stock = stock - p_quantity
    WHERE id = p_product_id
      AND stock >= p_quantity;  -- Check stock

    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Insufficient stock';
    END IF;

    COMMIT;
END$$

DELIMITER ;
```

### 4. Use Appropriate Isolation Level

```sql
-- High concurrency, OK với dirty reads
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- Normal operations
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- Financial transactions
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- Critical operations
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
```

### 5. Explicit Locking When Needed

```sql
-- Check and update atomically
START TRANSACTION;

SELECT stock
FROM products
WHERE id = 1
FOR UPDATE;  -- Lock row

-- Now safe to update
UPDATE products
SET stock = stock - 1
WHERE id = 1 AND stock > 0;

COMMIT;
```

## Monitoring Transactions

### Active Transactions

```sql
-- Show running transactions
SELECT *
FROM information_schema.INNODB_TRX;

-- Show locks
SELECT *
FROM information_schema.INNODB_LOCKS;

-- Show lock waits
SELECT *
FROM information_schema.INNODB_LOCK_WAITS;
```

### Transaction History

```sql
-- Enable general log (temporary)
SET GLOBAL general_log = 'ON';
SET GLOBAL log_output = 'TABLE';

-- View logs
SELECT * FROM mysql.general_log
WHERE command_type = 'Query'
  AND argument LIKE '%START TRANSACTION%'
ORDER BY event_time DESC;
```

## Practical Transaction Scenarios

### 1. E-commerce Checkout

```sql
DELIMITER $$

CREATE PROCEDURE checkout_cart(IN p_customer_id INT)
BEGIN
    DECLARE v_order_id INT;
    DECLARE v_total DECIMAL(10,2);

    DECLARE exit handler FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- Calculate total
    SELECT SUM(p.price * c.quantity) INTO v_total
    FROM cart c
    JOIN products p ON c.product_id = p.id
    WHERE c.customer_id = p_customer_id;

    -- Create order
    INSERT INTO orders (customer_id, total_amount, status)
    VALUES (p_customer_id, v_total, 'pending');

    SET v_order_id = LAST_INSERT_ID();

    -- Move cart items to order_items
    INSERT INTO order_items (order_id, product_id, quantity, price, subtotal)
    SELECT
        v_order_id,
        c.product_id,
        c.quantity,
        p.price,
        p.price * c.quantity
    FROM cart c
    JOIN products p ON c.product_id = p.id
    WHERE c.customer_id = p_customer_id;

    -- Update stock
    UPDATE products p
    JOIN cart c ON p.id = c.product_id
    SET p.stock = p.stock - c.quantity
    WHERE c.customer_id = p_customer_id
      AND p.stock >= c.quantity;

    -- Check all products have sufficient stock
    IF ROW_COUNT() <> (SELECT COUNT(*) FROM cart WHERE customer_id = p_customer_id) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Insufficient stock for some products';
    END IF;

    -- Clear cart
    DELETE FROM cart WHERE customer_id = p_customer_id;

    COMMIT;

    SELECT v_order_id AS order_id;
END$$

DELIMITER ;
```

### 2. Inventory Adjustment

```sql
DELIMITER $$

CREATE PROCEDURE adjust_inventory(
    IN p_product_id INT,
    IN p_quantity_change INT,
    IN p_reason VARCHAR(255)
)
BEGIN
    DECLARE v_old_stock INT;
    DECLARE v_new_stock INT;

    DECLARE exit handler FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- Lock and get current stock
    SELECT stock INTO v_old_stock
    FROM products
    WHERE id = p_product_id
    FOR UPDATE;

    -- Calculate new stock
    SET v_new_stock = v_old_stock + p_quantity_change;

    -- Validate
    IF v_new_stock < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Stock cannot be negative';
    END IF;

    -- Update stock
    UPDATE products
    SET stock = v_new_stock
    WHERE id = p_product_id;

    -- Log adjustment
    INSERT INTO inventory_logs (product_id, old_stock, new_stock, change_amount, reason)
    VALUES (p_product_id, v_old_stock, v_new_stock, p_quantity_change, p_reason);

    COMMIT;
END$$

DELIMITER ;
```

## Bài Tập

**1. Basic Transactions**
```sql
-- Tạo transaction để transfer điểm giữa 2 customers
-- Handle errors và rollback nếu insufficient points
```

**2. Complex Transaction**
```sql
-- Implement refund process:
--   1. Update order status to 'refunded'
--   2. Restore product stock
--   3. Create refund record
--   4. Update customer balance
```

**3. Deadlock Prevention**
```sql
-- Viết transaction update multiple products
-- Đảm bảo không bị deadlock
```

**4. Isolation Levels**
```sql
-- Test các isolation levels
-- Demonstrate dirty read, non-repeatable read, phantom read
```

## Đáp Án

<details>
<summary>Click để xem đáp án</summary>

```sql
-- 1. Transfer Points
DELIMITER $$
CREATE PROCEDURE transfer_points(
    IN from_customer INT,
    IN to_customer INT,
    IN points INT
)
BEGIN
    DECLARE from_balance INT;

    DECLARE exit handler FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT loyalty_points INTO from_balance
    FROM customers
    WHERE id = from_customer
    FOR UPDATE;

    IF from_balance < points THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Insufficient points';
    END IF;

    UPDATE customers
    SET loyalty_points = loyalty_points - points
    WHERE id = from_customer;

    UPDATE customers
    SET loyalty_points = loyalty_points + points
    WHERE id = to_customer;

    COMMIT;
END$$
DELIMITER ;

-- 2. Refund Process
DELIMITER $$
CREATE PROCEDURE refund_order(IN p_order_id INT)
BEGIN
    DECLARE exit handler FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    UPDATE orders
    SET status = 'refunded'
    WHERE id = p_order_id;

    UPDATE products p
    JOIN order_items oi ON p.id = oi.product_id
    SET p.stock = p.stock + oi.quantity
    WHERE oi.order_id = p_order_id;

    INSERT INTO refunds (order_id, amount, created_at)
    SELECT id, total_amount, NOW()
    FROM orders
    WHERE id = p_order_id;

    COMMIT;
END$$
DELIMITER ;

-- 3. Deadlock Prevention
START TRANSACTION;
UPDATE products
SET stock = stock - 1
WHERE id IN (5, 10, 15)
ORDER BY id;  -- Consistent order prevents deadlock
COMMIT;

-- 4. Isolation Levels
-- Terminal 1
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
START TRANSACTION;
SELECT price FROM products WHERE id = 1;  -- 100000

-- Terminal 2
START TRANSACTION;
UPDATE products SET price = 200000 WHERE id = 1;
-- Don't commit yet

-- Terminal 1
SELECT price FROM products WHERE id = 1;  -- 200000 (dirty read!)

-- Terminal 2
ROLLBACK;

-- Terminal 1
SELECT price FROM products WHERE id = 1;  -- Back to 100000
COMMIT;
```

</details>

## Tổng Kết

Transactions là foundation của data integrity:

- ✅ Always use transactions cho multi-step operations
- ✅ Keep transactions short
- ✅ Handle errors và rollback properly
- ✅ Use appropriate isolation levels
- ✅ Prevent deadlocks bằng consistent ordering
- ❌ Never wait for user input trong transaction
- ❌ Tránh long-running transactions

## Tiếp Theo

➡️ [Stored Procedures & Views](03-procedures-views.md)

⬅️ [Indexes](01-indexes.md)
