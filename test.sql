-- =============================================================================
-- BookingBus SQL Schema - Corrected and Enhanced Version
-- Target Database: BookingBus
-- =============================================================================

-- --- Database Creation (Optional - Run manually if needed) ---
-- CREATE DATABASE IF NOT EXISTS BookingBus CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
-- USE BookingBus;

-- --- Table Structure ---

-- ตารางบทบาทผู้ใช้
DROP TABLE IF EXISTS `roles`;
CREATE TABLE `roles` (
  `role_id` INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
  `role` ENUM('user','admin') NOT NULL DEFAULT 'user' UNIQUE COMMENT 'บทบาท: user หรือ admin'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='ตารางเก็บประเภทบทบาทผู้ใช้';

-- ตารางบัญชีผู้ใช้
DROP TABLE IF EXISTS `userAccount`;
CREATE TABLE `userAccount` (
  `user_id` INT AUTO_INCREMENT NOT NULL PRIMARY KEY COMMENT 'ID ผู้ใช้ (Auto Increment)',
  `user_name` VARCHAR(30) NOT NULL UNIQUE COMMENT 'ชื่อผู้ใช้ (สำหรับ Login หรือแสดงผล)',
  `first_name` VARCHAR(50) NOT NULL COMMENT 'ชื่อจริง',
  `last_name` VARCHAR(50) NOT NULL COMMENT 'นามสกุล',
  `email` VARCHAR(50) NOT NULL UNIQUE COMMENT 'อีเมล (สำหรับ Login)',
  `password` VARCHAR(255) NOT NULL COMMENT 'รหัสผ่าน (ต้องเก็บค่าที่ HASH แล้วเท่านั้น!)',
  `role_id` INT NOT NULL DEFAULT 1 COMMENT 'FK อ้างอิง roles.role_id (1=user, 2=admin)',
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'เวลาสร้างบัญชี',
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'เวลาแก้ไขบัญชีล่าสุด',
  FOREIGN KEY (`role_id`) REFERENCES `roles`(`role_id`)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='ตารางเก็บข้อมูลบัญชีผู้ใช้';

-- ตารางเอกสารยืนยันตัวตน (เชื่อมกับ userAccount)
DROP TABLE IF EXISTS `identityDocs`;
CREATE TABLE `identityDocs` (
  `identity_id` INT AUTO_INCREMENT NOT NULL PRIMARY KEY COMMENT 'ID เอกสาร',
  `user_id` INT NOT NULL COMMENT 'FK อ้างอิง userAccount.user_id',
  `identification_no` VARCHAR(20) NOT NULL UNIQUE COMMENT 'เลขบัตรประชาชน',
  `passport_no` VARCHAR(40) NULL UNIQUE COMMENT 'เลขหนังสือเดินทาง (ถ้ามี)',
  -- `role_id` INT NOT NULL COMMENT 'FK อ้างอิง roles.role_id (ข้อมูลซ้ำซ้อน อาจไม่จำเป็น)', -- หมายเหตุ: เอา role_id ออก เพราะดึงจาก userAccount ได้
  FOREIGN KEY (`user_id`) REFERENCES `userAccount`(`user_id`)
    ON UPDATE CASCADE ON DELETE CASCADE
  -- , FOREIGN KEY (`role_id`) REFERENCES `roles`(`role_id`) -- ถ้าต้องการเก็บ role ซ้ำซ้อน
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='ตารางเก็บเอกสารยืนยันตัวตน';

-- ตารางข้อมูลผู้โดยสาร (อาจเป็นคนเดียวกับ userAccount หรือเป็นคนอื่นที่ user จองให้)
DROP TABLE IF EXISTS `passenger`;
CREATE TABLE `passenger` (
  `passenger_id` INT AUTO_INCREMENT NOT NULL PRIMARY KEY COMMENT 'ID ผู้โดยสาร',
  `user_id` INT NULL COMMENT 'FK อ้างอิง userAccount.user_id (ถ้าผู้โดยสารคือ user เอง)',
  `identity_id` INT NULL COMMENT 'FK อ้างอิง identityDocs.identity_id (ถ้ามีข้อมูลเอกสาร)',
  `first_name` VARCHAR(50) NOT NULL COMMENT 'ชื่อจริงผู้โดยสาร',
  `last_name` VARCHAR(50) NOT NULL COMMENT 'นามสกุลผู้โดยสาร',
  `phone_number` VARCHAR(20) NOT NULL COMMENT 'เบอร์โทรติดต่อผู้โดยสาร (ไม่จำเป็นต้อง UNIQUE)',
  `birthday` DATE NULL COMMENT 'วันเกิดผู้โดยสาร (อาจ NULL ได้)',
  `email` VARCHAR(50) NULL DEFAULT NULL COMMENT 'อีเมลผู้โดยสาร (ถ้าต้องการเก็บ)',
  `gender` ENUM('Male', 'Female', 'Other') NULL DEFAULT NULL COMMENT 'เพศผู้โดยสาร',
  FOREIGN KEY (`user_id`) REFERENCES `userAccount`(`user_id`) ON DELETE SET NULL ON UPDATE CASCADE, -- ถ้า user ลบ ไม่จำเป็นต้องลบ passenger
  FOREIGN KEY (`identity_id`) REFERENCES `identityDocs`(`identity_id`) ON DELETE SET NULL ON UPDATE CASCADE -- ถ้าเอกสารลบ ไม่จำเป็นต้องลบ passenger
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='ตารางเก็บข้อมูลผู้โดยสาร';

-- ตารางเส้นทางเดินรถ
DROP TABLE IF EXISTS `route`;
CREATE TABLE `route` (
  `route_id` INT AUTO_INCREMENT NOT NULL PRIMARY KEY COMMENT 'ID เส้นทาง',
  `start_point` VARCHAR(80) NOT NULL COMMENT 'เมืองต้นทาง',
  `end_point` VARCHAR(80) NOT NULL COMMENT 'เมืองปลายทาง'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='ตารางเก็บข้อมูลเส้นทาง';

-- ตารางพนักงาน (คนขับ/แอดมินที่อาจเชื่อมกับ userAccount)
DROP TABLE IF EXISTS `employee`;
CREATE TABLE `employee` (
  `employee_id` VARCHAR(10) NOT NULL PRIMARY KEY COMMENT 'รหัสพนักงาน (กำหนดเอง)',
  `user_id` INT NULL UNIQUE COMMENT 'FK อ้างอิง userAccount.user_id (ถ้าพนักงาน login ได้)',
  `identity_id` INT NULL UNIQUE COMMENT 'FK อ้างอิง identityDocs.identity_id',
  -- role_id ดึงจาก userAccount ถ้ามี user_id
  `first_name` VARCHAR(30) NOT NULL COMMENT 'ชื่อจริงพนักงาน',
  `last_name` VARCHAR(30) NOT NULL COMMENT 'นามสกุลพนักงาน',
  `phone_number` VARCHAR(20) NOT NULL UNIQUE COMMENT 'เบอร์โทรพนักงาน',
  `email` VARCHAR(50) NOT NULL UNIQUE COMMENT 'อีเมลพนักงาน',
  `license_number` VARCHAR(20) NULL UNIQUE COMMENT 'เลขใบขับขี่ (ถ้าเป็นคนขับ)',
  `license_expiry` DATE NULL COMMENT 'วันหมดอายุใบขับขี่',
  `hire_date` DATE NOT NULL COMMENT 'วันที่เริ่มจ้าง',
  `position` VARCHAR(50) NULL COMMENT 'ตำแหน่งงาน',
  FOREIGN KEY (`user_id`) REFERENCES `userAccount`(`user_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  FOREIGN KEY (`identity_id`) REFERENCES `identityDocs`(`identity_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='ตารางเก็บข้อมูลพนักงาน';

-- ตารางรถโดยสาร
DROP TABLE IF EXISTS `bus`;
CREATE TABLE `bus` (
  `bus_id` VARCHAR(10) NOT NULL PRIMARY KEY COMMENT 'รหัสรถ (กำหนดเอง)',
  `employee_id` VARCHAR(10) NULL COMMENT 'FK อ้างอิง employee.employee_id (คนขับ)',
  `bus_type` ENUM('Economy Class', 'Gold Class', 'First Class') NOT NULL COMMENT 'ประเภทรถ',
  `total_seats` INT NOT NULL COMMENT 'จำนวนที่นั่งทั้งหมด',
  `license_plate` VARCHAR(10) NOT NULL UNIQUE COMMENT 'ทะเบียนรถ',
  FOREIGN KEY (`employee_id`) REFERENCES `employee`(`employee_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='ตารางเก็บข้อมูลรถโดยสาร';

-- ตารางตารางเวลาเดินรถ
DROP TABLE IF EXISTS `Schedule`;
CREATE TABLE `Schedule` (
  `schedule_id` INT AUTO_INCREMENT NOT NULL PRIMARY KEY COMMENT 'ID รอบเวลา',
  `route_id` INT NOT NULL COMMENT 'FK อ้างอิง route.route_id',
  `bus_id` VARCHAR(10) NOT NULL COMMENT 'FK อ้างอิง bus.bus_id',
  `departure_date` DATE NOT NULL COMMENT 'วันที่ออกเดินทาง',
  `departure_time` TIME NOT NULL COMMENT 'เวลาออกเดินทาง',
  `arrival_time` TIME NOT NULL COMMENT 'เวลาถึงโดยประมาณ',
  `price` DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'ราคาสำหรับรอบเวลานี้', -- เพิ่มคอลัมน์ราคา
  FOREIGN KEY (`route_id`) REFERENCES `route`(`route_id`) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (`bus_id`) REFERENCES `bus`(`bus_id`) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='ตารางเก็บรอบเวลาเดินรถ';
-- หมายเหตุ: availableSeats (ที่นั่งว่าง) ควรคำนวณโดย Backend Application ไม่ใช่เก็บใน DB

-- ตารางการจอง
DROP TABLE IF EXISTS `booking`;
CREATE TABLE `booking` (
  `booking_id` VARCHAR(10) NOT NULL PRIMARY KEY COMMENT 'รหัสการจอง (สร้างโดยระบบ)',
  `passenger_id` INT NOT NULL COMMENT 'FK อ้างอิง passenger.passenger_id',
  `user_id` INT NULL COMMENT 'FK อ้างอิง userAccount.user_id (ผู้ทำการจอง)',
  `booking_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'วันและเวลาที่ทำการจอง',
  `total_price` DECIMAL(10,2) NOT NULL COMMENT 'ราคารวมของการจองนี้',
  `status` ENUM('Pending Payment', 'Confirmed', 'Cancelled', 'Completed') NOT NULL DEFAULT 'Pending Payment' COMMENT 'สถานะการจอง',
  FOREIGN KEY (`passenger_id`) REFERENCES `passenger`(`passenger_id`) ON UPDATE CASCADE ON DELETE RESTRICT, -- ไม่ควรลบ passenger ถ้ามี booking ค้างอยู่
  FOREIGN KEY (`user_id`) REFERENCES `userAccount`(`user_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='ตารางเก็บข้อมูลการจองหลัก';

-- ตารางการชำระเงิน
DROP TABLE IF EXISTS `payment`;
CREATE TABLE `payment` (
  `payment_id` INT AUTO_INCREMENT NOT NULL PRIMARY KEY COMMENT 'ID การชำระเงิน',
  `booking_id` VARCHAR(10) NOT NULL COMMENT 'FK อ้างอิง booking.booking_id',
  `payment_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'วันและเวลาที่ชำระเงิน/แจ้งชำระ',
  `payment_method` ENUM('Credit Card', 'QR Code', 'Bank Transfer') NOT NULL COMMENT 'ช่องทางการชำระเงิน',
  `amount` DECIMAL(10,2) NOT NULL COMMENT 'จำนวนเงินที่ชำระ',
  `payment_status` ENUM('Pending', 'Paid', 'Failed', 'Canceled', 'Expired', 'Verifying') NOT NULL DEFAULT 'Pending' COMMENT 'สถานะการชำระเงิน (อาจเพิ่ม Verifying ตอนรอตรวจสลิป)',
  `slip_image_url` VARCHAR(255) NULL DEFAULT NULL COMMENT 'URL หรือ Path ของไฟล์สลิป',
  `transaction_ref` VARCHAR(100) NULL COMMENT 'รหัสอ้างอิงจาก Payment Gateway (ถ้ามี)',
  `verified_by` INT NULL COMMENT 'FK อ้างอิง userAccount.user_id (Admin ที่ตรวจสอบ)',
  `verified_at` DATETIME NULL COMMENT 'เวลาที่ตรวจสอบสลิป',
  FOREIGN KEY (`booking_id`) REFERENCES `booking`(`booking_id`) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (`verified_by`) REFERENCES `userAccount`(`user_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='ตารางเก็บข้อมูลการชำระเงิน';

-- ตารางตั๋ว (รายละเอียดที่นั่งในการจอง)
DROP TABLE IF EXISTS `ticket`;
CREATE TABLE `ticket` (
  `ticket_id` VARCHAR(10) NOT NULL PRIMARY KEY COMMENT 'รหัสตั๋ว (อาจจะไม่จำเป็นต้องใช้ ถ้า booking_id+seat_number พอ)',
  `booking_id` VARCHAR(10) NOT NULL COMMENT 'FK อ้างอิง booking.booking_id',
  `schedule_id` INT NOT NULL COMMENT 'FK อ้างอิง Schedule.schedule_id',
  `seat_Number` VARCHAR(10) NOT NULL COMMENT 'หมายเลขที่นั่ง',
  `passenger_name_on_ticket` VARCHAR(100) NULL COMMENT 'ชื่อผู้โดยสารบนตั๋ว (อาจดึงจาก passenger)',
  FOREIGN KEY (`booking_id`) REFERENCES `booking`(`booking_id`) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (`schedule_id`) REFERENCES `Schedule`(`schedule_id`) ON UPDATE CASCADE ON DELETE CASCADE,
  UNIQUE KEY `unique_seat_on_schedule` (`schedule_id`, `seat_Number`) COMMENT 'ป้องกันการจองที่นั่งซ้ำในรอบรถเดียวกัน'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='ตารางเก็บรายละเอียดตั๋ว/ที่นั่งที่จอง';


-- --- Sample Data (แก้ไขให้ถูกต้องและสอดคล้องกัน) ---

-- ใส่ข้อมูล Roles (ถูกต้องแล้ว)
-- INSERT INTO roles (role) VALUES ('user'), ('admin'); -- รันไปแล้วตอน CREATE

-- ใส่ข้อมูล User Account (ต้องใส่ Hashed Password!)
-- **สำคัญ:** แทนที่ 'YOUR_HASHED_PASSWORD_HERE_X' ด้วยค่า Hash จริงจาก PHP password_hash()
INSERT INTO `userAccount` (`user_id`, `user_name`, `first_name`, `last_name`, `email`, `password`, `role_id`) VALUES
(NULL, 'testuser', 'Test', 'User', 'user@test.com', 'YOUR_HASHED_PASSWORD_HERE_1', 1),
(NULL, 'adminuser', 'Admin', 'Main', 'admin@test.com', 'YOUR_HASHED_PASSWORD_HERE_2', 2),
(NULL, 'somsak2049','Somsak', 'Thongmak','somsak2547@gmqail.com', 'YOUR_HASHED_PASSWORD_HERE_3', 1);
-- (เพิ่ม User อื่นๆ ตามต้องการ)

-- ใส่ข้อมูล Identity Docs (อ้างอิง user_id ที่ถูกสร้างขึ้น)
-- สมมติว่า user_id 1 คือ testuser, 2 คือ adminuser, 3 คือ somsak2049
INSERT INTO `identityDocs` (`identity_id`, `user_id`, `identification_no`, `passport_no`) VALUES
(NULL, 1, '1111111111111', NULL),
(NULL, 2, '2222222222222', 'AA123456'),
(NULL, 3, '1947796324103', NULL);

-- ใส่ข้อมูล Passenger (อ้างอิง user_id หรือ identity_id ถ้ามี)
INSERT INTO `passenger` (`passenger_id`, `user_id`, `identity_id`, `first_name`, `last_name`, `phone_number`, `birthday`, `email`, `gender`) VALUES
(NULL, 1, 1, 'Test', 'User', '0810000001', '1995-05-10', 'user@test.com', 'Male'), -- User จองให้ตัวเอง
(NULL, 3, 3, 'Somsak', 'Thongmak', '0812345671', '2000-12-28', 'somsak2547@gmail.com', 'Male'), -- User จองให้ตัวเอง
(NULL, 1, NULL, 'Child', 'Test', '0810000001', '2018-01-15', NULL, 'Female'); -- User จองให้คนอื่น (ไม่มีข้อมูล identity)

-- ใส่ข้อมูล Route
INSERT INTO `route` (`route_id`, `start_point`, `end_point`) VALUES
(NULL, 'Bangkok', 'Chiang Mai'), -- route_id = 1
(NULL, 'Bangkok', 'Phuket'),    -- route_id = 2
(NULL, 'Chiang Mai', 'Bangkok'); -- route_id = 3

-- ใส่ข้อมูล Employee (อ้างอิง user_id, identity_id ถ้ามี)
INSERT INTO `employee` (`employee_id`, `user_id`, `identity_id`, `first_name`, `last_name`, `phone_number`, `email`, `license_number`, `license_expiry`, `hire_date`, `position`) VALUES
('EMP001', 2, 2, 'Admin', 'Main', '0820000001', 'admin@test.com', NULL, NULL, '2023-01-01', 'System Admin'),
('DRV001', NULL, NULL, 'Driver', 'One', '0830000001', 'driver1@test.com', 'D12345678', '2026-12-31', '2023-02-01', 'Driver');

-- ใส่ข้อมูล Bus (อ้างอิง employee_id ถ้ามีคนขับประจำ)
INSERT INTO `bus` (`bus_id`, `employee_id`, `bus_type`, `total_seats`, `license_plate`) VALUES
('BUS001', 'DRV001', 'Economy Class', 40, '1A-1111'),
('BUS002', 'DRV001', 'Gold Class', 32, '1A-2222'),
('BUS003', NULL, 'First Class', 24, '1A-3333'); -- ไม่มีคนขับประจำ

-- ใส่ข้อมูล Schedule (อ้างอิง route_id, bus_id)
-- **สำคัญ:** กำหนดราคา (price) ที่นี่
INSERT INTO `Schedule` (`schedule_id`, `route_id`, `bus_id`, `departure_date`, `departure_time`, `arrival_time`, `price`) VALUES
(NULL, 1, 'BUS001', '2025-08-10', '08:00:00', '17:00:00', 450.00), -- BKK-CNX Economy
(NULL, 1, 'BUS002', '2025-08-10', '10:00:00', '19:00:00', 650.00), -- BKK-CNX Gold
(NULL, 1, 'BUS003', '2025-08-10', '20:00:00', '05:00:00', 850.00), -- BKK-CNX First (Night)
(NULL, 2, 'BUS001', '2025-08-11', '09:00:00', '21:00:00', 550.00), -- BKK-Phuket Economy
(NULL, 3, 'BUS002', '2025-08-12', '08:30:00', '17:30:00', 650.00); -- CNX-BKK Gold

-- ใส่ข้อมูล Booking ตัวอย่าง (อ้างอิง passenger_id)
-- Booking ID ควรสร้่างจาก PHP ตอนจองจริง
INSERT INTO `booking` (`booking_id`, `passenger_id`, `user_id`, `booking_date`, `total_price`, `status`) VALUES
('BK250001', 1, 1, '2025-08-01 10:00:00', 470.00, 'Confirmed'), -- สมมติ user 1 จองให้ passenger 1 (ตัวเอง), จ่ายแล้ว
('BK250002', 3, 1, '2025-08-02 11:00:00', 670.00, 'Pending Payment'); -- สมมติ user 1 จองให้ passenger 3 (ลูก), รอจ่ายเงิน

-- ใส่ข้อมูล Payment ตัวอย่าง (อ้างอิง booking_id)
-- payment_id จะเป็น Auto Increment
INSERT INTO `payment` (`payment_id`, `booking_id`, `payment_date`, `payment_method`, `amount`, `payment_status`, `slip_image_url`, `verified_by`, `verified_at`) VALUES
(NULL, 'BK250001', '2025-08-01 10:05:00', 'QR Code', 470.00, 'Paid', NULL, NULL, NULL), -- จ่าย QR สำเร็จ
(NULL, 'BK250002', '2025-08-02 11:05:00', 'Bank Transfer', 670.00, 'Pending', NULL, NULL, NULL); -- รอจ่ายแบบโอน

-- ใส่ข้อมูล Ticket ตัวอย่าง (อ้างอิง booking_id, schedule_id)
-- ticket_id ควรสร้่างจาก PHP ตอนจองจริง
-- schedule_id อ้างอิงจาก INSERT ด้านบน (1, 2, 3, 4, 5)
INSERT INTO `ticket` (`ticket_id`, `booking_id`, `schedule_id`, `seat_Number`, `passenger_name_on_ticket`) VALUES
('TKA00001', 'BK250001', 1, 'A1', 'Test User'), -- ตั๋วสำหรับ Booking แรก รอบรถแรก ที่นั่ง A1
('TKA00002', 'BK250002', 5, 'B5', 'Child Test'), -- ตั๋วสำหรับ Booking สอง รอบรถที่ห้า ที่นั่ง B5
('TKA00003', 'BK250002', 5, 'B6', 'Child Test'); -- ตั๋วสำหรับ Booking สอง รอบรถที่ห้า ที่นั่ง B6 (ถ้าจอง 2 ที่)

