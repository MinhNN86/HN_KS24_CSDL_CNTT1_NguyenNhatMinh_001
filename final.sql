DROP DATABASE IF EXISTS logistics_db;
CREATE DATABASE logistics_db;
USE logistics_db;

-- PHẦN 1: THIẾT KẾ CSDL & CHÈN DỮ LIỆU
# Thiết kế bảng
CREATE TABLE Shippers (
    shipper_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(15) NOT NULL UNIQUE,
    license_type VARCHAR(50) NOT NULL,
    rating DECIMAL(2,1) DEFAULT 5.0 CHECK (rating BETWEEN 0 AND 5)
);

CREATE TABLE Vehicle_Details (
    vehicle_id INT AUTO_INCREMENT PRIMARY KEY,
    shipper_id INT NOT NULL,
    license_plate VARCHAR(20) NOT NULL UNIQUE,
    vehicle_type ENUM('Truck', 'Motorbike', 'Container') NOT NULL,
    max_load DECIMAL(10,2) NOT NULL CHECK (max_load > 0),
	FOREIGN KEY (shipper_id) REFERENCES Shippers(shipper_id) ON DELETE CASCADE
);

CREATE TABLE Shipments (
    shipment_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    actual_weight DECIMAL(10,2) NOT NULL CHECK (actual_weight > 0),
    product_value DECIMAL(15,2),
    status ENUM('In Transit', 'Delivered', 'Returned') NOT NULL
);

CREATE TABLE Delivery_Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    shipment_id INT NOT NULL,
    shipper_id INT NOT NULL,
    assigned_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    shipping_fee DECIMAL(12,2),
    status ENUM('Pending','Processing','Finished','Cancelled'),
    FOREIGN KEY (shipment_id) REFERENCES Shipments(shipment_id),
    FOREIGN KEY (shipper_id) REFERENCES Shippers(shipper_id)
);

CREATE TABLE Delivery_Log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT ,
    current_location VARCHAR(255) NOT NULL,
    log_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    note VARCHAR(255),
    FOREIGN KEY (order_id) REFERENCES Delivery_Orders(order_id)
);

# DML
-- Shippers
INSERT INTO Shippers (full_name, phone, license_type, rating) VALUES
('Nguyen Van An', '0901234567', 'C', 4.8),
('Tran Thi Binh', '0912345678', 'A2', 5.0),
('Le Hoang Nam', '0983456789', 'FC', 4.2),
('Pham Minh Duc', '0354567890', 'B2', 4.9),
('Hoang Quoc Viet', '0775678901', 'C', 4.7);

-- Vehicle_Details
INSERT INTO Vehicle_Details (vehicle_id, shipper_id, license_plate, vehicle_type, max_load) VALUES
(101, 1, '29C-123.45', 'Truck', 3500),
(102, 2, '59A-888.88', 'Motorbike', 500),
(103, 3, '15R-999.99', 'Container', 32000),
(104, 4, '30F-111.22', 'Truck', 1500),
(105, 5, '43C-444.55', 'Truck', 5000);


-- Shipments
INSERT INTO Shipments (shipment_id, product_name, actual_weight, product_value, status) VALUES
(5001, 'Smart TV Samsung 55 inch', 25.5, 15000000, 'In Transit'),
(5002, 'Laptop Dell XPS', 2.0, 35000000, 'Delivered'),
(5003, 'Máy nén khí công nghiệp', 450.0, 120000000, 'In Transit'),
(5004, 'Thùng trái cây nhập khẩu', 15.0, 2500000, 'Returned'),
(5005, 'Máy giặt LG Inverter', 70.0, 9500000, 'In Transit');

-- Delivery_Orders
INSERT INTO Delivery_Orders (order_id, shipment_id, shipper_id, assigned_time, shipping_fee, status) VALUES
(9001, 5001, 1, '2024-05-20 08:00:00', 2000000, 'Processing'),
(9002, 5002, 2, '2024-05-20 09:30:00', 3500000, 'Finished'),
(9003, 5003, 3, '2024-05-20 10:15:00', 2500000, 'Processing'),
(9004, 5004, 5, '2024-05-21 07:00:00', 1500000, 'Finished'),
(9005, 5005, 4, '2024-05-21 08:45:00', 2500000, 'Pending');

-- Delivery_Log
INSERT INTO Delivery_Log (log_id, order_id, current_location, log_time, note) VALUES
(1, 9001, 'Kho tổng (Hà Nội)', '2021-05-15 08:15:00', 'Rời kho'),
(2, 9001, 'Trạm thu phí Phủ Lý', '2021-05-17 10:00:00', 'Đang giao'),
(3, 9002, 'Quận 1, TP.HCM', '2024-05-19 10:30:00', 'Đã đến điểm đích'),
(4, 9003, 'Cảng Hải Phòng', '2024-05-20 11:00:00', 'Rời kho'),
(5, 9004, 'Kho hoàn hàng (Đà Nẵng)', '2024-05-21 14:00:00', 'Đã nhập kho trả hàng');


