


BULK INSERT SalesData
FROM 'C:\Users\quokk\Downloads\data_sales.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2, -- bỏ qua dòng tiêu đề
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '0x0a',
    TABLOCK
);

Select *
From salesdata

--create Dimention table
--createDimdate
Create table Dimdate (
	Datekey Date Primary Key,
	Year Int,
	Month Int,
	Quarter Int);

--creat Store
Create Table DimStore (
	StoreKey Int Identity(1,1) Primary Key,
	StoreNumber Int,
	StoreName Nvarchar(255),
	City Nvarchar(100)
	);
--create Catogory
Create Table DimCatogory (
	CatagoryKey Int Identity(1,1) Primary Key,
	CatogoryName Nvarchar(255)
	);
--Create vendor
Create table DimVendor (
	VendorKey int identity(1,1) Primary Key,
	VendorNumber int,
	VendorName NVarchar(100)
	);

--Create Facttable
Create table FactSales (
	SalesID INT IDENTITY(1,1) PRIMARY KEY,
    DateKey DATE,
    StoreKey INT,
    CategoryKey INT,
    VendorKey INT,
    BottlesSold INT,
Foreign key (Datekey) references Dimdate(Datekey),
FOREIGN KEY (StoreKey) REFERENCES DimStore(StoreKey),
FOREIGN KEY (CategoryKey) REFERENCES DimCatogory(CatagoryKey),
FOREIGN KEY (VendorKey) REFERENCES DimVendor(VendorKey)
);
--insert into table
Insert into DimCatogory (CatogoryName)
select distinct [CategoryName]
From SalesData;

Insert into DimStore (StoreName,StoreNumber,City)
Select distinct [StoreName],[StoreNumber],City
From SalesData;

Insert into Dimdate (Datekey,Year,Month,Quarter)
Select Distinct [Date], 
				Year([Date]),
				Month([Date]),
				DATEPART(QUARTER,[Date])
From SalesData;

Insert into DimVendor (VendorNumber,VendorName)
Select Distinct [VendorNumber],[VendorName]
From SalesData;

-- insert into fact table
Insert into FactSales (DateKey,StoreKey,CategoryKey, VendorKey, BottlesSold)
Select 
	s.[Date],
	st.StoreKey,
	c.CatagoryKey,
	vd.VendorKey,
	s.BottlesSold
From SalesData s
Join DimCatogory c On c.CatogoryName = s.CategoryName
Join DimVendor vd On vd.VendorNumber = s.VendorNumber And vd.VendorName =s.VendorName
Join DimStore st On st.StoreNumber =s.StoreNumber And st.StoreName =s.StoreName;

select *
From FactSales

Select *
From DimVendor
order by VendorName
Select *
From DimStore

Select *, count(*)
From DimCatogory
Group by CatogoryName
Having count(*)>1


Select *
From SalesData
Where CategoryName is Null
-- Update City cho dòng có dùng storeNumber và StoreName

WITH City_Resolved AS (
  SELECT 
    StoreNumber,
    StoreName,
    -- Giả định mỗi store chỉ có 1 giá trị city không null → dùng MAX/ MIN để lấy ra
    MAX(City) AS resolved_city
  FROM dbo.SalesData
  WHERE city IS NOT NULL
  GROUP BY StoreNumber,StoreName
)
UPDATE r
SET r.City = c.resolved_city
FROM dbo.SalesData r
JOIN City_Resolved c
  ON r.StoreNumber = c.StoreNumber
 AND r.StoreName = c.StoreName
WHERE r.City IS NULL

Select *
From dbo.SalesData
Where StoreNumber = 4482

SELECT 
  COUNT(*) AS total_rows,
  SUM(CASE WHEN [Date] IS NULL THEN 1 ELSE 0 END) AS null_sale_date,
  SUM(CASE WHEN StoreNumber IS NULL THEN 1 ELSE 0 END) AS null_store_id,
  SUM(CASE WHEN StoreName IS NULL THEN 1 ELSE 0 END) AS null_store_name,
  SUM(CASE WHEN City IS NULL THEN 1 ELSE 0 END) AS null_city,
  SUM(CASE WHEN CategoryName IS NULL THEN 1 ELSE 0 END) AS null_category_name,
  SUM(CASE WHEN VendorNumber IS NULL THEN 1 ELSE 0 END) AS null_vendor_id,
  SUM(CASE WHEN VendorName IS NULL THEN 1 ELSE 0 END) AS null_vendor_name,
  SUM(CASE WHEN BottlesSold IS NULL THEN 1 ELSE 0 END) AS null_bottles_sold
