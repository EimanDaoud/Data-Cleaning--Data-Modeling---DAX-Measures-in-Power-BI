// ───────────────────────────────────────────────
// 📊 FULL SALES KPIs TEMPLATE (STAR SCHEMA)
// All measures are created in the DAXs table
// ───────────────────────────────────────────────

// Change table names here only once 👇
var daxTable = Model.Tables["DAXs"];
var fact = "'Sales'";
var dimCustomer = "'DimCustomer'";
var dimProduct = "'DimProduct'";
var dimSalesRep = "'DimSalesRep'";
var dimStore = "'DimStore'";
var dimPayment = "'DimPayment'";
var dimDate = "'Date'";

// ──────────────── BASIC SALES KPIs ────────────────
daxTable.AddMeasure("Total Sales", "SUM(" + fact + "[Total_Sales])", "Basic Sales KPIs");
daxTable.AddMeasure("Total Quantity Sold", "SUM(" + fact + "[Quantity])", "Basic Sales KPIs");
daxTable.AddMeasure("Total Cost", "SUM(" + fact + "[Cost])", "Basic Sales KPIs");
daxTable.AddMeasure("Total Profit", "SUM(" + fact + "[Profit])", "Basic Sales KPIs");
daxTable.AddMeasure("Total Discount Amount", "SUMX(" + fact + ", " + fact + "[Discount] * " + fact + "[Total_Sales])", "Basic Sales KPIs");
daxTable.AddMeasure("Total Returns (Qty)", "CALCULATE(SUM(" + fact + "[Quantity]), " + fact + "[Quantity] < 0)", "Basic Sales KPIs");
daxTable.AddMeasure("Return Rate %", "DIVIDE(ABS([Total Returns (Qty)]), [Total Quantity Sold])", "Basic Sales KPIs");

// ──────────────── PROFITABILITY KPIs ────────────────
daxTable.AddMeasure("Gross Profit Margin %", "DIVIDE([Total Profit], [Total Sales])", "Profitability KPIs");
daxTable.AddMeasure("Cost Margin %", "DIVIDE([Total Cost], [Total Sales])", "Profitability KPIs");
daxTable.AddMeasure("Discount Impact %", "DIVIDE([Total Discount Amount], [Total Sales])", "Profitability KPIs");
daxTable.AddMeasure("Return Impact on Profit %", "DIVIDE([Returned Sales Value], [Total Profit])", "Profitability KPIs");

// ──────────────── CUSTOMER KPIs ────────────────
daxTable.AddMeasure("Distinct Customers", "DISTINCTCOUNT(" + dimCustomer + "[Customer_Name])", "Customer KPIs");
daxTable.AddMeasure("Average Sales per Customer", "DIVIDE([Total Sales], [Distinct Customers])", "Customer KPIs");
daxTable.AddMeasure("Average Profit per Customer", "DIVIDE([Total Profit], [Distinct Customers])", "Customer KPIs");
daxTable.AddMeasure("Repeat Purchase Rate", 
    "DIVIDE(CALCULATE(DISTINCTCOUNT(" + dimCustomer + "[Customer_Name]), FILTER(ALL(" + fact + "), COUNTROWS(RELATEDTABLE(" + fact + ")) > 1)), [Distinct Customers])", 
    "Customer KPIs");

// ──────────────── PRODUCT KPIs ────────────────
daxTable.AddMeasure("Distinct Products Sold", "DISTINCTCOUNT(" + dimProduct + "[Product_ID])", "Product KPIs");
daxTable.AddMeasure("Average Unit Price", "AVERAGE(" + fact + "[Unit_Price])", "Product KPIs");
daxTable.AddMeasure("Average Quantity per Order", "AVERAGEX(VALUES(" + fact + "[Order_ID]), SUM(" + fact + "[Quantity]))", "Product KPIs");
daxTable.AddMeasure(
    "Top-Selling Product",
    "VAR ProductSales = SUMMARIZE(" + dimProduct + ", " + dimProduct + "[Product_Name], \"Sales\", [Total Sales]) " +
    "VAR TopProduct = TOPN(1, ProductSales, [Sales], DESC) " +
    "RETURN MAXX(TopProduct, " + dimProduct + "[Product_Name])",
    "Product KPIs"
);

