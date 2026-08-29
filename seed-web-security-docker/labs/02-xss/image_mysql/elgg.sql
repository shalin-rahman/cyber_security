CREATE DATABASE IF NOT EXISTS elgg;
USE elgg;

-- Basic Elgg user credentials and profile tables
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    password VARCHAR(64) NOT NULL,
    profile_about TEXT
);

INSERT INTO users (username, name, password, profile_about) VALUES
('admin', 'Administrator', 'seedelgg', 'Site Administrator profile.'),
('alice', 'Alice', 'seedalice', 'Welcome to Alice\'s profile page!'),
('boby', 'Boby', 'seedboby', 'Hello from Boby.'),
('charlie', 'Charlie', 'seedcharlie', 'Charlie\'s space.'),
('samy', 'Samy (Attacker)', 'seedsamy', 'Attacker profile');
