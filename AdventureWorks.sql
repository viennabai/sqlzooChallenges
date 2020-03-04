-- #6
/*
A "Single Item Order" is a customer order where only one item is ordered. Show the SalesOrderID and the UnitPrice for every Single Item Order.
*/
SELECT SalesOrderID, UnitPrice, SUM(OrderQty)
FROM SalesOrderDetail
WHERE OrderQty=1
GROUP BY SalesOrderID 
HAVING SUM(OrderQty)=1

-- #7
/*
Where did the racing socks go? List the product name and the CompanyName for all Customers who ordered ProductModel 'Racing Socks'.
*/

SELECT DISTINCT ProductModel.name AS ProductName, Customer.CompanyName
FROM ProductModel JOIN Product 
     ON ProductModel.ProductModelID=Product.ProductModelID
     JOIN SalesOrderDetail ON Product.ProductId=SalesOrderDetail.ProductId
     JOIN SalesOrderHeader ON SalesOrderHeader.SalesOrderID=SalesOrderDetail.SalesOrderID
     JOIN Customer ON Customer.CustomerID=SalesOrderHeader.CustomerID

WHERE ProductModel.name='Racing Socks'

-- #8
/*
Show the product description for culture 'fr' for product with ProductID 736.
*/

SELECT ProductDescription.DESCRIPTION 

FROM Product JOIN ProductModelProductDescription 
ON ProductModelProductDescription.ProductModelID=Product.ProductModelID 
JOIN ProductDescription ON ProductDescription.ProductDescriptionID=ProductModelProductDescription.ProductDescriptionID

WHERE ProductID=736 AND Culture='fr'

-- #9
/*
Use the SubTotal value in SaleOrderHeader to list orders from the largest to the smallest. For each order show the CompanyName and the SubTotal and the total weight of the order.
*/

SELECT ProductDescription.DESCRIPTION 

FROM Product JOIN ProductModelProductDescription 
ON ProductModelProductDescription.ProductModelID=Product.ProductModelID 
JOIN ProductDescription ON ProductDescription.ProductDescriptionID=ProductModelProductDescription.ProductDescriptionID

WHERE ProductID=736 AND Culture='fr'

SELECT CompanyName, SubTotal, SUM(OrderQty*Weight) AS TotalWeight
FROM SalesOrderDetail JOIN Product 
ON Product.ProductID=SalesOrderDetail.ProductID 
JOIN SalesOrderHeader 
ON SalesOrderDetail.SalesOrderID=SalesOrderHeader.SalesOrderID
JOIN Customer 
ON SalesOrderHeader.CustomerID=Customer.CustomerID
GROUP BY SalesOrderDetail.SalesOrderID
ORDER BY SubTotal DESC 

-- #10
/*
How many products in ProductCategory 'Cranksets' have been sold to an address in 'London'?
*/

SELECT COUNT(DISTINCT SalesOrderDetail.ProductID)
FROM SalesOrderDetail 
JOIN Product
ON SalesOrderDetail.ProductID = Product.ProductID
JOIN ProductCategory
ON ProductCategory.ProductCategoryID=Product.ProductCategoryID
JOIN SalesOrderHeader 
ON SalesOrderHeader.SalesOrderID=SalesOrderDetail.SalesOrderID
JOIN CustomerAddress
ON CustomerAddress.CustomerID=SalesOrderHeader.CustomerID
JOIN Address 
ON Address.AddressID=CustomerAddress.AddressID 

WHERE Address.City='London' AND ProductCategory.Name='Cranksets'

