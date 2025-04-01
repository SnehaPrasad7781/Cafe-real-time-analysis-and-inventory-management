
-- Now if the materials go below the marked value then the stock will refill and gives a mail to us b y a python code
SELECT 
  Material_Id, 
  Total_Units
FROM inventory_backup
WHERE Total_Units <= 10;


-- Add original_qty column if it doesn't exist

DROP TABLE IF EXISTS refill_log;

CREATE TABLE IF NOT EXISTS refill_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    Material_Id INT,
    old_stock DECIMAL(10,2),
    refill_amount DECIMAL(10,2),
    new_stock DECIMAL(10,2),
    unit_type VARCHAR(10),
    refill_count INT,  -- New column to track how many times a material was refilled
    refill_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Stores the date and time of refill
    refill_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP -- Updates time if modified
);


