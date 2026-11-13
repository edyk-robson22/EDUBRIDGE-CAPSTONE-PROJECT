-- QUESTION 1 --
SELECT 
    e.BusinessEntityID,
    p.FirstName + ' ' + p.LastName AS SalesPersonName,
    e.JobTitle,
    sp.SalesYTD,
    st.Name AS TerritoryName,
    st.Group AS TerritoryRegion
FROM HumanResources_Employee e
JOIN Person_Person p 
    ON e.BusinessEntityID = p.BusinessEntityID
JOIN Sales_SalesPerson sp 
    ON e.BusinessEntityID = sp.BusinessEntityID
JOIN Sales_SalesTerritory st 
    ON sp.TerritoryID = st.TerritoryID
WHERE sp.SalesYTD > 0
ORDER BY sp.SalesYTD DESC;

-- QUESTION 2 --
SELECT 
    c.CustomerID,
    p.FirstName,
    p.LastName,
    ea.EmailAddress
FROM Sales_Customer c
JOIN Person_Person p 
    ON c.PersonID = p.BusinessEntityID
LEFT JOIN Sales_SalesOrderHeader soh 
    ON c.CustomerID = soh.CustomerID
LEFT JOIN Person_EmailAddress ea 
    ON p.BusinessEntityID = ea.BusinessEntityID
WHERE soh.SalesOrderID IS NULL;

-- QUESTION 3 --
SELECT 
    p.ProductID,
    p.Name AS ProductName,
    p.ProductNumber
FROM Production_Product p
LEFT JOIN Sales_SalesOrderDetail sod 
    ON p.ProductID = sod.ProductID
WHERE sod.SalesOrderID IS NULL;

-- QUESTION 4 --
SELECT 
    soh.SalesOrderID,
    soh.OrderDate,
    soh.TotalDue,
    p.FirstName + ' ' + p.LastName AS CustomerName
FROM Sales.SalesOrderHeader soh
JOIN Sales.Customer c 
    ON soh.CustomerID = c.CustomerID
JOIN Person.Person p 
    ON c.PersonID = p.BusinessEntityID
WHERE soh.TotalDue > 50000.00
ORDER BY soh.TotalDue DESC;

-- QUESTION 4 --
SELECT 
    soh.SalesOrderID,
    soh.OrderDate,
    soh.TotalDue,
    p.FirstName + ' ' + p.LastName AS CustomerName
FROM Sales_SalesOrderHeader soh
JOIN Sales_Customer c 
    ON soh.CustomerID = c.CustomerID
JOIN Person_Person p 
    ON c.PersonID = p.BusinessEntityID
WHERE soh.TotalDue > 50000.00
ORDER BY soh.TotalDue DESC;

-- QUESTION 5 --
SELECT 
    pc.Name AS CategoryName,
    SUM(sod.OrderQty) AS TotalQuantitySold,
    SUM(sod.LineTotal) AS TotalGrossRevenue
FROM Sales_SalesOrderDetail sod
JOIN Production_Product p 
    ON sod.ProductID = p.ProductID
JOIN Production_ProductSubcategory psc 
    ON p.ProductSubcategoryID = psc.ProductSubcategoryID
JOIN Production_ProductCategory pc 
    ON psc.ProductCategoryID = pc.ProductCategoryID
GROUP BY pc.Name
ORDER BY TotalGrossRevenue DESC;

-- QUESTION 6 --
SELECT 
    e.BusinessEntityID,
    p.FirstName + ' ' + p.LastName AS EmployeeName,
    COUNT(DISTINCT edh.DepartmentID) AS DepartmentCount
FROM HumanResources_EmployeeDepartmentHistory edh
JOIN HumanResources_Employee e 
    ON edh.BusinessEntityID = e.BusinessEntityID
JOIN Person_Person p 
    ON e.BusinessEntityID = p.BusinessEntityID
GROUP BY e.BusinessEntityID, p.FirstName, p.LastName
HAVING COUNT(DISTINCT edh.DepartmentID) > 1
ORDER BY DepartmentCount DESC;

-- QUESTION 7 --
SELECT 
    p.ProductID,
    p.Name AS ProductName,
    p.ListPrice,
    p.ProductSubcategoryID
FROM Production_Product p
WHERE p.ProductSubcategoryID IS NOT NULL
  AND p.ListPrice > (
      SELECT AVG(p_sub.ListPrice)
      FROM Production_Product p_sub
      WHERE p_sub.ProductSubcategoryID = p.ProductSubcategoryID)
ORDER BY p.ProductSubcategoryID, p.ListPrice DESC;

-- QUESTION 8 --
SELECT c.CustomerID,
    p.FirstName + ' ' + p.LastName AS CustomerName,
    SUM(soh.TotalDue) AS LifetimeSpend
FROM Sales_Customer c
JOIN Person_Person p 
    ON c.PersonID = p.BusinessEntityID
JOIN Sales_SalesOrderHeader soh 
    ON c.CustomerID = soh.CustomerID
GROUP BY c.CustomerID, p.FirstName, p.LastName
ORDER BY LifetimeSpend DESC;

-- QUESTION 9 --
SELECT DISTINCT
    v.Name AS VendorName,
    p.Name AS ProductName,
    p.StandardCost
