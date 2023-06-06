/*
Cleaning Data in SQL
*/

--- Date Standardisation
select SaleDate, convert(date, SaleDate)
from NashvilleHousing;

Update NashvilleHousing
set SaleDate = convert(date, SaleDate);

alter table NashvilleHousing
add SaleDateConverted date;

update NashvilleHousing
set SaleDateConverted = convert(date, SaleDate);

select SaleDateConverted, convert(date, SaleDate)
from NashvilleHousing;

--- Populate Property Address Data
select *
from NashvilleHousing
order by ParcelID;

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a 
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;

update a
set PropertyAddress =  ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ] 

--- Breaking down address to Address, City and State
select *
from NashvilleHousing
order by ParcelID;

select
substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1) as Address,
substring(PropertyAddress, charindex(',', PropertyAddress)+1, len(PropertyAddress)) as Address
from NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress varchar(255);

update NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1);

alter table NashvilleHousing
add PropertySplitCity varchar(255);

update NashvilleHousing
set PropertySplitCity = substring(PropertyAddress, charindex(',', PropertyAddress)+1, len(PropertyAddress));

select parsename(replace(OwnerAddress, ',', '.') ,3),
parsename(replace(OwnerAddress, ',', '.') ,2),
parsename(replace(OwnerAddress, ',', '.') ,1)
from NashvilleHousing;

alter table NashvilleHousing
add OwnerSplitAddress varchar(255);

update NashvilleHousing
set OwnerSplitAddress = parsename(replace(OwnerAddress, ',', '.') ,3);

alter table NashvilleHousing
add OwnerSplitCity varchar(255);

update NashvilleHousing
set OwnerSplitCity = parsename(replace(OwnerAddress, ',', '.') ,2);

alter table NashvilleHousing
add OwnerSplitState varchar(255);

update NashvilleHousing
set OwnerSplitState = parsename(replace(OwnerAddress, ',', '.') ,1);

select * from NashvilleHousing;

--- Convert to Yes and No in Sold as Vacant field

select distinct(SoldAsVacant), count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from NashvilleHousing;

update NashvilleHousing
set SoldAsVacant = 
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end;

--- Remove Duplicates
with row_numCTE as(
select *,
row_number()
over (partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference order by UniqueID) row_num
from NashvilleHousing)
delete from row_numCTE
where row_num >1;

--- Remove Unused columns
alter table NashvilleHousing
drop column OwnerAddress, SaleDate, TaxDistrict, PropertyAddress;