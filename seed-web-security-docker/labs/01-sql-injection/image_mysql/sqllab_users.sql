CREATE DATABASE IF NOT EXISTS sqllab_users;
USE sqllab_users;

DROP TABLE IF EXISTS credential;
CREATE TABLE credential (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(50) NOT NULL,
    EID INT NOT NULL,
    Salary INT NOT NULL,
    Birthday VARCHAR(20),
    SSN VARCHAR(20),
    PhoneNumber VARCHAR(20),
    Address VARCHAR(100),
    Email VARCHAR(50),
    NickName VARCHAR(50),
    Password VARCHAR(64) NOT NULL
);

INSERT INTO credential (Name, EID, Salary, Birthday, SSN, PhoneNumber, Address, Email, NickName, Password) VALUES
('admin', 10001, 150000, '1980-01-01', '999-99-9999', '555-0101', '100 Admin Way', 'admin@seed.lab', 'Boss', '21232f297a57a5a743894a0e4a801fc3'),
('alice', 10002, 95000, '1992-05-12', '111-11-1111', '555-0102', '102 Alice St', 'alice@seed.lab', 'Ali', '5f4dcc3b5aa765d61d8327deb882cf99'),
('boby', 10003, 75000, '1990-11-23', '222-22-2222', '555-0103', '103 Boby Ave', 'boby@seed.lab', 'Bob', '5f4dcc3b5aa765d61d8327deb882cf99'),
('charlie', 10004, 82000, '1988-03-15', '333-33-3333', '555-0104', '104 Charlie Rd', 'charlie@seed.lab', 'Chuck', '5f4dcc3b5aa765d61d8327deb882cf99'),
('samy', 10005, 68000, '1995-08-30', '444-44-4444', '555-0105', '105 Samy Blvd', 'samy@seed.lab', 'Sam', '5f4dcc3b5aa765d61d8327deb882cf99');
