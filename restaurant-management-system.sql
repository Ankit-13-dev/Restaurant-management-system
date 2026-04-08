-- ============================================================
--   RESTAURANT CHAIN MANAGEMENT SYSTEM
--   MySQL Project | 2nd Year Student Project
--   Topic: Managing Multiple Chains of the Same Restaurant
-- ============================================================

-- ============================================================
-- STEP 1: CREATE AND SELECT DATABASE
-- ============================================================

CREATE DATABASE IF NOT EXISTS RestaurantChainDB;
USE RestaurantChainDB;

-- ============================================================
-- STEP 2: CREATE ALL TABLES
-- ============================================================

-- 2.1 Restaurant Brand (e.g., "Pizza Hut", "Domino's")
CREATE TABLE Restaurant_Brand (
    brand_id        INT AUTO_INCREMENT PRIMARY KEY,
    brand_name      VARCHAR(100) NOT NULL,
    cuisine_type    VARCHAR(50),
    founded_year    YEAR,
    headquarters    VARCHAR(150),
    contact_email   VARCHAR(100),
    website         VARCHAR(100)
);

-- 2.2 Chain Branches (individual outlets of a brand)
CREATE TABLE Branch (
    branch_id       INT AUTO_INCREMENT PRIMARY KEY,
    brand_id        INT NOT NULL,
    branch_name     VARCHAR(100) NOT NULL,
    city            VARCHAR(80),
    state           VARCHAR(80),
    address         VARCHAR(200),
    phone           VARCHAR(20),
    opening_time    TIME,
    closing_time    TIME,
    seating_cap     INT DEFAULT 50,
    is_active       BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (brand_id) REFERENCES Restaurant_Brand(brand_id)
        ON DELETE CASCADE
);

-- 2.3 Managers assigned to each branch
CREATE TABLE Manager (
    manager_id      INT AUTO_INCREMENT PRIMARY KEY,
    branch_id       INT NOT NULL,
    full_name       VARCHAR(100) NOT NULL,
    email           VARCHAR(100) UNIQUE,
    phone           VARCHAR(20),
    hire_date       DATE,
    salary          DECIMAL(10,2),
    FOREIGN KEY (branch_id) REFERENCES Branch(branch_id)
        ON DELETE CASCADE
);

-- 2.4 Staff / Employees
CREATE TABLE Employee (
    emp_id          INT AUTO_INCREMENT PRIMARY KEY,
    branch_id       INT NOT NULL,
    full_name       VARCHAR(100) NOT NULL,
    role            ENUM('Chef','Waiter','Cashier','Cleaner','Delivery') NOT NULL,
    phone           VARCHAR(20),
    hire_date       DATE,
    salary          DECIMAL(10,2),
    shift           ENUM('Morning','Evening','Night') DEFAULT 'Morning',
    FOREIGN KEY (branch_id) REFERENCES Branch(branch_id)
        ON DELETE CASCADE
);

-- 2.5 Menu Categories (e.g., Starters, Main Course, Desserts)
CREATE TABLE Menu_Category (
    category_id     INT AUTO_INCREMENT PRIMARY KEY,
    category_name   VARCHAR(80) NOT NULL,
    description     VARCHAR(200)
);

-- 2.6 Menu Items (linked to brand — shared across all branches)
CREATE TABLE Menu_Item (
    item_id         INT AUTO_INCREMENT PRIMARY KEY,
    brand_id        INT NOT NULL,
    category_id     INT NOT NULL,
    item_name       VARCHAR(100) NOT NULL,
    description     VARCHAR(255),
    price           DECIMAL(8,2) NOT NULL,
    is_vegetarian   BOOLEAN DEFAULT FALSE,
    is_available    BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (brand_id) REFERENCES Restaurant_Brand(brand_id)
        ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES Menu_Category(category_id)
);

-- 2.7 Branch-Specific Price Override (a branch can alter price)
CREATE TABLE Branch_Menu_Price (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    branch_id       INT NOT NULL,
    item_id         INT NOT NULL,
    custom_price    DECIMAL(8,2) NOT NULL,
    FOREIGN KEY (branch_id) REFERENCES Branch(branch_id),
    FOREIGN KEY (item_id)   REFERENCES Menu_Item(item_id),
    UNIQUE KEY unique_branch_item (branch_id, item_id)
);

