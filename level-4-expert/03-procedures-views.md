# Stored Procedures & Views

Stored Procedures và Views giúp organize và reuse SQL code.

## Views - Virtual Tables

Views là stored queries, trông giống tables nhưng không lưu data.

### Creating Views

```sql
-- Basic view
CREATE VIEW customer_orders AS
SELECT
    c.id AS customer_id,
    c.name AS customer_name,
    c.email,
    COUNT(o.id) AS order_count,
    COALESCE(SUM(o.total_amount), 0) AS total_spent
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
  AND o.status = 'delivered'
GROUP BY c.id, c.name, c.email;

-- Use view like a table
SELECT * FROM customer_orders
WHERE total_spent > 1000000
ORDER BY total_spent DESC;
```

### OR REPLACE

```sql
-- Update existing view
CREATE OR REPLACE VIEW customer_orders AS
SELECT
    c.id AS customer_id,
    c.name AS customer_name,
    c.email,
    c.city,  -- Added column
    COUNT(o.id) AS order_count,
    COALESCE(SUM(o.total_amount), 0) AS total_spent
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
  AND o.status = 'delivered'
GROUP BY c.id, c.name, c.email, c.city;
```

### Practical View Examples

#### 1. Product Catalog View

```sql
CREATE OR REPLACE VIEW product_catalog AS
SELECT
    p.id,
    p.name AS product_name,
    cat.name AS category_name,
    p.price,
    p.stock,
    CASE
        WHEN p.stock = 0 THEN 'Hết hàng'
        WHEN p.stock < 10 THEN 'Sắp hết'
        ELSE 'Còn hàng'
    END AS stock_status,
    COALESCE(AVG(r.rating), 0) AS avg_rating,
    COUNT(r.id) AS review_count
FROM products p
JOIN categories cat ON p.category_id = cat.id
LEFT JOIN reviews r ON p.id = r.product_id
GROUP BY p.id, p.name, cat.name, p.price, p.stock;

-- Use it
SELECT * FROM product_catalog
WHERE category_name = 'Điện tử'
  AND stock_status != 'Hết hàng'
ORDER BY avg_rating DESC;
```

#### 2. Order Summary View

```sql
CREATE OR REPLACE VIEW order_summary AS
SELECT
    o.id AS order_id,
    o.created_at,
    c.name AS customer_name,
    c.email AS customer_email,
    c.city,
    o.status,
    o.payment_method,
    o.total_amount,
    COUNT(oi.id) AS item_count,
    GROUP_CONCAT(p.name SEPARATOR ', ') AS products
FROM orders o
JOIN customers c ON o.customer_id = c.id
LEFT JOIN order_items oi ON o.id = oi.order_id
LEFT JOIN products p ON oi.product_id = p.id
GROUP BY o.id, o.created_at, c.name, c.email, c.city, o.status, o.payment_method, o.total_amount;

-- Use it
SELECT * FROM order_summary
WHERE status = 'pending'
  AND DATEDIFF(CURDATE(), created_at) > 7
ORDER BY created_at;
```

#### 3. Sales Performance View

```sql
CREATE OR REPLACE VIEW sales_performance AS
SELECT
    DATE_FORMAT(o.created_at, '%Y-%m') AS month,
    cat.name AS category,
    COUNT(DISTINCT o.id) AS order_count,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.subtotal) AS revenue,
    AVG(oi.price) AS avg_price
FROM orders o
JOIN order_items oi ON o.id = oi.order_id
JOIN products p ON oi.product_id = p.id
JOIN categories cat ON p.category_id = cat.id
WHERE o.status = 'delivered'
GROUP BY month, cat.name;

-- Monthly category performance
SELECT * FROM sales_performance
WHERE month >= DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 6 MONTH), '%Y-%m')
ORDER BY month DESC, revenue DESC;
```

### Managing Views

