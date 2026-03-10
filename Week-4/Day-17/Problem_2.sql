-- When cancelling an order, system must restore stock quantities and update order_status to Rejected (3). All actions must be atomic.
-- 📌 Requirements 
-- - Begin a transaction when cancelling an order.
-- - Restore stock quantities based on order_items.
-- - Update order_status to 3.
-- - Use SAVEPOINT before stock restoration.
-- - If stock restoration fails, rollback to SAVEPOINT.
-- - Commit transaction only if all operations succeed.

-- 🛠️ Technical Constraints 
-- - Use BEGIN TRANSACTION.
-- - Use SAVE TRANSACTION (SAVEPOINT).
-- - Use TRY…CATCH with custom error handling.
-- - Use COMMIT and ROLLBACK appropriately.

-- Expectations
-- - Proper use of SAVEPOINT.
-- - Atomic and consistent transaction handling.
-- - Accurate stock restoration.
-- - Robust error management.

-- Products table
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    stock_qty INT
);

-- Orders table
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    order_status INT -- 1 = placed, 2 = shipped, 3 = rejected
);

-- Order Items table
CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

DECLARE @orderId INT = 101

BEGIN TRANSACTION

BEGIN TRY

    -- Savepoint before stock restoration
    SAVE TRANSACTION BeforeStockRestore

    -- Restore stock based on order items
    UPDATE p
    SET p.stock_qty = p.stock_qty + oi.quantity
    FROM products p
    JOIN order_items oi 
        ON p.product_id = oi.product_id
    WHERE oi.order_id = @orderId


    -- Update order status to Rejected (3)
    UPDATE orders
    SET order_status = 3
    WHERE order_id = @orderId


    -- Commit if everything successful
    COMMIT TRANSACTION
    PRINT 'Order cancelled successfully and stock restored.'

END TRY


BEGIN CATCH

    PRINT 'Error occurred while restoring stock.'

    -- Rollback to savepoint 
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION BeforeStockRestore

    PRINT 'Rolled back to savepoint.'

    -- Full rollback
    ROLLBACK TRANSACTION
    PRINT 'Transaction cancelled.'

END CATCH