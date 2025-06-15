CREATE TABLE OrderDetails (
    OrderID INT,
    ProductID INT,
    UnitPrice MONEY,
    Quantity INT,
    Discount FLOAT,
    PRIMARY KEY (OrderID, ProductID),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
	)