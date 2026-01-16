create database fake_reviews;
use fake_reviews;

CREATE TABLE users (
    user_id INT PRIMARY KEY,
    account_age_days INT,
    total_reviews INT,
    verified_buyer BOOLEAN,
    country VARCHAR(30)
);

INSERT INTO users VALUES
(1, 5, 22, FALSE, 'India'),
(2, 8, 30, FALSE, 'India'),
(3, 12, 18, FALSE, 'USA'),
(4, 20, 25, FALSE, 'India'),
(5, 15, 28, FALSE, 'India'),

(6, 400, 55, TRUE, 'India'),
(7, 620, 80, TRUE, 'UK'),
(8, 900, 120, TRUE, 'Germany'),
(9, 1100, 150, TRUE, 'USA'),
(10, 750, 95, TRUE, 'Canada'),

(11, 60, 12, TRUE, 'India'),
(12, 45, 15, TRUE, 'India'),
(13, 300, 40, TRUE, 'USA'),
(14, 280, 38, TRUE, 'UK'),
(15, 500, 65, TRUE, 'India'),

(16, 7, 20, FALSE, 'India'),
(17, 10, 26, FALSE, 'India'),
(18, 14, 22, FALSE, 'USA'),
(19, 900, 90, TRUE, 'Germany'),
(20, 1000, 130, TRUE, 'India');
select * from users;


CREATE TABLE products (
    product_id INT PRIMARY KEY,
    category VARCHAR(40),
    avg_rating DECIMAL(2,1),
    total_reviews INT,
    seller_id INT
);

INSERT INTO products VALUES
(101, 'Electronics', 4.8, 220, 501),
(102, 'Electronics', 3.9, 95, 502),
(103, 'Home Appliances', 4.6, 180, 503),
(104, 'Beauty', 4.9, 310, 504),
(105, 'Books', 4.2, 75, 505),
(106, 'Fitness', 4.7, 140, 506),
(107, 'Kitchen', 4.1, 88, 507),
(108, 'Fashion', 3.8, 65, 508);

select * from products;

CREATE TABLE reviews (
    review_id INT PRIMARY KEY,
    user_id INT,
    product_id INT,
    rating INT,
    review_text VARCHAR(255),
    review_date DATE,
    verified_purchase BOOLEAN,
    helpful_votes INT
);

INSERT INTO reviews VALUES

(1,1,101,5,'Amazing product highly recommend','2025-01-01',FALSE,0),
(2,2,101,5,'Amazing product highly recommend','2025-01-01',FALSE,0),
(3,3,101,5,'Best product ever','2025-01-02',FALSE,0),
(4,4,101,5,'Worth every penny','2025-01-02',FALSE,1),
(5,5,101,5,'Excellent quality must buy','2025-01-03',FALSE,0),
(6,16,104,5,'Very nice product','2025-01-03',FALSE,0),
(7,17,104,5,'Loved it great deal','2025-01-03',FALSE,0),
(8,18,104,5,'Awesome highly recommended','2025-01-04',FALSE,0),
(9,1,104,5,'Best product ever','2025-01-04',FALSE,0),
(10,6,101,4,'Good product but slightly expensive','2025-01-05',TRUE,22),
(11,7,103,5,'Works perfectly as described','2025-01-06',TRUE,30),
(12,8,105,4,'Nice book easy to read','2025-01-07',TRUE,15),
(13,9,102,3,'Average experience','2025-01-07',TRUE,12),
(14,10,106,5,'Very useful for daily workouts','2025-01-08',TRUE,25),
(15,11,107,4,'Decent quality for price','2025-01-08',TRUE,9),
(16,12,108,3,'Material quality could be better','2025-01-09',TRUE,6),
(17,13,102,4,'Value for money','2025-01-09',TRUE,18),
(18,14,103,4,'Reliable appliance','2025-01-10',TRUE,20),
(19,15,106,5,'Highly durable and effective','2025-01-11',TRUE,28),
(20,3,101,5,'Amazing product highly recommend','2025-01-02',FALSE,0),
(21,2,104,5,'Excellent quality must buy','2025-01-04',FALSE,0),
(22,19,105,4,'Informative and engaging','2025-01-12',TRUE,11),
(23,20,107,5,'Exceeded expectations','2025-01-12',TRUE,19),
(24,9,108,2,'Not satisfied with stitching','2025-01-13',TRUE,8),
(25,7,102,4,'Stable performance','2025-01-14',TRUE,14);
select * from reviews;
SELECT 
    user_id,
    account_age_days,
    total_reviews,
    verified_buyer
FROM users
WHERE account_age_days < 30   -- very new accounts
AND total_reviews > 15;     -- high activity for new users

SELECT 
    r.user_id,
    COUNT(*) AS extreme_review_count,
    SUM(CASE WHEN r.rating = 5 THEN 1 ELSE 0 END) AS five_star_count,
    SUM(CASE WHEN r.rating = 1 THEN 1 ELSE 0 END) AS one_star_count
FROM reviews r
GROUP BY r.user_id
HAVING extreme_review_count >= 3;  -- adjust threshold

SELECT 
    user_id,
    COUNT(*) AS reviews_in_period,
    MIN(review_date) AS first_review,
    MAX(review_date) AS last_review
FROM reviews
GROUP BY user_id
HAVING DATEDIFF(MAX(review_date), MIN(review_date)) < 7   -- reviews in < 1 week
AND reviews_in_period >= 3;

SELECT 
    review_text,
    COUNT(*) AS occurrences,
    product_id
FROM reviews
GROUP BY review_text, product_id
HAVING occurrences > 1;
