
CREATE TABLE Users (
    id VARCHAR(255) PRIMARY KEY, 
    created_at TIMESTAMP, 
    email VARCHAR(255));

INSERT INTO Users (id, created_at, email)
VALUES ('bnkt123123', '2020-01-01 11:11:12', 'test@test.com');

CREATE TABLE Orders (
    id VARCHAR(255),
    user_id VARCHAR(255),
    created_at TIMESTAMP,
    paid_at TIMESTAMP,
    category VARCHAR(255),
    PRIMARY KEY (id),
    FOREIGN KEY (user_id) REFERENCES Users(id));

INSERT INTO Orders (id, user_id, created_at, paid_at, category)
VALUES ('aaas123123', 'bnkt123123', '2020-01-07 12:12:12', '2020-01-23 09:01:01', 'T-shirts');


SELECT u.id AS user_id, u.email, MIN(o.paid_at) AS date_of_first_paid_order, 
FIRST_VALUE(o.category) OVER (PARTITION BY o.user_id ORDER BY o.paid_at) AS category_of_first_paid_order
FROM Users u
INNER JOIN Order o ON u.id = o.user_id
WHERE u.creted_at LIKE '2020%' AND o.paid_at IS NOT NULL
GROUP BY u.id, u.email
HAVING COUNT(o.id) >= 1;