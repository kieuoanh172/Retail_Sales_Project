# Wine_Sales_Analysis_Project
## Project Overview
Project Title: Retail Sales Analysis
Database: p1_retail_db
### Introduction
This project analyzes a Wine sales record dataset, including sales dates, Vendor details, product categories, and Bottles Sold. By leveraging SQL queries and data analysis techniques, I aim to answer various questions and uncover valuable insights from the dataset.
### Dataset Overview
The dataset used in this project consists of +17,000,000 rows of data, representing the number of wine sales transactions from 2017 to 2023. Along with the sales data, the dataset includes information about the vendor, products, and city.
### Project Structure
### 1. Database Setup
Database Creation: The project starts by creating a database named: 'Retail_Sales'

```sql
CREATE DATABASE Retail_Sales;
CREATE TABLE Sales_Data (
    Date_Sales DATE,
    StoreNumber INT,
    StoreName varchar(255),
    City varchar(100),
    CategoryName NVARCHAR(100),
    VendorNumber INT,
    VendorName VARCHAR(255),
    BottlesSold INT
);
```

### 2.Import Data
```sql
BULK INSERT SalesData
FROM 'C:\Users\quokk\Downloads\data_sales.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2, -- bỏ qua dòng tiêu đề
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '0x0a',
    TABLOCK
);
```
### 3.Data Exploration & Cleaning:
•	Record Count: Determine the total number of records in the dataset.
•	Customer Count: Find out how many unique customers are in the dataset.
•	Category Count: Identify all unique product categories in the dataset.
•	Null Value Check: Check for any null values in the dataset and delete records with missing data.
## Schema Design
### Use a Star Schema: 
Easier to query and report on, Clear separation of measures (fact) and descriptors
### Fact Table: FactSales
•	SaleDateKey (FK to Date dimension)

•	StoreKey (FK to Store dimension)

•	CategoryKey (FK to Category dimension)

•	VendorKey (FK to Vendor dimension)

•	BottlesSold (Measure)
 ### Dimension Tables:
•	DimDate → Date, Month, Year, Quarter.

•	DimStore → Store Number, Store Name, City.

•	DimCategory → Category Name.

•	DimVendor → Vendor Number, Vendor Name.

![image](https://github.com/user-attachments/assets/ae889a94-bcc0-423f-87f5-b021ad3fd951)

## Data Analysis & Findings
The following SQL queries were developed to answer specific business questions:
### 1.	Total Bottles Sold per Year: Calculate the total number of bottles sold each year from 2017 to 2023.
```SQL
Select d.Year as Year_Sales, Sum(BottlesSold) as Total_BottesSold
From FactSales s
Join Dimdate d On d.Datekey = s.DateKey
Group by d.Year
Order by Year_Sales;
```
### 2.	Top 3 Vendors per City: Identify the top three vendors (Vendor Name) with the highest sales (by bottle count) in each city.
```SQL
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
```
### 3.	Sales Analysis by Category: Analyze the sales trends for the top-selling wine categories (Category Name) year by year.
```SQL
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
```
### 4.	Top Stores by Sales per City: Identify the stores (Store Name) with the highest wine sales in each city in the most recent year (2023).
```SQL
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
```
### 5.	Vendor Sales Share: Calculate the percentage of total sales for each vendor (Vendor Name) compared to the overall sales of all vendors across the entire time period (2017-2023).
```SQL
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
```
## Build Dashboard
![image](https://github.com/user-attachments/assets/b9c5e1d0-2260-4768-baef-1e7af6caa948)







