-- Inventory management starts here 
-- First We are going to insert the values into a table called used_materials
DROP TABLE IF EXISTS used_materials;
CREATE TABLE used_materials (
    Sale_ID INT,
    Order_ID2 INT,
    Product_ID INT,
    Material_ID INT,
    used_quantity DECIMAL(10,2)
);

INSERT INTO used_materials (Sale_ID, Order_ID2, Product_ID, Material_ID, used_quantity)
SELECT 
    so.Sale_ID,
    so.Order_ID2,
    so.Product_ID,
    mr.Material_ID,
    mr.Quantity_Used * so.Quantity AS used_quantity
FROM sales_orderly so
JOIN menu_raw mr
  ON so.Product_ID = mr.Product_ID;

-- Now lets create a new table called inventory_backup and assign rawmaterials sheet data to it
DROP TABLE IF EXISTS inventory_backup;
CREATE TABLE inventory_backup AS
SELECT * FROM raw_materials;


SET SQL_SAFE_UPDATES = 0;

-- now create a temp table to store the used value
DROP TABLE IF EXISTS temp_usage1;
CREATE TEMPORARY TABLE temp_usage1
SELECT
    Material_Id,
    SUM(used_quantity) AS total_used
FROM used_materials
GROUP BY Material_Id;

-- Now update the backup table tby subtracting used materials from existing materials
UPDATE inventory_backup ib
JOIN temp_usage1 tu ON ib.Material_Id = tu.Material_Id
SET ib.Total_Units = ib.Total_Units - tu.total_used;

SELECT * FROM inventory_backup LIMIT 200;
-- Update Total_Units to ensure no negative values
UPDATE inventory_backup
SET Total_Units = 
    CASE 
        WHEN Units = 'g' AND Total_Units <= 0 THEN 100
        WHEN Units = 'ml' AND Total_Units <= 0 THEN 750
        WHEN Units = 'ml' AND Total_Units <= 0 THEN 750
        WHEN Units = 'units' AND Total_Units <= 0 THEN 15
        WHEN Units = 'unit' AND Total_Units <= 0 THEN 15
        ELSE Total_Units
    END;

SELECT * FROM inventory_backup;
