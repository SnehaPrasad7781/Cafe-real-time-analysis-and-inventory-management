ALTER TABLE inventory_backup
ADD COLUMN original_qty DECIMAL(10,2) NOT NULL DEFAULT 100;

DROP PROCEDURE IF EXISTS sp_record_sale;

DELIMITER $$

CREATE PROCEDURE sp_record_sale(
    IN p_Order_ID2 INT,
    IN p_Product_ID INT,
    IN p_Quantity INT,
    OUT p_new_Sale_ID INT
)
BEGIN
    DECLARE v_Price INT;
    DECLARE v_Item_Subtotal INT;
    DECLARE v_Order_Subtotal INT;
    DECLARE v_Delivery_Charge INT DEFAULT 0;
    DECLARE v_Order_Total INT;
    
    -- 1. Get the price from the menu table
    SELECT Price INTO v_Price FROM menu WHERE Product_ID = p_Product_ID;
    
    -- 2. Calculate values
    SET v_Item_Subtotal = v_Price * p_Quantity;
    SET v_Order_Subtotal = v_Item_Subtotal;  -- Assuming one item per order
    SET v_Order_Total = v_Order_Subtotal + v_Delivery_Charge;

    -- 3. Insert into sales_orderly
    INSERT INTO sales_orderly (
        Order_ID2, 
        Date, 
        Time, 
        Order_Type, 
        Product_ID, 
        Price, 
        Quantity, 
        Item_Subtotal, 
        Order_Subtotal, 
        Delivery_Charge, 
        Order_Total
    )
    VALUES (
        p_Order_ID2, 
        CURDATE(),   -- Auto-fills the current date
        CURTIME(),   -- Auto-fills the current time
        'Dine-in',   -- Default order type
        p_Product_ID, 
        v_Price, 
        p_Quantity, 
        v_Item_Subtotal, 
        v_Order_Subtotal, 
        v_Delivery_Charge, 
        v_Order_Total
    );

    -- 4. Get the new Sale_ID
    SET p_new_Sale_ID = LAST_INSERT_ID();

    -- 5. Insert used materials from menu_raw table
    INSERT INTO used_materials (
        Sale_ID, 
        Order_ID2, 
        Product_ID, 
        Material_ID, 
        used_quantity
    )
    SELECT 
        p_new_Sale_ID,
        p_Order_ID2,
        mr.Product_ID,
        mr.Material_ID,
        mr.Quantity_Used * p_Quantity AS used_quantity
    FROM menu_raw mr
    WHERE mr.Product_ID = p_Product_ID;

    -- 6. Update inventory_backup
    UPDATE inventory_backup inv
    JOIN (
        SELECT Material_ID, SUM(mr.Quantity_Used * p_Quantity) AS used_qty
        FROM menu_raw mr
        WHERE mr.Product_ID = p_Product_ID
        GROUP BY Material_Id
    ) AS mat_usage ON inv.Material_ID = mat_usage.Material_ID
    SET inv.Total_Units = GREATEST(0, inv.Total_Units - mat_usage.used_qty);  -- Prevent negative stock

END $$

DELIMITER ;

-- Turn off safe mode
SET SQL_SAFE_UPDATES = 0;

-- Example call (Only Order_ID2, Product_ID, and Quantity required)
CALL sp_record_sale(102, 277, 5, @new_saleid);

-- Check results
SELECT * FROM sales_orderly;
SELECT * FROM used_materials;
SELECT * FROM inventory_backup;
