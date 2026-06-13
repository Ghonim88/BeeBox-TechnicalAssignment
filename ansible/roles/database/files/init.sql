-- Schema and seed data for the BeeBox API.
-- Idempotent: safe to run repeatedly (CREATE IF NOT EXISTS + INSERT IGNORE).

CREATE TABLE IF NOT EXISTS items (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    description VARCHAR(255),
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT IGNORE INTO items (id, name, description) VALUES
    (1, 'alpha', 'First sample item'),
    (2, 'beta',  'Second sample item'),
    (3, 'gamma', 'Third sample item');