FROM SalesData;

UPDATE SalesData
SET City = 'UNKNOWN'
WHERE City IS NULL;

Select *
From dbo.SalesData
Where VendorNumber is null

UPDATE SalesData
SET VendorNumber = 0,
	VendorName ='UNKNOWNVENDOR'
WHERE VendorNumber IS NULL;

UPDATE SalesData
SET CategoryName = 'UNKNOWNCATEGORY'
WHERE CategoryName IS NULL;

-- Kiểm tra các dòng trùng lặp

Select *
From DimCatogory
-- Xóa table để làm lại
DROP TABLE IF EXISTS FactSales;
TRUNCATE TABLE DimStore;
TRUNCATE TABLE DimCatogory;
TRUNCATE TABLE Dimdate;
TRUNCATE TABLE FactSales;
TRUNCATE TABLE DimVendor;



Create table DimDate (
	Datekey Date Primary Key,
	Year Int,
	Month Int,
	Quarter Int);

Insert into DimDate (Datekey,Year,Month,Quarter)
Select Distinct [Date], 
				Year([Date]),
				Month([Date]),
				DATEPART(QUARTER,[Date])
From SalesData;

--create Category
Create Table DimCategory (
	CategoryKey Int Identity(1,1) Primary Key,
	CategoryName Nvarchar(255)
	);
Insert into DimCategory (CategoryName)
Select Distinct [CategoryName]
From SalesData;

Insert into DimStore (StoreNumber,StoreName,City)
Select Distinct [StoreNumber],[StoreName],City
From SalesData;

Insert into DimVendor (VendorNumber, VendorName)
Select Distinct [VendorNumber],[VendorName]
From SalesData

Create table FactSales (
	SalesID INT IDENTITY(1,1) PRIMARY KEY,
    DateKey DATE,
    StoreKey INT,
    CategoryKey INT,
    VendorKey INT,
    BottlesSold INT,
Foreign key (Datekey) references DimDate(Datekey),
FOREIGN KEY (StoreKey) REFERENCES DimStore(StoreKey),
FOREIGN KEY (CategoryKey) REFERENCES DimCategory(CategoryKey),
FOREIGN KEY (VendorKey) REFERENCES DimVendor(VendorKey)
);

Insert into FactSales (DateKey,StoreKey,CategoryKey, VendorKey, BottlesSold)
Select 
	s.[Date],
	st.StoreKey,
	c.CategoryKey,
	vd.VendorKey,
	s.BottlesSold
From SalesData s
Join DimCategory c On c.CategoryName = s.CategoryName
Join DimVendor vd On vd.VendorNumber = s.VendorNumber And vd.VendorName =s.VendorName
Join DimStore st On st.StoreNumber =s.StoreNumber And st.StoreName =s.StoreName;


WITH CTE_Duplicates AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY 
                   [Date],
                   StoreNumber,
                   StoreName,
                   City,
                   CategoryName,
                   VendorNumber,
                   VendorName,
                   BottlesSold
               ORDER BY (SELECT NULL)
           ) AS rn
    FROM SalesData
)
SELECT *
FROM CTE_Duplicates
WHERE rn > 1;


SELECT 
    *,
    COUNT(*) OVER (
        PARTITION BY 
            [Date], StoreNumber, StoreName, City, 
            CategoryName, VendorNumber, VendorName, BottlesSold
    ) AS duplicate_count
FROM SalesData;

--tra loi cau hoi
---	1. Total Bottles Sold per Year: Calculate the total number of bottles sold each year from 2017 to 2023.
Select d.Year as Year_Sales, Sum(BottlesSold) as Total_BottesSold
From FactSales s
Join Dimdate d On d.Datekey = s.DateKey
Group by d.Year
Order by Year_Sales;

--Top 3 Vendors per City: Identify the top three vendors (Vendor Name) with the highest sales (by bottle count) in each city.

