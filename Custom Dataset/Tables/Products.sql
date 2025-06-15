CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    QuantityPerUnit VARCHAR(50),
    UnitPrice MONEY,
    UnitsInStock INT,
    ReorderLevel INT,
    Discontinued BIT,
    SupplierID INT,
    CategoryID INT,
    FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID),
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);