```sql
-- List all views
SHOW FULL TABLES WHERE Table_type = 'VIEW';

-- View definition
SHOW CREATE VIEW customer_orders;

-- Drop view
DROP VIEW IF EXISTS customer_orders;

-- Rename view
RENAME TABLE old_view_name TO new_view_name;
```

### Updatable Views

Some views cho phép INSERT/UPDATE/DELETE.

```sql
-- Simple updatable view
CREATE VIEW active_customers AS
SELECT id, name, email, city
FROM customers
WHERE status = 'active';

-- Can UPDATE through view
UPDATE active_customers
SET city = 'Hà Nội'
WHERE id = 1;

-- Can INSERT
INSERT INTO active_customers (name, email, city)
VALUES ('New Customer', 'new@email.com', 'Đà Nẵng');
```

**Requirements for updatable views:**
- No JOINs, DISTINCT, GROUP BY, HAVING
- No subqueries in SELECT
- No aggregate functions

### WITH CHECK OPTION

```sql
CREATE VIEW high_value_customers AS
SELECT id, name, email, loyalty_points
FROM customers
WHERE loyalty_points > 1000
WITH CHECK OPTION;

-- This will FAIL (loyalty_points < 1000)
UPDATE high_value_customers
SET loyalty_points = 500
WHERE id = 1;
-- Error: CHECK OPTION failed

-- This OK
UPDATE high_value_customers
SET loyalty_points = 2000
WHERE id = 1;
```

## Stored Procedures

Stored Procedures là reusable SQL code blocks.

### Basic Syntax

```sql
DELIMITER $$

CREATE PROCEDURE procedure_name(
    IN param1 datatype,
    OUT param2 datatype,
    INOUT param3 datatype
)
BEGIN
    -- SQL statements
END$$

DELIMITER ;
```

### Simple Procedure

```sql
DELIMITER $$

CREATE PROCEDURE get_customer_orders(IN customer_id INT)
BEGIN
    SELECT
        o.id,
        o.created_at,
        o.total_amount,
        o.status
    FROM orders o
    WHERE o.customer_id = customer_id
    ORDER BY o.created_at DESC;
END$$

DELIMITER ;

-- Call procedure
CALL get_customer_orders(1);
```

### Parameters: IN, OUT, INOUT

```sql
DELIMITER $$

CREATE PROCEDURE calculate_order_stats(
    IN p_customer_id INT,
    OUT p_order_count INT,
    OUT p_total_spent DECIMAL(10,2),
    OUT p_avg_order DECIMAL(10,2)
)
BEGIN
    SELECT
        COUNT(*),
        COALESCE(SUM(total_amount), 0),
        COALESCE(AVG(total_amount), 0)
    INTO p_order_count, p_total_spent, p_avg_order
    FROM orders
    WHERE customer_id = p_customer_id
      AND status = 'delivered';
END$$

DELIMITER ;

-- Call with OUT parameters
CALL calculate_order_stats(1, @count, @total, @avg);
SELECT @count, @total, @avg;
```

### Variables

```sql
DELIMITER $$

CREATE PROCEDURE process_order(IN p_order_id INT)
BEGIN
    DECLARE v_customer_id INT;
    DECLARE v_total_amount DECIMAL(10,2);
    DECLARE v_item_count INT;

    -- Assign values
    SELECT customer_id, total_amount
    INTO v_customer_id, v_total_amount
    FROM orders
    WHERE id = p_order_id;

    -- Count items
    SELECT COUNT(*)
    INTO v_item_count
    FROM order_items
    WHERE order_id = p_order_id;

    -- Use variables
    IF v_item_count > 0 THEN
        UPDATE orders
        SET status = 'processing'
        WHERE id = p_order_id;
    END IF;
END$$

DELIMITER ;
```

### Control Flow

#### IF-THEN-ELSE

