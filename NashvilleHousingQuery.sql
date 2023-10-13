/*

Cleaing Data in SQL Queries

*/

Select * 
From PortfolioProject.dbo.NashvilleHousing

--Standardize date format

Select SaleDate, CONVERT(date,saledate)
From PortfolioProject.dbo.NashvilleHousing

Alter table NashvilleHousing
Alter column saledate Date

--Populate property Address date

Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is Null
Order by ParcelID 

--Similar parcel ID has same Property address. if there is No address but ParcelID is same so we will populate the property address with the address that has parcelID
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

update a
SET PropertyAddress = ISNULL(a.propertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

----------------------------------------------------------------------------------------------
--Breaking out Address into individual columns (address, city, state)

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is Null
--Order by ParcelID 

Select
SUBSTRING (propertyaddress, 1, CHARINDEX(',',propertyaddress)-1) As address
, SUBSTRING(propertyaddress, CHARINDEX(',',PropertyAddress) +1,Len(propertyaddress)) as Address

From PortfolioProject.dbo.NashvilleHousing

-- Adding two cloumns to Split PropertyAddress to the address and City

Alter table NashvilleHousing
add PropertySplitAddress Nvarchar(255)

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING (propertyaddress, 1, CHARINDEX(',',propertyaddress)-1)



Alter Table NashvilleHousing
Add PropertySplitCity nvarchar(255)

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(propertyaddress, CHARINDEX(',',PropertyAddress) +1,Len(propertyaddress))

Select *
From PortfolioProject.dbo.NashvilleHousing

-- looking at OwnerAddress
Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing
Where OwnerAddress is NULL

Select
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From PortfolioProject.dbo.NashvilleHousing

--Adding 3 coulums to split OwnerAddress and set up the value on those colums

Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255)

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

Alter Table NashvilleHousing
Add OwnerSplitCity nvarchar(255)

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

Alter Table NashvilleHousing
Add OwnerSplitState nvarchar(255)

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

-----------------------------------------------------------------------------------------------------
--Change Y and N to Yes and No in "SOLD AS VACANT" Field

Select Distinct (SoldAsVacant), Count(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
Group By SoldAsVacant
Order By 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'YES'
		When SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
		END
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'YES'
		When SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
		END

------------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates

WITH RowNumCTE As(
SELECT *,  
	ROW_NUMBER () OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SaleDate,
				LegalReference
				ORDER BY 
					UniqueID
					) row_num
					
FROM PortfolioProject.dbo.NashvilleHousing
--Order BY ParcelID
) 
-- Deleted duplicate values using CTE & partition 
Delete
FROM RowNumCTE
Where row_num >1


---------------------------------------------------------------------------------------------------------------------------------
--Delete unused Colums

Select *
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE OwnerName is NULL

Alter TABLE PortfolioProject.dbo.NashvilleHousing
DROP column OwnerAddress, TaxDistrict, PropertyAddress