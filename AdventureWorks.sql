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

-- #11
/* THIS ONLY WORKS WHEN Shipping&Main are in the same City?
(this one I had trouble with) 
For every customer with a 'Main Office' in Dallas show AddressLine1 of the 'Main Office' and AddressLine1 of the 'Shipping' address - if there is no shipping address leave it blank. Use one row per customer.
*/

SELECT CompanyName, 
max(CASE WHEN a1.AddressType='Main Office' THEN AddressLine1 ELSE '' END) AS MainOffice,
max(CASE WHEN a1.AddressType='Shipping' THEN AddressLine1 ELSE '' END) AS Shipping

FROM Customer
LEFT JOIN CustomerAddress a1
ON Customer.CustomerID = a1.CustomerID
JOIN Address 
ON Address.AddressID=a1.AddressID

WHERE City='Dallas'
GROUP BY CompanyName

-- #12
/*
For each order show the SalesOrderID and SubTotal calculated three ways:
A) From the SalesOrderHeader
B) Sum of OrderQty*UnitPrice
C) Sum of OrderQty*ListPrice
*/

SELECT SalesOrderDetail.SalesOrderID, 
       SubTotal AS 'A) Subtotal',
       SUM(OrderQty*UnitPrice) AS 'B) UnitPrice',
       SUM(OrderQty*ListPrice) AS 'C) ListPrice'

FROM SalesOrderDetail 
JOIN SalesOrderHeader
ON SalesOrderDetail.SalesOrderID=SalesOrderHeader.SalesOrderID
JOIN Product
ON SalesOrderDetail.ProductID=Product.ProductID

GROUP BY SalesOrderDetail.SalesOrderID

-- #13
/*
Show the best selling item by value.
*/

SELECT ProductModel.name AS 'Product Model', SUM(OrderQty*UnitPrice) AS 'Value'

FROM Product
JOIN SalesOrderDetail 
On Product.ProductID=SalesOrderDetail.ProductID
JOIN ProductModel
ON ProductModel.ProductModelID=Product.ProductModelID

GROUP BY 1
ORDER BY 2 DESC

-- #14
/*
Show how many orders are in the following ranges (in $):
    RANGE      Num Orders      Total Value
    0-  99
  100- 999
 1000-9999
10000-
*/

SELECT 
CASE WHEN SubTotal BETWEEN 0 AND 99 THEN '0-99'
     WHEN SubTotal BETWEEN 100 AND 999 THEN '100-999'
     WHEN SubTotal BETWEEN 1000 AND 9999 THEN '1000-9999'
     WHEN SubTotal >= 10000 THEN '10000-' 
     END AS 'RANGE', 
COUNT(1) AS 'Num Orders',
SUM(SubTotal)
FROM SalesOrderHeader 
GROUP BY 1

-- #15
/*
Identify the three most important cities (to do this, same code as below, just group by City (not name). Show the break down of top level product category against city.
*/

SELECT Address.City, ProductCategory.Name, sum(OrderQty*UnitPrice) AS 'Value'

FROM SalesOrderDetail 
JOIN SalesOrderHeader 
ON SalesOrderDetail.SalesOrderID=SalesOrderHeader.SalesOrderID
JOIN CustomerAddress 
ON SalesOrderHeader.CustomerID=CustomerAddress.CustomerID
JOIN Address
ON CustomerAddress.AddressID=Address.AddressID 
JOIN Product 
ON Product.ProductID=SalesOrderDetail.ProductID
JOIN ProductCategory
ON ProductCategory.ProductCategoryID=Product.ProductCategoryID

WHERE City in ('Woolston','London','Union City')

GROUP BY 1, 2
ORDER BY 1, 2

/*
Resit Questions
*/

-- #1
/*
List the SalesOrderNumber for the customer 'Good Toys' 'Bike World'
*/

SELECT CompanyName, COALESCE(SalesOrderID, 'No Order') AS 'Order'

FROM Customer
LEFT JOIN SalesOrderHeader
ON Customer.CustomerID=SalesOrderHeader.CustomerID

WHERE CompanyName IN ('Good Toys', 'Bike World')

-- #2
/*
List the ProductName and the quantity of what was ordered by 'Futuristic Bikes'
*/

SELECT Product.Name, OrderQty

FROM SalesOrderDetail JOIN SalesOrderHeader
ON SalesOrderDetail.SalesOrderID=SalesOrderHeader.SalesOrderID
JOIN Product
ON SalesOrderDetail.ProductID=Product.ProductID

WHERE CustomerID=(SELECT CustomerID FROM Customer
WHERE CompanyName='Futuristic Bikes')

-- #3
/*
List the name and addresses of companies containing the word 'Bike' (upper or lower case) and companies containing 'cycle' (upper or lower case). Ensure that the 'bike's are listed before the 'cycles's.
*/

SELECT temp.CompanyName,AddressLine1,AddressLine2,City,StateProvince

FROM(
SELECT DISTINCT Customer.CustomerID, AddressID, CompanyName,
    CASE WHEN CompanyName Like '%bike%' THEN '0' 
         WHEN CompanyName Like '%cycle%' THEN '1' END AS 'Marker'
FROM Customer JOIN CustomerAddress 
ON CustomerAddress.CustomerID=Customer.CustomerID 
WHERE CompanyName Like '%bike%' OR CompanyName Like '%cycle%'
ORDER BY Marker) AS temp
JOIN Address
ON Address.AddressID=temp.AddressID

-- #4
/*
Show the total order value for each CountryRegion. List by value with the highest first.
(note the spelling in table of is 'CountyRegion')
*/

SELECT CountyRegion, COALESCE(SUM(SubTotal), 'No Sales') AS 'Value in Sales'

FROM Address LEFT JOIN SalesOrderHeader
ON SalesOrderHeader.BillToAddressID =Address.AddressID

GROUP BY 1

-- #5
/*
Find the best customer in each region.
*/

SELECT StateProvince, Company, total_spent

FROM(
SELECT StateProvince, 
Customer.CompanyName AS Company, 
sum(SubTotal) AS total_spent, 
RANK() OVER (PARTITION BY StateProvince ORDER BY total_spent DESC) AS group_rank

FROM SalesOrderHeader
JOIN CustomerAddress
ON CustomerAddress.CustomerID=SalesOrderHeader.CustomerID
JOIN Address 
ON CustomerAddress.AddressID=Address.AddressID
JOIN Customer
ON Customer.CustomerID=SalesOrderHeader.CustomerID
GROUP BY 1, 2) AS t

WHERE t.group_rank=1