With RankedVendor As (
Select ss.City,
	   v.VendorName,
	   Sum(s.BottlesSold) As TotalBotles,
	   ROW_NUMBER () Over (
							Partition By ss.City
							Order by Sum(s.BottlesSold) Desc
							) As Rn
From FactSales s
Join DimVendor v On v.VendorKey =s.VendorKey
Join DimStore ss On ss.StoreKey =s.StoreKey
Group by ss.City,
		 v.VendorName
)
Select City,
	   VendorName,
	   TotalBotles
From RankedVendor
Where Rn<=3
Order by City,
	   VendorName,
	   TotalBotles Desc;
---Thử lại


With Rank_vendor As (
Select st.City,
	   v.VendorNumber,
	   v.VendorName,
	   Sum(fs.BottlesSold) as Total_Bottles,
	   ROW_NUMBER () Over (
		Partition By st.City
		Order by Sum(fs.BottlesSold) Desc) As Rank_City
From FactSales fs
Join DimVendor v On v.VendorKey = fs.VendorKey
Join DimStore st On st.StoreKey = fs.StoreKey
Group by st.City,
		 v.VendorNumber,
		 v.VendorName
)
Select City,
	   VendorNumber,
	   VendorName,
	   Total_Bottles
From Rank_vendor
Where Rank_City<=3
Order By City,
		VendorNumber,
		VendorName,
		Total_Bottles desc;

---	Sales Analysis by Category: Analyze the sales trends for the top-selling wine categories (Category Name) year by year.

--show top 5 categories overall, year by year

With Top_Category As (
Select dd.[Year] As Sales_Year,
	   ct.CategoryName as Category,
	   Sum(fs.BottlesSold) as Total_Bottles,
	   ROW_NUMBER () Over (
							Partition By dd.[Year]
							Order By Sum(fs.BottlesSold) Desc
							) As Rank_Category 
From FactSales fs
Join DimCategory ct On ct.CategoryKey = fs.CategoryKey
Join Dimdate dd On dd.Datekey = fs.DateKey
Group by dd.[Year],
		ct.CategoryName

)
Select Sales_Year,
		Category,
		Total_Bottles
From Top_Category
Where Rank_Category <= 5
Order by Sales_Year, Category, Total_Bottles


With Top_category As (
Select dd.[Year] As Sales_Year,
	   ct.CategoryName as Category,
	   Sum(fs.BottlesSold) as Total_Bottles
	   
From FactSales fs
Join DimCategory ct On ct.CategoryKey = fs.CategoryKey
Join Dimdate dd On dd.Datekey = fs.DateKey
Group by dd.[Year],
		ct.CategoryName
), Rankedcategory As(
					Select *,
						Rank () Over (
										Partition By Sales_Year
										Order By Total_Bottles DESC) as Rank_PerYear
					From Top_category
					)
Select *
From Rankedcategory
Where Rank_PerYear <=5
Order By Sales_Year, 
		 Total_Bottles Desc;
	


---	Top Stores by Sales per City: Identify the stores (Store Name) with the highest wine sales in each city in the most recent year (2023).

With Top_Store As(
Select Year(fs.DateKey) as SalesYear,
	   s.City,
	   s.StoreName,
	   Sum(fs.BottlesSold) as Total_Bottles
From FactSales fs
Join DimStore s On s.StoreKey = fs.StoreKey
Where Year(fs.DateKey) = 2023
Group by Year(fs.DateKey),
		s.City,
	   s.StoreName	 
), 
RankedStore As (
				Select *,
				Rank() Over (Partition By City Order By Total_Bottles Desc) as rank_top
				From Top_Store
				)
Select SalesYear,
	   City,
	   StoreName,
	   Total_Bottles
From RankedStore
Where rank_top = 1
Order by City;
		 
		 
---Vendor Sales Share: Calculate the percentage of total sales for each vendor (Vendor Name) compared to the overall sales of all vendors across the entire time period (2017-2023).

With Sales_Share As(
Select vd.VendorName,
	   Sum(fs.BottlesSold) as Total_bottles
From FactSales fs
Join DimVendor vd On vd.VendorKey = fs.VendorKey
Group by vd.VendorName
), OveralSales As (
				Select Sum(BottlesSold) As TotalSales
		        From FactSales
      
				)
Select ss.VendorName,
	   ss.Total_bottles,
	   os.TotalSales,
	   Cast((Total_bottles/os.TotalSales)*100 as decimal(5,5)) as Percent_of_Sales
From Sales_Share ss
Cross Join  OveralSales os
Order by ss.Total_bottles Desc




