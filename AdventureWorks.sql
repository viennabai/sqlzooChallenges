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
