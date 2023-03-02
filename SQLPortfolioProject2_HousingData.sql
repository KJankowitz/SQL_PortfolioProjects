/*
Cleaning Data in SQL
Skills Demonstrated: Convert, Join, Update, Substring, Parsename, Case statement, CTE
*/

Select *
From PortfolioProject1..NashvilleHousing


-- Standardise Date Format-----------------------------


Select SaleDate, CONVERT(date,SaleDate)
From PortfolioProject1..NashvilleHousing

Update NashvilleHousing
Set SaleDate = CONVERT(Date,SaleDate) 

--Query above didn't update properly

Alter table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date,SaleDate)



--Populate Property Address Data-----------------------------

Select *
From PortfolioProject1..NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID

Select one.ParcelID, one.PropertyAddress, two.ParcelID, two.PropertyAddress, ISNULL(one.PropertyAddress, two.PropertyAddress)
From PortfolioProject1..NashvilleHousing one
Join PortfolioProject1..NashvilleHousing two
	On one.ParcelID = two.ParcelID
	And one.[UniqueID ] <> two.[UniqueID ]
where one.PropertyAddress is null

Update one
Set PropertyAddress = ISNULL(one.PropertyAddress, two.PropertyAddress)
From PortfolioProject1..NashvilleHousing one
Join PortfolioProject1..NashvilleHousing two
	On one.ParcelID = two.ParcelID
	And one.[UniqueID ] <> two.[UniqueID ]
where one.PropertyAddress is null



-- Breaking up Address Into Individual Columns (Address, City, State)-------------------------------

Select PropertyAddress
From PortfolioProject1..NashvilleHousing


Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) As Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, Len(PropertyAddress)) As Address
From PortfolioProject1..NashvilleHousing

--Using Substrings

Alter table NashvilleHousing
Add PropertySplitAddress nvarchar(255)

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter table NashvilleHousing
Add PropertySplitCity nvarchar(255)

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, Len(PropertyAddress))


--Using Parsename
Select OwnerAddress
From PortfolioProject1..NashvilleHousing

Select 
PARSENAME(Replace(OwnerAddress, ',', '.') ,3)
,PARSENAME(Replace(OwnerAddress, ',', '.') ,2)
,PARSENAME(Replace(OwnerAddress, ',', '.') ,1)
From PortfolioProject1..NashvilleHousing

Alter table NashvilleHousing
Add OwnerSplitAddress nvarchar(255)

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.') ,3)

Alter table NashvilleHousing
Add OwnerSplitCity nvarchar(255)

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.') ,2)

Alter table NashvilleHousing
Add OwnerSplitState nvarchar(255)

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.') ,1)

Select *
From PortfolioProject1..NashvilleHousing




-- Change Y and N to Yes and No in 'Sold as Vacant' Column------------------------

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject1..NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end
From PortfolioProject1..NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end



-- Remove Duplicates--------------------------------------------------

With RowNumCTE As(
Select *,
ROW_NUMBER() over (
Partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
Order by UniqueID) row_num
From PortfolioProject1..NashvilleHousing
)
Select *
From RowNumCTE
Where row_num >1




--Delete Unused Columns-------------------------------------------

Alter table PortfolioProject1..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

Select *
From PortfolioProject1..NashvilleHousing

