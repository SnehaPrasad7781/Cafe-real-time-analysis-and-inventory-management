DROP PROCEDURE IF EXISTS sp_refill_from_zero_stock;
DELIMITER //
CREATE PROCEDURE sp_refill_from_zero_stock()
BEGIN
    -- Declare variables
    DECLARE done INT DEFAULT FALSE;
    DECLARE material_id INT;
    DECLARE zero_date DATE;
    DECLARE old_stock DECIMAL(10,2);
    DECLARE refill_amount DECIMAL(10,2);
    DECLARE new_stock DECIMAL(10,2);
    DECLARE unit_type VARCHAR(10);
    DECLARE refill_count INT DEFAULT 1;

    -- Cursor to find the first date a material's stock dropped to 0 or negative
    DECLARE cur CURSOR FOR 
    SELECT sp.Material_Id, MIN(sp.sales_date) AS zero_date, rm.stock, rm.unit_type
    FROM sales_product sp
    JOIN raw_materials rm ON sp.Material_Id = rm.Material_Id
    WHERE rm.stock <= 0
    GROUP BY sp.Material_Id;

    -- Declare handler for loop termination
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Open cursor
    OPEN cur;

    refill_loop: LOOP
        FETCH cur INTO material_id, zero_date, old_stock, unit_type;

        IF done THEN
            LEAVE refill_loop;
        END IF;

        -- If stock is NULL or negative, assume it was 0 before refill
        SET old_stock = IFNULL(old_stock, 0);

        -- Determine refill amount based on unit type
        SET refill_amount = 
            CASE 
                WHEN unit_type = 'g' THEN 100
                WHEN unit_type = 'ml' THEN 750
                WHEN unit_type = 'units' THEN 15
                ELSE 50  -- Default value if unit type is unknown
            END;

        -- Calculate new stock value
        SET new_stock = old_stock + refill_amount;

        -- Update inventory with new stock level
        UPDATE raw_materials
        SET stock = new_stock
        WHERE Material_Id = material_id;

        -- Insert refill log entry with correct past date
        INSERT INTO refill_log (Material_Id, old_stock, refill_amount, new_stock, unit_type, refill_count, refill_date)
        VALUES (material_id, old_stock, refill_amount, new_stock, unit_type, refill_count, zero_date);
    END LOOP;

    -- Close cursor
    CLOSE cur;
END //

DELIMITER ;

select * from refill_log