-- 2.8 Customers
CREATE TABLE Customer (
    customer_id     INT AUTO_INCREMENT PRIMARY KEY,
    full_name       VARCHAR(100) NOT NULL,
    email           VARCHAR(100) UNIQUE,
    phone           VARCHAR(20),
    loyalty_points  INT DEFAULT 0,
    registered_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2.9 Orders
CREATE TABLE `Order` (
    order_id        INT AUTO_INCREMENT PRIMARY KEY,
    branch_id       INT NOT NULL,
    customer_id     INT,
    emp_id          INT,                        -- waiter who took the order
    order_date      DATETIME DEFAULT NOW(),
    order_type      ENUM('Dine-In','Takeaway','Delivery') DEFAULT 'Dine-In',
    status          ENUM('Pending','Preparing','Served','Cancelled') DEFAULT 'Pending',
    total_amount    DECIMAL(10,2) DEFAULT 0.00,
    FOREIGN KEY (branch_id)   REFERENCES Branch(branch_id),
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
    FOREIGN KEY (emp_id)      REFERENCES Employee(emp_id)
);

-- 2.10 Order Line Items
CREATE TABLE Order_Item (
    order_item_id   INT AUTO_INCREMENT PRIMARY KEY,
    order_id        INT NOT NULL,
    item_id         INT NOT NULL,
    quantity        INT NOT NULL DEFAULT 1,
    unit_price      DECIMAL(8,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES `Order`(order_id)
        ON DELETE CASCADE,
    FOREIGN KEY (item_id)  REFERENCES Menu_Item(item_id)
);

-- 2.11 Payments
CREATE TABLE Payment (
    payment_id      INT AUTO_INCREMENT PRIMARY KEY,
    order_id        INT NOT NULL UNIQUE,
    payment_mode    ENUM('Cash','Card','UPI','Online') DEFAULT 'Cash',
    amount_paid     DECIMAL(10,2) NOT NULL,
    payment_date    DATETIME DEFAULT NOW(),
    payment_status  ENUM('Paid','Pending','Refunded') DEFAULT 'Paid',
    FOREIGN KEY (order_id) REFERENCES `Order`(order_id)
);

-- 2.12 Inventory per Branch
CREATE TABLE Inventory (
    inventory_id    INT AUTO_INCREMENT PRIMARY KEY,
    branch_id       INT NOT NULL,
    item_name       VARCHAR(100) NOT NULL,
    quantity        DECIMAL(10,2) NOT NULL,
    unit            VARCHAR(30),               -- kg, litres, pieces
    reorder_level   DECIMAL(10,2) DEFAULT 10,
    last_updated    TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (branch_id) REFERENCES Branch(branch_id)
);

-- 2.13 Feedback / Reviews
CREATE TABLE Feedback (
    feedback_id     INT AUTO_INCREMENT PRIMARY KEY,
    branch_id       INT NOT NULL,
    customer_id     INT,
    order_id        INT,
    rating          TINYINT CHECK (rating BETWEEN 1 AND 5),
    comments        TEXT,
    feedback_date   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (branch_id)   REFERENCES Branch(branch_id),
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
    FOREIGN KEY (order_id)    REFERENCES `Order`(order_id)
);


-- ============================================================
-- STEP 3: INSERT SAMPLE DATA
-- ============================================================

-- 3.1 Brands
INSERT INTO Restaurant_Brand (brand_name, cuisine_type, founded_year, headquarters, contact_email, website) VALUES
('Spice Garden',  'Indian',       2005, 'Mumbai, India',    'info@spicegarden.com',  'www.spicegarden.com'),
('Pizza Planet',  'Italian',      2010, 'Delhi, India',     'hello@pizzaplanet.com', 'www.pizzaplanet.com'),
('Burger Bliss',  'Fast Food',    2015, 'Bangalore, India', 'hi@burgerbliss.com',    'www.burgerbliss.com');

-- 3.2 Branches
INSERT INTO Branch (brand_id, branch_name, city, state, address, phone, opening_time, closing_time, seating_cap) VALUES
(1, 'Spice Garden - Andheri',   'Mumbai',    'Maharashtra', '12 Link Road, Andheri West',     '9800011111', '09:00:00', '23:00:00', 80),
(1, 'Spice Garden - Pune',      'Pune',      'Maharashtra', '5 FC Road, Shivaji Nagar',       '9800022222', '10:00:00', '22:30:00', 60),
(1, 'Spice Garden - Nagpur',    'Nagpur',    'Maharashtra', '8 Sitabuldi Main Road',           '9800033333', '10:00:00', '22:00:00', 50),
(2, 'Pizza Planet - Connaught', 'Delhi',     'Delhi',       '22 Connaught Place',              '9811100001', '11:00:00', '23:30:00', 70),
(2, 'Pizza Planet - Noida',     'Noida',     'UP',          'Sector 18 Market, Noida',         '9811100002', '11:00:00', '23:00:00', 60),
(3, 'Burger Bliss - Koramangala','Bangalore','Karnataka',   '100 Feet Road, Koramangala',      '9822200001', '08:00:00', '00:00:00', 90),
(3, 'Burger Bliss - Whitefield', 'Bangalore','Karnataka',   'ITPL Main Road, Whitefield',      '9822200002', '08:00:00', '23:00:00', 75);

-- 3.3 Managers
INSERT INTO Manager (branch_id, full_name, email, phone, hire_date, salary) VALUES
(1, 'Rajesh Kumar',   'rajesh@spicegarden.com',  '9000000001', '2018-03-15', 55000.00),
(2, 'Priya Sharma',   'priya@spicegarden.com',   '9000000002', '2019-07-01', 52000.00),
(3, 'Amit Desai',     'amit@spicegarden.com',    '9000000003', '2020-01-10', 50000.00),
(4, 'Sneha Verma',    'sneha@pizzaplanet.com',   '9000000004', '2017-11-20', 58000.00),
(5, 'Vikram Nair',    'vikram@pizzaplanet.com',  '9000000005', '2021-05-01', 53000.00),
(6, 'Ananya Rao',     'ananya@burgerbliss.com',  '9000000006', '2019-08-15', 60000.00),
(7, 'Saurabh Joshi',  'saurabh@burgerbliss.com', '9000000007', '2022-02-01', 56000.00);

-- 3.4 Employees
INSERT INTO Employee (branch_id, full_name, role, phone, hire_date, salary, shift) VALUES
(1, 'Ramesh Tiwari',   'Chef',     '8100000001', '2019-04-01', 35000, 'Morning'),
(1, 'Kavya Mehta',     'Waiter',   '8100000002', '2020-06-15', 22000, 'Evening'),
(1, 'Suresh Yadav',    'Cashier',  '8100000003', '2021-01-10', 20000, 'Morning'),
(2, 'Deepa Patil',     'Chef',     '8100000004', '2020-03-01', 33000, 'Morning'),
(2, 'Arjun Singh',     'Waiter',   '8100000005', '2021-07-20', 21000, 'Evening'),
(4, 'Mohit Gupta',     'Chef',     '8100000006', '2018-09-01', 38000, 'Morning'),
(4, 'Lata Mishra',     'Waiter',   '8100000007', '2022-03-15', 21000, 'Night'),
(6, 'Tejas Kulkarni',  'Chef',     '8100000008', '2019-11-01', 40000, 'Morning'),
(6, 'Neha Jain',       'Cashier',  '8100000009', '2020-08-10', 22000, 'Evening'),
(6, 'Ritesh More',     'Delivery', '8100000010', '2023-01-05', 18000, 'Evening');

-- 3.5 Menu Categories
INSERT INTO Menu_Category (category_name, description) VALUES
('Starters',     'Soups, salads, and appetizers'),
('Main Course',  'Rice, breads, curries'),
('Desserts',     'Sweets and frozen treats'),
('Beverages',    'Hot and cold drinks'),
('Fast Food',    'Burgers, wraps, fries'),
('Pizzas',       'Classic and special pizzas');

-- 3.6 Menu Items
INSERT INTO Menu_Item (brand_id, category_id, item_name, description, price, is_vegetarian) VALUES
-- Spice Garden
(1, 1, 'Paneer Tikka',       'Grilled cottage cheese with spices',    180.00, TRUE),
(1, 2, 'Butter Chicken',     'Creamy tomato-based chicken curry',      320.00, FALSE),
(1, 2, 'Dal Makhani',        'Black lentils cooked overnight',         220.00, TRUE),
(1, 2, 'Garlic Naan',        'Soft bread with garlic butter',           60.00, TRUE),
(1, 3, 'Gulab Jamun',        'Milk solid balls in sugar syrup',         80.00, TRUE),
(1, 4, 'Masala Chai',        'Spiced Indian tea',                       40.00, TRUE),
-- Pizza Planet
(2, 6, 'Margherita Pizza',   'Classic tomato and mozzarella',          350.00, TRUE),
(2, 6, 'BBQ Chicken Pizza',  'Barbecue sauce with chicken toppings',   450.00, FALSE),
(2, 1, 'Garlic Bread',       'Toasted bread with garlic and herbs',    120.00, TRUE),
(2, 3, 'Tiramisu',           'Italian coffee-flavoured dessert',        200.00, TRUE),
(2, 4, 'Cold Coffee',        'Chilled blended coffee',                  130.00, TRUE),
-- Burger Bliss
(3, 5, 'Classic Beef Burger','Juicy beef patty with fresh veggies',    250.00, FALSE),
(3, 5, 'Veg Burger',         'Crispy veggie patty with cheese',        180.00, TRUE),
(3, 5, 'Crispy Fries',       'Golden seasoned french fries',            90.00, TRUE),
(3, 4, 'Vanilla Milkshake',  'Thick creamy vanilla shake',             150.00, TRUE),
(3, 3, 'Chocolate Brownie',  'Warm brownie with ice cream',            160.00, TRUE);

-- 3.7 Branch-Specific Price Overrides
INSERT INTO Branch_Menu_Price (branch_id, item_id, custom_price) VALUES
(2, 1, 160.00),   -- Pune branch sells Paneer Tikka cheaper
(5, 7, 320.00),   -- Noida Margherita slightly cheaper
(7, 12, 270.00);  -- Whitefield Burger Bliss charges more for Classic Burger

-- 3.8 Customers
INSERT INTO Customer (full_name, email, phone, loyalty_points) VALUES
('Aarav Sharma',    'aarav@gmail.com',    '7000000001', 120),
('Diya Kapoor',     'diya@gmail.com',     '7000000002', 300),
('Rohan Mehta',     'rohan@gmail.com',    '7000000003',  50),
('Pooja Nair',      'pooja@gmail.com',    '7000000004', 200),
('Harsh Malhotra',  'harsh@gmail.com',    '7000000005',  10);

-- 3.9 Orders
INSERT INTO `Order` (branch_id, customer_id, emp_id, order_date, order_type, status, total_amount) VALUES
(1, 1, 2, '2024-11-01 13:00:00', 'Dine-In',  'Served',    560.00),
(1, 2, 2, '2024-11-02 19:30:00', 'Takeaway', 'Served',    400.00),
(4, 3, 7, '2024-11-03 20:00:00', 'Dine-In',  'Served',    700.00),
(6, 4, 9, '2024-11-04 12:00:00', 'Delivery', 'Served',    490.00),
(2, 5, 5, '2024-11-05 18:00:00', 'Dine-In',  'Pending',   380.00);

-- 3.10 Order Items
INSERT INTO Order_Item (order_id, item_id, quantity, unit_price) VALUES
(1, 1, 1, 180.00),
(1, 2, 1, 320.00),
(1, 6, 2,  40.00),     -- 2 Masala Chai = 80
(2, 3, 1, 220.00),
(2, 4, 2,  60.00),
(2, 5, 1,  80.00),
(3, 7, 1, 350.00),
(3, 8, 1, 450.00),     -- wait total = 800? adjust
(4,12, 1, 250.00),
(4,13, 1, 180.00),
(4,14, 2,  90.00),     -- 2 fries = 180
(5, 1, 2, 160.00),     -- custom price in Pune
(5, 6, 2,  40.00);

-- 3.11 Payments
INSERT INTO Payment (order_id, payment_mode, amount_paid, payment_date, payment_status) VALUES
(1, 'UPI',   560.00, '2024-11-01 13:45:00', 'Paid'),
(2, 'Cash',  400.00, '2024-11-02 20:00:00', 'Paid'),
(3, 'Card',  700.00, '2024-11-03 20:50:00', 'Paid'),
(4, 'Online',490.00, '2024-11-04 12:30:00', 'Paid'),
(5, 'Cash',  380.00, '2024-11-05 18:30:00', 'Pending');

-- 3.12 Inventory
INSERT INTO Inventory (branch_id, item_name, quantity, unit, reorder_level) VALUES
(1, 'Tomatoes',       15.0,  'kg',     5.0),
(1, 'Chicken',        10.0,  'kg',     3.0),
(1, 'Paneer',         8.0,   'kg',     2.0),
(2, 'Rice',           25.0,  'kg',     5.0),
(4, 'Mozzarella',     12.0,  'kg',     4.0),
(4, 'Pizza Dough',    20.0,  'pieces', 10.0),
(6, 'Beef Patties',   50.0,  'pieces', 15.0),
(6, 'Burger Buns',    60.0,  'pieces', 20.0),
(6, 'Potatoes',       30.0,  'kg',     10.0);

-- 3.13 Feedback
INSERT INTO Feedback (branch_id, customer_id, order_id, rating, comments) VALUES
(1, 1, 1, 5, 'Amazing food! Butter Chicken was outstanding.'),
(1, 2, 2, 4, 'Good food but a bit slow service.'),
(4, 3, 3, 5, 'Best pizza in Delhi without a doubt!'),
(6, 4, 4, 3, 'Burger was okay but delivery was late.'),
(2, 5, 5, 4, 'Nice ambiance, friendly staff.');


-- ============================================================
-- STEP 4: USEFUL QUERIES
-- ============================================================

-- Q1: View all branches of a specific brand
SELECT b.branch_id, b.branch_name, b.city, b.state, b.phone,
       b.opening_time, b.closing_time, b.seating_cap,
       CASE WHEN b.is_active THEN 'Open' ELSE 'Closed' END AS status
FROM Branch b
JOIN Restaurant_Brand rb ON b.brand_id = rb.brand_id
WHERE rb.brand_name = 'Spice Garden';

-- Q2: Full menu of a brand with category
SELECT mi.item_id, mc.category_name, mi.item_name, mi.price,
       IF(mi.is_vegetarian, 'Veg', 'Non-Veg') AS type,
       IF(mi.is_available, 'Available', 'Unavailable') AS availability
FROM Menu_Item mi
JOIN Menu_Category mc ON mi.category_id = mc.category_id
JOIN Restaurant_Brand rb ON mi.brand_id = rb.brand_id
WHERE rb.brand_name = 'Spice Garden'
ORDER BY mc.category_name, mi.item_name;

-- Q3: Effective price for a menu item at a specific branch (with override)
SELECT mi.item_name,
       mi.price AS standard_price,
       COALESCE(bmp.custom_price, mi.price) AS effective_price,
       b.branch_name
FROM Menu_Item mi
JOIN Branch b ON b.brand_id = mi.brand_id
LEFT JOIN Branch_Menu_Price bmp
       ON bmp.branch_id = b.branch_id AND bmp.item_id = mi.item_id
WHERE b.branch_name = 'Spice Garden - Pune';

-- Q4: Total revenue per branch
SELECT b.branch_name, b.city,
       COUNT(o.order_id)        AS total_orders,
       SUM(o.total_amount)      AS total_revenue
FROM Branch b
LEFT JOIN `Order` o ON b.branch_id = o.branch_id
                    AND o.status = 'Served'
GROUP BY b.branch_id, b.branch_name, b.city
ORDER BY total_revenue DESC;

-- Q5: Total revenue per brand (across all chains)
SELECT rb.brand_name,
       COUNT(DISTINCT b.branch_id) AS total_branches,
       COUNT(o.order_id)           AS total_orders,
       SUM(o.total_amount)         AS total_revenue
FROM Restaurant_Brand rb
JOIN Branch b        ON rb.brand_id   = b.brand_id
LEFT JOIN `Order` o  ON b.branch_id   = o.branch_id
                     AND o.status = 'Served'
GROUP BY rb.brand_id, rb.brand_name
ORDER BY total_revenue DESC;

-- Q6: Top 3 best-selling menu items per brand
SELECT rb.brand_name, mi.item_name,
       SUM(oi.quantity) AS total_sold,
       SUM(oi.quantity * oi.unit_price) AS revenue_generated
FROM Order_Item oi
JOIN Menu_Item mi ON oi.item_id = mi.item_id
JOIN Restaurant_Brand rb ON mi.brand_id = rb.brand_id
JOIN `Order` o ON oi.order_id = o.order_id AND o.status = 'Served'
GROUP BY rb.brand_id, rb.brand_name, mi.item_id, mi.item_name
ORDER BY rb.brand_name, total_sold DESC;

-- Q7: All employees in a specific branch with their role and shift
SELECT e.emp_id, e.full_name, e.role, e.shift, e.salary, e.hire_date
FROM Employee e
JOIN Branch b ON e.branch_id = b.branch_id
WHERE b.branch_name = 'Burger Bliss - Koramangala'
ORDER BY e.role;

-- Q8: Employee salary expense per branch
SELECT b.branch_name, b.city,
       COUNT(e.emp_id)   AS total_employees,
       SUM(e.salary)     AS monthly_salary_expense
FROM Branch b
LEFT JOIN Employee e ON b.branch_id = e.branch_id
GROUP BY b.branch_id, b.branch_name, b.city
ORDER BY monthly_salary_expense DESC;

-- Q9: Average rating per branch
SELECT b.branch_name, b.city,
       ROUND(AVG(f.rating), 2)  AS avg_rating,
       COUNT(f.feedback_id)     AS total_reviews
FROM Branch b
LEFT JOIN Feedback f ON b.branch_id = f.branch_id
GROUP BY b.branch_id, b.branch_name, b.city
ORDER BY avg_rating DESC;

-- Q10: Customer loyalty points leaderboard
SELECT customer_id, full_name, phone, loyalty_points
FROM Customer
ORDER BY loyalty_points DESC;

-- Q11: Orders with payment details
SELECT o.order_id, b.branch_name, c.full_name AS customer,
       o.order_type, o.order_date, o.status,
       o.total_amount, p.payment_mode, p.payment_status
FROM `Order` o
JOIN Branch b    ON o.branch_id   = b.branch_id
LEFT JOIN Customer c ON o.customer_id = c.customer_id
LEFT JOIN Payment  p ON o.order_id    = p.order_id
ORDER BY o.order_date DESC;

-- Q12: Low inventory alert (quantity below reorder level)
SELECT b.branch_name, b.city,
       i.item_name, i.quantity, i.unit, i.reorder_level
FROM Inventory i
JOIN Branch b ON i.branch_id = b.branch_id
WHERE i.quantity <= i.reorder_level
ORDER BY b.branch_name;

-- Q13: Order details with itemized bill
SELECT o.order_id, b.branch_name, c.full_name AS customer,
       mi.item_name, oi.quantity, oi.unit_price,
       (oi.quantity * oi.unit_price) AS subtotal
FROM Order_Item oi
JOIN `Order`    o  ON oi.order_id  = o.order_id
JOIN Branch     b  ON o.branch_id  = b.branch_id
JOIN Menu_Item  mi ON oi.item_id   = mi.item_id
LEFT JOIN Customer c ON o.customer_id = c.customer_id
WHERE o.order_id = 1;

-- Q14: Monthly revenue report
SELECT b.branch_name,
       DATE_FORMAT(o.order_date, '%Y-%m') AS month,
       SUM(o.total_amount)                AS monthly_revenue
FROM `Order` o
JOIN Branch b ON o.branch_id = b.branch_id
WHERE o.status = 'Served'
GROUP BY b.branch_id, b.branch_name, month
ORDER BY b.branch_name, month;


-- ============================================================
-- STEP 5: VIEWS (Saved Queries for Easy Use)
-- ============================================================

-- View 5.1: Branch Summary View
CREATE OR REPLACE VIEW v_branch_summary AS
SELECT rb.brand_name, b.branch_id, b.branch_name, b.city, b.state,
       b.phone, b.seating_cap,
       CONCAT(TIME_FORMAT(b.opening_time,'%H:%i'), ' - ',
              TIME_FORMAT(b.closing_time,'%H:%i')) AS timings,
       CASE WHEN b.is_active THEN 'Active' ELSE 'Inactive' END AS status
FROM Branch b
JOIN Restaurant_Brand rb ON b.brand_id = rb.brand_id;

-- View 5.2: Revenue per Branch View
CREATE OR REPLACE VIEW v_branch_revenue AS
SELECT b.branch_id, b.branch_name, b.city, rb.brand_name,
       COUNT(o.order_id)   AS orders_served,
       SUM(o.total_amount) AS total_revenue
FROM Branch b
JOIN Restaurant_Brand rb ON b.brand_id = rb.brand_id
LEFT JOIN `Order` o ON b.branch_id = o.branch_id AND o.status = 'Served'
GROUP BY b.branch_id, b.branch_name, b.city, rb.brand_name;

-- View 5.3: Full Menu with Effective Price (considering branch overrides)
CREATE OR REPLACE VIEW v_full_menu AS
SELECT rb.brand_name, b.branch_name, mc.category_name,
       mi.item_name,
       mi.price AS base_price,
       COALESCE(bmp.custom_price, mi.price) AS selling_price,
       IF(mi.is_vegetarian,'Veg','Non-Veg') AS type
FROM Menu_Item mi
JOIN Restaurant_Brand rb ON mi.brand_id = rb.brand_id
JOIN Menu_Category mc    ON mi.category_id = mc.category_id
JOIN Branch b            ON b.brand_id = rb.brand_id
LEFT JOIN Branch_Menu_Price bmp
       ON bmp.item_id = mi.item_id AND bmp.branch_id = b.branch_id;


-- ============================================================
-- STEP 6: STORED PROCEDURES
-- ============================================================

DELIMITER $$

-- Procedure 6.1: Place a new order
CREATE PROCEDURE PlaceOrder(
    IN p_branch_id INT,
    IN p_customer_id INT,
    IN p_emp_id INT,
    IN p_order_type VARCHAR(20),
    OUT p_order_id INT
)
BEGIN
    INSERT INTO `Order` (branch_id, customer_id, emp_id, order_type, status, total_amount)
    VALUES (p_branch_id, p_customer_id, p_emp_id, p_order_type, 'Pending', 0.00);
    SET p_order_id = LAST_INSERT_ID();
    SELECT CONCAT('Order #', p_order_id, ' created successfully!') AS message;
END$$

-- Procedure 6.2: Add item to an order and update total
CREATE PROCEDURE AddOrderItem(
    IN p_order_id INT,
    IN p_item_id  INT,
    IN p_branch_id INT,
    IN p_quantity INT
)
BEGIN
    DECLARE v_price DECIMAL(8,2);

    -- Get effective price (branch override or standard)
    SELECT COALESCE(bmp.custom_price, mi.price) INTO v_price
    FROM Menu_Item mi
    LEFT JOIN Branch_Menu_Price bmp
           ON bmp.item_id = mi.item_id AND bmp.branch_id = p_branch_id
    WHERE mi.item_id = p_item_id;

    INSERT INTO Order_Item (order_id, item_id, quantity, unit_price)
    VALUES (p_order_id, p_item_id, p_quantity, v_price);

    -- Update order total
    UPDATE `Order`
    SET total_amount = (
        SELECT SUM(quantity * unit_price)
        FROM Order_Item
        WHERE order_id = p_order_id
    )
    WHERE order_id = p_order_id;

    SELECT CONCAT('Item added. Unit price: ₹', v_price) AS message;
END$$

-- Procedure 6.3: Mark order as served and add loyalty points
CREATE PROCEDURE ServeOrder(IN p_order_id INT)
BEGIN
    DECLARE v_customer INT;
    DECLARE v_points INT;

    SELECT customer_id, FLOOR(total_amount / 100)
    INTO v_customer, v_points
    FROM `Order` WHERE order_id = p_order_id;

    UPDATE `Order` SET status = 'Served'
    WHERE order_id = p_order_id;

    IF v_customer IS NOT NULL THEN
        UPDATE Customer
        SET loyalty_points = loyalty_points + v_points
        WHERE customer_id = v_customer;
    END IF;

    SELECT CONCAT('Order #', p_order_id, ' served. Points added: ', v_points) AS message;
END$$

-- Procedure 6.4: Get full report for a branch
CREATE PROCEDURE BranchReport(IN p_branch_id INT)
BEGIN
    SELECT 'Branch Info' AS section;
    SELECT * FROM v_branch_summary WHERE branch_id = p_branch_id;

    SELECT 'Revenue Summary' AS section;
    SELECT * FROM v_branch_revenue WHERE branch_id = p_branch_id;

    SELECT 'Low Inventory Alerts' AS section;
    SELECT item_name, quantity, unit, reorder_level
    FROM Inventory
    WHERE branch_id = p_branch_id AND quantity <= reorder_level;

    SELECT 'Recent Orders' AS section;
    SELECT order_id, order_type, order_date, status, total_amount
    FROM `Order`
    WHERE branch_id = p_branch_id
    ORDER BY order_date DESC LIMIT 10;
END$$

DELIMITER ;


-- ============================================================
-- STEP 7: TRIGGERS
-- ============================================================

-- Trigger 7.1: Prevent order from being placed if branch is inactive
DELIMITER $$
CREATE TRIGGER before_order_insert
BEFORE INSERT ON `Order`
FOR EACH ROW
BEGIN
    DECLARE v_active BOOLEAN;
    SELECT is_active INTO v_active FROM Branch WHERE branch_id = NEW.branch_id;
    IF NOT v_active THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot place order: Branch is currently inactive.';
    END IF;
END$$
DELIMITER ;

-- Trigger 7.2: Log when inventory goes below reorder level (uses a log table)
CREATE TABLE IF NOT EXISTS Inventory_Alert_Log (
    log_id       INT AUTO_INCREMENT PRIMARY KEY,
    branch_id    INT,
    item_name    VARCHAR(100),
    quantity     DECIMAL(10,2),
    alert_time   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER $$
CREATE TRIGGER after_inventory_update
AFTER UPDATE ON Inventory
FOR EACH ROW
BEGIN
    IF NEW.quantity <= NEW.reorder_level AND OLD.quantity > OLD.reorder_level THEN
        INSERT INTO Inventory_Alert_Log (branch_id, item_name, quantity)
        VALUES (NEW.branch_id, NEW.item_name, NEW.quantity);
    END IF;
END$$
DELIMITER ;


-- ============================================================
-- STEP 8: TEST STORED PROCEDURES
-- ============================================================

-- Test 8.1: Place a new order
CALL PlaceOrder(1, 1, 2, 'Dine-In', @new_order_id);
SELECT @new_order_id;

-- Test 8.2: Add items to that order
CALL AddOrderItem(@new_order_id, 1, 1, 2);  -- 2x Paneer Tikka
CALL AddOrderItem(@new_order_id, 2, 1, 1);  -- 1x Butter Chicken

-- Test 8.3: Serve the order
CALL ServeOrder(@new_order_id);

-- Test 8.4: Get full branch report
CALL BranchReport(1);

-- Test 8.5: Use views
SELECT * FROM v_branch_summary;
SELECT * FROM v_branch_revenue ORDER BY total_revenue DESC;
SELECT * FROM v_full_menu WHERE brand_name = 'Spice Garden' AND branch_name = 'Spice Garden - Pune';


-- ============================================================
-- STEP 9: SAMPLE QUERIES TO EXPLORE
-- ============================================================

-- 9.1 Which branch has the highest average customer rating?
SELECT b.branch_name, b.city, ROUND(AVG(f.rating),1) AS avg_rating
FROM Feedback f JOIN Branch b ON f.branch_id = b.branch_id
GROUP BY b.branch_id ORDER BY avg_rating DESC LIMIT 1;

-- 9.2 Which item is ordered the most across all chains?
SELECT mi.item_name, SUM(oi.quantity) AS times_ordered
FROM Order_Item oi JOIN Menu_Item mi ON oi.item_id = mi.item_id
GROUP BY mi.item_id ORDER BY times_ordered DESC LIMIT 5;

-- 9.3 How many vegetarian vs non-vegetarian items per brand?
SELECT rb.brand_name,
       SUM(IF(mi.is_vegetarian, 1, 0)) AS veg_items,
       SUM(IF(NOT mi.is_vegetarian, 1, 0)) AS non_veg_items
FROM Menu_Item mi JOIN Restaurant_Brand rb ON mi.brand_id = rb.brand_id
GROUP BY rb.brand_id;

-- 9.4 Payment method popularity
SELECT payment_mode, COUNT(*) AS count, SUM(amount_paid) AS total
FROM Payment WHERE payment_status = 'Paid'
GROUP BY payment_mode ORDER BY count DESC;

-- 9.5 Top customers by spending
SELECT c.full_name, c.phone,
       COUNT(o.order_id) AS total_orders,
       SUM(o.total_amount) AS total_spent,
       c.loyalty_points
FROM Customer c
JOIN `Order` o ON c.customer_id = o.customer_id AND o.status = 'Served'
GROUP BY c.customer_id ORDER BY total_spent DESC;

-- ============================================================
--   END OF PROJECT
-- ============================================================