--Sales Fact Table 
SELECT 
	DP.ProductKey AS ProductID,
	OrderQuantity,
	ROUND(UnitPrice,2) AS UnitPrice,
	ROUND(SalesAmount,2) AS SalesAmount,
	CONVERT(DATE,OrderDate) AS OrderDate,
	ResellerName,
	FRS.ResellerKey
FROM FactResellerSales FRS
JOIN DimProduct DP ON FRS.ProductKey = DP.ProductKey
JOIN DimReseller DRS ON FRS.ResellerKey = DRS.ResellerKey
WHERE OrderDate BETWEEN '2021-01-01' AND '2023-12-31'
ORDER BY OrderDate; 