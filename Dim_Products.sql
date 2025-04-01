--Dim Products Table
SELECT 
	ProductKey AS ProductID,
	DPC.ProductCategoryKey AS ProductCategoryID,
	EnglishProductCategoryName AS ProductCategory,
	DPS.ProductSubcategoryKey AS ProductSubcategoryID,
	EnglishProductSubcategoryName AS ProductSubcategory,
	Size,
	Weight
FROM DimProductCategory DPC
JOIN DimProductSubcategory DPS ON DPC.ProductCategoryKey = DPS.ProductCategoryKey
JOIN DimProduct DP ON DPS.ProductSubcategoryKey = DP.ProductSubcategoryKey
ORDER BY PRODUCTID;