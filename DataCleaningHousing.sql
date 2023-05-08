/*

Cleaning Data in SQL 

*/


Select *
From dbo.Housing

--------------------------------------------------------------------------------------------------------------------------------

-- Standardize Date format of SaleDate

Select SaleDateConverted, CONVERT(Date,SaleDate)
FROM dbo.Housing

UPDATE dbo.Housing
	SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE dbo.housing
	ADD SaleDateConverted Date;

UPDATE dbo.Housing
	SET SaleDateConverted = CONVERT(Date,SaleDate)


---------------------------------------------------------------------------------------------------------------------------------

--Populate Property Address Data, self join to populate address based on parcell Id


Select *
FROM dbo.Housing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM dbo.Housing a
JOIN dbo.Housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM dbo.Housing a
JOIN dbo.Housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--------------------------------------------------------------------------------------------------------------------------------------------

--Breaking out Address into Individual Columns (Street, City, State)

Select PropertyAddress
FROM dbo.Housing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM dbo.Housing


ALTER TABLE dbo.housing
	ADD PropertySplitAddress Nvarchar(255);

UPDATE dbo.Housing
	SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)


ALTER TABLE dbo.housing
	ADD PropertySplitCity Nvarchar(255);

UPDATE dbo.Housing
	SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))



Select OwnerAddress
FROM dbo.Housing

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM dbo.Housing

ALTER TABLE dbo.housing
	ADD OwnerSplitAddress Nvarchar(255);

UPDATE dbo.Housing
	SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)


ALTER TABLE dbo.housing
	ADD OwnerSplitCity Nvarchar(255);

UPDATE dbo.Housing
	SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE dbo.housing
ADD OwnerSplitState Nvarchar(255);

UPDATE dbo.Housing
	SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


--------------------------------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in Sold as Vacant Fields

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From dbo.Housing
GROUP BY SoldAsVacant

Select SoldAsVacant
, CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
From dbo.Housing

Update dbo.Housing
SET SoldAsVacant = CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END


--------------------------------------------------------------------------------------------------------------------------------

--Remove Duplicates


WITH RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY	ParcelID, 
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY
						UniqueID
						) row_num
From dbo.Housing
--ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress


---------------------------------------------------------------------------------------------------------------------------

--Delete Unused Columns

Select *
From dbo.Housing

ALTER TABLE dbo.housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE dbo.housing
DROP COLUMN SaleDate


