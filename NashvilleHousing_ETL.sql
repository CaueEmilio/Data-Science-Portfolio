/* 1 - Importing Data using BULK INSERT */	

/* 1.1 - Creating table and defining every row */
CREATE TABLE NashvilleHousing(
	UniqueID numeric
	, ParcelID nvarchar(50)
	, LandUse nvarchar(255)
	, PropertyAddress nvarchar(255)
	, SaleDate date
	, SalePrice money --When adding this column, some prices had the '$' symbol, so the Regex (?<=;(?=\$)).(?=\d)
	, LegalReference nvarchar(255)
	, SoldAsVacant bit --Setting this column as bit, allows to get the right input when adding the information. Yes and Y were changed to 1 and No and N were changed to 0 (A simple find and replace could be used to clean it
	, OwnerName nvarchar(255)
	, OwnerAddress nvarchar(255)
	, Acreage numeric(10,2)
	, TaxDistrict nvarchar(255)
	, LandValue money
	, BuildingValue money
	, TotalValue money
	, YearBuilt smallint
	, Bedrooms tinyint
	, FullBath tinyint
	, HalfBath tinyint
	);
GO
/* 1.2.2 Deletes the previous table keeping the column names and types if there was any issue when building it on 1.2.1
TRUNCATE TABLE NashvilleHousing
*/


/* 1.2.1 - Using BULK INSERT to add data from the CSV file */
USE NashvilleHousingProject;
GO
BULK INSERT NashvilleHousing FROM 'C:\Windows\Temp\NashvilleHousing_Clean.csv'
   WITH (
	FIRSTROW = 2
	, FORMAT='CSV'
	, FIELDTERMINATOR = ';'
	, ROWTERMINATOR = '\n'
	, CODEPAGE = 'UTF-8'
);
GO

/* 2 - Checking and filling all Properties that have more than one record, but are missing its address in one of them 
This was made using a self join and assuming that a property address won't change between two records if it has the same ParcelID*/
SELECT n1.ParcelID, n1.PropertyAddress, n2.ParcelID, n2.PropertyAddress
FROM ..NashvilleHousing n1
LEFT JOIN ..NashvilleHousing n2 
	ON n1.ParcelID = n2.ParcelID
	AND n1.UniqueID <> n2.UniqueID
WHERE n1.PropertyAddress IS NULL;

UPDATE n1
SET PropertyAddress = ISNULL(n1.PropertyAddress, n2.PropertyAddress)
FROM ..NashvilleHousing n1
LEFT JOIN NashvilleHousing n2 
	ON n1.ParcelID = n2.ParcelID
	AND n1.UniqueID <> n2.UniqueID
WHERE n1.PropertyAddress IS NULL;

/* 3 - Breaking up addresses in distinct columns (Street, City and State), adding it as new columns and dropping the previous columns*/

/* 3.1 - First for PropertyAddress using SUBSTRING and CHARINDEX, since all addresses had a comma spliting the street and the city*/
ALTER TABLE NashvilleHousing
ADD PropertyStreet nvarchar(255)
	, PropertyCity nvarchar(255);

UPDATE ..NashvilleHousing
SET PropertyStreet = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1);
UPDATE ..NashvilleHousing
SET PropertyCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress));

--SELECT PropertyStreet,PropertyCity FROM NashvilleHousing --Checking if it was properly created and added

/* 3.2 - Then for OwnerAddress using PARSENAME and REPLACE, since all addresses are smaller than 128 characters and had a comma spliting the street, city and State and ParseName uses '.' to parse*/

ALTER TABLE ..NashvilleHousing
ADD OwnerStreet nvarchar(255)
	, OwnerCity nvarchar(255)
	, OwnerState nvarchar(255);

UPDATE ..NashvilleHousing
SET OwnerStreet = PARSENAME(REPLACE(OwnerAddress,',','.'),3);
UPDATE NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2);
UPDATE NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'),1);

--SELECT OwnerStreet,OwnerCity,OwnerState FROM NashvilleHousing --Checking if it was properly created and added

/* 3.3 - Dropping the 2 columns that were broken down on step 3.1 and 3.2 */ 

ALTER TABLE ..NashvilleHousing
DROP COLUMN 
	PropertyAddress
	, OwnerAddress;


/* 4 - Finding duplicates using every column except UniqueID and then deleting all duplicates (Second record)*/

WITH Duplicates AS (
SELECT
	*
	, ROW_NUMBER() OVER (
		PARTITION BY 
			ParcelID
			, LandUse
			, PropertyAddress
			, SaleDate
			, SalePrice
			, LegalReference	
			, SoldAsVacant	
			, OwnerName	
			, OwnerAddress	
			, Acreage	
			, TaxDistrict	
			, LandValue	
			, BuildingValue	
			, TotalValue	
			, YearBuilt	
			, Bedrooms	
			, FullBath	
			, HalfBath	
			, PropertyStreet	
			, PropertyCity	
			, OwnerStreet	
			, OwnerCity	
			, OwnerState
		ORDER BY UniqueID
	) row_num
FROM ..NashvilleHousing
)
DELETE
FROM Duplicates
WHERE row_num > 1;

--103 Rows were deleted


--SELECT * FROM NashvilleHousing --Checking updated data