```sql
DELIMITER $$

CREATE PROCEDURE update_customer_tier(IN p_customer_id INT)
BEGIN
    DECLARE v_total_spent DECIMAL(10,2);
    DECLARE v_tier VARCHAR(20);

    SELECT COALESCE(SUM(total_amount), 0)
    INTO v_total_spent
    FROM orders
    WHERE customer_id = p_customer_id
      AND status = 'delivered';

    IF v_total_spent >= 10000000 THEN
        SET v_tier = 'Platinum';
    ELSEIF v_total_spent >= 5000000 THEN
        SET v_tier = 'Gold';
    ELSEIF v_total_spent >= 1000000 THEN
        SET v_tier = 'Silver';
    ELSE
        SET v_tier = 'Bronze';
    END IF;

    UPDATE customers
    SET tier = v_tier
    WHERE id = p_customer_id;
END$$

DELIMITER ;
```

#### CASE

```sql
DELIMITER $$

CREATE PROCEDURE get_discount_rate(
    IN p_customer_id INT,
    OUT p_discount DECIMAL(5,2)
)
BEGIN
    DECLARE v_order_count INT;

    SELECT COUNT(*)
    INTO v_order_count
    FROM orders
    WHERE customer_id = p_customer_id
      AND status = 'delivered';

    SET p_discount = CASE
        WHEN v_order_count >= 50 THEN 20.00
        WHEN v_order_count >= 20 THEN 15.00
        WHEN v_order_count >= 10 THEN 10.00
        WHEN v_order_count >= 5 THEN 5.00
        ELSE 0.00
    END;
END$$

DELIMITER ;
```

#### LOOP

```sql
DELIMITER $$

CREATE PROCEDURE generate_sample_data(IN p_count INT)
BEGIN
    DECLARE v_counter INT DEFAULT 0;

    WHILE v_counter < p_count DO
        INSERT INTO test_data (name, value)
        VALUES (
            CONCAT('Item ', v_counter),
            FLOOR(RAND() * 1000)
        );

        SET v_counter = v_counter + 1;
    END WHILE;
END$$

DELIMITER ;
```

### Cursors

Iterate through result sets.

```sql
DELIMITER $$

CREATE PROCEDURE update_all_product_prices(IN p_increase_pct DECIMAL(5,2))
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_product_id INT;
    DECLARE v_old_price DECIMAL(10,2);
    DECLARE v_new_price DECIMAL(10,2);

    -- Declare cursor
    DECLARE product_cursor CURSOR FOR
        SELECT id, price FROM products;

    -- Handler for end of cursor
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Open cursor
    OPEN product_cursor;

    read_loop: LOOP
        -- Fetch next row
        FETCH product_cursor INTO v_product_id, v_old_price;

        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Calculate new price
        SET v_new_price = v_old_price * (1 + p_increase_pct / 100);

        -- Update
        UPDATE products
        SET price = v_new_price
        WHERE id = v_product_id;

    END LOOP;

    -- Close cursor
    CLOSE product_cursor;
END$$

DELIMITER ;
```

### Error Handling

```sql
DELIMITER $$

CREATE PROCEDURE safe_create_order(
    IN p_customer_id INT,
    IN p_total_amount DECIMAL(10,2),
    OUT p_order_id INT,
    OUT p_error_message VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Rollback on error
        ROLLBACK;
        SET p_order_id = NULL;
        SET p_error_message = 'Error creating order';
    END;

    START TRANSACTION;

    -- Insert order
    INSERT INTO orders (customer_id, total_amount, status)
    VALUES (p_customer_id, p_total_amount, 'pending');

    SET p_order_id = LAST_INSERT_ID();
    SET p_error_message = NULL;

    COMMIT;
END$$

DELIMITER ;

-- Call
CALL safe_create_order(1, 1000000, @order_id, @error);
SELECT @order_id, @error;
```

## Practical Procedure Examples

### 1. Complete Checkout Process

