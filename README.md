# Project 3: Power BI Reseller Performance Report

![Image Alt](https://github.com/cturner0206/reseller-performance-report/blob/a4e017a531b534008330cf662531b89694e29f08/Dashboard.png)

# Table of Contents 
- [Project Overview](#project-overview)
- [Data Source](#data-source)
- [Data Preparation and Cleaning](#data-preparation-and-cleaning)
- [Process of Building the Report](#process-of-building-the-report)
- [Findings](#findings)
- [Recommendations](#recommendations)


# Project Overview

The goal of this project was to query necessary data from the Adventure Works database (using SQL Server Management Studio) and create an interactive dashboard in Power BI. 

### Objectives of the Dashboard:
- **Analyze Sales Performance:**  
  Provide insights into Adventure Works' reseller sales performance from 2021 to 2023, highlighting both present and past sales trends.

- **Track New Reseller Regions:**  
  Monitor the introduction of new reseller regions and their impact on overall sales.

- **Assess Product Popularity:**  
  Evaluate the popularity of different products across various markets.

- **Examine Regional Sales Differences:**  
  Investigate differences in sales performance by region to facilitate informed decision-making and future strategic planning.


# Data Source
The data being used for this project is from the `AdventureWorksDW2022` sample database provided by Microsoft. 


# Data Preparation and Cleaning

The initial data preparation and cleaning phase involved the following steps:

- **Loading the Database:**  
  Loaded and restored the `AdventureWorksDW2022.bak` file in SQL Server Management Studio.

- **Exploring Database Tables:**  
  Reviewed the various database tables to understand the data provided and the relationships between them.

- **Selecting Relevant Data:**  
  With numerous tables available, I determined which information would be valuable for the report. I opted to use:
  - One sales fact table
  - Two dimension tables: resellers and products

- **Data Cleaning:**  
  The data cleaning process included:
  - Renaming columns for clarity
  - Rounding numerical values
  - Selecting a specific order date range
  - Converting the date column to the appropriate format
  - Joining relevant tables to get all necessary data for the table queries


The final three table queries:

```sql
--Sales Fact Table 
SELECT 
    DP.ProductKey AS ProductID,
    OrderQuantity,
    ROUND(UnitPrice,2) AS UnitPrice,
    ROUND(SalesAmount,2) AS SalesAmount,
    CONVERT(DATE,OrderDate) AS OrderDate,
    ResellerName,
    FRS.ResellerKey
FROM FactResellerSales FRS
JOIN DimProduct DP ON FRS.ProductKey = DP.ProductKey
JOIN DimReseller DRS ON FRS.ResellerKey = DRS.ResellerKey
WHERE OrderDate BETWEEN '2021-01-01' AND '2023-12-31'
ORDER BY OrderDate; 
```

```sql
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
```

```sql
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
```
    
# Process of Building the Report

## Report Brainstorm
Before creating the report, I thought about what kind of visuals and features I could add that would allow end users to gain valuable insights while also being easily understandable. I knew I wanted to include:
- A Slicer between sales and quantity
- YTD vs PYTD comparison
- MoM comparison
- Filter to swap between different countries 
- Top-performing resellers
- Product category performance 


## Creating the Report

### Steps in Creating the Report:

### 1. **Import SQL Queries:**  
   Imported the SQL queries into Power BI to create the fact and dimension tables.

### 2. **Create Dim Date Table:**  
   Created a Dim Date table to enable date filtering. Created a calculated column to identify dates that are one year in the past for future PYTD analysis.

### 3. **Connect Tables in Model View:**  
   Established connections between different tables in the model view, using a STAR schema design.
![Image Alt](https://github.com/cturner0206/reseller-performance-report/blob/a4e017a531b534008330cf662531b89694e29f08/Model.png)

### 4. **Create Measures:**  
   Developed most of the measures (dynamic title measures were created after the visuals). The types of measures included:
   - Year-to-Date (YTD)
   - Prior Year-to-Date (PYTD)
   - YTD vs. PYTD
   - Switch measures
     
![Image Alt](https://github.com/cturner0206/reseller-performance-report/blob/a4e017a531b534008330cf662531b89694e29f08/Measures.png)




Examples of some of the DAX used to create measures: 

```dax
Switch_PYTD = 
VAR selected_value =SELECTEDVALUE(Slicer_Values[Values])
VAR result = SWITCH(selected_value,
    "Sales", [PYTD_Sales],
    "Quantity", [PYTD_Quantity],
    BLANK()
)
RETURN
result
```
```dax
Inpast = 
VAR lastsalesdate = MAX(Fact_Sales[OrderDate])
VAR lastsalesdatePY = EDATE(lastsalesdate,-12)
RETURN
Dim_Date[Date] <= lastsalesdatePY
```
```dax
PYTD_Sales = 
    CALCULATE(
        [Sales], 
        SAMEPERIODLASTYEAR(Dim_Date[Date]), 
        Dim_Date[Inpast] = TRUE()
    )
```

### 5. **Built the different visuals**
   - Created a tree map, waterfall chart, bar chart, column chart, and cards.
   - Altered the color palette for better aesthetics.
   - Created slicers for sales/quantity and a dropdown for year selection.
   - Applied conditional formatting to improve visual clarity.
   - Enabled drill-down functionality for further data analysis:
     - Waterfall chart (month → country → product)
     - Column chart (quarter → month) 
   - Created dynamic titles for the report and visuals, allowing for seamless switching between sales and quantity slicers.



# Findings

## Missing Data Notice
Some months are empty of data, which can skew the overall results of the report. It's unclear as to why there are missing data points, but it likely stems from the original database file itself. 
- In 2021, the months of February, April, and June don't have any reseller data (likely data loss/data issue stemming from the dataset)
- December 2023 is also blank (either a data loss issue or Q4 was incomplete at the time of creating the dataset). 

An example where this is noticeable is the card for PYTD sales in 2023 is at 25.5m, while the YTD in 2022 is at 28.19m because the PYTD in 2023 does not account for December, as there is no data for December in 2023 like in 2022. 


## Sales Overview

### Sales Growth
- Total sales increased by **55%** from **2021 to 2022**.
- Total sales increased by **19.1%** from **2022 to 2023**.

### Percent of Total Sales by Region

### 2021
- United States: 79.16%
- Canada: 19.79%
- France: 0.53%
- United Kingdom: 0.44%

### 2022
- United States: 69.60%
- Canada: 19.44%
- United Kingdom: 5.25%
- France: 4.93%
- Germany: 0.64%
- Australia: 0.18%

### 2023
- United States: 57.19%
- Canada: 15.4%
- France: 9.29%
- United Kingdom: 8.1%
- Germany: 5.36%
- Australia: 4.59%

### Year-to-Date Sales Comparison
- In **2023**, newer markets (**Germany**, **France**, **Australia**, and the **United Kingdom**) surpassed both the **United States** and **Canada** in **YTD vs. prior year-to-date** sales growth.
- In **2021**, the **United States** and **Canada** saw positive **YTD vs. PYTD** growth. However, from **2022** to **2023**, growth slowed significantly, with several months showing negative **YTD vs. PYTD** values ranging from being down hundreds of thousands to being down around **$2 million** per month.
- In contrast, the newer markets have consistently shown positive **YTD vs. PYTD** growth since their introduction.

### Sales Trends
- From **2022 to 2023**, **Q1** has been the highest-selling quarter. Sales dipped in **Q2** and **Q3**, with the most significant drop occurring in **Q3** during the summer. Sales rebound in **Q4**, peaking again in **Q1**. 
  > **Note:** **Q4 2023** lacks December data, but sales in **October** and **November** were around **$3.3 million** each, suggesting December's sales will likely boost **Q4** totals to around **$9-10 million**.
  
- In **2021**, sales began low in **Q1** and increased through **Q4**. This pattern reflects the natural progression of establishing reseller relationships, as **2021** was the first year Adventure Works began working with resellers.


## Quantity Overview

### Overall Trends 
  - Quantity trends mirror sales trends; when sales increase, quantity also increases.

### Quantity by Country
  - From **2021 to 2023**, the **United States** and **Canada** accounted for the majority of total quantity. In **2023**, newer countries of **Germany**, **France**, **Australia**, and the **United Kingdom** began to close the gap with the **United States** in **year-to-date vs. prior year-to-date** quantity differences.

### Quarterly Trends 
  - Similar to sales, quantity peaks in **Q1**, dips in **Q2 and Q3**, and then rises again in **Q4**.

## Product Category Trends

### Overall Trends
  Product category trends are consistent. The **bike category** makes up the largest percentage of sales, followed by **components** as the second best-selling category. **Clothing and accessories** account for less than **5%** of total sales.

### 2023 
  - In the **United States** and **Canada**, there was a major decline in **road bike** sales, accompanied by a stark increase in **touring bike** sales.
  - In the other four countries, **road bike** sales remained relatively stable, while **touring bike** sales saw a major increase.

### 2022
  - The **components** category had approximately twice the total sales compared to **2021 and 2023**.
  - **Road bikes** experienced the most substantial increase from the prior year across all countries. 
  - Geographic differences included:
    - The **United States** saw a decrease of **$1.3 million YTD vs PYTD** in mountain bike sales.
    - **France** and the **United Kingdom** had a **larger mountain bike demographic**, alongside **road bikes**.
    - **Germany** and **Australia** recorded **touring bikes** as their largest sales increase, despite having limited product selections in their first year of sales.

### 2021 
  - In **2021**, **mountain bikes** and **road bikes** were the best-selling products overall, except in **Germany**, where **road bikes** and **road frames** were the top sellers.




# Recommendations

**Manage Seasonal Fluctuations:**  
  - With Q1 being the highest-selling quarter, create promotions or special events leading into Q2 and Q3 to sustain momentum and mitigate dips. Consider summer promotions or targeted advertising.

**Address Product Declines:**  
  - Investigate the reasons behind the decline in road bike sales in the US and Canada. Explore options such as redesigns, marketing campaigns, or bundle offers to rejuvenate interest.

**Focus on Emerging Markets:**  
  - Given the positive growth in countries like Germany, France, Australia, and the UK, consider tailored marketing strategies for these regions. 
  - Allocate resources to enhance brand visibility and establish stronger reseller partnerships.

**Adapt to Regional Preferences:**  
  - Recognize and promote product preferences in different markets. For example, emphasize touring bikes in regions where they are gaining popularity.