FROM Purchasing_ProductVendor pv
JOIN Purchasing_Vendor v 
    ON pv.BusinessEntityID = v.BusinessEntityID
JOIN Production_Product p 
    ON pv.ProductID = p.ProductID
WHERE p.StandardCost > 500.00
ORDER BY p.StandardCost DESC;

-- QUESTION 10 --
SELECT 
    edh.BusinessEntityID,
    p.FirstName + ' ' + p.LastName AS EmployeeName,
    edh.DepartmentID,
    eph.Rate AS EmployeeRate
FROM HumanResources_EmployeePayHistory eph
JOIN HumanResources_EmployeeDepartmentHistory edh 
    ON eph.BusinessEntityID = edh.BusinessEntityID
JOIN Person_Person p 
    ON eph.BusinessEntityID = p.BusinessEntityID
WHERE edh.EndDate IS NULL  -- Current active department history
  AND eph.Rate > (SELECT AVG(eph_sub.Rate)
      FROM HumanResources_EmployeePayHistory eph_sub
      JOIN HumanResources_EmployeeDepartmentHistory edh_sub 
          ON eph_sub.BusinessEntityID = edh_sub.BusinessEntityID
      WHERE edh_sub.DepartmentID = edh.DepartmentID
        AND edh_sub.EndDate IS NULL)
ORDER BY edh.DepartmentID, EmployeeRate DESC;

-- QUESTION 11 --
SELECT 
    YEAR(soh.OrderDate) AS OrderYear,
    MONTH(soh.OrderDate) AS OrderMonth,
    COUNT(DISTINCT soh.SalesOrderID) AS TotalOrders,
    SUM(soh.TotalDue) AS MonthlyRevenue
FROM Sales_SalesOrderHeader soh
GROUP BY YEAR(soh.OrderDate), MONTH(soh.OrderDate)
ORDER BY OrderYear, OrderMonth;

-- QUESTION 12 --
SELECT 
    p.ProductID,
    p.Name AS ProductName,
    IFNULL(inv.TotalStock, 0) AS TotalInventory,
    IFNULL(sales.TotalSold, 0) AS TotalSold
FROM Production_Product p
LEFT JOIN (
    SELECT ProductID, SUM(Quantity) AS TotalStock
    FROM Production_ProductInventory
    GROUP BY ProductID
) inv ON p.ProductID = inv.ProductID
LEFT JOIN (
    SELECT ProductID, SUM(OrderQty) AS TotalSold
    FROM Sales_SalesOrderDetail
    GROUP BY ProductID
) sales ON p.ProductID = sales.ProductID
WHERE ifnull(inv.TotalStock, 0) < (IFNULL(sales.TotalSold, 0) * 0.50)
  AND IFNULL(sales.TotalSold, 0) > 0
ORDER BY TotalSold DESC;

-- QUESTION 13 --
SELECT 
    sp.BusinessEntityID,
    p.FirstName + ' ' + p.LastName AS SalesPersonName,
    sp.TerritoryID,
    sp.SalesYTD
FROM Sales_SalesPerson sp
JOIN Person_Person p 
    ON sp.BusinessEntityID = p.BusinessEntityID
WHERE sp.SalesYTD > (
    SELECT AVG(sp_sub.SalesYTD)
    FROM Sales_SalesPerson sp_sub
    WHERE sp_sub.TerritoryID = sp.TerritoryID)
ORDER BY sp.TerritoryID, sp.SalesYTD DESC;

-- QUESTION 14 --
SELECT 
    sp.BusinessEntityID,
    p.FirstName + ' ' + p.LastName AS SalesPersonName,
    sp.TerritoryID,
    sp.SalesYTD
FROM Sales_SalesPerson sp
JOIN Person_Person p 
    ON sp.BusinessEntityID = p.BusinessEntityID
WHERE sp.SalesYTD > (
    SELECT AVG(sp_sub.SalesYTD)
    FROM Sales_SalesPerson sp_sub
    WHERE sp_sub.TerritoryID = sp.TerritoryID)
ORDER BY sp.TerritoryID, sp.SalesYTD DESC;

-- QUESTION 15 --
SELECT 
    c.CustomerID,
    CONCAT(p.FirstName, ' ', p.LastName) AS CustomerName
FROM Sales_Customer c
JOIN Person_Person p 
    ON c.PersonID = p.BusinessEntityID
WHERE NOT EXISTS (
    -- Check if there are any products in the subcategory the customer has NOT purchased
    SELECT sub_p.ProductID
    FROM Production_Product sub_p
    WHERE sub_p.ProductSubcategoryID = 1
      AND sub_p.ProductID NOT IN (
          SELECT sod.ProductID
          FROM Sales_SalesOrderHeader soh
          JOIN Sales_SalesOrderDetail sod 
              ON soh.SalesOrderID = sod.SalesOrderID
          WHERE soh.CustomerID = c.CustomerID
      )
)
AND EXISTS (
    -- Ensure they actually bought at least one item from this subcategory
    SELECT 1
    FROM Sales_SalesOrderHeader soh
    JOIN Sales_SalesOrderDetail sod 
        ON soh.SalesOrderID = sod.SalesOrderID
    JOIN Production_Product sub_p 
        ON sod.ProductID = sub_p.ProductID
    WHERE soh.CustomerID = c.CustomerID
      AND sub_p.ProductSubcategoryID = 1
);