```sql
DELIMITER $$

CREATE PROCEDURE checkout(
    IN p_customer_id INT,
    IN p_payment_method VARCHAR(50),
    OUT p_order_id INT,
    OUT p_success BOOLEAN,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE v_total DECIMAL(10,2);
    DECLARE v_item_count INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_success = FALSE;
        SET p_message = 'Transaction failed';
        SET p_order_id = NULL;
    END;

    START TRANSACTION;

    -- Check cart not empty
    SELECT COUNT(*) INTO v_item_count
    FROM cart
    WHERE customer_id = p_customer_id;

    IF v_item_count = 0 THEN
        SET p_success = FALSE;
        SET p_message = 'Cart is empty';
        ROLLBACK;
    ELSE
        -- Calculate total
        SELECT SUM(p.price * c.quantity) INTO v_total
        FROM cart c
        JOIN products p ON c.product_id = p.id
        WHERE c.customer_id = p_customer_id;

        -- Create order
        INSERT INTO orders (customer_id, total_amount, status, payment_method)
        VALUES (p_customer_id, v_total, 'pending', p_payment_method);

        SET p_order_id = LAST_INSERT_ID();

        -- Move cart to order_items
        INSERT INTO order_items (order_id, product_id, quantity, price, subtotal)
        SELECT
            p_order_id,
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
        WHERE c.customer_id = p_customer_id;

        -- Clear cart
        DELETE FROM cart WHERE customer_id = p_customer_id;

        SET p_success = TRUE;
        SET p_message = 'Order created successfully';

        COMMIT;
    END IF;
END$$

DELIMITER ;
```

### 2. Product Restock Alert

```sql
DELIMITER $$

CREATE PROCEDURE check_restock_alerts()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_product_id INT;
    DECLARE v_product_name VARCHAR(255);
    DECLARE v_stock INT;
    DECLARE v_monthly_sales INT;

    DECLARE product_cursor CURSOR FOR
        SELECT
            p.id,
            p.name,
            p.stock,
            COALESCE(SUM(oi.quantity), 0) AS monthly_sales
        FROM products p
        LEFT JOIN order_items oi ON p.id = oi.product_id
        LEFT JOIN orders o ON oi.order_id = o.id
          AND o.created_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
          AND o.status = 'delivered'
        GROUP BY p.id, p.name, p.stock
        HAVING p.stock < monthly_sales / 4;  -- Stock < 1 week of sales

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Create temp table for alerts
    CREATE TEMPORARY TABLE IF NOT EXISTS restock_alerts (
        product_id INT,
        product_name VARCHAR(255),
        current_stock INT,
        monthly_sales INT,
        recommended_order INT
    );

    TRUNCATE restock_alerts;

    OPEN product_cursor;

    read_loop: LOOP
        FETCH product_cursor INTO v_product_id, v_product_name, v_stock, v_monthly_sales;

        IF done THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO restock_alerts
        VALUES (
            v_product_id,
            v_product_name,
            v_stock,
            v_monthly_sales,
            GREATEST(v_monthly_sales - v_stock, 0)
        );
    END LOOP;

    CLOSE product_cursor;

    -- Return alerts
    SELECT * FROM restock_alerts
    ORDER BY recommended_order DESC;
END$$

DELIMITER ;
```

### 3. Customer Segmentation Update

```sql
DELIMITER $$

CREATE PROCEDURE update_customer_segments()
BEGIN
    -- Update all customer segments based on RFM
    UPDATE customers c
    LEFT JOIN (
        SELECT
            customer_id,
            DATEDIFF(CURDATE(), MAX(created_at)) AS recency,
            COUNT(*) AS frequency,
            SUM(total_amount) AS monetary
        FROM orders
        WHERE status = 'delivered'
        GROUP BY customer_id
    ) stats ON c.id = stats.customer_id
    SET c.segment = CASE
        WHEN stats.recency IS NULL THEN 'New'
        WHEN stats.recency > 180 THEN 'Churned'
        WHEN stats.recency > 90 THEN 'At Risk'
        WHEN stats.frequency >= 10 AND stats.monetary > 5000000 THEN 'Champion'
        WHEN stats.frequency >= 5 THEN 'Loyal'
        WHEN stats.frequency >= 2 THEN 'Repeat'
        ELSE 'One-time'
    END;

    -- Log update
    INSERT INTO segment_update_log (updated_at, customers_updated)
    VALUES (NOW(), ROW_COUNT());
END$$

DELIMITER ;
```

