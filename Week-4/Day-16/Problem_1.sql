-- Scenario
-- The company requires reusable database logic to generate reports such as total sales per store and discounted order totals.

--  Requirements 
-- - Create a stored procedure to generate total sales amount per store.
-- - Create a stored procedure to retrieve orders by date range.
-- - Create a scalar function to calculate total price after discount.
-- - Create a table-valued function to return top 5 selling products.

--  Technical Constraints 
-- - Use input parameters in stored procedures.
-- - Handle NULL values properly.
-- - Ensure optimized queries inside procedures.
-- - Follow proper naming conventions.

-- Stores
CREATE TABLE stores (
    store_id INT PRIMARY KEY,
    store_name VARCHAR(100)
);

-- Orders
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    store_id INT,
    order_date DATE,
    total_amount DECIMAL(10,2),
    FOREIGN KEY (store_id) REFERENCES stores(store_id)
);

-- Products
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100)
);

-- Order Items
CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE PROCEDURE sp_GetTotalSalesPerStore
    @StoreID INT = NULL
AS
BEGIN

    SELECT 
        s.store_id,
        s.store_name,
        SUM(ISNULL(o.total_amount,0)) AS total_sales
    FROM stores s
    LEFT JOIN orders o
        ON s.store_id = o.store_id
    WHERE (@StoreID IS NULL OR s.store_id = @StoreID)
    GROUP BY s.store_id, s.store_name

END

CREATE PROCEDURE sp_GetOrdersByDateRange
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN

    SELECT 
        o.order_id,
        o.store_id,
        o.order_date,
        o.total_amount
    FROM orders o
    WHERE o.order_date BETWEEN @StartDate AND @EndDate

END

CREATE FUNCTION fn_CalculateDiscountedPrice
(
    @TotalAmount DECIMAL(10,2),
    @DiscountRate DECIMAL(5,2)
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    RETURN @TotalAmount - (@TotalAmount * @DiscountRate / 100)
END

CREATE FUNCTION fn_GetTopSellingProducts()  
RETURNS @TopProducts TABLE
(
    product_id INT,
    product_name VARCHAR(100),
    total_quantity_sold INT
)
AS
BEGIN
    INSERT INTO @TopProducts
    SELECT 
        p.product_id,
        p.product_name,
        SUM(oi.quantity) AS total_quantity_sold
    FROM products p
    JOIN order_items oi 
        ON p.product_id = oi.product_id
    GROUP BY p.product_id, p.product_name
    ORDER BY total_quantity_sold DESC
    OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY

    RETURN
END