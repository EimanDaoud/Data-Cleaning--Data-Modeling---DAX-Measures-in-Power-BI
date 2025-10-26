# Data Cleaning, Data Modeling, DAX measures- Power BI


 **Tool Used:** Power BI

 **Dataset:** Custom-generated raw sales data (3,000 rows) using Python representing transactions from Khartoum, Omdurman, Port Sudan, and Kassala.

 [Python Code for genrating the dataset](https://www.kaggle.com/datasets/arunkumaroraon/blinkit-grocery-dataset/data)

**Objective:**

To clean, model, sales data using Power BI — transforming a raw dataset into a professional Star Schema Data Model 


**Skills Demonstrated**

* Data Cleaning using **Power Query**

* Data Modeling and Star **Schema Design**

* **DAX Measures** and KPIs



## **Step 1: Data Import & Setup**
### __1.1 Import Raw Data__

* Open Power BI Desktop.

* Go to Home → Get Data → Text/CSV.

* Import the file sudan_sales_raw.csv.

* Click Load to bring the data into Power BI.

* Confirm that the dataset contains 3,000 sales records and 21 columns

### **1.2 Duplicate the Query for Cleaning**

Before cleaning, i kept one copy of the raw dataset as a reference.

* Open Power Query Editor
→ Right-click the query sales_raw
→ Select Duplicate
→ Rename it to Sales_Clean

💡 Keeping the raw data untouched ensures you can always refer back to the original source during cleaning and transformation.

### **1.3 Data Dictionary**
| **Column Name** | **Description**                                            | **Data Type**  | **Example Value** |
| --------------- | ---------------------------------------------------------- | -------------- | ----------------- |
| `Order_ID`      | Unique identifier for each sales transaction               | Text           | SUD-2025-1452     |
| `Order_Date`    | Date when the order was placed                             | Date           | 2025-03-18        |
| `Customer_Name` | Name of the customer who made the purchase                 | Text           | Ahmed Musa        |
| `Segment`       | Customer segment (Individual, Small Business, Enterprise)  | Text           | Individual        |
| `Region`        | Sudanese region where the sale occurred                    | Text           | Red Sea           |
| `City`          | Specific city of the transaction                           | Text           | Port Sudan        |
| `Product_ID`    | Unique product identifier                                  | Text           | PRD-301           |
| `Product_Name`  | Name or description of the sold product                    | Text           | HP LaserJet P1102 |
| `Category`      | Product category (Electronics, Furniture, Office Supplies) | Text           | Office Supplies   |
| `Quantity`      | Number of units sold                                       | Whole Number   | 5                 |
| `Unit_Price`    | Price per unit in Sudanese Pounds (SDG)                    | Decimal Number | 15000             |
| `Total_Sales`   | Total sales amount (Quantity × Unit_Price)                 | Decimal Number | 75000             |
| `Payment_Type`  | Payment method used (Cash, Bank)                           | Text           | Cash              |
| `Customer_ID`   | Unique customer code                                       | Text           | CUST-1209         |
| `Sales_Rep`     | Name of the sales representative handling the transaction  | Text           | Fatima Khalid     |
| `Discount`      | Discount applied on the transaction (if any)               | Decimal Number | 5                 |
| `Profit`        | Calculated profit per order (after discount)               | Decimal Number | 10500             |

## **Step 2: Data Cleaning**



### **2.2 Data Profiling**

**Objective:** Assess data quality before cleaning to identify potential issues.

| **Check**               | **Action in Power Query**                                          | **Purpose / Insights**                                               |
| ----------------------- | ------------------------------------------------------------------ | -------------------------------------------------------------------- |
| **Row & Column Count**  | Confirm total number of rows (≈ 3,000) and columns (16)            | Ensures the dataset loaded completely                                |
| **Column Quality**      | *View → Column Quality*                                            | Shows % of valid, error, and empty values per column                 |
| **Column Distribution** | *View → Column Distribution*                                       | Displays value frequencies and helps identify duplicates or outliers |
| **Column Profile**      | *View → Column Profile*                                            | Provides summary statistics for numeric fields (min, max, average)   |
| **Unique Value Check**  | Review `Order_ID`, `Customer_ID`, and `Product_ID` columns         | Detects potential duplicate or missing keys                          |
| **Missing Values**      | Observe null counts in columns like `City`, `Segment`, or `Profit` | Helps plan replacement or removal strategies                         |


### **2.3 Cleaning Steps Summary**
**➡️ View the full Power Query M Code:**  
[`datacleaning.pq`](datacleaning.pq)

| **Step** | **Action in Power Query**                                                          | **Purpose / Description**                                                                                  | **Result / Notes**                                                                    |
| -------- | ---------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------- |
| 1        | **Duplicate Raw Query**                                                            | *Right-click original query → Duplicate → rename to* `Sales_Clean`                                         | Keeps original data untouched for reference and auditing                              |
| 2        | **Promote Headers**                                                                | *Home → Use First Row as Headers*                                                                          | Ensures all fields are recognized correctly as column names                           |
| 3        | **Fix Data Types (Initial Pass)**                                                  | *Transform → Detect Data Type / Manually assign where required*                                            | Prevents type-related errors in later transformations                                 |
| 4        | **Clean & Trim Text Columns**                                                      | *Transform → Format → Clean & Trim*                                                                        | Removes extra spaces, non-printable characters, and irregular formatting              |
| 5        | **Apply Proper Case to Text Columns** *(Product Name, Customer Name,...)*        | *Transform → Format → Capitalize Each Word*                                                                | Standardizes text presentation across the dataset                                     |
| 6        | **Standardize Categorical Columns** *(Payment Method, Category, City)* | *Transform → Replace Values / Format Standardization Rules*                                                | Ensures consistent category labels for accurate grouping and filtering                |
| 7        | **Clean Numerical Columns (Unit Price & Cost)**                                    | Remove non-numeric characters → Replace `"k"` with `"000"` → *Transform → Data Type → Decimal Number*      | Converts inconsistent number formats into valid numeric values that can be calculated |
| 8        | **Calculate Total Sales**                                                          | *Add Column → Custom Column:* `Total_Sales = Quantity * Unit_Price`                                        | Generates correct sales value now that Unit Price is cleaned                          |
| 9        | **Calculate Profit**                                                               | *Add Column → Custom Column:* `Profit = Total_Sales - Cost`                                                | Provides profitability metric for analysis                                            |
| 10       | **Remove Duplicates**                                                              | *Home → Remove Rows → Remove Duplicates* (based on `Order_ID` or transaction identifier)                   | Ensures each sale record appears only once                                            |
| 11       | **Remove Helper Columns / Replace Original Columns**                               | Delete the original raw columns that contained issues → Rename the cleaned columns to their original names | Keeps the model clean, accurate, and ready for use                                    |
| 12       | **Final Data Type Review**                                                         | Confirm correct types for Date, Decimal, Whole Number, Text columns                                        | Ensures smooth loading in Power BI and avoids modeling issues                         |

### **2.3 Building the Star Schema**
![Total Sales by Fat Content](https://github.com/EimanDaoud/Blinkit-Project/blob/main/Images/LF%20Vs%20Regular.png?raw=true)
Charts codes? Check them out here: [Chart Python Code](charts.ipynb).


After completing the data cleaning steps, we used the cleaned table (Sales_Clean) as the source for constructing the **dimension tables and the fact table**.

### 1. Create Dimension Tables

We created reference queries from Sales_Clean and extracted only the necessary descriptive fields, removed duplicates, assigning surrogate keys (Index columns) where needed.

| Dimension Table | Source Columns Used                      | Added Key                    | Notes                                                                        |
| --------------- | ---------------------------------------- | ---------------------------- | ---------------------------------------------------------------------------- |
| **DimCustomer** | `Customer_Name`, `Segment`               | `Customer_ID` (Index)        | Surrogate key created because no unique key existed in raw data.             |
| **DimProduct**  | `Product_ID`, `Product_Name`, `Category` | *(Already had `Product_ID`)* | No new index needed since product code already uniquely identifies products. |
| **DimSalesRep** | `Sales_Rep`                              | `Rep_ID` (Index)             | Added index to serve as primary key.                                         |
| **DimStore**    | `Region`, `City`                         | `Store_ID` (Index)           | Store dimension created to support location-level analysis.                  |
| **DimPayment**  | `Payment_Type`                           | `Payment_Method_ID` (Index)  | Standardizes different payment method labels.                                |


### 2. Create Date Table

* A separate Date Dimension was required for time intelligence calculations.

* Used Invoke Function to generate a full calendar table

* Converted necessary columns to Date type

* Added Year, Month, Quarter, Day Name, etc.

**➡️ For the Date Table function code, click here**
[`datacleaning.pq`](datacleaning.pq)


### 3. Build the Fact Table

#### The Fact_Sales table was created by:

1. Starting from Sales_Clean

2. Merging it with each Dimension table

3. Bringing in only the surrogate key columns (e.g., Customer_ID, Product_ID, Store_ID, etc.)

4. Removing the original descriptive columns that now live in the Dim tables
(ensuring the fact table contains measurements + foreign keys only)

#### This resulted in a clean, concise fact table structure ready for reporting.

### 4. Establish Relationships in the Data Model

#### Finally, in the Model View in Power BI:

* Connected each Dimension table to Fact_Sales using the surrogate key relationships

* Connected DimDate[Date] → Fact_Sales[Date]

* Relationships are Many-to-One, with filters flowing from Dimension → Fact to maintain star schema behavior.

![Total Sales by Fat Content](https://github.com/EimanDaoud/Blinkit-Project/blob/main/Images/LF%20Vs%20Regular.png?raw=true)
Charts codes? Check them out here: [Chart Python Code](charts.ipynb).









