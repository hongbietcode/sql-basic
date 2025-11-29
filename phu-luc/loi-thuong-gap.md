# Lỗi Thường Gặp & Cách Sửa

## 1. Syntax Errors

### Missing Semicolon
```sql
❌ SELECT * FROM products
❌ SELECT * FROM customers

✅ SELECT * FROM products;
✅ SELECT * FROM customers;
```

### Missing Quotes for Strings
```sql
❌ SELECT * FROM customers WHERE city = Ha Noi;

✅ SELECT * FROM customers WHERE city = 'Hà Nội';
```

### Column Name Typos
```sql
❌ SELECT nmae FROM products;  -- typo: nmae

✅ SELECT name FROM products;
```

---

## 2. WHERE Clause Errors

### Using = NULL Instead of IS NULL
```sql
❌ SELECT * FROM products WHERE description = NULL;

✅ SELECT * FROM products WHERE description IS NULL;
```

### Incorrect AND/OR Logic
```sql
❌ Wrong Logic
SELECT * FROM products
WHERE price > 100000 OR price < 500000 AND stock > 0;

✅ Correct - Use Parentheses
SELECT * FROM products
WHERE (price > 100000 OR price < 500000) AND stock > 0;
```

### LIKE Without Wildcards
```sql
❌ SELECT * FROM products WHERE name LIKE 'Áo';
-- Chỉ match chính xác "Áo"

✅ SELECT * FROM products WHERE name LIKE '%Áo%';
-- Match bất kỳ đâu có "Áo"
```

---

## 3. JOIN Errors

### Missing JOIN Condition
```sql
❌ Cartesian Product (tất cả combinations)
SELECT * FROM orders, customers;

✅ Proper JOIN
SELECT * FROM orders o
JOIN customers c ON o.customer_id = c.id;
```

### Ambiguous Column Names
```sql
❌ Lỗi: Column 'id' is ambiguous
SELECT id, name FROM orders
JOIN customers ON orders.customer_id = customers.id;

✅ Specify Table
SELECT orders.id, customers.name FROM orders
JOIN customers ON orders.customer_id = customers.id;

✅ Better: Use Aliases
SELECT o.id, c.name FROM orders o
JOIN customers c ON o.customer_id = c.id;
```

---

## 4. GROUP BY Errors

### Column Not in GROUP BY
```sql
❌ Column 'name' not in GROUP BY
SELECT name, COUNT(*) FROM customers GROUP BY city;

✅ Include in GROUP BY
SELECT city, COUNT(*) FROM customers GROUP BY city;

✅ Or Use Aggregate
SELECT city, COUNT(*) as total, MAX(name) FROM customers GROUP BY city;
```

### WHERE với Aggregates
```sql
❌ Cannot use WHERE with aggregates
SELECT city, COUNT(*) as total
FROM customers
WHERE total > 10
GROUP BY city;

✅ Use HAVING
SELECT city, COUNT(*) as total
FROM customers
GROUP BY city
HAVING total > 10;
```

---

## 5. Subquery Errors

### Subquery Returns Multiple Rows
```sql
❌ Lỗi nếu subquery trả về > 1 row
SELECT * FROM products
WHERE category_id = (SELECT id FROM categories);

✅ Use IN
SELECT * FROM products
WHERE category_id IN (SELECT id FROM categories);
```

### Missing Alias for Subquery
```sql
❌ Every derived table must have an alias
SELECT * FROM (
    SELECT customer_id, COUNT(*) FROM orders GROUP BY customer_id
);

✅ Add Alias
SELECT * FROM (
    SELECT customer_id, COUNT(*) as order_count
    FROM orders
    GROUP BY customer_id
) AS customer_stats;
```

---

## 6. Data Type Errors

### String vs Number
```sql
❌ Comparing string with number
SELECT * FROM orders WHERE id = '1';

✅ Use correct type
SELECT * FROM orders WHERE id = 1;
```

### Date Format
```sql
❌ Invalid date format
SELECT * FROM orders WHERE created_at = '01-01-2024';

✅ Correct format: YYYY-MM-DD
SELECT * FROM orders WHERE created_at = '2024-01-01';
```

---

## 7. Performance Issues

### SELECT * on Large Tables
```sql
❌ Slow - lấy tất cả columns
SELECT * FROM orders;

✅ Fast - chỉ lấy cần thiết
SELECT id, customer_id, total_amount FROM orders;
```

### Missing Index
```sql
❌ Slow - full table scan
SELECT * FROM products WHERE price > 100000;

✅ Create index
CREATE INDEX idx_price ON products(price);
SELECT * FROM products WHERE price > 100000;
```

### N+1 Query Problem
```sql
❌ Chạy query trong loop (N+1 queries)
-- Lấy orders, rồi mỗi order lại query customer

✅ Use JOIN (1 query)
SELECT o.*, c.name FROM orders o
JOIN customers c ON o.customer_id = c.id;
```

---

## 8. Transaction Errors

### Forgetting COMMIT
```sql
❌ Changes not saved
START TRANSACTION;
UPDATE products SET price = 200000 WHERE id = 1;
-- Quên COMMIT

✅ Always COMMIT or ROLLBACK
START TRANSACTION;
UPDATE products SET price = 200000 WHERE id = 1;
COMMIT;
```

---

## 9. Connection Errors

### Can't Connect to MySQL
```
❌ Error: Can't connect to MySQL server
```

**Solutions:**
1. Check Docker container running: `docker ps`
2. Check port: `netstat -an | grep 3306`
3. Verify credentials in `.env`
4. Restart container: `docker-compose restart`

### Access Denied
```
❌ Access denied for user 'sqllearner'@'localhost'
```

**Solutions:**
1. Check username/password
2. Check database exists: `SHOW DATABASES;`
3. Check permissions: `SHOW GRANTS FOR 'sqllearner'@'%';`

---

## 10. Common Mistakes

### Not Using LIMIT in Development
```sql
❌ Returns all rows (dangerous!)
SELECT * FROM orders;

✅ Always LIMIT during testing
SELECT * FROM orders LIMIT 10;
```

### Không Backup Trước Khi DELETE/UPDATE
```sql
❌ No backup
DELETE FROM products WHERE price > 1000000;

✅ Backup first
CREATE TABLE products_backup AS SELECT * FROM products;
DELETE FROM products WHERE price > 1000000;
```

### Hard-Coding Values
```sql
❌ Hard-coded
SELECT * FROM products WHERE created_at > '2024-01-01';

✅ Parameterized (trong app)
SELECT * FROM products WHERE created_at > ?;
```

---

## Debug Tips

### 1. Start Simple
```sql
-- Thay vì query phức tạp ngay
SELECT o.*, c.name, p.name, ...

-- Bắt đầu đơn giản, thêm dần
SELECT * FROM orders;  -- Test basic
SELECT * FROM orders WHERE ...;  -- Add WHERE
SELECT o.*, c.name FROM orders o JOIN ...;  -- Add JOIN
```

### 2. Use EXPLAIN
```sql
EXPLAIN SELECT * FROM products WHERE price > 100000;
-- Xem query plan, check indexes
```

### 3. Check Row Count
```sql
-- Trước khi DELETE/UPDATE
SELECT COUNT(*) FROM products WHERE price > 1000000;
-- Nếu OK thì mới chạy:
DELETE FROM products WHERE price > 1000000;
```

### 4. Comment Out Parts
```sql
SELECT *
FROM orders o
JOIN customers c ON o.customer_id = c.id
-- JOIN products p ON ...  -- Comment để test
WHERE o.status = 'delivered';
```

---

⬅️ [Quay lại Phụ Lục](README.md)
