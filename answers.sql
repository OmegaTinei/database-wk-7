--Question 1
-- This query achieves First Normal Form (1NF) by splitting the
-- multi-valued 'Products' column into separate rows.

-- We use a Common Table Expression (CTE) to represent the
-- original data for this example. In a real-world scenario,
-- you would use your actual table name instead of 'ProductDetail'.
WITH ProductDetail (OrderID, CustomerName, Products) AS (
    VALUES
        (101, 'John Doe', 'Laptop, Mouse'),
        (102, 'Jane Smith', 'Tablet, Keyboard, Mouse'),
        (103, 'Emily Clark', 'Phone')
)

-- This is the main part of the query that performs the transformation.
SELECT
    -- We select the original columns (OrderID, CustomerName)
    -- from the CTE.
    original_data.OrderID,
    original_data.CustomerName,
    
    -- We use a string-splitting function to get each individual product.
    -- This function splits the string by the comma and space delimiter
    -- and returns each split value as a new row.
    TRIM(split_products.product_name) AS Product
FROM
    ProductDetail AS original_data,
    
    -- CROSS JOIN LATERAL is used to apply the splitting function to each
    -- row of the original table. It's a very efficient way to handle this.
    LATERAL UNNEST(string_to_array(original_data.Products, ',')) AS split_products(product_name);

--Question 2
-- This query demonstrates how to achieve Second Normal Form (2NF)
-- by splitting a table to remove partial dependencies.

-- The original table, OrderDetails, has a partial dependency where
-- `CustomerName` depends only on `OrderID` and not on the full
-- composite key (OrderID, Product).

-- We'll use a Common Table Expression (CTE) to represent your original
-- data for this example.
WITH OrderDetails (OrderID, CustomerName, Product, Quantity) AS (
    VALUES
        (101, 'John Doe', 'Laptop', 2),
        (101, 'John Doe', 'Mouse', 1),
        (102, 'Jane Smith', 'Tablet', 3),
        (102, 'Jane Smith', 'Keyboard', 1),
        (102, 'Jane Smith', 'Mouse', 2),
        (103, 'Emily Clark', 'Phone', 1)
)

--
-- Step 1: We create a new table for the Order and Customer information.
--
-- This new table, `Orders`, will have a primary key on `OrderID`.
-- It stores information that depends only on the Order ID.
SELECT
    -- We use SELECT DISTINCT to ensure each OrderID appears only once.
    DISTINCT OrderID,
    CustomerName
FROM
    OrderDetails;

--
-- Step 2: We create a separate table for the details of each order.
--
-- This `OrderItems` table will link back to the `Orders` table
-- via `OrderID`, which now serves as a foreign key.
-- Its primary key is the composite key of (OrderID, Product).
SELECT
    OrderID,
    Product,
    Quantity
FROM
    OrderDetails;
