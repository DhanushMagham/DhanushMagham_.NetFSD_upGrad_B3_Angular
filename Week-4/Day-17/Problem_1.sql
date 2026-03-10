-- #Scenario
-- Auto retail company wants to ensure stock consistency while placing orders. Whenever an order is placed, stock should reduce automatically and transaction should rollback if stock is insufficient.

-- Requirements 
-- - Write a transaction to insert data into orders and order_items tables.
-- - Check stock availability before confirming order.
-- - Create a trigger to reduce stock quantity after order insertion.
-- - Rollback transaction if stock quantity is insufficient.

-- Technical Constraints 
-- - Use explicit transactions (BEGIN TRANSACTION, COMMIT, ROLLBACK).
-- - Trigger must handle multiple rows.
-- - Do not allow negative stock values.
-- - Maintain referential integrity.
-- Expectations
-- - Successful implementation of ACID properties.
-- - Automatic stock update using trigger.
-- - Proper rollback mechanism in failure scenarios.

#creating tables
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    stock_quantity INT
);
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    order_date DATE
);
CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
# Inserting data
INSERT INTO products (product_id, product_name, stock_quantity) VALUES (1, 'Car Model A', 10);
INSERT INTO products (product_id, product_name, stock_quantity) VALUES (2, 'Car Model B', 5);
INSERT INTO products (product_id, product_name, stock_quantity) VALUES (3, 'Car Model C', 8);
INSERT INTO products (product_id, product_name, stock_quantity) VALUES (4, 'Car Model D', 12);
#Creating trigger
DELIMITER //
CREATE TRIGGER after_order_insert
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    UPDATE products
    SET stock_quantity = stock_quantity - NEW.quantity
    WHERE product_id = NEW.product_id;
END//
DELIMITER ;
#Transactions to insert order, order items
BEGIN TRANSACTION;
INSERT INTO orders (order_id, order_date) VALUES (1, CURDATE());
INSERT INTO order_items (order_item_id, order_id, product_id, quantity) VALUES (1, 1, 1, 3);

SELECT stock_quantity FROM products WHERE product_id = 1;

COMMIT;

SELECT stock_quantity FROM products WHERE product_id = 1;

