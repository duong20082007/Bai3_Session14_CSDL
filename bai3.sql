use rikkeiclinicdb;

DROP PROCEDURE DispenseMedicine ;
DELIMITER //

CREATE PROCEDURE DispenseMedicine(
    IN p_patient_id INT,        
    IN p_medicine_id INT,      
    IN p_quantity INT,          
    OUT p_status_message VARCHAR(255) 
)
BEGIN
    DECLARE v_current_stock INT DEFAULT 0;
    DECLARE v_unit_price DECIMAL(18,2) DEFAULT 0;

    START TRANSACTION;

    SELECT stock_quantity, unit_price INTO v_current_stock, v_unit_price
    FROM Medicines
    WHERE medicine_id = p_medicine_id;

    IF p_quantity > v_current_stock THEN
        ROLLBACK;
        SET p_status_message = 'Số lượng tồn kho không đủ';
    ELSE
        UPDATE Medicines 
        SET stock_quantity = stock_quantity - p_quantity 
        WHERE medicine_id = p_medicine_id;

        UPDATE Patient_Invoices 
        SET total_due = total_due + (p_quantity * v_unit_price) 
        WHERE patient_id = p_patient_id;

        COMMIT;
        SET p_status_message = 'Đã cấp phát thành công';
    END IF;
END //

DELIMITER ;

SET @status_message = '';
CALL control_medicines(1, 1, 2, @status_message);

CALL control_medicines(2, 2, 10, @status_message);
SELECT @status_message;