-- Phần 2
# CÂU 1:
SELECT license_plate, vehicle_type, max_load
FROM Vehicle_Details
WHERE max_load > 5000
   OR (vehicle_type = 'Container' AND max_load < 2000);
# CÂU 2:
SELECT full_name, phone
FROM Shippers
WHERE rating BETWEEN 4.5 AND 5.0
AND phone LIKE '090%';
# CÂU 3:
SELECT *
FROM Shipments
ORDER BY product_value DESC
LIMIT 2 OFFSET 2;

-- Phần 3:
# CÂU 1:
SELECT 
	s.full_name, 
    sh.shipment_id, 
    sh.product_name,
	d.shipping_fee, 
    d.assigned_time
FROM Delivery_Orders d
JOIN Shippers s ON d.shipper_id = s.shipper_id
JOIN Shipments sh ON d.shipment_id = sh.shipment_id;

# CÂU 2:
SELECT s.full_name, SUM(d.shipping_fee) AS total_fee
FROM Delivery_Orders d
JOIN Shippers s ON d.shipper_id = s.shipper_id
GROUP BY s.shipper_id
HAVING total_fee > 3000000;

# CÂU 3: 
SELECT *
FROM Shippers
WHERE rating = (SELECT MAX(rating) FROM Shippers);

-- Phần 4: 
# CÂU 1:
CREATE INDEX idx_shipment_status_value
ON Shipments(status, product_value);
# CÂU 2: 
CREATE VIEW vw_driver_performance AS
SELECT s.full_name,
       COUNT(d.order_id) AS total_orders,
       SUM(d.shipping_fee) AS total_revenue
FROM Shippers s
JOIN Delivery_Orders d ON s.shipper_id = d.shipper_id
WHERE d.status <> 'Cancelled'
GROUP BY s.shipper_id;

SELECT * FROM vw_driver_performance;

-- Phần 5:
# CÂU 1:
DELIMITER //
CREATE TRIGGER trg_after_delivery_finish 
AFTER UPDATE ON Delivery_Orders
FOR EACH ROW
BEGIN
	IF NEW.status = 'Finished' AND OLD.status <> 'Finished' THEN
		INSERT INTO Delivery_Log(order_id, current_location, note) VALUE
        (NEW.order_id, 'Tại điểm đích', 'Delivery Completed Successfully');
    END IF;
END // DELIMITER ;

# CÂU 2:
DELIMITER //
CREATE TRIGGER trg_update_driver_rating
AFTER INSERT ON Delivery_Orders
FOR EACH ROW
BEGIN
    IF NEW.status = 'Finished' THEN
        UPDATE Shippers
        SET rating = LEAST(rating + 0.1, 5.0)
        WHERE shipper_id = NEW.shipper_id;
    END IF;
END; // DELIMITER ;

-- Phần 6 
# CÂU 1:
DROP PROCEDURE sp_check_payload_status;
DELIMITER //
CREATE PROCEDURE sp_check_payload_status(
    IN p_vehicle_id INT,
    OUT message VARCHAR(50)
)
BEGIN
    DECLARE v_max_load DECIMAL(10,2);
    DECLARE v_actual_weight DECIMAL(10,2);

    SELECT max_load INTO v_max_load
    FROM Vehicle_Details
    WHERE vehicle_id = p_vehicle_id;

    SELECT sh.actual_weight INTO v_actual_weight
    FROM Shipments sh
    JOIN Delivery_Orders d ON sh.shipment_id = d.shipment_id
    JOIN Vehicle_Details v ON v.shipper_id = d.shipper_id
    WHERE v.vehicle_id = p_vehicle_id
    LIMIT 1;

    IF v_actual_weight > v_max_load THEN
        SET message = 'Quá tải';
    ELSEIF v_actual_weight = v_max_load THEN
        SET message = 'Đầy tải';
    ELSE
        SET message = 'An toàn';
    END IF;
END // DELIMITER ;

SET @messageCheckPayload = '';
CALL sp_check_payload_status(101, @messageCheckPayload);
SELECT @messageCheckPayload AS '.'

-- CÂU 2
DELIMITER //
CREATE PROCEDURE sp_reassign_driver(
	IN p_order_id INT,
    IN p_new_shipper_id INT,
)
BEGIN
	
END // DELIMITER ;








