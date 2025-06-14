# CSI-Assignment2

# 💼 Celebal Technologies Internship – Level B SQL Assignment

This repository contains the complete solution to the **Level B SQL Task**, assigned as part of the **Week 2 deliverables** during the **Summer Internship Program at Celebal Technologies**.

---
## 🛠️ Technologies & Tools Used

- **SQL Server 2022 Express / Developer Edition**
- **SQL Server Management Studio (SSMS)**
- **AdventureWorks2022 OLTP Sample Database**

> ✔️ All queries are designed and tested using the default schema structure of the **AdventureWorks2022** database available from Microsoft's official GitHub repository.

---

## ✅ Overview of Implemented SQL Components

### 🔧 Stored Procedures
- `InsertOrderDetails`: Validates stock and inserts order lines.
- `UpdateOrderDetails`: Updates fields with NULL-safety and adjusts inventory.
- `GetOrderDetails`: Fetches order line items by OrderID.
- `DeleteOrderDetails`: Removes a specific product from an order with validation.

### 🧮 Scalar Functions
- `fn_FormatDate_MMDDYYYY`: Converts DATETIME to MM/DD/YYYY.
- `fn_FormatDate_YYYYMMDD`: Converts DATETIME to YYYYMMDD.

### 👁️ Views
- `vwCustomerOrders`: Shows order details with customer and product info.
- `vwCustomerOrders_Yesterday`: Filters the above view for yesterday's orders.
- `MyProducts`: Lists non-discontinued products with vendor and category info.

### 🔥 Triggers
- `trg_InsteadOfDeleteSalesOrder`: Deletes dependent order details before order.
- `trg_CheckStockBeforeInsert`: Prevents insert when stock is insufficient and updates inventory on success.

---

## 💾 How to Use This Project

### 1. Prerequisites
- Microsoft SQL Server (2019 or later)
- SQL Server Management Studio (SSMS)
- `AdventureWorks2022` OLTP database restored on your SQL Server

### 2. Execution Steps
```sql
USE AdventureWorks2022;
GO
-- Run the script AdventureWorks_LevelB_Task.sql

---

## 📁 Repository Structure

```plaintext
📂 AdventureWorks2022/
│      ├── 📂 Functions/
│      │        ├── FormatDate_MMDDYYYY.sql
│      │        └── FormatDate_YYYYMMDD.sql
│      ├── 📂 Stored procedures/
│      │        ├── DeleteOrderDetails.sql
│      │        ├── GetOrderDetails.sql
│      │        ├── InsertOrderDetails.sql
│      │        └── UpdateOrderDetails.sql
│      ├── 📂 Triggers/
│      │        ├── trg_CheckStockBeforeInsert.sql
│      │        └── trg_InsteadOfDeleteSalesOrder.sql
│      └── 📂 Views/
│               ├── MyProducts.sql
│               ├── vwCustomerOrders.sql
│               └── vwCustomerOrders_Yesterday.sql
├── Level B Task.pdf
│
└── README.md
