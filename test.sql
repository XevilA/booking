CREATE DATABASE IF NOT EXISTS BookingBus CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE BookingBus;

DROP TABLE IF EXISTS `ticket`;
DROP TABLE IF EXISTS `payment`;
DROP TABLE IF EXISTS `booking`;
DROP TABLE IF EXISTS `Schedule`;
DROP TABLE IF EXISTS `bus`;
DROP TABLE IF EXISTS `employee`;
DROP TABLE IF EXISTS `route`;
DROP TABLE IF EXISTS `passenger`;
DROP TABLE IF EXISTS `identityDocs`;
DROP TABLE IF EXISTS `userAccount`;
DROP TABLE IF EXISTS `roles`;

CREATE TABLE `roles` (
  `role_id` INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
  `role` ENUM('user','admin') NOT NULL DEFAULT 'user' UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `userAccount` (
  `user_id` INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
  `user_name` VARCHAR(30) NOT NULL UNIQUE,
  `first_name` VARCHAR(50) NOT NULL,
  `last_name` VARCHAR(50) NOT NULL,
  `email` VARCHAR(50) NOT NULL UNIQUE,
  `password` VARCHAR(255) NOT NULL,
  `role_id` INT NOT NULL DEFAULT 1,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`role_id`) REFERENCES `roles`(`role_id`)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `identityDocs` (
  `identity_id` INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
  `user_id` INT NOT NULL,
  `identification_no` VARCHAR(20) NOT NULL UNIQUE,
  `passport_no` VARCHAR(40) NULL UNIQUE,
  FOREIGN KEY (`user_id`) REFERENCES `userAccount`(`user_id`)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `passenger` (
  `passenger_id` INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
  `user_id` INT NULL,
  `identity_id` INT NULL,
  `first_name` VARCHAR(50) NOT NULL,
  `last_name` VARCHAR(50) NOT NULL,
  `phone_number` VARCHAR(20) NOT NULL,
  `birthday` DATE NULL,
  `email` VARCHAR(50) NULL DEFAULT NULL,
  `gender` ENUM('Male', 'Female', 'Other') NULL DEFAULT NULL,
  FOREIGN KEY (`user_id`) REFERENCES `userAccount`(`user_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  FOREIGN KEY (`identity_id`) REFERENCES `identityDocs`(`identity_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `route` (
  `route_id` INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
  `start_point` VARCHAR(80) NOT NULL,
  `end_point` VARCHAR(80) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `employee` (
  `employee_id` VARCHAR(10) NOT NULL PRIMARY KEY,
  `user_id` INT NULL UNIQUE,
  `identity_id` INT NULL UNIQUE,
  `first_name` VARCHAR(30) NOT NULL,
  `last_name` VARCHAR(30) NOT NULL,
  `phone_number` VARCHAR(20) NOT NULL UNIQUE,
  `email` VARCHAR(50) NOT NULL UNIQUE,
  `license_number` VARCHAR(20) NULL UNIQUE,
  `license_expiry` DATE NULL,
  `hire_date` DATE NOT NULL,
  `position` VARCHAR(50) NULL,
  FOREIGN KEY (`user_id`) REFERENCES `userAccount`(`user_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  FOREIGN KEY (`identity_id`) REFERENCES `identityDocs`(`identity_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `bus` (
  `bus_id` VARCHAR(10) NOT NULL PRIMARY KEY,
  `employee_id` VARCHAR(10) NULL,
  `bus_type` ENUM('Economy Class', 'Gold Class', 'First Class') NOT NULL,
  `total_seats` INT NOT NULL,
  `license_plate` VARCHAR(10) NOT NULL UNIQUE,
  FOREIGN KEY (`employee_id`) REFERENCES `employee`(`employee_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `Schedule` (
  `schedule_id` INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
  `route_id` INT NOT NULL,
  `bus_id` VARCHAR(10) NOT NULL,
  `departure_date` DATE NOT NULL,
  `departure_time` TIME NOT NULL,
  `arrival_time` TIME NULL, -- Removed arrival_time as requested earlier, re-added as NULLable based on schema review
  `price` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  FOREIGN KEY (`route_id`) REFERENCES `route`(`route_id`) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (`bus_id`) REFERENCES `bus`(`bus_id`) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `booking` (
  `booking_id` VARCHAR(10) NOT NULL PRIMARY KEY,
  `passenger_id` INT NOT NULL,
  `user_id` INT NULL,
  `booking_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `total_price` DECIMAL(10,2) NOT NULL,
  `status` ENUM('Pending Payment', 'Confirmed', 'Cancelled', 'Completed') NOT NULL DEFAULT 'Pending Payment',
  FOREIGN KEY (`passenger_id`) REFERENCES `passenger`(`passenger_id`) ON UPDATE CASCADE ON DELETE RESTRICT,
  FOREIGN KEY (`user_id`) REFERENCES `userAccount`(`user_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `payment` (
  `payment_id` INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
  `booking_id` VARCHAR(10) NOT NULL,
  `payment_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `payment_method` ENUM('Credit Card', 'QR Code', 'Bank Transfer') NOT NULL,
  `amount` DECIMAL(10,2) NOT NULL,
  `payment_status` ENUM('Pending', 'Paid', 'Failed', 'Canceled', 'Expired', 'Verifying') NOT NULL DEFAULT 'Pending',
  `slip_image_url` VARCHAR(255) NULL DEFAULT NULL,
  `transaction_ref` VARCHAR(100) NULL,
  `verified_by` INT NULL,
  `verified_at` DATETIME NULL,
  FOREIGN KEY (`booking_id`) REFERENCES `booking`(`booking_id`) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (`verified_by`) REFERENCES `userAccount`(`user_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `ticket` (
  `ticket_id` VARCHAR(10) NOT NULL PRIMARY KEY,
  `booking_id` VARCHAR(10) NOT NULL,
  `schedule_id` INT NOT NULL,
  `seat_Number` VARCHAR(10) NOT NULL,
  `passenger_name_on_ticket` VARCHAR(100) NULL,
  FOREIGN KEY (`booking_id`) REFERENCES `booking`(`booking_id`) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (`schedule_id`) REFERENCES `Schedule`(`schedule_id`) ON UPDATE CASCADE ON DELETE CASCADE,
  UNIQUE KEY `unique_seat_on_schedule` (`schedule_id`, `seat_Number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


INSERT INTO `roles` (`role_id`, `role`) VALUES (1, 'user'), (2, 'admin');

INSERT INTO `userAccount` (`user_id`, `user_name`, `first_name`, `last_name`, `email`, `password`, `role_id`) VALUES
(NULL, 'testuser', 'Test', 'User', 'user@test.com', 'YOUR_HASHED_PASSWORD_HERE_1', 1),
(NULL, 'adminuser', 'Admin', 'Main', 'admin@test.com', 'YOUR_HASHED_PASSWORD_HERE_2', 2),
(NULL, 'somsak2049','Somsak', 'Thongmak','somsak2547@gmail.com', 'YOUR_HASHED_PASSWORD_HERE_3', 1);

INSERT INTO `identityDocs` (`identity_id`, `user_id`, `identification_no`, `passport_no`) VALUES
(NULL, 1, '1111111111111', NULL),
(NULL, 2, '2222222222222', 'AA123456'),
(NULL, 3, '1947796324103', NULL);

INSERT INTO `passenger` (`passenger_id`, `user_id`, `identity_id`, `first_name`, `last_name`, `phone_number`, `birthday`, `email`, `gender`) VALUES
(NULL, 1, 1, 'Test', 'User', '0810000001', '1995-05-10', 'user@test.com', 'Male'),
(NULL, 3, 3, 'Somsak', 'Thongmak', '0812345671', '2000-12-28', 'somsak2547@gmail.com', 'Male'),
(NULL, 1, NULL, 'Child', 'Test', '0810000001', '2018-01-15', NULL, 'Female');

INSERT INTO `route` (`route_id`, `start_point`, `end_point`) VALUES
(NULL, 'Bangkok', 'Chiang Mai'),
(NULL, 'Bangkok', 'Phuket'),
(NULL, 'Chiang Mai', 'Bangkok');

INSERT INTO `employee` (`employee_id`, `user_id`, `identity_id`, `first_name`, `last_name`, `phone_number`, `email`, `license_number`, `license_expiry`, `hire_date`, `position`) VALUES
('EMP001', 2, 2, 'Admin', 'Main', '0820000001', 'admin@test.com', NULL, NULL, '2023-01-01', 'System Admin'),
('DRV001', NULL, NULL, 'Driver', 'One', '0830000001', 'driver1@test.com', 'D12345678', '2026-12-31', '2023-02-01', 'Driver');

INSERT INTO `bus` (`bus_id`, `employee_id`, `bus_type`, `total_seats`, `license_plate`) VALUES
('BUS001', 'DRV001', 'Economy Class', 40, '1A-1111'),
('BUS002', 'DRV001', 'Gold Class', 32, '1A-2222'),
('BUS003', NULL, 'First Class', 24, '1A-3333');

INSERT INTO `Schedule` (`schedule_id`, `route_id`, `bus_id`, `departure_date`, `departure_time`, `arrival_time`, `price`) VALUES
(NULL, 1, 'BUS001', '2025-08-10', '08:00:00', '17:00:00', 450.00), -- Note: Added arrival_time back as NULLable
(NULL, 1, 'BUS002', '2025-08-10', '10:00:00', '19:00:00', 650.00),
(NULL, 1, 'BUS003', '2025-08-10', '20:00:00', '05:00:00', 850.00),
(NULL, 2, 'BUS001', '2025-08-11', '09:00:00', '21:00:00', 550.00),
(NULL, 3, 'BUS002', '2025-08-12', '08:30:00', '17:30:00', 650.00);

INSERT INTO `booking` (`booking_id`, `passenger_id`, `user_id`, `booking_date`, `total_price`, `status`) VALUES
('BK250001', 1, 1, '2025-08-01 10:00:00', 470.00, 'Confirmed'),
('BK250002', 3, 1, '2025-08-02 11:00:00', 670.00, 'Pending Payment');

INSERT INTO `payment` (`payment_id`, `booking_id`, `payment_date`, `payment_method`, `amount`, `payment_status`, `slip_image_url`, `verified_by`, `verified_at`) VALUES
(NULL, 'BK250001', '2025-08-01 10:05:00', 'QR Code', 470.00, 'Paid', NULL, NULL, NULL),
(NULL, 'BK250002', '2025-08-02 11:05:00', 'Bank Transfer', 670.00, 'Pending', NULL, NULL, NULL);

INSERT INTO `ticket` (`ticket_id`, `booking_id`, `schedule_id`, `seat_Number`, `passenger_name_on_ticket`) VALUES
('TKA00001', 'BK250001', 1, 'A1', 'Test User'),
('TKA00002', 'BK250002', 5, 'B5', 'Child Test');
