/*

Cleaning Data in SQL Queries 

*/

Select * 
From PortfolioProject.dbo.NashvilleHousing

------------------------------------------------------------
--Standardize Data Format 

Select SaleDateConverted, convert(date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SaleDate = Convert(Data,SaleDate)


Alter Table NashvilleHousing
Add SaleDateConverted Date; 

Update NashvilleHousing
SET SaleDateConverted = Convert(Data,SaleDate)

------------------------------------------------------------
-- Populate Property Address data 

Select *
From PortfolioProject.dbo.NashvilleHousing
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress) 
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID]<>b.[UniqueID] 
Where a.PropertyAddress is null


Update a
SET PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress) 
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID]<>b.[UniqueID] 
Where a.PropertyAddress is null


------------------------------------------------------------
-- Populate Property Address data 

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--Order by ParcelID

Select 
SUBSTRING(PropertyAddress,1,charindex(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,charindex(',',PropertyAddress)+1,len(PropertyAddress)) as Address
From PortfolioProject.dbo.NashvilleHousing


ALter Table NashvilleHousing
add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,charindex(',',PropertyAddress)-1)


Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255); 

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,charindex(',',PropertyAddress)+1,len(PropertyAddress)) 



Select * 
From PortfolioProject.dbo.NashvilleHousing



Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

Select 
Parsename(Replace(OwnerAddress,',','.'),3) ,
Parsename(Replace(OwnerAddress,',','.'),2) ,
Parsename(Replace(OwnerAddress,',','.'),1) 
from PortfolioProject.dbo.NashvilleHousing

ALter Table NashvilleHousing
add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = Parsename(Replace(OwnerAddress,',','.'),3) 

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255); 

Update NashvilleHousing
SET OwnerSplitCity = Parsename(Replace(OwnerAddress,',','.'),2) 

Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255); 

Update NashvilleHousing
SET OwnerSplitState = Parsename(Replace(OwnerAddress,',','.'),1) 


Select SoldAsVacant
From PortfolioProject.dbo.NashvilleHousing




------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field 

Select Distinct(SoldAsVacant) , count(SoldAsVacant)
From  PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant ,
CASE when SoldAsVacant = 0 then 'Yes'
     when SoldAsVacant = 1 then 'No'
	 Else SoldAsVacant
	END
From  PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'Yes'
    when SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	END


------------------------------------------------------------
-- Remove Duplicates 

WITH RowNumCTE as(
Select * ,
Row_number() Over( 
partition by ParcelID , 
			 PropertyAddress, 
			 SalePrice, 
			 SaleDate, 
			 LegalReference 
			 Order by 
				UniqueID 
				) row_num

From  PortfolioProject.dbo.NashvilleHousing
-- Order by ParcelID
)
Select *
from RowNumCTE
where row_num > 1
-- Order by PropertyAddress


----------------------------------------------------------------------------------
--- Delete Unused Columns 


Select * 
From  PortfolioProject.dbo.NashvilleHousing

Alter Table PortfolioProject.dbo.NashvilleHousing
Drop column OwnerAddress, TaxDistrict, PropertyAddress 


Alter Table PortfolioProject.dbo.NashvilleHousing
Drop column SaleDate

