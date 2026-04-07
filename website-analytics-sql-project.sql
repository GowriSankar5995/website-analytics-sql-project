CREATE DATABASE IF NOT EXISTS website_analytics;
USE website_analytics;
show tables;
DROP DATABASE website_analytics;
-- Users table
CREATE TABLE users (
    user_id INT PRIMARY KEY,
    signup_date DATE,
    country VARCHAR(50)
);


-- Sessions table
CREATE TABLE sessions (
    session_id INT PRIMARY KEY,
    user_id INT,
    session_start DATETIME,
    session_end DATETIME,
    traffic_source VARCHAR(50),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Pageviews table
CREATE TABLE pageviews (
    pageview_id INT PRIMARY KEY,
    session_id INT,
    page_url VARCHAR(100),
    time_spent INT,
    FOREIGN KEY (session_id) REFERENCES sessions(session_id)
);

-- Conversions table
CREATE TABLE conversions (
    conversion_id INT PRIMARY KEY,
    session_id INT,
    conversion_type VARCHAR(50),
    revenue DECIMAL(10,2),
    FOREIGN KEY (session_id) REFERENCES sessions(session_id)
);

-- Step 5: Insert Data

INSERT INTO users VALUES
(1, '2024-01-01', 'India'),
(2, '2024-01-05', 'USA'),
(3, '2024-01-10', 'UK'),
(4, '2024-01-12', 'India'),
(5, '2024-01-15', 'Canada');

INSERT INTO sessions VALUES
(101, 1, '2024-02-01 10:00:00', '2024-02-01 10:10:00', 'Google'),
(102, 2, '2024-02-01 11:00:00', '2024-02-01 11:20:00', 'Facebook'),
(103, 3, '2024-02-02 09:00:00', '2024-02-02 09:05:00', 'Direct'),
(104, 4, '2024-02-02 14:00:00', '2024-02-02 14:30:00', 'Google'),
(105, 5, '2024-02-03 16:00:00', '2024-02-03 16:25:00', 'Instagram');

INSERT INTO pageviews VALUES
(1, 101, 'home', 30),
(2, 101, 'product', 60),
(3, 101, 'checkout', 40),

(4, 102, 'home', 20),

(5, 103, 'home', 15),
(6, 103, 'product', 20),

(7, 104, 'home', 25),
(8, 104, 'product', 50),
(9, 104, 'checkout', 30),
(10, 104, 'thank_you', 10),

(11, 105, 'home', 35);

INSERT INTO conversions VALUES
(1, 104, 'purchase', 500.00),
(2, 101, 'purchase', 300.00);

-- Step 6: Analysis Queries

-- Total Users
SELECT COUNT(*) AS total_users FROM users;

-- Daily Traffic
SELECT DATE(session_start) AS date, COUNT(*) AS visits
FROM sessions
GROUP BY date;

-- Traffic Source Analysis
SELECT traffic_source, COUNT(*) AS visits
FROM sessions
GROUP BY traffic_source
ORDER BY visits DESC;

-- Top Pages
SELECT page_url, COUNT(*) AS views
FROM pageviews
GROUP BY page_url
ORDER BY views DESC;

-- Average Session Duration
SELECT AVG(TIMESTAMPDIFF(SECOND, session_start, session_end)) AS avg_duration_seconds
FROM sessions;

-- Bounce Rate
SELECT 
    COUNT(*) * 100.0 / (SELECT COUNT(*) FROM sessions) AS bounce_rate
FROM (
    SELECT session_id
    FROM pageviews
    GROUP BY session_id
    HAVING COUNT(*) = 1
) AS bounce_sessions;

-- Conversion Rate
SELECT 
    COUNT(DISTINCT c.session_id) * 100.0 / COUNT(DISTINCT s.session_id) AS conversion_rate
FROM sessions s
LEFT JOIN conversions c ON s.session_id = c.session_id;

-- Revenue by Traffic Source
SELECT s.traffic_source, SUM(c.revenue) AS total_revenue
FROM sessions s
JOIN conversions c ON s.session_id = c.session_id
GROUP BY s.traffic_source;

-- Funnel Analysis
SELECT 
    COUNT(DISTINCT session_id) AS total_sessions,
    COUNT(DISTINCT CASE WHEN page_url = 'product' THEN session_id END) AS product_views,
    COUNT(DISTINCT CASE WHEN page_url = 'checkout' THEN session_id END) AS checkout_views,
    COUNT(DISTINCT CASE WHEN page_url = 'thank_you' THEN session_id END) AS purchases
FROM pageviews;

-- User Retention
SELECT user_id, COUNT(DISTINCT DATE(session_start)) AS active_days
FROM sessions
GROUP BY user_id;