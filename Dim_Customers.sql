--Dim Resellers Table
SELECT
	ResellerKey AS ResellerID,
	ResellerAlternateKey AS ResellerAlternateID,
	ResellerName,
	AddressLine1,
	AddressLine2,
	EnglishCountryRegionName AS Country,
	City,
	PostalCode
FROM DimReseller DRS
JOIN DimGeography DG ON DRS.GeographyKey = DG.GeographyKey
ORDER BY ResellerID;
