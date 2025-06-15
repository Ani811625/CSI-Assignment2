INSERT INTO Customers VALUES (1, 'Techno India'), (2, 'TCS');
INSERT INTO Suppliers VALUES (1, 'ABC Ltd.'), (2, 'XYZ Pvt Ltd.');
INSERT INTO Categories VALUES (1, 'Electronics'), (2, 'Stationery');

INSERT INTO Products VALUES
(101, 'Wireless Mouse', '1 unit', 450, 50, 10, 0, 1, 1),
(102, 'Keyboard', '1 unit', 700, 30, 5, 0, 2, 1),
(103, 'Notebook', '1 book', 50, 100, 20, 1, 1, 2); 

INSERT INTO Orders VALUES
(1001, 1, '2025-06-13'),
(1002, 2, '2025-06-14');

INSERT INTO OrderDetails VALUES
(1001, 101, 450, 2, 0.05),
(1001, 102, 700, 1, 0),
(1002, 101, 450, 3, 0.10);