daxTable.AddMeasure(
    "Top-Returning Product",
    "VAR ReturnTable = SUMMARIZE(" + dimProduct + ", " + dimProduct + "[Product_Name], \"Returns\", ABS(CALCULATE(SUM(" + fact + "[Quantity]), " + fact + "[Quantity] < 0))) " +
    "VAR TopReturned = TOPN(1, ReturnTable, [Returns], DESC) " +
    "RETURN MAXX(TopReturned, " + dimProduct + "[Product_Name])",
    "Product KPIs"
);

// ──────────────── STORE / REGIONAL KPIs ────────────────
daxTable.AddMeasure("Sales by Region", "SUMMARIZE(" + dimStore + ", " + dimStore + "[Region], \"Sales\", [Total Sales])", "Store / Regional KPIs");
daxTable.AddMeasure("Profit by Region", "SUMMARIZE(" + dimStore + ", " + dimStore + "[Region], \"Profit\", [Total Profit])", "Store / Regional KPIs");
daxTable.AddMeasure("Gross Margin by Region %", 
    "DIVIDE([Profit by Region], [Sales by Region])", "Store / Regional KPIs");
daxTable.AddMeasure("Return Rate by Region %", 
    "DIVIDE(ABS(CALCULATE(SUM(" + fact + "[Quantity]), " + fact + "[Quantity]<0)), [Total Quantity Sold])", "Store / Regional KPIs");

// ──────────────── TIME-BASED KPIs ────────────────
daxTable.AddMeasure("Sales MTD", "CALCULATE([Total Sales], DATESMTD(" + dimDate + "[Date]))", "Time-Based KPIs");
daxTable.AddMeasure("Sales QTD", "CALCULATE([Total Sales], DATESQTD(" + dimDate + "[Date]))", "Time-Based KPIs");
daxTable.AddMeasure("Sales YTD", "CALCULATE([Total Sales], DATESYTD(" + dimDate + "[Date]))", "Time-Based KPIs");
daxTable.AddMeasure("MoM Growth %", 
    "DIVIDE([Total Sales] - CALCULATE([Total Sales], DATEADD(" + dimDate + "[Date], -1, MONTH)), CALCULATE([Total Sales], DATEADD(" + dimDate + "[Date], -1, MONTH)))", 
    "Time-Based KPIs");
daxTable.AddMeasure("YoY Growth %", 
    "DIVIDE([Total Sales] - CALCULATE([Total Sales], DATEADD(" + dimDate + "[Date], -1, YEAR)), CALCULATE([Total Sales], DATEADD(" + dimDate + "[Date], -1, YEAR)))", 
    "Time-Based KPIs");
daxTable.AddMeasure("Average Daily Sales", 
    "AVERAGEX(VALUES(" + dimDate + "[Date]), [Total Sales])", "Time-Based KPIs");
daxTable.AddMeasure("Peak Sales Day", 
    "TOPN(1, SUMMARIZE(" + dimDate + ", " + dimDate + "[Date], \"Sales\", [Total Sales]), [Sales], DESC)", "Time-Based KPIs");
daxTable.AddMeasure("Peak Sales Month", 
    "TOPN(1, SUMMARIZE(" + dimDate + ", " + dimDate + "[Month], \"Sales\", [Total Sales]), [Sales], DESC)", "Time-Based KPIs");