## Managing Procedures

```sql
-- List procedures
SHOW PROCEDURE STATUS WHERE Db = 'ecommerce_db';

-- View procedure code
SHOW CREATE PROCEDURE procedure_name;

-- Drop procedure
DROP PROCEDURE IF EXISTS procedure_name;

-- Call procedure
CALL procedure_name(param1, param2);
```

## Functions vs Procedures

### User-Defined Functions

```sql
DELIMITER $$

CREATE FUNCTION calculate_discount(
    p_total_amount DECIMAL(10,2),
    p_customer_tier VARCHAR(20)
) RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_discount_pct DECIMAL(5,2);

    SET v_discount_pct = CASE p_customer_tier
        WHEN 'Platinum' THEN 20.00
        WHEN 'Gold' THEN 15.00
        WHEN 'Silver' THEN 10.00
        WHEN 'Bronze' THEN 5.00
        ELSE 0.00
    END;

    RETURN p_total_amount * v_discount_pct / 100;
END$$

DELIMITER ;

-- Use function in query
SELECT
    id,
    total_amount,
    calculate_discount(total_amount, 'Gold') AS discount,
    total_amount - calculate_discount(total_amount, 'Gold') AS final_amount
FROM orders
LIMIT 10;
```

**Functions vs Procedures:**
| Feature | Function | Procedure |
|---------|----------|-----------|
| Return value | Single value | Multiple OUT params |
| Use in SELECT | ✅ Yes | ❌ No |
| Transactions | ❌ No | ✅ Yes |
| Call | `SELECT func()` | `CALL proc()` |

## Best Practices

### 1. Use Views for Common Queries

```sql
-- Instead of repeating this query
CREATE VIEW monthly_revenue AS
SELECT
    DATE_FORMAT(created_at, '%Y-%m') AS month,
    SUM(total_amount) AS revenue
FROM orders
WHERE status = 'delivered'
GROUP BY month;

-- Just query the view
SELECT * FROM monthly_revenue
WHERE month >= '2024-01'
ORDER BY month;
```

### 2. Parameterize Procedures

```sql
-- Good: Flexible
CREATE PROCEDURE get_orders_by_date_range(
    IN p_start_date DATE,
    IN p_end_date DATE
)
BEGIN
    SELECT * FROM orders
    WHERE created_at BETWEEN p_start_date AND p_end_date;
END;

-- Bad: Hard-coded
CREATE PROCEDURE get_orders_last_month()
BEGIN
    SELECT * FROM orders
    WHERE MONTH(created_at) = MONTH(DATE_SUB(CURDATE(), INTERVAL 1 MONTH));
END;
```

### 3. Handle Errors

Always include error handlers trong procedures.

```sql
DELIMITER $$
CREATE PROCEDURE safe_procedure()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        -- Log error or notify
    END;

    START TRANSACTION;
    -- Operations
    COMMIT;
END$$
DELIMITER ;
```

### 4. Document Procedures

```sql
DELIMITER $$

/**
 * Creates a new order from cart items
 * @param p_customer_id Customer ID
 * @param p_payment_method Payment method (credit_card, bank_transfer, cash)
 * @returns p_order_id New order ID or NULL if failed
 * @returns p_message Success or error message
 */
CREATE PROCEDURE create_order_from_cart(
    IN p_customer_id INT,
    IN p_payment_method VARCHAR(50),
    OUT p_order_id INT,
    OUT p_message VARCHAR(255)
)
BEGIN
    -- Implementation
END$$

DELIMITER ;
```