// ──────────────── OPERATIONAL KPIs ────────────────
daxTable.AddMeasure("Orders Count", "DISTINCTCOUNT(" + fact + "[Order_ID])", "Operational KPIs");
daxTable.AddMeasure("Average Order Value (AOV)", "DIVIDE([Total Sales], [Orders Count])", "Operational KPIs");
daxTable.AddMeasure("Profit per Order", "DIVIDE([Total Profit], [Orders Count])", "Operational KPIs");
daxTable.AddMeasure("Average Discount per Order", "DIVIDE([Total Discount Amount], [Orders Count])", "Operational KPIs");

// ──────────────── SALES REPRESENTATIVE KPIs ────────────────
daxTable.AddMeasure("Sales by Rep", "SUMMARIZE(" + dimSalesRep + ", " + dimSalesRep + "[Sales_Rep], \"Sales\", [Total Sales])", "Sales Rep KPIs");
daxTable.AddMeasure("Profit by Rep", "SUMMARIZE(" + dimSalesRep + ", " + dimSalesRep + "[Sales_Rep], \"Profit\", [Total Profit])", "Sales Rep KPIs");
daxTable.AddMeasure("Orders per Rep", 
    "DIVIDE([Orders Count], DISTINCTCOUNT(" + dimSalesRep + "[Sales_Rep]))", "Sales Rep KPIs");
daxTable.AddMeasure("Avg. Sales per Order by Rep", "DIVIDE([Total Sales], [Orders Count])", "Sales Rep KPIs");
daxTable.AddMeasure("Return Rate per Rep", 
    "DIVIDE(ABS(CALCULATE(SUM(" + fact + "[Quantity]), " + fact + "[Quantity]<0)), [Total Quantity Sold])", "Sales Rep KPIs");

// ──────────────── PAYMENT KPIs ────────────────
daxTable.AddMeasure("Sales by Payment Type", "SUMMARIZE(" + dimPayment + ", " + dimPayment + "[Payment_Type], \"Sales\", [Total Sales])", "Payment KPIs");
daxTable.AddMeasure("Share of Payment Type %", 
    "DIVIDE([Total Sales], CALCULATE([Total Sales], ALL(" + dimPayment + ")))", "Payment KPIs");
daxTable.AddMeasure("Profit by Payment Type", "SUMMARIZE(" + dimPayment + ", " + dimPayment + "[Payment_Type], \"Profit\", [Total Profit])", "Payment KPIs");

// ──────────────── RETURN ANALYSIS ────────────────
daxTable.AddMeasure("Returned Orders Count", 
    "CALCULATE(DISTINCTCOUNT(" + fact + "[Order_ID]), " + fact + "[Quantity] < 0)", "Return Analysis");
daxTable.AddMeasure("Returned Sales Value", 
    "CALCULATE(SUM(" + fact + "[Total_Sales]), " + fact + "[Quantity] < 0)", "Return Analysis");
daxTable.AddMeasure("Return Rate % (Value)", 
    "DIVIDE(ABS([Returned Sales Value]), [Total Sales])", "Return Analysis");
daxTable.AddMeasure("Net Sales (after returns)", 
    "[Total Sales] - ABS([Returned Sales Value])", "Return Analysis");

// ──────────────── DERIVED / ADVANCED KPIs ────────────────
daxTable.AddMeasure("Sales to Cost Ratio", "DIVIDE([Total Sales], [Total Cost])", "Advanced KPIs");
daxTable.AddMeasure("Profit per Product Category", 
    "AVERAGEX(VALUES(" + dimProduct + "[Category]), [Total Profit])", "Advanced KPIs");
daxTable.AddMeasure("Top 10% Products by Sales", 
    "TOPN(ROUNDUP(DIVIDE(COUNTROWS(VALUES(" + dimProduct + "[Product_ID])),10),0), VALUES(" + dimProduct + "[Product_Name]), [Total Sales], DESC)", "Advanced KPIs");
daxTable.AddMeasure("Sales Variance vs Target", 
    "IF(HASONEVALUE(" + dimDate + "[Date]), [Total Sales] - [Target Sales], BLANK())", "Advanced KPIs");