## Bài Tập

**1. Create Views**
```sql
-- View: Top selling products
-- View: Customer lifetime value
-- View: Daily sales summary
```

**2. Simple Procedures**
```sql
-- Procedure: Get customer order history
-- Procedure: Calculate customer tier
-- Procedure: Add product to cart
```

**3. Complex Procedures**
```sql
-- Procedure: Process return/refund
-- Procedure: Generate monthly report
-- Procedure: Cleanup old data
```

**4. Functions**
```sql
-- Function: Calculate shipping fee based on weight
-- Function: Get customer discount rate
-- Function: Format phone number
```

## Đáp Án

<details>
<summary>Click để xem đáp án</summary>

```sql
-- 1. Views
CREATE VIEW top_selling_products AS
SELECT
    p.name,
    cat.name AS category,
    SUM(oi.quantity) AS total_sold,
    SUM(oi.subtotal) AS revenue
FROM products p
JOIN categories cat ON p.category_id = cat.id
JOIN order_items oi ON p.id = oi.product_id
JOIN orders o ON oi.order_id = o.id
WHERE o.status = 'delivered'
GROUP BY p.id, p.name, cat.name
ORDER BY total_sold DESC;

-- 2. Simple Procedure
DELIMITER $$
CREATE PROCEDURE add_to_cart(
    IN p_customer_id INT,
    IN p_product_id INT,
    IN p_quantity INT
)
BEGIN
    INSERT INTO cart (customer_id, product_id, quantity)
    VALUES (p_customer_id, p_product_id, p_quantity)
    ON DUPLICATE KEY UPDATE
        quantity = quantity + p_quantity;
END$$
DELIMITER ;

-- 3. Complex Procedure
DELIMITER $$
CREATE PROCEDURE process_refund(
    IN p_order_id INT,
    OUT p_success BOOLEAN,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE v_customer_id INT;
    DECLARE v_total_amount DECIMAL(10,2);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_success = FALSE;
        SET p_message = 'Refund failed';
    END;

    START TRANSACTION;

    SELECT customer_id, total_amount
    INTO v_customer_id, v_total_amount
    FROM orders
    WHERE id = p_order_id;

    UPDATE orders SET status = 'refunded'
    WHERE id = p_order_id;

    UPDATE products p
    JOIN order_items oi ON p.id = oi.product_id
    SET p.stock = p.stock + oi.quantity
    WHERE oi.order_id = p_order_id;

    INSERT INTO refunds (order_id, customer_id, amount)
    VALUES (p_order_id, v_customer_id, v_total_amount);

    SET p_success = TRUE;
    SET p_message = 'Refund processed';

    COMMIT;
END$$
DELIMITER ;

-- 4. Function
DELIMITER $$
CREATE FUNCTION calculate_shipping_fee(p_weight_kg DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN CASE
        WHEN p_weight_kg <= 0.5 THEN 20000
        WHEN p_weight_kg <= 1 THEN 30000
        WHEN p_weight_kg <= 2 THEN 40000
        WHEN p_weight_kg <= 5 THEN 60000
        ELSE 60000 + (p_weight_kg - 5) * 10000
    END;
END$$
DELIMITER ;
```

</details>

## Tổng Kết

Views và Stored Procedures là essential tools:

- ✅ Use views cho complex queries thường dùng
- ✅ Use procedures cho business logic
- ✅ Handle errors properly
- ✅ Document code
- ✅ Use transactions trong procedures
- ❌ Tránh over-complicated logic trong database
- ❌ Không lưu sensitive logic trong views (security)

## Tiếp Theo

➡️ [Bài Tập Level 4](bai-tap.md)

⬅️ [Transactions](02-transactions.md)
